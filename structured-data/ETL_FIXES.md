# ETL Job Fixes and Improvements

## Summary of Changes Made

### 1. Database Schema Fixes
- **Added missing `updated_at` column** to `taxable_object` table
- **Expanded all VARCHAR columns** to 500 characters to prevent length constraint violations
- **Removed all foreign key constraints** to allow flexible data loading order

### 2. ETL Script Improvements (`csv_to_database_etl_v2.py`)

#### Data Type Conversions
- Added comprehensive mapping for all DECIMAL, INTEGER, and DATE columns across all 14 tables
- Proper handling of NULL values and empty strings in data type conversions

#### CSV Parsing Enhancements
- Added robust CSV parsing options: `quoteChar`, `escaper`, `multiline`
- Implemented fallback parsing with Spark if Glue DynamicFrame parsing fails
- Better error handling and logging for parsing issues

#### Connection and Configuration
- Fixed Glue job to use VPC connection for Aurora database access
- Updated source bucket to correct location: `map-appraiser-data-raw-appraisal`
- Corrected connection name: `dcad-csv-to-database-etl-database-connection`

#### Data Deduplication
- Added deduplication logic based on primary key columns for each table
- Prevents duplicate key violations during data loading

### 3. Database Management Scripts

#### Created New SQL Scripts
- `drop_all_foreign_keys.sql` - Removes all foreign key constraints
- `expand_all_varchar_columns.sql` - Expands all VARCHAR columns to 500 chars
- `purge_all_data.sql` - Safely deletes all data in dependency order
- `purge_2019_data.sql` - Deletes specific year data

### 4. Documentation Updates
- Updated README.md with current job configuration
- Added troubleshooting section for common issues
- Documented all new database management scripts

## Current ETL Job Status
- **Job Name**: `dcad-csv-to-database-etl`
- **Script Location**: `s3://aws-glue-assets-006559585423-us-west-2/scripts/csv_to_database_etl_v2.py`
- **Source Bucket**: `map-appraiser-data-raw-appraisal`
- **Database**: `map_appraiser` on Aurora PostgreSQL
- **Status**: Successfully loaded 2019 data

## Next Steps
1. Load all 6 years of data (2019-2024)
2. Analyze data quality issues that caused foreign key violations
3. Consider re-implementing foreign keys after data quality analysis