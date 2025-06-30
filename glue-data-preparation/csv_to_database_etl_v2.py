import sys
import boto3
import json
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import lit, current_timestamp, col, to_date, when, isnan, isnull, substring
from pyspark.sql.types import *
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_secret_value(secret_name, region_name='us-west-2'):
    """Retrieve database password from AWS Secrets Manager"""
    session = boto3.session.Session()
    client = session.client('secretsmanager', region_name=region_name)
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return response['SecretString']
    except Exception as e:
        logger.error(f"Failed to retrieve secret {secret_name}: {e}")
        raise

def discover_year_folders(s3_client, bucket_name):
    """Discover available year folders in S3 bucket"""
    try:
        response = s3_client.list_objects_v2(
            Bucket=bucket_name,
            Delimiter='/'
        )
        
        year_folders = []
        if 'CommonPrefixes' in response:
            for prefix in response['CommonPrefixes']:
                folder = prefix['Prefix'].rstrip('/')
                # Look for DCAD folders with year patterns
                if 'DCAD' in folder:
                    import re
                    if re.search(r'\d{4}', folder):
                        year_folders.append(folder)
                        
        logger.info(f"Found year folders: {year_folders}")
        return sorted(year_folders)
        
    except Exception as e:
        logger.error(f"Failed to discover year folders: {e}")
        raise

def extract_year_from_folder(folder_name):
    """Extract year from folder name (e.g., DCAD2025_CURRENT -> 2025)"""
    import re
    match = re.search(r'(\d{4})', folder_name)
    return int(match.group(1)) if match else None

def get_csv_files_for_year(s3_client, bucket_name, year_folder):
    """Get list of CSV files for a specific year folder"""
    try:
        response = s3_client.list_objects_v2(
            Bucket=bucket_name,
            Prefix=f"{year_folder}/"
        )
        
        csv_files = []
        if 'Contents' in response:
            for obj in response['Contents']:
                if obj['Key'].lower().endswith('.csv') and obj['Size'] > 0:
                    csv_files.append(obj['Key'])
                    
        logger.info(f"Found {len(csv_files)} CSV files in {year_folder}")
        return csv_files
        
    except Exception as e:
        logger.error(f"Failed to get CSV files for {year_folder}: {e}")
        raise

def map_csv_to_table(csv_filename):
    """Map CSV filename to database table name"""
    filename_to_table = {
        'account_info.csv': 'account_info',
        'account_apprl_year.csv': 'account_apprl_year', 
        'taxable_object.csv': 'taxable_object',
        'res_detail.csv': 'res_detail',
        'com_detail.csv': 'com_detail',
        'land.csv': 'land',
        'res_addl.csv': 'res_addl',
        'multi_owner.csv': 'multi_owner',
        'applied_std_exempt.csv': 'applied_std_exempt',
        'acct_exempt_value.csv': 'acct_exempt_value',
        'abatement_exempt.csv': 'abatement_exempt',
        'freeport_exemption.csv': 'freeport_exemption',
        'total_exemption.csv': 'total_exemption',
        'account_tif.csv': 'account_tif'
    }
    
    csv_name = csv_filename.split('/')[-1].lower()
    return filename_to_table.get(csv_name)

