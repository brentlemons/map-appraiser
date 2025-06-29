#!/bin/bash

# =====================================================
# Deploy DCAD Appraisal Database Schema
# Master deployment script using psql command line tool
# =====================================================

set -e

# Configuration
DB_HOST="${DB_HOST:-map-appraiser-aurora-db-cluster.cluster-cjcydnj4gvc0.us-west-2.rds.amazonaws.com}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-map_appraiser}"
DB_USER="${DB_USER:-postgres}"
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

# Check if psql is available
check_psql() {
    if ! command -v psql &> /dev/null; then
        # Try the specific path we know works
        if [ -f "/opt/homebrew/Cellar/libpq/17.5/bin/psql" ]; then
            export PSQL_CMD="/opt/homebrew/Cellar/libpq/17.5/bin/psql"
            log_info "Using psql at: $PSQL_CMD"
        else
            log_error "psql command not found. Please install PostgreSQL client tools."
            exit 1
        fi
    else
        export PSQL_CMD="psql"
        log_info "Using system psql: $(which psql)"
    fi
}

# Test database connection
test_connection() {
    log_info "Testing database connection..."
    
    if ! $PSQL_CMD -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT version();" > /dev/null 2>&1; then
        log_error "Cannot connect to database. Please check:"
        echo "  - Host: $DB_HOST"
        echo "  - Port: $DB_PORT"
        echo "  - Database: $DB_NAME"
        echo "  - User: $DB_USER"
        echo "  - Password: Set PGPASSWORD environment variable"
        exit 1
    fi
    
    log_success "Database connection successful"
}

# Execute SQL script
execute_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    
    if [ ! -f "$script_path" ]; then
        log_error "Script not found: $script_path"
        return 1
    fi
    
    log_info "Executing: $script_name"
    
    if $PSQL_CMD -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$script_path"; then
        log_success "Successfully executed: $script_name"
        return 0
    else
        log_error "Failed to execute: $script_name"
        return 1
    fi
}

# Main deployment function
deploy_database() {
    log_info "Starting DCAD Appraisal Database deployment..."
    log_info "Target database: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
    echo
    
    # Array of scripts to execute in order
    scripts=(
        "01_create_schema.sql"
        "02_create_tables.sql"
        "03_create_foreign_keys.sql"
        "04_create_indexes.sql"
    )
    
    # Execute each script
    for script in "${scripts[@]}"; do
        if ! execute_script "$script"; then
            log_error "Deployment failed at script: $script"
            exit 1
        fi
        echo
    done
    
    log_success "Database deployment completed successfully!"
    echo
    log_info "Schema 'appraisal' has been created with:"
    echo "  ✓ 14 tables with appropriate data types"
    echo "  ✓ Primary key constraints"
    echo "  ✓ Foreign key relationships"
    echo "  ✓ Performance indexes"
    echo
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    # Check schema exists
    schema_count=$($PSQL_CMD -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'appraisal';")
    
    if [ "$schema_count" -eq 1 ]; then
        log_success "Schema 'appraisal' exists"
    else
        log_error "Schema 'appraisal' not found"
        return 1
    fi
    
    # Check table count
    table_count=$($PSQL_CMD -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'appraisal';")
    
    if [ "$table_count" -eq 14 ]; then
        log_success "All 14 tables created"
    else
        log_warning "Expected 14 tables, found $table_count"
    fi
    
    # List all tables
    log_info "Tables in appraisal schema:"
    $PSQL_CMD -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'appraisal' ORDER BY table_name;"
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Deploy DCAD Appraisal Database Schema"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --verify    Verify deployment after completion"
    echo "  --dry-run       Show what would be executed without running"
    echo
    echo "Environment Variables:"
    echo "  DB_HOST         Database host (default: Aurora cluster endpoint)"
    echo "  DB_PORT         Database port (default: 5432)"
    echo "  DB_NAME         Database name (default: map_appraiser)"
    echo "  DB_USER         Database user (default: postgres)"
    echo "  PGPASSWORD      Database password (required)"
    echo
    echo "Example:"
    echo "  export PGPASSWORD='your-password'"
    echo "  $0 --verify"
}

# Parse command line arguments
VERIFY=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verify)
            VERIFY=true
            shift
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
    echo "  DCAD Appraisal Database Schema Deployment"
    echo "======================================================="
    echo
    
    # Check password
    if [ -z "$PGPASSWORD" ]; then
        log_error "PGPASSWORD environment variable is required"
        echo "Please set it with: export PGPASSWORD='your-password'"
        exit 1
    fi
    
    # Check psql availability
    check_psql
    
    # Test connection
    test_connection
    
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN - Would execute the following scripts:"
        echo "  1. 01_create_schema.sql"
        echo "  2. 02_create_tables.sql"
        echo "  3. 03_create_foreign_keys.sql"
        echo "  4. 04_create_indexes.sql"
        exit 0
    fi
    
    # Deploy database
    deploy_database
    
    # Verify if requested
    if [ "$VERIFY" = true ]; then
        echo
        verify_deployment
    fi
    
    echo
    log_success "Deployment completed successfully!"
}

# Run main function
main "$@"