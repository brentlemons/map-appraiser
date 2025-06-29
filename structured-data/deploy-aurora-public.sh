#!/bin/bash

# Deploy script for Aurora Serverless PostgreSQL database with public access

set -e

STACK_NAME="map-appraiser-aurora-db"
TEMPLATE_FILE="aurora-serverless-public.yaml"
REGION="us-west-2"

# Check if required AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is required but not installed. Please install it first."
    exit 1
fi

# Get current public IP
CURRENT_IP=$(curl -s https://checkip.amazonaws.com)
if [ -z "$CURRENT_IP" ]; then
    echo "Error: Could not determine current public IP address"
    exit 1
fi

echo "Updating Aurora Serverless PostgreSQL database with public access..."
echo "Region: $REGION"
echo "Stack: $STACK_NAME"
echo "Allowing access from IP: $CURRENT_IP/32"

# Prompt for database password
read -s -p "Enter master password for database (8-128 characters): " DB_PASSWORD
echo

if [ ${#DB_PASSWORD} -lt 8 ]; then
    echo "Error: Password must be at least 8 characters long"
    exit 1
fi

# Deploy CloudFormation stack
echo "Updating CloudFormation stack..."
aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        MasterUserPassword=$DB_PASSWORD \
        AllowedCIDR=$CURRENT_IP/32 \
    --capabilities CAPABILITY_IAM \
    --region $REGION

echo "Deployment completed successfully!"
echo ""
echo "Getting connection information..."

# Get outputs
ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs[?OutputKey=='ClusterEndpoint'].OutputValue" \
    --output text \
    --region $REGION)

SECRET_ARN=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs[?OutputKey=='DatabaseSecretArn'].OutputValue" \
    --output text \
    --region $REGION)

echo "Database Information:"
echo "  Endpoint: $ENDPOINT"
echo "  Port: 5432"
echo "  Database: map_appraiser"
echo "  Username: postgres"
echo "  Allowed IP: $CURRENT_IP/32"
echo "  Secrets Manager ARN: $SECRET_ARN"
echo ""
echo "Connection command:"
echo "  psql -h $ENDPOINT -p 5432 -U postgres -d map_appraiser"
echo ""
echo "To retrieve password from Secrets Manager:"
echo "  aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region $REGION"
echo ""
echo "SECURITY NOTE: Database is now publicly accessible from your IP address only."