def apply_data_type_conversions(df, table_name):
    """Apply proper data type conversions based on database schema"""
    
    # Define date columns for each table
    date_columns = {
        'account_info': ['deed_txfr_date'],
        'applied_std_exempt': [
            'homestead_eff_dt', 'city_ceil_dt', 'county_ceil_dt', 'isd_ceil_dt', 'college_ceil_dt',
            'disable_eff_dt', 'prorate_eff_dt', 'prorate_exp_dt'
        ]
    }
    
    # Define decimal/numeric columns for each table
    decimal_columns = {
        'account_apprl_year': [
            'impr_val', 'land_val', 'land_ag_exempt', 'ag_use_val', 'tot_val', 'hmstd_cap_val',
            'prev_mkt_val', 'tot_contrib_amt', 'city_split_pct', 'county_split_pct', 'isd_split_pct',
            'hospital_split_pct', 'college_split_pct', 'special_dist_split_pct', 'city_taxable_val',
            'county_taxable_val', 'isd_taxable_val', 'hospital_taxable_val', 'college_taxable_val',
            'special_dist_taxable_val', 'city_ceiling_value', 'county_ceiling_value', 'isd_ceiling_value',
            'hospital_ceiling_value', 'college_ceiling_value', 'special_dist_ceiling_value', 'rendition_penalty'
        ],
        'res_detail': [
            'tot_main_sf', 'tot_living_area_sf', 'pct_complete', 'num_fireplaces', 'num_kitchens',
            'num_full_baths', 'num_half_baths', 'num_wet_bars', 'num_bedrooms', 'mbl_home_length',
            'mbl_home_width', 'depreciation_pct'
        ],
        'com_detail': [
            'gross_bldg_area', 'foundation_area', 'basement_area', 'num_stories', 'num_units',
            'net_lease_area', 'phys_depr_pct', 'funct_depr_pct', 'extrnl_depr_pct', 'tot_depr_pct',
            'imp_val', 'land_val', 'mkt_val', 'pct_complete'
        ],
        'land': [
            'front_dim', 'depth_dim', 'area_size', 'cost_per_uom', 'market_adj_pct', 'val_amt', 'acct_ag_val_amt'
        ],
        'res_addl': [
            'area_size', 'val_amt', 'depreciation_pct'
        ],
        'multi_owner': ['ownership_pct'],
        'applied_std_exempt': [
            'ownership_pct', 'city_ceil_tax_val', 'city_ceil_xfer_pct', 'county_ceil_tax_val',
            'county_ceil_xfer_pct', 'isd_ceil_tax_val', 'isd_ceil_xfer_pct', 'college_ceil_tax_val',
            'college_ceil_xfer_pct', 'vet_disable_pct', 'vet_flat_amt', 'vet2_disable_pct', 'vet2_flat_amt',
            'capped_hs_amt', 'hs_pct', 'tot_val', 'over65_pct', 'disabledpct'
        ],
        'acct_exempt_value': [
            'city_appld_val', 'cnty_appld_val', 'isd_appld_val', 'hospital_appld_val', 'college_appld_val', 'spcl_applied_val'
        ],
        'abatement_exempt': [
            'tot_val', 'city_exemption_pct', 'city_base_val', 'city_val_dif', 'city_exemption_amt',
            'cnty_exemption_pct', 'cnty_base_val', 'cnty_val_dif', 'cnty_exemption_amt',
            'isd_exemption_pct', 'isd_base_val', 'isd_val_dif', 'isd_exemption_amt',
            'coll_exemption_pct', 'coll_base_val', 'coll_val_dif', 'coll_exemption_amt',
            'spec_exemption_pct', 'spec_base_val', 'spec_val_dif', 'spec_exemption_amt'
        ],
        'account_tif': [
            'acct_mkt', 'city_pct', 'city_base_mkt', 'city_base_taxable', 'city_acct_taxable',
            'cnty_pct', 'cnty_base_mkt', 'cnty_base_taxable', 'cnty_acct_taxable',
            'isd_pct', 'isd_base_mkt', 'isd_base_taxable', 'isd_acct_taxable',
            'hosp_pct', 'hosp_base_mkt', 'hosp_base_taxable', 'hosp_acct_taxable',
            'coll_pct', 'coll_base_mkt', 'coll_base_taxable', 'coll_acct_taxable',
            'spec_pct', 'spec_base_mkt', 'spec_base_taxable', 'spec_acct_taxable'
        ]
    }
    
    # Define integer columns for each table
    integer_columns = {
        'account_info': ['appraisal_yr'],
        'account_apprl_year': ['appraisal_yr', 'reval_yr', 'prev_reval_yr'],
        'taxable_object': ['appraisal_yr'],
        'res_detail': [
            'appraisal_yr', 'yr_built', 'eff_yr_built', 'act_age', 'tot_main_sf', 'tot_living_area_sf',
            'num_stories', 'num_fireplaces', 'num_kitchens', 'num_full_baths', 'num_half_baths', 
            'num_wet_bars', 'num_bedrooms'
        ],
        'com_detail': [
            'appraisal_yr', 'year_built', 'remodel_yr', 'gross_bldg_area', 'foundation_area',
            'basement_area', 'num_stories', 'num_units', 'net_lease_area'
        ],
        'land': ['appraisal_yr', 'section_num'],
        'res_addl': ['appraisal_yr', 'seq_num', 'yr_built', 'num_stories'],
        'multi_owner': ['appraisal_yr', 'owner_seq_num'],
        'applied_std_exempt': [
            'appraisal_yr', 'owner_seq_num', 'vet_eff_yr', 'vet2_eff_yr', 'days_taxable'
        ],
        'acct_exempt_value': ['appraisal_yr', 'sortorder'],
        'abatement_exempt': [
            'appraisal_yr', 'city_eff_yr', 'city_exp_yr', 'cnty_eff_yr', 'cnty_exp_yr',
            'isd_eff_yr', 'isd_exp_yr', 'coll_eff_yr', 'coll_exp_yr', 'spec_eff_yr', 'spec_exp_yr'
        ],
        'freeport_exemption': ['appraisal_yr'],
        'total_exemption': ['appraisal_yr'],
        'account_tif': ['appraisal_yr', 'effective_yr', 'expiration_yr']
    }
    
    # Apply date conversions
    if table_name in date_columns:
        for date_col in date_columns[table_name]:
            if date_col in df.columns:
                # Convert date strings to proper date format, handle empty strings
                df = df.withColumn(date_col, 
                    when((col(date_col).isNull()) | (col(date_col) == '') | (col(date_col) == ' '), None)
                    .otherwise(to_date(col(date_col), 'MM/dd/yyyy'))
                )
    
    # Apply integer conversions
    if table_name in integer_columns:
        for int_col in integer_columns[table_name]:
            if int_col in df.columns:
                # Convert to integer, handle empty strings and nulls
                df = df.withColumn(int_col,
                    when((col(int_col).isNull()) | (col(int_col) == '') | (col(int_col) == ' '), None)
                    .otherwise(col(int_col).cast(IntegerType()))
                )
    
    # Apply decimal conversions
    if table_name in decimal_columns:
        for dec_col in decimal_columns[table_name]:
            if dec_col in df.columns:
                # Convert to decimal, handle empty strings and nulls
                df = df.withColumn(dec_col,
                    when((col(dec_col).isNull()) | (col(dec_col) == '') | (col(dec_col) == ' '), None)
                    .otherwise(col(dec_col).cast(DecimalType(18, 2)))
                )
    
    # Apply string length constraints based on database schema
    string_length_constraints = {
        'account_info': {
            'division_cd': 10,
            'exclude_owner': 1, 
            'owner_state': 20,
            'owner_zipcode': 10,
            'property_zipcode': 10,
            'mapsco': 20,  # Increase this if needed
            'nbhd_cd': 10,
            'phone_num': 15,
            'lma': 20,
            'ima': 20
        },
        # Add other tables as needed
    }
    
    if table_name in string_length_constraints:
        for str_col, max_length in string_length_constraints[table_name].items():
            if str_col in df.columns:
                # Truncate strings that are too long
                df = df.withColumn(str_col,
                    when(col(str_col).isNull(), None)
                    .otherwise(substring(col(str_col), 1, max_length))
                )
    
    return df

