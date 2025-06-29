#!/bin/bash

# =====================================================
# Deploy DCAD CSV to Database ETL Job
# Creates AWS Glue job to load CSV data into Aurora PostgreSQL
# =====================================================

set -e

# Configuration
STACK_NAME="dcad-csv-to-database-etl"
TEMPLATE_FILE="csv-to-database-glue-job.yaml"
SCRIPT_FILE="csv_to_database_etl.py"
REGION="us-west-2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Please install AWS CLI."
        exit 1
    fi
    
    # Check template file exists
    if [ ! -f "$SCRIPT_DIR/$TEMPLATE_FILE" ]; then
        log_error "Template file not found: $TEMPLATE_FILE"
        exit 1
    fi
    
    # Check script file exists
    if [ ! -f "$SCRIPT_DIR/$SCRIPT_FILE" ]; then
        log_error "ETL script file not found: $SCRIPT_FILE"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        log_error "AWS credentials not configured. Please run 'aws configure'."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Create S3 bucket for Glue assets if it doesn't exist
create_glue_assets_bucket() {
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    BUCKET_NAME="aws-glue-assets-${ACCOUNT_ID}-${REGION}"
    
    log_info "Checking Glue assets bucket: $BUCKET_NAME"
    
    if ! aws s3 ls "s3://$BUCKET_NAME" > /dev/null 2>&1; then
        log_info "Creating Glue assets bucket: $BUCKET_NAME"
        aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"
        log_success "Created Glue assets bucket"
    else
        log_info "Glue assets bucket already exists"
    fi
    
    # Create scripts folder
    aws s3api put-object --bucket "$BUCKET_NAME" --key "scripts/" > /dev/null 2>&1 || true
}

# Upload ETL script to S3
upload_script() {
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    BUCKET_NAME="aws-glue-assets-${ACCOUNT_ID}-${REGION}"
    
    log_info "Uploading ETL script to S3..."
    
    if aws s3 cp "$SCRIPT_DIR/$SCRIPT_FILE" "s3://$BUCKET_NAME/scripts/"; then
        log_success "ETL script uploaded successfully"
    else
        log_error "Failed to upload ETL script"
        exit 1
    fi
}

# Create or update secrets manager secret for database password
create_database_secret() {
    SECRET_NAME="aurora-postgres-password"
    
    log_info "Checking database secret: $SECRET_NAME"
    
    if aws secretsmanager describe-secret --secret-id "$SECRET_NAME" > /dev/null 2>&1; then
        log_info "Database secret already exists"
    else
        log_warning "Database secret not found. Please create it manually:"
        echo "  aws secretsmanager create-secret --name $SECRET_NAME --description 'Aurora PostgreSQL password' --secret-string 'your-password'"
        echo ""
        echo "Or update existing secret:"
        echo "  aws secretsmanager update-secret --secret-id $SECRET_NAME --secret-string 'your-password'"
        echo ""
        read -p "Press Enter after creating the secret to continue..."
    fi
}

# Deploy CloudFormation stack
deploy_stack() {
    log_info "Deploying CloudFormation stack: $STACK_NAME"
    
    # Check if stack exists
    if aws cloudformation describe-stacks --stack-name "$STACK_NAME" > /dev/null 2>&1; then
        log_info "Stack exists, updating..."
        OPERATION="update-stack"
    else
        log_info "Stack does not exist, creating..."
        OPERATION="create-stack"
    fi
    
    # Deploy the stack
    aws cloudformation "$OPERATION" \
        --stack-name "$STACK_NAME" \
        --template-body "file://$SCRIPT_DIR/$TEMPLATE_FILE" \
        --capabilities CAPABILITY_NAMED_IAM \
        --region "$REGION" \
        --tags Key=Environment,Value=development Key=Project,Value=map-appraiser Key=Component,Value=etl
    
    log_info "Waiting for stack operation to complete..."
    
    if [ "$OPERATION" = "create-stack" ]; then
        aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME" --region "$REGION"
    else
        aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME" --region "$REGION"
    fi
    
    log_success "Stack deployment completed successfully"
}

# Show stack outputs
show_outputs() {
    log_info "Stack outputs:"
    
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue,Description]' \
        --output table
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Deploy DCAD CSV to Database ETL Job"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  --dry-run       Show what would be executed without running"
    echo
    echo "Example:"
    echo "  $0"
    echo
    echo "After deployment, you can run the job with:"
    echo "  aws glue start-job-run --job-name dcad-csv-to-database-etl"
    echo
    echo "Or for a specific year:"
    echo "  aws glue start-job-run --job-name dcad-csv-to-database-etl --arguments='{\"--TARGET_YEAR\":\"2025\"}'"
}

# Parse command line arguments
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "======================================================="
    echo "  DCAD CSV to Database ETL Job Deployment"
    echo "======================================================="
    echo
    
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN - Would execute the following steps:"
        echo "  1. Check prerequisites"
        echo "  2. Create Glue assets bucket"
        echo "  3. Upload ETL script to S3"
        echo "  4. Check database secret"
        echo "  5. Deploy CloudFormation stack"
        echo "  6. Show stack outputs"
        exit 0
    fi
    
    # Execute deployment steps
    check_prerequisites
    echo
    
    create_glue_assets_bucket
    echo
    
    upload_script
    echo
    
    create_database_secret
    echo
    
    deploy_stack
    echo
    
    show_outputs
    echo
    
    log_success "Deployment completed successfully!"
    echo
    log_info "To run the ETL job:"
    echo "  # Process all years:"
    echo "  aws glue start-job-run --job-name dcad-csv-to-database-etl"
    echo
    echo "  # Process specific year:"
    echo "  aws glue start-job-run --job-name dcad-csv-to-database-etl --arguments='{\"--TARGET_YEAR\":\"2025\"}'"
    echo
    echo "  # Monitor job status:"
    echo "  aws glue get-job-runs --job-name dcad-csv-to-database-etl"
}

# Run main function
main "$@"