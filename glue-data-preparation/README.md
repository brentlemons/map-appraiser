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

## Structure

```
glue-data-preparation/
├── README.md                    # This file
├── csv_to_json_etl.py          # CSV to JSON conversion ETL job
├── glue-job-cloudformation.yaml # CloudFormation template for deployment
└── deploy.sh                    # Deployment script
```

## Requirements

- AWS Glue environment
- PySpark
- boto3
- AWS credentials with appropriate Glue permissions

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