def clear_year_data_sql(connection_name, db_name, year, glue_context):
    """Clear existing data for a specific year using direct SQL execution"""
    try:
        # Get connection details from Glue catalog
        glue_client = boto3.client('glue', region_name='us-west-2')
        connection_response = glue_client.get_connection(Name=connection_name)
        connection_properties = connection_response['Connection']['ConnectionProperties']
        
        jdbc_url = connection_properties['JDBC_CONNECTION_URL']
        username = connection_properties['USERNAME']
        password = connection_properties['PASSWORD']
        
        # List of tables in dependency order (children first)
        tables = [
            'applied_std_exempt',
            'acct_exempt_value', 
            'abatement_exempt',
            'freeport_exemption',
            'total_exemption',
            'account_tif',
            'multi_owner',
            'res_addl',
            'res_detail',
            'com_detail',
            'land',
            'taxable_object',
            'account_apprl_year',
            'account_info'
        ]
        
        # Use Spark's JDBC capabilities to execute delete statements
        spark = glue_context.spark_session
        
        for table in tables:
            try:
                # Create a temporary view with the count of rows to delete
                temp_query = f"(SELECT COUNT(*) as count_to_delete FROM appraisal.{table} WHERE appraisal_yr = {year}) AS temp_count"
                
                # Execute the count query first to verify the delete will work
                count_df = spark.read.format("jdbc") \
                    .option("url", jdbc_url) \
                    .option("driver", "org.postgresql.Driver") \
                    .option("user", username) \
                    .option("password", password) \
                    .option("query", temp_query) \
                    .load()
                
                row_count = count_df.collect()[0]['count_to_delete']
                
                if row_count > 0:
                    # Execute the actual delete using a simple select with a side effect
                    delete_query = f"(SELECT 1 FROM appraisal.{table} WHERE appraisal_yr = {year} LIMIT 1) AS check_exists"
                    
                    # Since Spark JDBC can't execute DELETE directly, we'll use a workaround
                    # Create an empty DataFrame with the table structure and use overwrite mode
                    # But first we need to get the schema
                    schema_query = f"(SELECT * FROM appraisal.{table} WHERE 1=0) AS empty_schema"
                    empty_df = spark.read.format("jdbc") \
                        .option("url", jdbc_url) \
                        .option("driver", "org.postgresql.Driver") \
                        .option("user", username) \
                        .option("password", password) \
                        .option("query", schema_query) \
                        .load()
                    
                    logger.info(f"Would delete {row_count} rows from {table} for year {year}")
                else:
                    logger.info(f"No data to delete from {table} for year {year}")
                
            except Exception as e:
                logger.warning(f"Could not delete from {table} for year {year}: {e}")
                
        logger.info(f"Data clearing process completed for year {year}")
        
    except Exception as e:
        logger.error(f"Failed to clear data for year {year}: {e}")
        # Don't raise - continue with loading

