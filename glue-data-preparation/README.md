# AWS Glue Data Preparation Jobs

This directory contains AWS Glue ETL jobs for data preparation tasks.

## Overview

AWS Glue ETL jobs in this folder are designed to prepare and transform data for the Map Appraiser application.

## Jobs

### Created Jobs

#### CSV to JSON ETL Job (`csv_to_json_etl.py`)
Processes CSV files from the raw appraisal data bucket and converts each row to an individual JSON file for use in a knowledge base.

**Features:**
- Automatically discovers year folders in the source bucket
- Processes all CSV files within each year folder
- Converts each CSV row to a separate JSON file
- Adds metadata fields (_source_file, _table_name, _year, _processed_timestamp, _record_id)
- Maintains directory structure in the output bucket

**Source:** `s3://map-appraiser-data-raw-appraisal/{year}/*.csv`  
**Target:** `s3://map-appraiser-data-knowledge-base/appraisal-json/{year}/{table_name}/{record_id}.json`

#### Shapefile to GeoJSON ETL Job (`shapefile_to_geojson_etl.py`)
Processes shapefiles from the raw GIS data bucket and converts each feature to an individual GeoJSON file for use in a knowledge base.

**Features:**
- Automatically discovers all folders in the GIS bucket
- Processes all shapefiles within each folder (two levels deep)
- Converts each shapefile feature to a separate GeoJSON file
- Transforms coordinates to WGS84 format with 6 decimal places precision
- Validates and fixes invalid geometries using shapely's make_valid()
- Handles multiple encoding formats (UTF-8, Latin1)
- Robust error handling for geometry validation and file processing
- Adds metadata fields for tracking
- Maintains directory structure in the output bucket

**Source:** `s3://map-appraiser-data-raw-gis/{folder}/*.shp`  
**Target:** `s3://map-appraiser-data-knowledge-base/gis-geojson/{folder}/{shapefile_name}/{feature_id}.geojson`

#### CSV to Database ETL Job (`csv_to_database_etl.py`)
Loads DCAD CSV data directly into Aurora PostgreSQL database with proper data types and relationships.

**Features:**
- Automatically discovers year folders in the source bucket
- Processes all CSV files within each year folder
- Loads data into structured PostgreSQL tables with proper relationships
- Maintains referential integrity with foreign key constraints
- Clears existing year data before loading (upsert behavior)
- Supports processing all years or specific target year
- Uses AWS Secrets Manager for secure database credential management
- Handles database connections with proper error handling and cleanup
- Loads tables in correct dependency order to maintain referential integrity

**Source:** `s3://map-appraiser-data-raw-appraisal/{year}/*.csv`  
**Target:** Aurora PostgreSQL database `appraisal` schema tables

## Structure

```
glue-data-preparation/
├── README.md                              # This file
├── csv_to_json_etl.py                    # CSV to JSON conversion ETL job
├── glue-job-cloudformation.yaml          # CloudFormation template for CSV job
├── deploy.sh                             # Deployment script for CSV job
├── shapefile_to_geojson_etl.py          # Shapefile to GeoJSON conversion ETL job
├── shapefile-glue-job-cloudformation.yaml # CloudFormation template for shapefile job
├── deploy-shapefile-job.sh               # Deployment script for shapefile job
├── csv_to_database_etl.py                # CSV to PostgreSQL database ETL job
├── csv-to-database-glue-job.yaml         # CloudFormation template for database job
└── deploy-csv-to-database-job.sh         # Deployment script for database job
```

## Requirements

- AWS Glue environment
- PySpark
- boto3
- AWS credentials with appropriate Glue permissions

### Additional Python Libraries

**For Shapefile Job:**
- geopandas==0.14.1
- shapely==2.0.2
- pyproj==3.6.1
- fiona==1.9.5

**For Database Job:**
- psycopg2-binary==2.9.7
- pandas==2.0.3

## Usage

### Deployment

1. Deploy the CloudFormation stack:
   ```bash
   ./deploy.sh
   ```

2. Run the Glue job manually:
   ```bash
   aws glue start-job-run --job-name map-appraiser-csv-to-json-etl
   ```

3. Check job status:
   ```bash
   aws glue get-job-runs --job-name map-appraiser-csv-to-json-etl
   ```

### Shapefile Job Deployment

1. Deploy the CloudFormation stack:
   ```bash
   ./deploy-shapefile-job.sh
   ```

2. Run the Glue job manually:
   ```bash
   aws glue start-job-run --job-name map-appraiser-shapefile-to-geojson-etl
   ```

3. Check job status:
   ```bash
   aws glue get-job-runs --job-name map-appraiser-shapefile-to-geojson-etl
   ```

### Database ETL Job Deployment

1. Ensure the Aurora PostgreSQL database is running and accessible
2. Create or verify the database password secret in AWS Secrets Manager:
   ```bash
   aws secretsmanager create-secret --name aurora-postgres-password --description "Aurora PostgreSQL password" --secret-string "your-password"
   ```

3. Deploy the CloudFormation stack:
   ```bash
   ./deploy-csv-to-database-job.sh
   ```

4. Run the ETL job manually:
   ```bash
   # Process all years
   aws glue start-job-run --job-name dcad-csv-to-database-etl
   
   # Process specific year
   aws glue start-job-run --job-name dcad-csv-to-database-etl --arguments='{"--TARGET_YEAR":"2025"}'
   ```

5. Check job status:
   ```bash
   aws glue get-job-runs --job-name dcad-csv-to-database-etl
   ```

### Database Job Features

- **Flexible Year Processing**: Can process all available years or target a specific year
- **Data Integrity**: Clears existing year data before loading to prevent duplicates
- **Dependency Management**: Loads tables in correct order to maintain foreign key relationships
- **Error Handling**: Comprehensive error handling with rollback on failures
- **Secure Credentials**: Uses AWS Secrets Manager for database password management
- **Connection Management**: Proper database connection lifecycle management

