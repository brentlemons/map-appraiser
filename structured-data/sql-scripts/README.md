# DCAD Appraisal Database SQL Scripts

This directory contains SQL scripts to create the complete DCAD appraisal database schema based on the Entity Relationship Diagram analysis.

## Quick Start

```bash
# Set database password
export PGPASSWORD='your-database-password'

# Deploy the complete schema
./deploy_database.sh --verify
```

## Scripts Overview

### 1. Schema Creation (`01_create_schema.sql`)
- Creates the `appraisal` schema
- Sets appropriate permissions
- Configures search path

### 2. Table Creation (`02_create_tables.sql`)
- Creates all 14 tables with appropriate data types
- Defines primary key constraints
- Adds timestamp columns for audit trails
- Includes comprehensive column definitions based on CSV analysis

### 3. Foreign Keys (`03_create_foreign_keys.sql`)
- Establishes referential integrity between tables
- Implements cascade delete for data consistency
- Follows the ERD relationship model

### 4. Performance Indexes (`04_create_indexes.sql`)
- Creates indexes for common query patterns
- Optimizes for property searches, value analysis, and exemption queries
- Includes composite indexes for complex queries

## Database Tables

### Core Tables
- **account_info** - Master property and owner information
- **account_apprl_year** - Annual appraisal values and taxable values
- **taxable_object** - Links accounts to specific buildings/improvements

### Property Details
- **res_detail** - Residential property characteristics (38 columns)
- **com_detail** - Commercial property characteristics (30 columns) 
- **land** - Land parcel information and values
- **res_addl** - Additional residential improvements

### Ownership
- **multi_owner** - Multiple ownership scenarios

### Exemptions
- **applied_std_exempt** - Standard exemptions (homestead, over-65, disabled, veteran)
- **acct_exempt_value** - Exemption values by type and jurisdiction
- **abatement_exempt** - Tax abatements with effective/expiration dates
- **freeport_exemption** - Freeport exemption tracking
- **total_exemption** - Total exemption markers

### Special Districts
- **account_tif** - Tax Increment Financing zones

## Deployment Script Features

The `deploy_database.sh` script provides:

- **Automatic psql detection** - Finds psql in standard locations
- **Connection testing** - Verifies database connectivity before deployment
- **Error handling** - Stops on first error with clear messages
- **Verification mode** - Optional post-deployment verification
- **Dry run mode** - Preview what would be executed
- **Colored output** - Easy-to-read status messages

## Usage Examples

### Basic Deployment
```bash
export PGPASSWORD='your-password'
./deploy_database.sh
```

### With Verification
```bash
export PGPASSWORD='your-password'
./deploy_database.sh --verify
```

### Dry Run (Preview)
```bash
./deploy_database.sh --dry-run
```

### Custom Database Connection
```bash
export DB_HOST='your-host'
export DB_PORT='5432'
export DB_NAME='your-database'
export DB_USER='your-user'
export PGPASSWORD='your-password'
./deploy_database.sh --verify
```

## Manual Execution

You can also run individual scripts manually:

```bash
# Using system psql
psql -h your-host -p 5432 -U postgres -d map_appraiser -f 01_create_schema.sql

# Using specific psql path
/opt/homebrew/Cellar/libpq/17.5/bin/psql -h your-host -p 5432 -U postgres -d map_appraiser -f 01_create_schema.sql
```

## Key Features

### Data Types
- Appropriate PostgreSQL data types for each column
- Decimal precision for monetary values
- Proper date/timestamp handling
- VARCHAR sizing based on actual data analysis

### Constraints
- Primary keys on all tables
- Foreign key relationships with cascade deletes
- NOT NULL constraints on key fields

### Performance
- Strategic indexes on frequently queried columns
- Composite indexes for complex query patterns
- Partial indexes for filtered queries
- Include columns for covering indexes

### Audit Trail
- `created_at` and `updated_at` timestamps on all tables
- Automatic timestamp defaults

## Prerequisites

- PostgreSQL client tools (psql)
- Database connection credentials
- Aurora PostgreSQL 16.6 database instance