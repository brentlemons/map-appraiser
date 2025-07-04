# Appraisal Review Board ETL Job

## Overview

This AWS Glue ETL job processes appraisal review board CSV files from S3 and loads them into the Aurora PostgreSQL database. It handles both current and archive files, setting the `active` flag appropriately based on the file type.

## Job Configuration

- **Job Name**: `appraisal-review-board-etl`
- **Glue Version**: 4.0
- **Max Capacity**: 2.0 DPU
- **Script Location**: `s3://aws-glue-assets-006559585423-us-west-2/scripts/appraisal_review_board_etl_v3.py`
- **IAM Role**: `dcad-csv-to-database-etl-role`
- **VPC Connection**: `dcad-csv-to-database-etl-database-connection` (REQUIRED)

## Data Processing Logic

### Source Files
- **Current File**: `s3://map-appraiser-data-raw-appraisal/appraisal_review_board/appraisal_review_board_current.csv`
  - Sets `active = true` for all records
  - 55 columns (missing archive-specific columns)

- **Archive File**: `s3://map-appraiser-data-raw-appraisal/appraisal_review_board/appraisal_review_board_archive.csv`
  - Sets `active = false` for all records  
  - 57 columns (includes all columns)

### Data Transformations

#### Column Mapping
Maps CSV column names (uppercase) to database column names (lowercase):
- `PROTEST_YR` → `protest_yr`
- `ACCOUNT_NUM` → `account_num`
- `MAIL_NAME` → `mail_name`
- etc.

#### Data Type Conversions
- **Integer Fields**: `protest_yr`
- **Decimal Fields**: `notified_val`, `new_val`, `panel_val` (DECIMAL 15,2)
- **Timestamp Fields**: `protest_sent_dt`, `protest_rcvd_dt`, `consent_dt`, `reinspect_dt`, `resolved_dt`
  - Handles nanosecond precision by truncating to microseconds for PostgreSQL compatibility
- **Date Fields**: `prev_hearing_dt`, `hearing_dt`, `cert_mail_dt`
  - Extracts date portion from timestamp values

#### Data Cleaning
- Converts `1900-01-01` dates to NULL (common placeholder value)
- Handles empty strings and "NULL" text as NULL values
- Removes non-numeric characters from decimal fields
- Truncates string fields to prevent constraint violations
- Adds automatic timestamps (`created_at`, `updated_at`)

#### Missing Column Handling
- For current file: Adds archive-specific columns (`value_protest_ind`, `name`, `taxpayer_rep_id`) as NULL
- For archive file: Ensures all expected columns exist
- Maintains consistent column order for union operation

#### Duplicate Analysis and Deduplication
- Analyzes duplicates before removal showing:
  - Count of duplicate (protest_yr, account_num) combinations
  - Source distribution (active vs archive files)
  - Duplicate count by year
- Removes duplicates based on primary key (`protest_yr`, `account_num`)
- Keeps active (current) records when duplicates exist between files

### Target Database
- **Database**: `map_appraiser`
- **Schema**: `appraisal`  
- **Table**: `appraisal_review_board`
- **Connection**: Uses Glue catalog connection (`dcad-csv-to-database-etl-database-connection`)
- **VPC**: Requires VPC connection for database access in private subnet

## Deployment

### Files
- `appraisal_review_board_etl_v3.py` - Main ETL script
- `appraisal-review-board-glue-job.yaml` - CloudFormation template

### Manual Deployment
```bash
# Upload script to S3
aws s3 cp appraisal_review_board_etl_v3.py s3://aws-glue-assets-006559585423-us-west-2/scripts/

# Deploy CloudFormation stack
aws cloudformation deploy \
    --template-file appraisal-review-board-glue-job.yaml \
    --stack-name appraisal-review-board-etl-job \
    --capabilities CAPABILITY_IAM \
    --region us-west-2
```

**IMPORTANT**: After deployment, manually add the VPC connection `dcad-csv-to-database-etl-database-connection` to the job in the AWS Glue console under Job Details > Connections.

## Job Execution

### Start Job
```bash
aws glue start-job-run \
    --job-name appraisal-review-board-etl \
    --region us-west-2
```

### Monitor Job
```bash
# Check job status
aws glue get-job-runs \
    --job-name appraisal-review-board-etl \
    --region us-west-2 \
    --query 'JobRuns[0].[JobRunState,StartedOn,CompletedOn]' \
    --output table

# Get detailed job run information
aws glue get-job-run \
    --job-name appraisal-review-board-etl \
    --run-id <RUN_ID> \
    --region us-west-2
```

### View Logs
CloudWatch log groups:
- `/aws-glue/jobs/logs-v2` - Job execution logs
- `/aws-glue/jobs/error` - Error logs
- `/aws-glue/jobs/output` - Output logs

## Expected Results

### Data Volume
- **Current File**: ~148.7 MB, ~55 columns
- **Archive File**: ~708.9 MB, ~57 columns (4.8x larger)
- **Combined**: Depends on overlap between files

### Processing Time
Estimated 15-30 minutes depending on data volume and processing complexity.

### Output
All records loaded into `appraisal.appraisal_review_board` table with:
- Current file records: `active = true`
- Archive file records: `active = false`
- Proper data types and cleaned values
- No duplicate primary keys

## Error Handling

The job includes comprehensive error handling for:
- Database connection issues
- Invalid CSV formatting
- Data type conversion errors
- Missing or malformed files
- AWS credential problems

## Monitoring and Troubleshooting

### Key Metrics
- Records processed from each file
- Duplicates removed
- Data type conversion errors
- Database write success/failure

### Common Issues
1. **VPC Connection**: CRITICAL - Ensure `dcad-csv-to-database-etl-database-connection` is added to the job
2. **Database Access**: Verify security groups and database accessibility in VPC
3. **File Access**: Check S3 bucket permissions and file existence
4. **Timestamp Parsing**: Job handles nanosecond precision timestamps automatically

## Data Quality Checks

After job completion, verify:
```sql
-- Check record counts by file type
SELECT active, COUNT(*) as record_count 
FROM appraisal.appraisal_review_board 
GROUP BY active;

-- Check data completeness
SELECT 
    COUNT(*) as total_records,
    COUNT(protest_yr) as records_with_year,
    COUNT(account_num) as records_with_account,
    COUNT(notified_val) as records_with_values
FROM appraisal.appraisal_review_board;

-- Check date ranges
SELECT 
    MIN(protest_yr) as min_year,
    MAX(protest_yr) as max_year,
    COUNT(DISTINCT protest_yr) as unique_years
FROM appraisal.appraisal_review_board;
```