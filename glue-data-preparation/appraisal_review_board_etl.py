#!/usr/bin/env python3
"""
Appraisal Review Board ETL Job

Processes appraisal review board CSV files from S3 and loads them into Aurora PostgreSQL.
Handles both current (active=true) and archive (active=false) files.

Usage:
    - Processes both current and archive files from s3://map-appraiser-data-raw-appraisal/appraisal_review_board/
    - Sets active flag based on file type (current=true, archive=false)
    - Handles data type conversions and CSV parsing
    - Uses VPC connection for secure database access
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

def get_database_password():
    """Retrieve database password from AWS Secrets Manager"""
    try:
        secrets_client = boto3.client('secretsmanager', region_name='us-west-2')
        response = secrets_client.get_secret_value(SecretId='aurora-postgres-password')
        return response['SecretString']
    except Exception as e:
        log_message(f"Error retrieving database password: {e}")
        raise

def create_connection_options(password):
    """Create database connection options"""
    return {
        "url": "jdbc:postgresql://map-appraiser-aurora-db-cluster.cluster-cjcydnj4gvc0.us-west-2.rds.amazonaws.com:5432/map_appraiser",
        "user": "postgres",
        "password": password,
        "dbtable": "appraisal.appraisal_review_board",
        "driver": "org.postgresql.Driver"
    }

def create_csv_format_options():
    """Create CSV format options for robust parsing"""
    return {
        "withHeader": True,
        "separator": ",",
        "optimizePerformance": False,
        "quoteChar": '"',
        "escaper": '\\',
        "multiline": True
    }

def clean_column_names(df):
    """Clean column names to match database schema"""
    # Create column mapping from CSV headers to database column names
    column_mapping = {
        "PROTEST_YR": "protest_yr",
        "ACCOUNT_NUM": "account_num",
        "OWNER_PROTEST_IND": "owner_protest_ind",
        "MAIL_NAME": "mail_name",
        "MAIL_ADDR_L1": "mail_addr_l1",
        "MAIL_ADDR_L2": "mail_addr_l2",
        "MAIL_ADDR_L3": "mail_addr_l3",
        "MAIL_CITY": "mail_city",
        "MAIL_STATE_CD": "mail_state_cd",
        "MAIL_ZIPCODE": "mail_zipcode",
        "NOT_PRESENT_IND": "not_present_ind",
        "LATE_PROTEST_CDX": "late_protest_cdx",
        "PROTEST_SENT_CDX": "protest_sent_cdx",
        "PROTEST_SENT_DT": "protest_sent_dt",
        "PROTEST_WD_CDX": "protest_wd_cdx",
        "PROTEST_RCVD_CDX": "protest_rcvd_cdx",
        "PROTEST_RCVD_DT": "protest_rcvd_dt",
        "CONSENT_CDX": "consent_cdx",
        "CONSENT_DT": "consent_dt",
        "REINSPECT_REQ_CDX": "reinspect_req_cdx",
        "REINSPECT_DT": "reinspect_dt",
        "RESOLVED_CDX": "resolved_cdx",
        "RESOLVED_DT": "resolved_dt",
        "EXEMPT_PROTEST_DESC": "exempt_protest_desc",
        "PREV_SCH_CDX": "prev_sch_cdx",
        "PREV_HEARING_DT": "prev_hearing_dt",
        "PREV_HEARING_TM": "prev_hearing_tm",
        "PREV_ARB_PANEL": "prev_arb_panel",
        "CERT_MAIL_NUM": "cert_mail_num",
        "VALUE_PROTEST_IND": "value_protest_ind",  # Archive only
        "LESSEE_IND": "lessee_ind",
        "HB201_REQ_IND": "hb201_req_ind",
        "ARB_PROTEST_IND": "arb_protest_ind",
        "P2525C1_IND": "p2525c1_ind",
        "P2525D_IND": "p2525d_ind",
        "P41411_IND": "p41411_ind",
        "P4208_IND": "p4208_ind",
        "TAXPAYER_INFO_IND": "taxpayer_info_ind",
        "CONSENT_ONREQ_IND": "consent_onreq_ind",
        "EXEMPT_IND": "exempt_ind",
        "AUTH_TAX_REP_ID": "auth_tax_rep_id",
        "ARB_PANEL": "arb_panel",
        "HEARING_DT": "hearing_dt",
        "HEARING_TM": "hearing_tm",
        "EXEMPT_AG_FINAL_ORDERS_CD": "exempt_ag_final_orders_cd",
        "AUDIO_ACCOUNT_NUM": "audio_account_num",
        "FINAL_ORDER_COMMENT": "final_order_comment",
        "P2525H_IND": "p2525h_ind",
        "P2525C2_IND": "p2525c2_ind",
        "P2525C3_IND": "p2525c3_ind",
        "P2525B_IND": "p2525b_ind",
        "CERT_MAIL_DT": "cert_mail_dt",
        "NOTIFIED_VAL": "notified_val",
        "NEW_VAL": "new_val",
        "PANEL_VAL": "panel_val",
        "ACCT_TYPE": "acct_type",
        "NAME": "name",  # Archive only
        "TAXPAYER_REP_ID": "taxpayer_rep_id"  # Archive only
    }
    
    # Apply column mapping
    for old_col, new_col in column_mapping.items():
        if old_col in df.columns:
            df = df.withColumnRenamed(old_col, new_col)
    
    return df

def apply_data_type_conversions(df):
    """Apply proper data type conversions"""
    
    # Convert integer fields
    integer_fields = ["protest_yr"]
    for field in integer_fields:
        if field in df.columns:
            df = df.withColumn(field, 
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL"), None)
                .otherwise(col(field).cast(IntegerType())))
    
    # Convert decimal fields
    decimal_fields = ["notified_val", "new_val", "panel_val"]
    for field in decimal_fields:
        if field in df.columns:
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL") | (col(field) == "0.00"), None)
                .otherwise(regexp_replace(col(field), "[^0-9.-]", "").cast(DecimalType(15, 2))))
    
    # Convert timestamp fields (handle 1900-01-01 as NULL)
    timestamp_fields = ["protest_sent_dt", "protest_rcvd_dt", "consent_dt", "reinspect_dt", "resolved_dt"]
    for field in timestamp_fields:
        if field in df.columns:
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL") | 
                     col(field).startswith("1900-01-01"), None)
                .otherwise(to_timestamp(col(field), "yyyy-MM-dd HH:mm:ss")))
    
    # Convert date fields (handle 1900-01-01 as NULL)
    date_fields = ["prev_hearing_dt", "hearing_dt", "cert_mail_dt"]
    for field in date_fields:
        if field in df.columns:
            df = df.withColumn(field,
                when(col(field).isNull() | (col(field) == "") | (col(field) == "NULL") | 
                     col(field).startswith("1900-01-01"), None)
                .otherwise(to_date(col(field), "yyyy-MM-dd")))
    
    # Add metadata columns
    df = df.withColumn("created_at", current_timestamp())
    df = df.withColumn("updated_at", current_timestamp())
    
    return df

def add_missing_columns(df, is_archive=False):
    """Add any missing columns that exist in the database schema but not in the CSV"""
    
    # Archive-specific columns (only in archive file)
    archive_columns = ["value_protest_ind", "name", "taxpayer_rep_id"]
    
    # If processing current file, add archive columns as NULL
    if not is_archive:
        for col_name in archive_columns:
            if col_name not in df.columns:
                df = df.withColumn(col_name, lit(None).cast(StringType()))
    
    # If processing archive file, ensure all columns exist
    if is_archive:
        for col_name in archive_columns:
            if col_name not in df.columns:
                df = df.withColumn(col_name, lit(None).cast(StringType()))
    
    return df

def process_csv_file(file_path, is_archive=False):
    """Process a single CSV file"""
    log_message(f"Processing file: {file_path}")
    log_message(f"Archive file: {is_archive}")
    
    try:
        # Read CSV file
        df = glueContext.create_dynamic_frame.from_options(
            connection_type="s3",
            connection_options={"paths": [file_path]},
            format="csv",
            format_options=create_csv_format_options()
        ).toDF()
        
        log_message(f"Initial row count: {df.count()}")
        log_message(f"Initial columns: {len(df.columns)}")
        
        # Clean column names
        df = clean_column_names(df)
        
        # Add missing columns
        df = add_missing_columns(df, is_archive)
        
        # Apply data type conversions
        df = apply_data_type_conversions(df)
        
        # Set active flag based on file type
        df = df.withColumn("active", lit(not is_archive))
        
        log_message(f"Final row count: {df.count()}")
        log_message(f"Final columns: {len(df.columns)}")
        
        return df
        
    except Exception as e:
        log_message(f"Error processing file {file_path}: {e}")
        raise

def write_to_database(df, connection_options):
    """Write DataFrame to PostgreSQL database"""
    try:
        log_message("Writing data to database...")
        
        # Convert back to DynamicFrame for writing
        dynamic_frame = glueContext.create_dynamic_frame.from_catalog(
            database="default",
            table_name="temp_table",
            transformation_ctx="dynamic_frame"
        )
        
        # Create DynamicFrame from DataFrame
        dynamic_frame = glueContext.create_dynamic_frame.from_catalog(
            database="default",
            table_name="temp_table"
        )
        
        # Use direct DataFrame write instead
        df.write \
            .format("jdbc") \
            .option("url", connection_options["url"]) \
            .option("dbtable", connection_options["dbtable"]) \
            .option("user", connection_options["user"]) \
            .option("password", connection_options["password"]) \
            .option("driver", connection_options["driver"]) \
            .mode("append") \
            .save()
        
        log_message("Data written successfully to database")
        
    except Exception as e:
        log_message(f"Error writing to database: {e}")
        raise

def main():
    """Main ETL process"""
    log_message("Starting Appraisal Review Board ETL job")
    
    # Get job arguments
    args = getResolvedOptions(sys.argv, ['JOB_NAME'])
    job.init(args['JOB_NAME'], args)
    
    try:
        # Get database password
        log_message("Retrieving database credentials...")
        password = get_database_password()
        connection_options = create_connection_options(password)
        
        # Define S3 paths
        s3_bucket = "map-appraiser-data-raw-appraisal"
        current_file_path = f"s3://{s3_bucket}/appraisal_review_board/appraisal_review_board_current.csv"
        archive_file_path = f"s3://{s3_bucket}/appraisal_review_board/appraisal_review_board_archive.csv"
        
        all_dataframes = []
        
        # Process current file (active=true)
        log_message("=" * 50)
        log_message("Processing CURRENT file (active=true)")
        log_message("=" * 50)
        current_df = process_csv_file(current_file_path, is_archive=False)
        all_dataframes.append(current_df)
        
        # Process archive file (active=false)
        log_message("=" * 50)
        log_message("Processing ARCHIVE file (active=false)")
        log_message("=" * 50)
        archive_df = process_csv_file(archive_file_path, is_archive=True)
        all_dataframes.append(archive_df)
        
        # Union all dataframes
        log_message("=" * 50)
        log_message("Combining all data")
        log_message("=" * 50)
        
        combined_df = all_dataframes[0]
        for df in all_dataframes[1:]:
            combined_df = combined_df.union(df)
        
        total_rows = combined_df.count()
        log_message(f"Total combined rows: {total_rows}")
        
        # Remove duplicates based on primary key (protest_yr, account_num)
        log_message("Removing duplicates based on primary key...")
        deduplicated_df = combined_df.dropDuplicates(["protest_yr", "account_num"])
        final_rows = deduplicated_df.count()
        
        log_message(f"Rows after deduplication: {final_rows}")
        log_message(f"Duplicates removed: {total_rows - final_rows}")
        
        # Write to database
        log_message("=" * 50)
        log_message("Writing to database")
        log_message("=" * 50)
        
        write_to_database(deduplicated_df, connection_options)
        
        log_message("=" * 50)
        log_message("ETL job completed successfully!")
        log_message(f"Total records processed: {final_rows}")
        log_message("=" * 50)
        
    except Exception as e:
        log_message(f"ETL job failed: {e}")
        raise
    finally:
        job.commit()

if __name__ == "__main__":
    main()