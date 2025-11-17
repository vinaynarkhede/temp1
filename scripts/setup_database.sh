#!/bin/bash
# =====================================================
# Database Setup Script
# =====================================================
# This script sets up the complete database schema

set -e  # Exit on error

echo "=========================================="
echo "PostgreSQL Database Setup"
echo "=========================================="
echo ""

# Configuration
DB_NAME="myapp_db"
DB_USER="myapp_user"
DB_PASSWORD="secure_password_change_in_production"
POSTGRES_USER="postgres"

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if PostgreSQL is running
print_info "Checking PostgreSQL status..."
if pg_isready -q; then
    print_success "PostgreSQL is running"
else
    print_error "PostgreSQL is not running"
    echo "Please start PostgreSQL with: pg_ctlcluster 16 main start"
    exit 1
fi

# Create database and user
print_info "Creating database and user..."
psql -U $POSTGRES_USER << EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF
print_success "Database and user created"

# Run schema migrations
print_info "Running schema migrations..."

print_info "  1/4 Creating tables and indexes..."
psql -U $POSTGRES_USER -d $DB_NAME -f sql/01_schema.sql > /dev/null
print_success "  Tables and indexes created"

print_info "  2/4 Implementing Row-Level Security..."
psql -U $POSTGRES_USER -d $DB_NAME -f sql/02_rls_policies.sql > /dev/null
print_success "  RLS policies implemented"

print_info "  3/4 Creating business logic functions..."
psql -U $POSTGRES_USER -d $DB_NAME -f sql/03_functions.sql > /dev/null
print_success "  Functions created"

print_info "  4/4 Creating views..."
psql -U $POSTGRES_USER -d $DB_NAME -f sql/04_views.sql > /dev/null
print_success "  Views created"

# Run tests
print_info "Running database tests..."
TEST_OUTPUT=$(psql -U $POSTGRES_USER -d $DB_NAME -f tests/database_tests.sql 2>&1 | grep -c "PASS")
print_success "Database tests completed ($TEST_OUTPUT tests passed)"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Database Details:"
echo "  Name: $DB_NAME"
echo "  User: $DB_USER"
echo "  Password: $DB_PASSWORD"
echo ""
echo "Connection String:"
echo "  postgres://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
echo ""
echo "Next Steps:"
echo "  1. Install PostgREST (see docs/postgrest_installation.md)"
echo "  2. Configure postgrest.conf with your settings"
echo "  3. Start PostgREST: postgrest postgrest.conf"
echo "  4. Test API: node tests/api_tests.js"
echo ""
print_success "All done!"
