#!/bin/bash
# Quick script to sample S3 CSV data using AWS CLI

BUCKET="map-appraiser-data-raw-appraisal"
KEY="appraisal_notices/2025/RES_COM_APPRAISAL_NOTICE_DATA.csv"

echo "Sampling first 10 lines from s3://${BUCKET}/${KEY}"
echo "================================================================"

# Get first 10 lines (including header)
aws s3api get-object \
    --bucket "${BUCKET}" \
    --key "${KEY}" \
    --range "bytes=0-10000" \
    /dev/stdout 2>/dev/null | head -n 10

echo ""
echo "================================================================"
echo "To get more detailed analysis, run: python3 sample_appraisal_notices_data.py"