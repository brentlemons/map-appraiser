# Structured Data Analysis

This directory contains documentation and analysis of the structured appraisal data stored in the `map-appraiser-data-raw-appraisal` S3 bucket.

## Overview

The appraisal data is organized by year, with each year containing CSV exports from a relational database system. The data represents property appraisal information from the Dallas Central Appraisal District (DCAD).

## Data Structure

### S3 Bucket Organization
```
map-appraiser-data-raw-appraisal/
├── DCAD2019_CURRENT/
├── DCAD2020_CURRENT/
├── DCAD2021_CURRENT/
├── DCAD2022_CURRENT/
├── DCAD2023_CURRENT/
├── DCAD2024_CURRENT/
├── DCAD2025_CURRENT/
│   ├── ACCOUNT_INFO.CSV
│   ├── ACCOUNT_APPRL_YEAR.CSV
│   ├── RES_DETAIL.CSV
│   ├── COM_DETAIL.CSV
│   ├── LAND.CSV
│   └── ... (14 CSV files total)
├── appraisal_review_board/
│   ├── appraisal_review_board_current.csv
│   └── appraisal_review_board_archive.csv
└── appraisal_notices/
    ├── 2025/
    │   ├── RES_COM_APPRAISAL_NOTICE_DATA.csv
    │   └── BPP_APPRAISAL_NOTICE_DATA.csv
    └── [other years...]
```

### Database Schema

The database consists of 16 interconnected tables that track:
- Property ownership and addresses
- Annual appraisal values
- Residential and commercial property details
- Land parcels
- Tax exemptions and abatements
- Tax Increment Financing (TIF) zones
- Property tax protests and appeals
- Appraisal notices with detailed exemption breakdowns

For a detailed Entity Relationship Diagram and table descriptions, see [DCAD ERD Documentation](./dcad-erd.md).

## Key Tables

### Core Property Data
- **ACCOUNT_INFO**: Master property and owner information
- **ACCOUNT_APPRL_YEAR**: Annual appraisal values and taxable values by jurisdiction

### Property Details
- **RES_DETAIL**: Detailed residential property characteristics (38 columns)
- **COM_DETAIL**: Detailed commercial property characteristics (30 columns)
- **LAND**: Land parcel information
- **RES_ADDL**: Additional residential improvements (garages, pools, etc.)

### Ownership
- **MULTI_OWNER**: Handles properties with multiple owners

### Exemptions
- **APPLIED_STD_EXEMPT**: Standard exemptions (homestead, over-65, disabled, veteran)
- **ACCT_EXEMPT_VALUE**: Exemption values by type and jurisdiction
- **ABATEMENT_EXEMPT**: Tax abatements
- **FREEPORT_EXEMPTION**: Freeport exemptions
- **TOTAL_EXEMPTION**: Total exemption tracking

### Other
- **TAXABLE_OBJECT**: Links accounts to specific buildings/improvements
- **ACCOUNT_TIF**: Tax Increment Financing zone information

### Property Tax Protests and Notices
- **APPRAISAL_REVIEW_BOARD**: Property tax protest tracking through ARB process
- **APPRAISAL_NOTICES**: Annual appraisal notices with detailed exemption amounts by taxing entity

## Data Characteristics

### Common Key Fields
- **ACCOUNT_NUM**: Unique property identifier used across all tables
- **APPRAISAL_YR**: Year of appraisal (part of composite key in most tables)
- **TAX_OBJ_ID**: Links specific structures/improvements to accounts

### Jurisdiction Columns
Many tables include jurisdiction-specific columns for:
- CITY (Municipal)
- COUNTY
- ISD (Independent School District)
- HOSPITAL
- COLLEGE
- SPECIAL/SPCL (Special Districts)

## Database Infrastructure

### Aurora Serverless PostgreSQL Database
A development/testing Aurora Serverless PostgreSQL database has been deployed in AWS us-west-2:

- **Database Name**: `map_appraiser`
- **Engine**: PostgreSQL 15.4 (Aurora Serverless v2)
- **Scaling**: 0.5 - 4 ACUs (Aurora Capacity Units)
- **Security**: VPC deployment with public access restricted to specific IP addresses
- **Backup**: 7-day retention with automated backups
- **Access**: Configured for public access with security group restrictions

#### Connection Information
- **Endpoint**: `map-appraiser-aurora-db-cluster.cluster-cjcydnj4gvc0.us-west-2.rds.amazonaws.com`
- **Port**: 5432
- **Username**: postgres
- **Database**: map_appraiser
- **Access**: Public access enabled, restricted by security group to authorized IPs only

#### CloudFormation Templates
- `aurora-serverless-simple.yaml` - Basic deployment with VPC creation (private access only)
- `aurora-serverless-public.yaml` - Deployment with public access configuration
- `aurora-update-public.yaml` - Update template for enabling public access
- `aurora-serverless-cloudformation.yaml` - Template for existing VPC deployment
- `deploy-aurora-simple.sh` - Deployment script for basic setup
- `deploy-aurora-public.sh` - Deployment script with public access
- `deploy-aurora-update.sh` - Script to update existing deployment for public access
- `deploy-aurora.sh` - Alternative deployment script for existing VPC

## Files in This Directory

