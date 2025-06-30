# Account Data Export Tool

## Overview

The `export_account_data.py` script creates comprehensive JSON exports for any account number in the DCAD property appraisal database. It follows the table hierarchy and includes data from all related tables.

## Features

✅ **Complete Data Export**: Includes all direct and secondary dependencies  
✅ **Flexible Year Filtering**: Export specific year or all available years  
✅ **JSON Format**: Structured, machine-readable output  
✅ **Summary Statistics**: Includes data overview and counts  
✅ **Proper Data Types**: Handles decimals, dates, and timestamps correctly  

## Installation

```bash
# Create and activate virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Ensure AWS credentials are configured for Secrets Manager access
aws configure
```

### Alternative Installation (System-wide)
```bash
# If you prefer system-wide installation
pip install --break-system-packages psycopg2-binary boto3
```

## Usage

### Export All Years for an Account
```bash
python export_account_data.py --account-num 00000100012000000 --pretty
```

### Export Specific Year
```bash
python export_account_data.py --account-num 00000100012000000 --year 2024 --pretty
```

### Export to File
```bash
python export_account_data.py --account-num 00000100012000000 --output account_data.json --pretty
```

### Command Line Options

- `--account-num` (required): Account number to export
- `--year`: Specific year to export (optional)
- `--all-years`: Export all available years (default behavior)
- `--output`: Output file path (default: stdout)
- `--pretty`: Pretty print JSON with indentation

## Data Structure

The exported JSON follows this hierarchical structure:

```json
{
  "account_number": "00000100012000000",
  "export_timestamp": "2024-06-30T12:00:00",
  "year_filter": null,
  "summary": {
    "total_records": 156,
    "years_available": [2019, 2020, 2021, 2022, 2023, 2024, 2025],
    "has_residential_details": true,
    "has_commercial_details": false,
    "taxable_objects_count": 7,
    "land_parcels_count": 7,
    "exemption_records": 14
  },
  "data": {
    "account_info": [...],
    "account_apprl_year": [...],
    "taxable_objects": [...],
    "land": [...],
    "exemptions": {
      "applied_std_exempt": [...],
      "acct_exempt_value": [...],
      "abatement_exempt": [...],
      "freeport_exemption": [...],
      "total_exemption": [...]
    },
    "other": {
      "multi_owner": [...],
      "account_tif": [...]
    },
    "property_details": {
      "res_detail": [...],
      "com_detail": [...],
      "res_addl": [...]
    }
  }
}
```

## Table Coverage

### Primary Table
- `account_info` - Master property and owner information

### Direct Dependencies (Tier 1)
- `account_apprl_year` - Annual appraisal values
- `taxable_object` - Structures/improvements 
- `land` - Land parcels
- `applied_std_exempt` - Standard exemptions
- `acct_exempt_value` - Exemption values
- `abatement_exempt` - Tax abatements
- `freeport_exemption` - Freeport exemptions  
- `total_exemption` - Total exemption tracking
- `multi_owner` - Multiple ownership
- `account_tif` - Tax increment financing

### Secondary Dependencies (Tier 2)
- `res_detail` - Residential property details
- `com_detail` - Commercial property details
- `res_addl` - Additional residential improvements

## Example Output

```bash
$ python export_account_data.py --account-num 00000100012000000 --year 2024 --pretty

🔍 Exporting data for account: 00000100012000000
📅 Year filter: 2024
✅ Found account data for 1 year(s)
📊 Export summary:
   Total records: 23
   Years available: [2024]
   Taxable objects: 1
   Land parcels: 1

==================================================
JSON OUTPUT:
==================================================
{
  "account_number": "00000100012000000",
  "export_timestamp": "2024-06-30T15:30:45.123456",
  "year_filter": 2024,
  "summary": {
    "total_records": 23,
    "years_available": [2024],
    "has_residential_details": true,
    "has_commercial_details": false,
    "has_additional_improvements": true,
    "taxable_objects_count": 1,
    "land_parcels_count": 1,
    "exemption_records": 3
  },
  "data": {
    // ... complete hierarchical data structure
  }
}
```

## Error Handling

The script includes comprehensive error handling for:
- Database connection issues
- Invalid account numbers
- Missing data for specified years
- AWS credential problems
- File I/O errors

## Requirements

- Python 3.6+
- AWS credentials with Secrets Manager access
- Network access to Aurora PostgreSQL cluster
- Dependencies: `psycopg2-binary`, `boto3`