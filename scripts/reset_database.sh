#!/bin/bash
# =====================================================
# Database Reset Script
# =====================================================
# This script drops and recreates the database

set -e

echo "=========================================="
echo "Database Reset"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will DELETE ALL DATA!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

DB_NAME="myapp_db"
DB_USER="myapp_user"
POSTGRES_USER="postgres"

echo ""
echo "Dropping database and user..."
psql -U $POSTGRES_USER << EOF
DROP DATABASE IF EXISTS $DB_NAME;
DROP USER IF EXISTS $DB_USER;
EOF

echo "Database reset complete."
echo ""
echo "Run ./scripts/setup_database.sh to recreate the database."