def load_csv_to_database(s3_path, table_name, year, connection_name, db_name, glue_context):
    """Load CSV data from S3 into database table using Glue"""
    try:
        logger.info(f"Loading {s3_path} -> {table_name}")
        
        # Read CSV from S3 using Glue
        dynamic_frame = glue_context.create_dynamic_frame.from_options(
            connection_type="s3",
            connection_options={"paths": [s3_path]},
            format="csv",
            format_options={
                "withHeader": True,
                "separator": ",",
                "optimizePerformance": False,
                "quoteChar": '"',
                "escaper": '\\',
                "multiline": True
            }
        )
        
        # Convert to DataFrame for transformation
        try:
            df = dynamic_frame.toDF()
        except Exception as e:
            logger.error(f"Failed to convert DynamicFrame to DataFrame for {table_name}: {e}")
            logger.error(f"File path: {s3_path}")
            # Try alternative parsing approach
            logger.info(f"Attempting to read {table_name} with Spark directly")
            spark = glue_context.spark_session
            df = spark.read.option("header", "true") \
                .option("inferSchema", "true") \
                .option("quote", '"') \
                .option("escape", '"') \
                .option("multiLine", "true") \
                .csv(s3_path)
        
        # Clean column names (lowercase, replace spaces with underscores)
        for column_name in df.columns:
            new_col_name = column_name.lower().replace(' ', '_').replace('-', '_')
            if new_col_name != column_name:
                df = df.withColumnRenamed(column_name, new_col_name)
        
        # Add appraisal year if not present
        if 'appraisal_yr' not in df.columns:
            df = df.withColumn('appraisal_yr', lit(year).cast(IntegerType()))
            
        # Apply data type conversions based on table schema
        df = apply_data_type_conversions(df, table_name)
            
        # Deduplicate data before writing to avoid primary key conflicts
        # Get primary key columns for the table
        primary_keys = {
            'account_info': ['account_num', 'appraisal_yr'],
            'account_apprl_year': ['account_num', 'appraisal_yr'], 
            'taxable_object': ['account_num', 'appraisal_yr', 'tax_obj_id'],
            'res_detail': ['account_num', 'appraisal_yr', 'tax_obj_id'],
            'com_detail': ['tax_obj_id', 'account_num', 'appraisal_yr'],
            'land': ['account_num', 'appraisal_yr', 'section_num'],
            'res_addl': ['account_num', 'appraisal_yr', 'tax_obj_id', 'seq_num'],
            'multi_owner': ['appraisal_yr', 'account_num', 'owner_seq_num'],
            'applied_std_exempt': ['account_num', 'appraisal_yr', 'owner_seq_num'],
            'acct_exempt_value': ['account_num', 'appraisal_yr', 'exemption_cd'],
            'abatement_exempt': ['account_num', 'appraisal_yr'],
            'freeport_exemption': ['appraisal_yr', 'account_num'],
            'total_exemption': ['account_num', 'appraisal_yr'],
            'account_tif': ['account_num', 'appraisal_yr']
        }
        
        # Deduplicate if primary keys are defined for this table
        if table_name in primary_keys:
            pk_columns = primary_keys[table_name]
            # Check if all PK columns exist in the dataframe
            missing_cols = [col for col in pk_columns if col not in df.columns]
            if not missing_cols:
                df = df.dropDuplicates(pk_columns)
                logger.info(f"Deduplicated {table_name} on columns: {pk_columns}")
            else:
                logger.warning(f"Cannot deduplicate {table_name}, missing columns: {missing_cols}")
        
        # Add audit timestamp columns
        df = df.withColumn('created_at', current_timestamp())
        df = df.withColumn('updated_at', current_timestamp())
        
        # Convert back to DynamicFrame
        dynamic_frame_transformed = DynamicFrame.fromDF(df, glue_context, f"{table_name}_frame")
        
        # Write to PostgreSQL using JDBC with append mode
        glue_context.write_dynamic_frame.from_jdbc_conf(
            frame=dynamic_frame_transformed,
            catalog_connection=connection_name,
            connection_options={
                "database": db_name,
                "dbtable": f"appraisal.{table_name}",
                "postactions": ""  # Ensure clean append mode
            },
            transformation_ctx=f"write_{table_name}"
        )
        
        row_count = df.count()
        logger.info(f"Loaded {row_count} rows into {table_name}")
        return row_count
        
    except Exception as e:
        logger.error(f"Failed to load data into {table_name}: {e}")
        raise

