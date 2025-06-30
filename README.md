# Map Appraiser

A comprehensive data platform for analyzing property appraisal and GIS data, featuring automated ETL pipelines and a structured PostgreSQL database.

## Project Structure

```
map-appraiser/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore patterns
├── glue-data-preparation/       # AWS Glue ETL jobs for data processing
│   ├── csv_to_json_etl.py          # Convert CSV files to JSON for knowledge base
│   ├── shapefile_to_geojson_etl.py # Convert shapefiles to GeoJSON
│   ├── csv_to_database_etl.py      # Load CSV data into PostgreSQL database
│   ├── *.yaml                      # CloudFormation templates for Glue jobs
│   └── deploy-*.sh                 # Deployment scripts
└── structured-data/             # Database infrastructure and analysis
    ├── README.md                   # Detailed documentation
    ├── dcad-erd.md                 # Entity Relationship Diagram documentation
    ├── aurora-*.yaml               # CloudFormation templates for Aurora PostgreSQL
    ├── deploy-*.sh                 # Database deployment scripts
    └── sql-scripts/                # Complete database schema implementation
        ├── 01_create_schema.sql       # Schema creation
        ├── 02_create_tables.sql       # Table definitions with constraints
        ├── 03_create_foreign_keys.sql # Referential integrity
        ├── 04_create_indexes.sql      # Performance optimization
        └── deploy_database.sh         # Master deployment script
```

## Data Sources

### Raw Appraisal Data
- **Source**: `s3://map-appraiser-data-raw-appraisal/`
- **Format**: CSV files organized by year (DCAD2019_CURRENT, DCAD2020_CURRENT, etc.)
- **Content**: Dallas Central Appraisal District property data with 14 interconnected tables

### Raw GIS Data  
- **Source**: `s3://map-appraiser-data-raw-gis/`
- **Format**: Shapefiles with geographic property boundaries and features
- **Content**: Spatial data for property mapping and analysis

## Database Infrastructure

### Aurora PostgreSQL Database
- **Engine**: PostgreSQL 16.6 (Aurora Serverless v2)
- **Scaling**: 0.5 - 4 ACUs (Aurora Capacity Units)
- **Schema**: Comprehensive `appraisal` schema with 14 tables
- **Security**: VPC deployment with restricted public access

### Key Features
- **14 interconnected tables** with proper relationships and constraints
- **Foreign key integrity** ensuring data consistency
- **Performance indexes** optimized for common query patterns
- **Secure credential management** via AWS Secrets Manager

## ETL Pipelines

### 1. CSV to Database ETL
Loads structured appraisal data directly into PostgreSQL database:
- **Job Name**: `dcad-csv-to-database-etl`
- **Source**: `s3://map-appraiser-data-raw-appraisal/`
- **Target**: Aurora PostgreSQL (`map_appraiser` database)
- **Flexibility**: Process all years or target specific year
- **Data Processing**: Automatic data type conversions, deduplication
- **Robust Parsing**: Handles complex CSV files with fallback options
- **VPC Connectivity**: Secure database access through private networking

### 2. CSV to JSON ETL
Converts CSV files to individual JSON documents for knowledge base:
- **Output**: Individual JSON files per CSV row
- **Metadata**: Includes source tracking and timestamps
- **Structure**: Maintains hierarchical organization

### 3. Shapefile to GeoJSON ETL
Processes spatial data for geographic analysis:
- **Geometry validation**: Fixes invalid polygons
- **Coordinate transformation**: Converts to WGS84 format
- **Feature separation**: Individual GeoJSON files per feature

## Quick Start

### 1. Deploy Database Infrastructure
```bash
cd structured-data
./deploy-aurora-public.sh
./sql-scripts/deploy_database.sh --verify
```

### 2. Deploy ETL Jobs
```bash
cd glue-data-preparation

# Deploy CSV to database ETL
./deploy-csv-to-database-job.sh

# Deploy other ETL jobs
./deploy.sh              # CSV to JSON
./deploy-shapefile-job.sh # Shapefile to GeoJSON
```

### 3. Run ETL Jobs
```bash
# Load all data into database
aws glue start-job-run --job-name dcad-csv-to-database-etl --region us-west-2

# Process specific year only
aws glue start-job-run --job-name dcad-csv-to-database-etl --arguments='{"--TARGET_YEAR":"2019"}' --region us-west-2

# Convert data for knowledge base
aws glue start-job-run --job-name map-appraiser-csv-to-json-etl
aws glue start-job-run --job-name map-appraiser-shapefile-to-geojson-etl
```

## Usage

### Database Access
Connect to the Aurora PostgreSQL database using standard PostgreSQL tools:
```bash
psql -h map-appraiser-aurora-db-cluster.cluster-cjcydnj4gvc0.us-west-2.rds.amazonaws.com -p 5432 -U postgres -d map_appraiser
```

### Data Analysis
The structured database enables complex property analysis:
- Property valuations and trends over time
- Geographic analysis with GIS integration  
- Tax exemption and abatement tracking
- Neighborhood and jurisdiction comparisons

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)