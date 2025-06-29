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
└── DCAD2025_CURRENT/
    ├── ACCOUNT_INFO.CSV
    ├── ACCOUNT_APPRL_YEAR.CSV
    ├── RES_DETAIL.CSV
    ├── COM_DETAIL.CSV
    ├── LAND.CSV
    └── ... (14 CSV files total)
```

### Database Schema

The database consists of 14 interconnected tables that track:
- Property ownership and addresses
- Annual appraisal values
- Residential and commercial property details
- Land parcels
- Tax exemptions and abatements
- Tax Increment Financing (TIF) zones

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

### Database Infrastructure
- `aurora-serverless-simple.yaml` - Basic Aurora deployment with VPC (private access)
- `aurora-serverless-public.yaml` - Aurora deployment with public access enabled
- `aurora-update-public.yaml` - Template to update existing deployment for public access
- `aurora-serverless-cloudformation.yaml` - Aurora deployment for existing VPC
- `deploy-aurora-simple.sh` - Basic deployment script
- `deploy-aurora-public.sh` - Public access deployment script
- `deploy-aurora-update.sh` - Update script for public access
- `deploy-aurora.sh` - Deployment script for existing VPC

## Important Notes

### Port Configuration
All CloudFormation templates now explicitly specify `Port: 5432` for the Aurora PostgreSQL cluster. Without this explicit configuration, Aurora may default to port 3306 (MySQL's default) instead of PostgreSQL's standard port 5432.

### Security Configuration
The database is configured with:
- Public accessibility enabled but restricted by security group rules
- Access allowed only from specific IP addresses (configured during deployment)
- VPC internal access on port 5432
- All data encrypted at rest

## Usage Notes

1. The first row of each CSV contains column headers
2. Data relationships are maintained through ACCOUNT_NUM and APPRAISAL_YR keys
3. Property details are split between residential (RES_DETAIL) and commercial (COM_DETAIL) tables
4. Multiple exemption tables allow for complex tax exemption scenarios
5. The TAXABLE_OBJECT table is crucial for linking property components
6. Database credentials are stored in AWS Secrets Manager for secure access