### Documentation
- `README.md` - This file
- `dcad-erd.md` - Detailed Entity Relationship Diagram and table documentation
- `dcad_table_headers.md` - Raw column headers from each CSV file
- `ETL_FIXES.md` - Comprehensive documentation of ETL fixes and improvements
- `DATA_QUALITY_ANALYSIS.md` - Detailed analysis of data quality issues and foreign key violations
- `APPRAISAL_REVIEW_BOARD_ANALYSIS.md` - Analysis of property tax protest data structure and business process
- `TABLE_HIERARCHY_ANALYSIS.md` - Complete table relationship hierarchy

### Database Infrastructure
- `aurora-serverless-simple.yaml` - Basic Aurora deployment with VPC (private access)
- `aurora-serverless-public.yaml` - Aurora deployment with public access enabled
- `aurora-update-public.yaml` - Template to update existing deployment for public access
- `aurora-serverless-cloudformation.yaml` - Aurora deployment for existing VPC
- `deploy-aurora-simple.sh` - Basic deployment script
- `deploy-aurora-public.sh` - Public access deployment script
- `deploy-aurora-update.sh` - Update script for public access
- `deploy-aurora.sh` - Deployment script for existing VPC

### Database Schema
- `sql-scripts/` - Complete database schema implementation
  - `01_create_schema.sql` - Creates appraisal schema
  - `02_create_tables.sql` - Creates all 14 tables with primary keys (updated with `updated_at` column for taxable_object)
  - `create_appraisal_review_board_table.sql` - Creates appraisal_review_board table for protest tracking
  - `create_appraisal_notices_table.sql` - Creates appraisal_notices table for notice data with detailed exemption amounts
  - `03_create_foreign_keys.sql` - Establishes referential integrity
  - `04_create_indexes.sql` - Performance optimization indexes
  - `05_expand_varchar_columns.sql` - Expands specific VARCHAR columns for data compatibility
  - `06_analyze_varchar_lengths.sql` - Analyzes actual data lengths in VARCHAR columns
  - `07_optimize_varchar_sizes.sql` - Optimizes VARCHAR sizes based on actual data
  - `expand_all_varchar_columns.sql` - Expands ALL VARCHAR columns to 500 chars
  - `drop_all_foreign_keys.sql` - Removes all foreign key constraints
  - `restore_foreign_keys.sql` - Restores all 13 foreign key constraints
  - `clean_orphaned_data.sql` - Cleans orphaned records for referential integrity
  - `complete_foreign_keys.sql` - Completes foreign key implementation with extended timeout
  - `complete_foreign_keys_fast.sql` - Fast foreign key addition without validation
  - `purge_2019_data.sql` - Purges specific year data
  - `purge_all_data.sql` - Purges all data in dependency order
  - `deploy_database.sh` - Master deployment script with verification
  - `README.md` - Detailed SQL scripts documentation

## Important Notes

### Port Configuration
All CloudFormation templates now explicitly specify `Port: 5432` for the Aurora PostgreSQL cluster. Without this explicit configuration, Aurora may default to port 3306 (MySQL's default) instead of PostgreSQL's standard port 5432.

### Security Configuration
The database is configured with:
- Public accessibility enabled but restricted by security group rules
- Access allowed only from specific IP addresses (configured during deployment)
- VPC internal access on port 5432
- All data encrypted at rest

## ETL Integration

### CSV to Database ETL Job
A complete ETL pipeline has been implemented to load CSV data from S3 directly into the Aurora PostgreSQL database:

- **Location**: `../glue-data-preparation/csv_to_database_etl.py`
- **CloudFormation**: `../glue-data-preparation/csv-to-database-glue-job.yaml`
- **Deployment**: `../glue-data-preparation/deploy-csv-to-database-job.sh`

**Features:**
- Automatically processes all available years or targets specific year  
- Comprehensive data type conversions (dates, decimals, integers)
- Deduplication based on primary keys to prevent duplicates
- Robust CSV parsing with fallback options for problematic files
- VPC connectivity for secure database access
- Uses AWS Secrets Manager for secure database credential management
- All 13 foreign key constraints enforced for data integrity

**Current Status:**
- ✅ Successfully loaded all 7 years of data (2019-2025)
- ✅ Over 6 million records imported
- ✅ All foreign key constraints implemented
- ✅ Data quality issues identified and resolved (0.02% orphaned records cleaned)

**Usage:**
```bash
# Deploy the ETL job
cd ../glue-data-preparation
./deploy-csv-to-database-job.sh

# Run for all years
aws glue start-job-run --job-name dcad-csv-to-database-etl --region us-west-2

# Run for specific year
aws glue start-job-run --job-name dcad-csv-to-database-etl --arguments='{"--TARGET_YEAR":"2019"}' --region us-west-2
```

## Usage Notes

1. The first row of each CSV contains column headers
2. Data relationships are maintained through ACCOUNT_NUM and APPRAISAL_YR keys
3. Property details are split between residential (RES_DETAIL) and commercial (COM_DETAIL) tables
4. Multiple exemption tables allow for complex tax exemption scenarios
5. The TAXABLE_OBJECT table is crucial for linking property components
6. Database credentials are stored in AWS Secrets Manager for secure access
7. ETL job automatically discovers and processes new year folders as they are added to S3