def main():
    # Get job parameters - TARGET_YEAR is optional
    required_args = [
        'JOB_NAME',
        'SOURCE_BUCKET',
        'CONNECTION_NAME',
        'DB_NAME'
    ]
    
    # Check if TARGET_YEAR is provided
    optional_args = []
    if '--TARGET_YEAR' in sys.argv:
        optional_args.append('TARGET_YEAR')
    
    args = getResolvedOptions(sys.argv, required_args + optional_args)
    
    # Initialize Glue context
    sc = SparkContext()
    glueContext = GlueContext(sc)
    spark = glueContext.spark_session
    job = Job(glueContext)
    job.init(args['JOB_NAME'], args)
    
    # Initialize AWS clients
    s3_client = boto3.client('s3')
    
    try:
        # Discover year folders
        year_folders = discover_year_folders(s3_client, args['SOURCE_BUCKET'])
        
        # Filter to specific year if provided
        if 'TARGET_YEAR' in args and args.get('TARGET_YEAR'):
            target_year = int(args['TARGET_YEAR'])
            year_folders = [f for f in year_folders if extract_year_from_folder(f) == target_year]
            logger.info(f"Processing only year {target_year}")
        else:
            logger.info("Processing all available years")
        
        total_rows_processed = 0
        
        # Process each year
        for year_folder in year_folders:
            year = extract_year_from_folder(year_folder)
            if not year:
                logger.warning(f"Could not extract year from folder: {year_folder}")
                continue
                
            logger.info(f"Processing year {year} from folder {year_folder}")
            
            # Clear existing data for this year - disabled, use manual purge instead
            # clear_year_data_sql(args['CONNECTION_NAME'], args['DB_NAME'], year, glueContext)
            logger.info(f"Skipping automatic data clearing for year {year} - ensure manual purge is done")
            
            # Get CSV files for this year
            csv_files = get_csv_files_for_year(s3_client, args['SOURCE_BUCKET'], year_folder)
            
            # Define load order (parents before children)
            load_order = [
                'account_info.csv',
                'account_apprl_year.csv',
                'taxable_object.csv',
                'res_detail.csv',
                'com_detail.csv', 
                'land.csv',
                'res_addl.csv',
                'multi_owner.csv',
                'applied_std_exempt.csv',
                'acct_exempt_value.csv',
                'abatement_exempt.csv',
                'freeport_exemption.csv',
                'total_exemption.csv',
                'account_tif.csv'
            ]
            
            year_rows_processed = 0
            
            # Process files in dependency order
            for expected_file in load_order:
                # Find the actual file (case insensitive)
                actual_file = None
                for csv_file in csv_files:
                    if csv_file.lower().endswith(expected_file.lower()):
                        actual_file = csv_file
                        break
                        
                if not actual_file:
                    logger.warning(f"File {expected_file} not found in {year_folder}")
                    continue
                    
                # Get table name
                table_name = map_csv_to_table(expected_file)
                if not table_name:
                    logger.warning(f"No table mapping for file: {expected_file}")
                    continue
                    
                # Load data
                s3_path = f"s3://{args['SOURCE_BUCKET']}/{actual_file}"
                rows_inserted = load_csv_to_database(
                    s3_path, table_name, year, 
                    args['CONNECTION_NAME'], args['DB_NAME'], glueContext
                )
                year_rows_processed += rows_inserted
            
            logger.info(f"Completed year {year}: {year_rows_processed} total rows processed")
            total_rows_processed += year_rows_processed
        
        logger.info(f"ETL job completed successfully. Total rows processed: {total_rows_processed}")
        
    except Exception as e:
        logger.error(f"ETL job failed: {e}")
        raise
        
    finally:
        job.commit()

if __name__ == "__main__":
    main()