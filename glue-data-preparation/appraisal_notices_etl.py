#!/usr/bin/env python3
"""
Appraisal Notices ETL Job

Processes appraisal notice CSV files from S3 and loads them into Aurora PostgreSQL.
Handles both residential/commercial and business personal property files.
Based on the working dcad-csv-to-database-etl pattern.
"""

import sys
from datetime import datetime
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import DataFrame
from pyspark.sql.functions import *
from pyspark.sql.types import *
from awsglue.dynamicframe import DynamicFrame
import boto3

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

def log_message(message):
    """Log message with timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def get_year_folders(s3_client, bucket_name):
    """Discover available year folders in appraisal_notices directory"""
    try:
        response = s3_client.list_objects_v2(
            Bucket=bucket_name,
            Prefix='appraisal_notices/',
            Delimiter='/'
        )
        
        year_folders = []
        if 'CommonPrefixes' in response:
            for prefix in response['CommonPrefixes']:
                folder = prefix['Prefix'].rstrip('/')
                year_part = folder.split('/')[-1]
                # Check if it's a valid year
                if year_part.isdigit() and len(year_part) == 4:
                    year_folders.append(year_part)
                    
        log_message(f"Found year folders: {sorted(year_folders)}")
        return sorted(year_folders)
        
    except Exception as e:
        log_message(f"Failed to discover year folders: {e}")
        raise

def clean_column_names(df):
    """Clean column names to match database schema (lowercase)"""
    for column_name in df.columns:
        new_col_name = column_name.lower()
        if new_col_name != column_name:
            df = df.withColumnRenamed(column_name, new_col_name)
    return df

def apply_data_type_conversions(df):
    """Apply proper data type conversions based on database schema"""
    
    # Convert integer fields
    integer_fields = ['appraisal_yr']
    for field in integer_fields:
        if field in df.columns:
            df = df.withColumn(field, 
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL"), None)
                .otherwise(col(field).cast(IntegerType())))
    
    # Convert date fields
    date_fields = ['hearings_start_date', 'protest_deadline_date', 'hearings_conclude_date']
    for field in date_fields:
        if field in df.columns:
            # Handle dates with 1900-01-01 as NULL
            # Try multiple date formats since the data may have single-digit months/days
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL") | 
                     col(field).startswith("1900-01-01"), None)
                .otherwise(
                    # First try M/d/yyyy format (5/19/2025)
                    when(to_date(col(field), "M/d/yyyy").isNotNull(), to_date(col(field), "M/d/yyyy"))
                    # Then try MM/dd/yyyy format (05/19/2025)
                    .otherwise(
                        when(to_date(col(field), "MM/dd/yyyy").isNotNull(), to_date(col(field), "MM/dd/yyyy"))
                        # Finally try M/dd/yyyy format (5/19/2025)
                        .otherwise(to_date(col(field), "M/dd/yyyy"))
                    )
                ))
    
    # Convert decimal fields (all exemption amounts and value fields)
    decimal_fields = ['tot_val', 'land_val', 'appraised_val', 'cap_value', 'contributory_amt']
    
    # Add all exemption amount fields
    entities = ['county', 'college', 'hospital', 'city', 'isd', 'special']
    exemption_types = ['hs', 'disabled', 'disabled_vet', 'ag', 'freeport', 'pc', 
                      'low_income', 'git', 'vet100', 'abatement', 'historic', 
                      'vet_home', 'child_care', 'other']
    
    for entity in entities:
        for exemption in exemption_types:
            field_name = f"{entity}_{exemption}_amt"
            if field_name in df.columns:
                decimal_fields.append(field_name)
    
    # Apply decimal conversions
    for field in decimal_fields:
        if field in df.columns:
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL") | (col(field) == "0.00"), None)
                .otherwise(regexp_replace(col(field), "[^0-9.-]", "").cast(DecimalType(15, 2))))
    
    # Handle indicator fields (single character)
    indicator_fields = ['bpp_penalty_ind', 'special_inv_penalty_ind', 'homestead_ind']
    for field in indicator_fields:
        if field in df.columns:
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL"), None)
                .otherwise(substring(col(field), 1, 1)))
    
    # Truncate string fields to prevent constraint violations
    string_fields_with_limits = {
        'account_num': 50,
        'mailing_number': 50,
        'property_type': 20
    }
    
    for field, max_length in string_fields_with_limits.items():
        if field in df.columns:
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL"), None)
                .otherwise(substring(col(field), 1, max_length)))
    
    return df

def process_csv_file(s3_path, property_type, year, glue_context):
    """Process a single CSV file"""
    log_message(f"Processing {property_type} file: {s3_path}")
    
    try:
        # Create CSV format options for robust parsing
        format_options = {
            "withHeader": True,
            "separator": ",",
            "optimizePerformance": False,
            "quoteChar": '"',
            "escaper": '\\',
            "multiline": True
        }
        
        # Read CSV file
        dynamic_frame = glue_context.create_dynamic_frame.from_options(
            connection_type="s3",
            connection_options={"paths": [s3_path]},
            format="csv",
            format_options=format_options
        )
        
        # Convert to DataFrame for transformations
        df = dynamic_frame.toDF()
        
        log_message(f"Initial row count: {df.count()}")
        log_message(f"Initial columns: {len(df.columns)}")
        
        # Clean column names
        df = clean_column_names(df)
        
        # Add appraisal year if not present
        if 'appraisal_yr' not in df.columns:
            df = df.withColumn('appraisal_yr', lit(year).cast(IntegerType()))
        
        # Add property type indicator
        df = df.withColumn('property_type', lit(property_type))
        
        # Apply data type conversions
        df = apply_data_type_conversions(df)
        
        # Add audit columns
        df = df.withColumn('created_at', current_timestamp())
        df = df.withColumn('updated_at', current_timestamp())
        
        log_message(f"Final row count: {df.count()}")
        
        return df
        
    except Exception as e:
        log_message(f"Error processing file {s3_path}: {e}")
        raise

def main():
    """Main ETL process"""
    log_message("Starting Appraisal Notices ETL job")
    
    # Get job arguments - TARGET_YEAR is optional
    required_args = [
        'JOB_NAME', 
        'CONNECTION_NAME', 
        'SOURCE_BUCKET', 
        'DB_NAME'
    ]
    
    # Check if TARGET_YEAR is provided
    optional_args = []
    if '--TARGET_YEAR' in sys.argv:
        optional_args.append('TARGET_YEAR')
    
    args = getResolvedOptions(sys.argv, required_args + optional_args)
    
    job.init(args['JOB_NAME'], args)
    
    # Initialize AWS clients
    s3_client = boto3.client('s3')
    
    try:
        connection_name = args['CONNECTION_NAME']
        source_bucket = args['SOURCE_BUCKET']
        db_name = args['DB_NAME']
        
        log_message(f"Using connection: {connection_name}")
        log_message(f"Source bucket: {source_bucket}")
        log_message(f"Database: {db_name}")
        
        # Discover year folders
        year_folders = get_year_folders(s3_client, source_bucket)
        
        # Filter to specific year if provided
        if 'TARGET_YEAR' in args and args.get('TARGET_YEAR'):
            target_year = args['TARGET_YEAR']
            if target_year in year_folders:
                year_folders = [target_year]
                log_message(f"Processing only year {target_year}")
            else:
                log_message(f"Warning: Year {target_year} not found. Available years: {year_folders}")
                return
        else:
            log_message("Processing all available years")
        
        total_rows_processed = 0
        
        # Process each year
        for year in year_folders:
            log_message(f"{'='*50}")
            log_message(f"Processing year {year}")
            log_message(f"{'='*50}")
            
            year_dataframes = []
            
            # Process residential/commercial file
            res_com_path = f"s3://{source_bucket}/appraisal_notices/{year}/RES_COM_APPRAISAL_NOTICE_DATA.csv"
            try:
                res_com_df = process_csv_file(res_com_path, 'RES_COM', int(year), glueContext)
                year_dataframes.append(res_com_df)
            except Exception as e:
                log_message(f"Failed to process RES_COM file for year {year}: {e}")
            
            # Process business personal property file
            bpp_path = f"s3://{source_bucket}/appraisal_notices/{year}/BPP_APPRAISAL_NOTICE_DATA.csv"
            try:
                bpp_df = process_csv_file(bpp_path, 'BPP', int(year), glueContext)
                year_dataframes.append(bpp_df)
            except Exception as e:
                log_message(f"Failed to process BPP file for year {year}: {e}")
            
            if not year_dataframes:
                log_message(f"No data to process for year {year}")
                continue
            
            # Union all dataframes for this year
            log_message(f"Combining data for year {year}")
            if len(year_dataframes) == 1:
                combined_df = year_dataframes[0]
            else:
                combined_df = year_dataframes[0]
                for df in year_dataframes[1:]:
                    combined_df = combined_df.unionByName(df, allowMissingColumns=True)
            
            total_rows = combined_df.count()
            log_message(f"Total combined rows for year {year}: {total_rows}")
            
            # Check for duplicates
            log_message("Checking for duplicates based on primary key...")
            duplicate_check = combined_df.groupBy("appraisal_yr", "account_num", "property_type").count()
            duplicates = duplicate_check.filter(col("count") > 1).count()
            
            if duplicates > 0:
                log_message(f"Warning: Found {duplicates} duplicate keys for year {year}")
                # Remove duplicates, keeping first occurrence
                combined_df = combined_df.dropDuplicates(["appraisal_yr", "account_num", "property_type"])
                final_rows = combined_df.count()
                log_message(f"Rows after deduplication: {final_rows}")
            else:
                log_message("No duplicates found")
                final_rows = total_rows
            
            # Convert back to DynamicFrame for writing
            dynamic_frame = DynamicFrame.fromDF(combined_df, glueContext, f"appraisal_notices_{year}")
            
            # Write to database using the same pattern as working DCAD job
            log_message(f"Writing {final_rows} records to database for year {year}...")
            glueContext.write_dynamic_frame.from_jdbc_conf(
                frame=dynamic_frame,
                catalog_connection=connection_name,
                connection_options={
                    "database": db_name,
                    "dbtable": "appraisal.appraisal_notices",
                    "postactions": ""  # Ensure clean append mode
                },
                transformation_ctx=f"write_appraisal_notices_{year}"
            )
            
            log_message(f"✓ Successfully wrote {final_rows} records for year {year}")
            total_rows_processed += final_rows
        
        log_message(f"{'='*50}")
        log_message(f"ETL job completed successfully!")
        log_message(f"Total records processed across all years: {total_rows_processed}")
        log_message(f"{'='*50}")
        
    except Exception as e:
        log_message(f"ETL job failed: {e}")
        raise
    finally:
        job.commit()

if __name__ == "__main__":
    main()