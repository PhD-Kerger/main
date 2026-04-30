#!/bin/bash
set -e

cpu_count=$(nproc)
echo "Found $cpu_count logical cores on the system for import..."

# Follows official TimescaleDB Backup and Restore guides: 
# https://docs.timescale.com/self-hosted/latest/backup-and-restore/logical-backup#back-up-and-restore-an-entire-database
# https://docs.timescale.com/self-hosted/latest/migration/schema-then-data/#migrate-schema-pre-data

# create database if it doesn't exist
if ! psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -qw "$POSTGRES_DB"; then
    echo "Creating database $POSTGRES_DB..."
    psql -U "$POSTGRES_USER" -c "CREATE DATABASE $POSTGRES_DB;"
else
    echo "Database $POSTGRES_DB already exists. Skipping creation..."
fi

echo "Creating Schema and importing extensions..."
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/database_schema.sql

echo "Database is ready. Please connect to the container and run the command ./scripts/import_data.sh to import the data and activate foreign key constraints."