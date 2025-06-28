#!/bin/bash

# Deploy script for Aurora Serverless PostgreSQL database

set -e

STACK_NAME="map-appraiser-aurora-db"
TEMPLATE_FILE="aurora-serverless-cloudformation.yaml"
REGION="us-west-2"

# Check if required AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is required but not installed. Please install it first."
    exit 1
fi

echo "Deploying Aurora Serverless PostgreSQL database..."
echo "Region: $REGION"
echo "Stack: $STACK_NAME"

# Get default VPC and subnets for the region
echo "Getting default VPC and subnets for region $REGION..."

DEFAULT_VPC=$(aws ec2 describe-vpcs \
    --filters "Name=is-default,Values=true" \
    --query "Vpcs[0].VpcId" \
    --output text \
    --region $REGION)

if [ "$DEFAULT_VPC" = "None" ] || [ -z "$DEFAULT_VPC" ]; then
    echo "No default VPC found in region $REGION. Please specify VPC and subnet IDs manually."
    exit 1
fi

echo "Found default VPC: $DEFAULT_VPC"

# Get subnets in different AZs
SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$DEFAULT_VPC" \
    --query "Subnets[*].SubnetId" \
    --output text \
    --region $REGION)

SUBNET_ARRAY=($SUBNETS)
if [ ${#SUBNET_ARRAY[@]} -lt 2 ]; then
    echo "Error: Need at least 2 subnets in different AZs. Found: ${#SUBNET_ARRAY[@]}"
    exit 1
fi

SUBNET_LIST=$(echo $SUBNETS | tr ' ' ',')
echo "Using subnets: $SUBNET_LIST"

# Prompt for database password
read -s -p "Enter master password for database (8-128 characters): " DB_PASSWORD
echo

if [ ${#DB_PASSWORD} -lt 8 ]; then
    echo "Error: Password must be at least 8 characters long"
    exit 1
fi

# Deploy CloudFormation stack
echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --parameter-overrides \
        VpcId=$DEFAULT_VPC \
        SubnetIds=$SUBNET_LIST \
        MasterUserPassword=$DB_PASSWORD \
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
echo "  Secrets Manager ARN: $SECRET_ARN"
echo ""
echo "Connection command:"
echo "  psql -h $ENDPOINT -p 5432 -U postgres -d map_appraiser"
echo ""
echo "To retrieve password from Secrets Manager:"
echo "  aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region $REGION"