# Appraisal Notices ETL Job

## Overview

This AWS Glue ETL job processes appraisal notices CSV files from S3 and loads them into the Aurora PostgreSQL database. It handles both residential/commercial and business personal property files for multiple years.

## Job Configuration

- **Job Name**: `appraisal-notices-etl`
- **Glue Version**: 4.0
- **Max Capacity**: 2.0 DPU
- **Script Location**: `s3://aws-glue-assets-006559585423-us-west-2/scripts/appraisal_notices_etl.py`
- **IAM Role**: `dcad-csv-to-database-etl-role`
- **VPC Connection**: `dcad-csv-to-database-etl-database-connection` (REQUIRED)

## Data Processing Logic

### Source Files

The job automatically discovers year folders in `s3://map-appraiser-data-raw-appraisal/appraisal_notices/` and processes:

- **Residential/Commercial File**: `RES_COM_APPRAISAL_NOTICE_DATA.csv`
  - Sets `property_type = 'RES_COM'`
  - Typically larger file (~193MB for 2025)

- **Business Personal Property File**: `BPP_APPRAISAL_NOTICE_DATA.csv`  
  - Sets `property_type = 'BPP'`
  - Typically smaller file (~18MB for 2025)

### Data Transformations

#### Column Mapping
Maps CSV column names (uppercase) to database column names (lowercase):
- `APPRAISAL_YR` → `appraisal_yr`
- `ACCOUNT_NUM` → `account_num`
- `TOT_VAL` → `tot_val`
- etc.

#### Data Type Conversions
- **Integer Fields**: `appraisal_yr`
- **Decimal Fields**: All value and exemption amount fields (DECIMAL 15,2)
- **Date Fields**: `hearings_start_date`, `protest_deadline_date`, `hearings_conclude_date`
  - Uses MM/dd/yyyy format
- **Indicator Fields**: Single character fields like `homestead_ind`

#### Data Cleaning
- Converts `1900-01-01` dates to NULL (common placeholder value)
- Handles empty strings and "NULL" text as NULL values
- Removes non-numeric characters from decimal fields
- Truncates string fields to prevent constraint violations
- Adds automatic timestamps (`created_at`, `updated_at`)

#### Property Type Handling
- Adds `property_type` column to distinguish file sources
- Enables union of both file types into single table
- Primary key includes property_type: (`appraisal_yr`, `account_num`, `property_type`)

#### Deduplication
- Checks for duplicates based on composite primary key
- Removes duplicates if found (keeps first occurrence)
- Logs duplicate statistics for monitoring

### Target Database
- **Database**: `map_appraiser`
- **Schema**: `appraisal`  
- **Table**: `appraisal_notices`
- **Connection**: Uses Glue catalog connection (`dcad-csv-to-database-etl-database-connection`)
- **VPC**: Requires VPC connection for database access in private subnet

## Deployment

### Files
- `appraisal_notices_etl.py` - Main ETL script
- `appraisal-notices-glue-job.yaml` - CloudFormation template
- `create_appraisal_notices_table.sql` - Database table creation script

### Manual Deployment
```bash
# Upload script to S3
aws s3 cp appraisal_notices_etl.py s3://aws-glue-assets-006559585423-us-west-2/scripts/

# Deploy CloudFormation stack
aws cloudformation deploy \
    --template-file appraisal-notices-glue-job.yaml \
    --stack-name appraisal-notices-etl-job \
    --capabilities CAPABILITY_IAM \
    --region us-west-2
```

**IMPORTANT**: After deployment, verify that the VPC connection `dcad-csv-to-database-etl-database-connection` is properly configured in the job.

## Job Execution

### Start Job (All Years)
```bash
aws glue start-job-run \
    --job-name appraisal-notices-etl \
    --region us-west-2
```

### Start Job (Specific Year)
```bash
aws glue start-job-run \
    --job-name appraisal-notices-etl \
    --arguments '--TARGET_YEAR=2025' \
    --region us-west-2
```

### Monitor Job
```bash
# Check job status
aws glue get-job-runs \
    --job-name appraisal-notices-etl \
    --region us-west-2 \
    --query 'JobRuns[0].[JobRunState,StartedOn,CompletedOn]' \
    --output table
```

## Expected Results

### Data Volume (2025 Example)
- **RES_COM File**: ~193 MB with ~94 columns
- **BPP File**: ~18 MB with ~94 columns (identical schema)
- **Combined**: Depends on record overlap between file types

### Processing Time
Estimated 15-30 minutes depending on data volume and number of years processed.

### Output
All records loaded into `appraisal.appraisal_notices` table with:
- RES_COM file records: `property_type = 'RES_COM'`
- BPP file records: `property_type = 'BPP'`
- Proper data types and cleaned values
- No duplicate primary keys per year

## Monitoring and Troubleshooting

### Key Metrics
- Records processed from each file type
- Years successfully processed
- Duplicates removed per year
- Data type conversion success/failure

### Common Issues
1. **VPC Connection**: CRITICAL - Ensure `dcad-csv-to-database-etl-database-connection` is added to the job
2. **File Access**: Check S3 bucket permissions and file existence for target years
3. **Schema Mismatch**: Verify CSV files maintain consistent 94-column structure
4. **Date Parsing**: Job handles MM/dd/yyyy format automatically

## Data Quality Checks

After job completion, verify:
```sql
-- Check record counts by property type and year
SELECT appraisal_yr, property_type, COUNT(*) as record_count 
FROM appraisal.appraisal_notices 
GROUP BY appraisal_yr, property_type
ORDER BY appraisal_yr, property_type;

-- Check data completeness
SELECT 
    COUNT(*) as total_records,
    COUNT(appraisal_yr) as records_with_year,
    COUNT(account_num) as records_with_account,
    COUNT(tot_val) as records_with_total_value
FROM appraisal.appraisal_notices;

-- Check exemption data availability
SELECT 
    appraisal_yr,
    COUNT(*) as total_records,
    COUNT(county_hs_amt) as homestead_exemptions,
    COUNT(county_disabled_amt) as disabled_exemptions
FROM appraisal.appraisal_notices
GROUP BY appraisal_yr
ORDER BY appraisal_yr;
```

## Schema Details

The table contains 96 total columns:
- **6 core fields**: Identifiers and main values
- **3 date fields**: Hearing and deadline dates  
- **3 indicator fields**: Penalty and homestead flags
- **82 exemption amount fields**: 6 taxing entities × 13-14 exemption types
- **2 metadata fields**: Property type and audit timestamps

This comprehensive schema captures all exemption details across all taxing entities in the Dallas County Appraisal District.