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

## Structure

```
glue-data-preparation/
├── README.md                              # This file
├── csv_to_json_etl.py                    # CSV to JSON conversion ETL job
├── glue-job-cloudformation.yaml          # CloudFormation template for CSV job
├── deploy.sh                             # Deployment script for CSV job
├── shapefile_to_geojson_etl.py          # Shapefile to GeoJSON conversion ETL job
├── shapefile-glue-job-cloudformation.yaml # CloudFormation template for shapefile job
└── deploy-shapefile-job.sh               # Deployment script for shapefile job
```

## Requirements

- AWS Glue environment
- PySpark
- boto3
- AWS credentials with appropriate Glue permissions

### Additional Python Libraries (for Shapefile Job)
- geopandas==0.14.1
- shapely==2.0.2
- pyproj==3.6.1
- fiona==1.9.5

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

## Development

When developing new ETL jobs:
1. Follow PySpark best practices
2. Include proper error handling
3. Add logging for debugging
4. Document data sources and destinations
5. Include sample configurations

## Testing

Local testing can be done using:
- AWS Glue Docker images
- PySpark local mode
- Unit tests for transformation logic