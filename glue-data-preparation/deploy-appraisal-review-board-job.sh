#!/bin/bash

# Deploy Appraisal Review Board ETL Glue Job
# This script uploads the ETL script to S3 and deploys the CloudFormation template

set -e

# Configuration
REGION="us-west-2"
STACK_NAME="appraisal-review-board-etl-job"
SCRIPT_BUCKET="map-appraiser-glue-scripts"
SCRIPT_KEY="appraisal_review_board_etl.py"
CLOUDFORMATION_TEMPLATE="appraisal-review-board-glue-job.yaml"

echo "=================================================="
echo "Deploying Appraisal Review Board ETL Glue Job"
echo "=================================================="

# Check if required files exist
if [ ! -f "$CLOUDFORMATION_TEMPLATE" ]; then
    echo "❌ Error: CloudFormation template $CLOUDFORMATION_TEMPLATE not found"
    exit 1
fi

if [ ! -f "appraisal_review_board_etl.py" ]; then
    echo "❌ Error: ETL script appraisal_review_board_etl.py not found"
    exit 1
fi

# Upload ETL script to S3
echo "📤 Uploading ETL script to S3..."
aws s3 cp appraisal_review_board_etl.py s3://$SCRIPT_BUCKET/$SCRIPT_KEY --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ ETL script uploaded successfully"
else
    echo "❌ Failed to upload ETL script"
    exit 1
fi

# Deploy CloudFormation stack
echo "🚀 Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file $CLOUDFORMATION_TEMPLATE \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        ScriptLocation="s3://$SCRIPT_BUCKET/$SCRIPT_KEY" \
    --capabilities CAPABILITY_IAM \
    --region $REGION \
    --no-fail-on-empty-changeset

if [ $? -eq 0 ]; then
    echo "✅ CloudFormation stack deployed successfully"
    
    # Get stack outputs
    echo ""
    echo "📋 Stack Information:"
    echo "-------------------"
    aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
        --output table
    
    echo ""
    echo "🎯 Glue Job Details:"
    echo "-------------------"
    JOB_NAME=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --region $REGION \
        --query 'Stacks[0].Outputs[?OutputKey==`JobName`].OutputValue' \
        --output text)
    
    echo "Job Name: $JOB_NAME"
    echo "Script Location: s3://$SCRIPT_BUCKET/$SCRIPT_KEY"
    echo "Region: $REGION"
    
    echo ""
    echo "▶️  To start the job, run:"
    echo "aws glue start-job-run --job-name $JOB_NAME --region $REGION"
    
    echo ""
    echo "📊 To monitor the job, run:"
    echo "aws glue get-job-runs --job-name $JOB_NAME --region $REGION --query 'JobRuns[0].[JobRunState,StartedOn,CompletedOn]' --output table"
    
else
    echo "❌ Failed to deploy CloudFormation stack"
    exit 1
fi

echo ""
echo "=================================================="
echo "✅ Deployment completed successfully!"
echo "=================================================="