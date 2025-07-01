#!/usr/bin/env python3
"""
Script to sample data from appraisal notices CSV files in S3
This will help understand data types and formats for database schema design
"""

import boto3
import pandas as pd
from io import StringIO
import json

def sample_s3_csv(bucket, key, num_rows=5):
    """
    Read first few rows from S3 CSV file to understand data structure
    """
    # Initialize S3 client
    s3 = boto3.client('s3')
    
    try:
        # Get object from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        
        # Read CSV content
        csv_content = response['Body'].read().decode('utf-8')
        
        # Use pandas to read CSV
        df = pd.read_csv(StringIO(csv_content), nrows=num_rows)
        
        return df
    except Exception as e:
        print(f"Error reading S3 file: {e}")
        return None

def analyze_data_types(df):
    """
    Analyze data types and patterns in the dataframe
    """
    analysis = {}
    
    for column in df.columns:
        col_data = df[column]
        
        analysis[column] = {
            'sample_values': col_data.tolist(),
            'null_count': col_data.isna().sum(),
            'empty_string_count': (col_data == '').sum() if col_data.dtype == 'object' else 0,
            'unique_values': col_data.nunique(),
            'pandas_dtype': str(col_data.dtype)
        }
        
        # Try to identify date patterns
        if col_data.dtype == 'object' and 'DATE' in column.upper():
            sample = col_data.dropna().iloc[0] if not col_data.dropna().empty else None
            if sample:
                analysis[column]['sample_format'] = sample
                
    return analysis

def main():
    # S3 location
    bucket = 'map-appraiser-data-raw-appraisal'
    key = 'appraisal_notices/2025/RES_COM_APPRAISAL_NOTICE_DATA.csv'
    
    print(f"Sampling data from s3://{bucket}/{key}")
    print("=" * 80)
    
    # Read sample data
    df = sample_s3_csv(bucket, key, num_rows=5)
    
    if df is not None:
        print(f"\nShape: {df.shape}")
        print(f"Columns: {len(df.columns)}")
        
        # Show key columns
        key_columns = [
            'APPRAISAL_YR', 'ACCOUNT_NUM', 'MAILING_NUMBER',
            'TOT_VAL', 'LAND_VAL', 'APPRAISED_VAL',
            'HEARINGS_START_DATE', 'PROTEST_DEADLINE_DATE', 'HEARINGS_CONCLUDE_DATE',
            'COUNTY_HS_AMT', 'ISD_HS_AMT', 'CITY_HS_AMT',
            'COUNTY_DISABLED_AMT', 'COUNTY_VET100_AMT'
        ]
        
        print("\n" + "=" * 80)
        print("SAMPLE DATA FOR KEY COLUMNS")
        print("=" * 80)
        
        for col in key_columns:
            if col in df.columns:
                print(f"\n{col}:")
                for i, val in enumerate(df[col]):
                    print(f"  Row {i+1}: {repr(val)}")
        
        # Analyze data types
        print("\n" + "=" * 80)
        print("DATA TYPE ANALYSIS")
        print("=" * 80)
        
        analysis = analyze_data_types(df)
        
        # Focus on key columns for analysis
        for col in key_columns:
            if col in analysis:
                print(f"\n{col}:")
                print(f"  Pandas dtype: {analysis[col]['pandas_dtype']}")
                print(f"  Null count: {analysis[col]['null_count']}")
                print(f"  Empty strings: {analysis[col]['empty_string_count']}")
                if 'sample_format' in analysis[col]:
                    print(f"  Sample format: {analysis[col]['sample_format']}")
        
        # Check for specific patterns
        print("\n" + "=" * 80)
        print("DATA PATTERNS")
        print("=" * 80)
        
        # Check date columns
        date_cols = [col for col in df.columns if 'DATE' in col.upper()]
        if date_cols:
            print("\nDate columns:")
            for col in date_cols:
                sample_val = df[col].dropna().iloc[0] if not df[col].dropna().empty else 'No non-null values'
                print(f"  {col}: {sample_val}")
        
        # Check numeric columns
        numeric_cols = [col for col in df.columns if 'AMT' in col or 'VAL' in col]
        if numeric_cols:
            print("\nNumeric columns (first 5):")
            for col in numeric_cols[:5]:
                sample_val = df[col].dropna().iloc[0] if not df[col].dropna().empty else 'No non-null values'
                print(f"  {col}: {sample_val}")
        
        # Export full sample to JSON for reference
        output_file = 'appraisal_notices_sample.json'
        sample_data = df.to_dict('records')
        with open(output_file, 'w') as f:
            json.dump(sample_data, f, indent=2, default=str)
        print(f"\nFull sample data exported to: {output_file}")
        
    else:
        print("Failed to read data from S3")

if __name__ == "__main__":
    main()