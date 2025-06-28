#!/bin/bash

# Deploy script for AWS Glue Shapefile to GeoJSON ETL Job

set -e

STACK_NAME="map-appraiser-shapefile-glue-etl"
TEMPLATE_FILE="shapefile-glue-job-cloudformation.yaml"
SCRIPT_FILE="shapefile_to_geojson_etl.py"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "Deploying AWS Glue Shapefile to GeoJSON ETL Job CloudFormation stack..."

# Deploy CloudFormation stack
echo "Creating/updating CloudFormation stack: $STACK_NAME"
aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION

# Upload Glue script to S3
echo "Uploading Glue script to S3..."
aws s3 cp $SCRIPT_FILE s3://map-appraiser-glue-scripts/$SCRIPT_FILE --region $REGION

echo "Deployment complete!"
echo ""
echo "To run the Glue job manually:"
echo "aws glue start-job-run --job-name map-appraiser-shapefile-to-geojson-etl --region $REGION"
echo ""
echo "To check job status:"
echo "aws glue get-job-runs --job-name map-appraiser-shapefile-to-geojson-etl --region $REGION"