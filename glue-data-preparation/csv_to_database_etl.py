import sys
import boto3
import psycopg2
import pandas as pd
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from io import StringIO
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseETL:
    def __init__(self, db_host, db_port, db_name, db_user, db_password):
        self.db_host = db_host
        self.db_port = db_port
        self.db_name = db_name
        self.db_user = db_user
        self.db_password = db_password
        self.connection = None
        
    def connect(self):
        """Establish database connection"""
        try:
            self.connection = psycopg2.connect(
                host=self.db_host,
                port=self.db_port,
                database=self.db_name,
                user=self.db_user,
                password=self.db_password
            )
            self.connection.autocommit = False
            logger.info("Database connection established")
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise
            
    def disconnect(self):
        """Close database connection"""
        if self.connection:
            self.connection.close()
            logger.info("Database connection closed")
            
    def clear_year_data(self, year):
        """Clear existing data for a specific year before loading new data"""
        try:
            cursor = self.connection.cursor()
            
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
            
            for table in tables:
                cursor.execute(f"DELETE FROM appraisal.{table} WHERE appraisal_yr = %s", (year,))
                deleted_count = cursor.rowcount
                logger.info(f"Deleted {deleted_count} rows from {table} for year {year}")
                
            self.connection.commit()
            logger.info(f"Successfully cleared all data for year {year}")
            
        except Exception as e:
            self.connection.rollback()
            logger.error(f"Failed to clear data for year {year}: {e}")
            raise
        finally:
            cursor.close()

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

def load_csv_to_dataframe(s3_client, bucket_name, csv_key):
    """Load CSV file from S3 into pandas DataFrame"""
    try:
        response = s3_client.get_object(Bucket=bucket_name, Key=csv_key)
        csv_content = response['Body'].read().decode('utf-8')
        
        # Use StringIO to read CSV content
        df = pd.read_csv(StringIO(csv_content))
        
        # Clean column names (lowercase, replace spaces with underscores)
        df.columns = df.columns.str.lower().str.replace(' ', '_').str.replace('-', '_')
        
        logger.info(f"Loaded {len(df)} rows from {csv_key}")
        return df
        
    except Exception as e:
        logger.error(f"Failed to load CSV {csv_key}: {e}")
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

def insert_dataframe_to_table(df, table_name, year, db_etl):
    """Insert DataFrame into database table"""
    try:
        cursor = db_etl.connection.cursor()
        
        # Add appraisal year to DataFrame if not present
        if 'appraisal_yr' not in df.columns:
            df['appraisal_yr'] = year
            
        # Convert DataFrame to list of tuples for bulk insert
        columns = list(df.columns)
        values = df.values.tolist()
        
        # Create INSERT statement
        placeholders = ','.join(['%s'] * len(columns))
        columns_str = ','.join(columns)
        insert_query = f"INSERT INTO appraisal.{table_name} ({columns_str}) VALUES ({placeholders})"
        
        # Execute bulk insert
        cursor.executemany(insert_query, values)
        
        rows_inserted = cursor.rowcount
        logger.info(f"Inserted {rows_inserted} rows into {table_name}")
        
        return rows_inserted
        
    except Exception as e:
        logger.error(f"Failed to insert data into {table_name}: {e}")
        raise
    finally:
        cursor.close()

def main():
    # Get job parameters
    args = getResolvedOptions(sys.argv, [
        'JOB_NAME',
        'SOURCE_BUCKET',
        'DB_SECRET_NAME',
        'DB_HOST',
        'DB_PORT', 
        'DB_NAME',
        'DB_USER',
        'TARGET_YEAR'  # Optional: specific year to process, otherwise process all
    ])
    
    # Initialize Glue context
    sc = SparkContext()
    glueContext = GlueContext(sc)
    job = Job(glueContext)
    job.init(args['JOB_NAME'], args)
    
    # Initialize AWS clients
    s3_client = boto3.client('s3')
    
    try:
        # Get database credentials
        db_password = get_secret_value(args['DB_SECRET_NAME'])
        
        # Initialize database ETL
        db_etl = DatabaseETL(
            db_host=args['DB_HOST'],
            db_port=int(args['DB_PORT']),
            db_name=args['DB_NAME'],
            db_user=args['DB_USER'],
            db_password=db_password
        )
        
        # Connect to database
        db_etl.connect()
        
        # Discover year folders
        year_folders = discover_year_folders(s3_client, args['SOURCE_BUCKET'])
        
        # Filter to specific year if provided
        if 'TARGET_YEAR' in args and args['TARGET_YEAR']:
            target_year = int(args['TARGET_YEAR'])
            year_folders = [f for f in year_folders if extract_year_from_folder(f) == target_year]
            logger.info(f"Processing only year {target_year}")
        
        total_rows_processed = 0
        
        # Process each year
        for year_folder in year_folders:
            year = extract_year_from_folder(year_folder)
            if not year:
                logger.warning(f"Could not extract year from folder: {year_folder}")
                continue
                
            logger.info(f"Processing year {year} from folder {year_folder}")
            
            # Clear existing data for this year
            db_etl.clear_year_data(year)
            
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
                    
                # Load and insert data
                logger.info(f"Processing {actual_file} -> {table_name}")
                df = load_csv_to_dataframe(s3_client, args['SOURCE_BUCKET'], actual_file)
                
                if len(df) > 0:
                    rows_inserted = insert_dataframe_to_table(df, table_name, year, db_etl)
                    year_rows_processed += rows_inserted
                else:
                    logger.warning(f"No data found in {actual_file}")
            
            # Commit all changes for this year
            db_etl.connection.commit()
            logger.info(f"Completed year {year}: {year_rows_processed} total rows processed")
            total_rows_processed += year_rows_processed
        
        logger.info(f"ETL job completed successfully. Total rows processed: {total_rows_processed}")
        
    except Exception as e:
        logger.error(f"ETL job failed: {e}")
        if db_etl.connection:
            db_etl.connection.rollback()
        raise
        
    finally:
        # Clean up
        if db_etl:
            db_etl.disconnect()
        job.commit()

if __name__ == "__main__":
    main()