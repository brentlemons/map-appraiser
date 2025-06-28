import sys
import json
import uuid
from datetime import datetime
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from pyspark.sql.types import StringType
import boto3

# Initialize contexts and job
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Configuration
source_bucket = "map-appraiser-data-raw-appraisal"
target_bucket = "map-appraiser-data-knowledge-base"
target_folder = "appraisal-json"

# S3 client for listing objects
s3_client = boto3.client('s3')

def list_year_folders():
    """List all year folders in the source bucket"""
    paginator = s3_client.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(
        Bucket=source_bucket,
        Delimiter='/',
        Prefix=''
    )
    
    year_folders = []
    for page in page_iterator:
        if 'CommonPrefixes' in page:
            for prefix in page['CommonPrefixes']:
                folder = prefix['Prefix'].rstrip('/')
                # Look for folders that contain DCAD and a 4-digit year
                if 'DCAD' in folder:
                    import re
                    if re.search(r'\d{4}', folder):
                        year_folders.append(folder)
    
    return sorted(year_folders)

def list_csv_files(year_folder):
    """List all CSV files in a year folder"""
    csv_files = []
    
    paginator = s3_client.get_paginator('list_objects_v2')
    pages = paginator.paginate(
        Bucket=source_bucket,
        Prefix=f"{year_folder}/"
    )
    
    for page in pages:
        if 'Contents' in page:
            for obj in page['Contents']:
                if obj['Key'].lower().endswith('.csv'):
                    csv_files.append(obj['Key'])
    
    return csv_files

def get_table_name_from_file(file_path):
    """Extract table name from file path"""
    file_name = file_path.split('/')[-1]
    # Remove .csv or .CSV extension
    table_name = file_name.replace('.csv', '').replace('.CSV', '')
    return table_name

def extract_year_from_folder(folder_name):
    """Extract year from folder name like DCAD2019_CURRENT"""
    import re
    match = re.search(r'(\d{4})', folder_name)
    return match.group(1) if match else folder_name

def process_csv_to_json(csv_path, year, table_name):
    """Process a single CSV file and write each row as a JSON file"""
    print(f"Processing {csv_path}")
    
    # Read CSV file
    df = spark.read.option("header", "true") \
        .option("inferSchema", "true") \
        .csv(f"s3://{source_bucket}/{csv_path}")
    
    # Add metadata columns
    df = df.withColumn("_source_file", F.lit(csv_path)) \
           .withColumn("_table_name", F.lit(table_name)) \
           .withColumn("_year", F.lit(year)) \
           .withColumn("_processed_timestamp", F.lit(datetime.utcnow().isoformat()))
    
    # Generate unique ID for each row
    df = df.withColumn("_record_id", F.expr("uuid()"))
    
    # Convert each row to JSON and write as individual files
    rows = df.collect()
    
    for idx, row in enumerate(rows):
        row_dict = row.asDict()
        
        # Generate unique filename
        record_id = row_dict.get('_record_id', str(uuid.uuid4()))
        output_key = f"{target_folder}/{year}/{table_name}/{record_id}.json"
        
        # Convert to JSON
        json_content = json.dumps(row_dict, default=str)
        
        # Write to S3
        s3_client.put_object(
            Bucket=target_bucket,
            Key=output_key,
            Body=json_content,
            ContentType='application/json'
        )
    
    print(f"Processed {len(rows)} records from {csv_path}")
    return len(rows)

def main():
    """Main ETL process"""
    total_records = 0
    processed_files = 0
    
    try:
        # Get all year folders
        year_folders = list_year_folders()
        print(f"Found {len(year_folders)} year folders: {year_folders}")
        
        for year_folder in year_folders:
            year = extract_year_from_folder(year_folder)
            print(f"\nProcessing year folder: {year_folder} (year: {year})")
            
            # Get all CSV files in the year folder
            csv_files = list_csv_files(year_folder)
            print(f"Found {len(csv_files)} CSV files in {year_folder}")
            
            for csv_file in csv_files:
                table_name = get_table_name_from_file(csv_file)
                
                try:
                    records = process_csv_to_json(csv_file, year, table_name)
                    total_records += records
                    processed_files += 1
                except Exception as e:
                    print(f"Error processing {csv_file}: {str(e)}")
                    continue
        
        print(f"\nETL completed successfully!")
        print(f"Total files processed: {processed_files}")
        print(f"Total records converted: {total_records}")
        
    except Exception as e:
        print(f"ETL job failed: {str(e)}")
        raise e
    
    job.commit()

if __name__ == "__main__":
    main()