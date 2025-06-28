#!/bin/bash

# Deploy script for AWS Glue ETL Job

set -e

STACK_NAME="map-appraiser-glue-etl"
TEMPLATE_FILE="glue-job-cloudformation.yaml"
SCRIPT_FILE="csv_to_json_etl.py"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "Deploying AWS Glue ETL Job CloudFormation stack..."

# Deploy CloudFormation stack
echo "Creating/updating CloudFormation stack: $STACK_NAME"
aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION

# Get the S3 bucket name from stack outputs
echo "Getting S3 bucket name from stack outputs..."
SCRIPTS_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs[?OutputKey=='GlueScriptsBucketName'].OutputValue" \
    --output text \
    --region $REGION)

echo "Scripts bucket: $SCRIPTS_BUCKET"

# Wait a moment for bucket to be ready
sleep 5

# Upload Glue script to S3
echo "Uploading Glue script to S3..."
aws s3 cp $SCRIPT_FILE s3://$SCRIPTS_BUCKET/$SCRIPT_FILE --region $REGION

echo "Deployment complete!"
echo ""
echo "To run the Glue job manually:"
echo "aws glue start-job-run --job-name map-appraiser-csv-to-json-etl --region $REGION"
echo ""
echo "To check job status:"
echo "aws glue get-job-runs --job-name map-appraiser-csv-to-json-etl --region $REGION"