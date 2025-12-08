#!/bin/bash
set -euo pipefail

TABLES=(geo_information station_names availability demand trips weather osm gtfs holidays vacations wfs demographics bike_counting_stations)
CHUNKED_TABLES=(availability demand trips gtfs)
OPERATOR_TABLES=(availability demand trips)

# Parse command line arguments for operators
SELECTED_OPERATORS=""
if [ $# -gt 0 ]; then
    SELECTED_OPERATORS="$@"
    echo "Selected operators: $SELECTED_OPERATORS"
fi

echo "Starting data import into PostgreSQL. Will set threads to $(nproc) and memory limit to $(free -g | awk '/^Mem:/{print int($2*0.8)}')GB for DuckDB."

# Temporarily disable foreign key constraints to allow metadata updates
psql -h "localhost" -p "5432" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
-- Disable all triggers (including foreign key constraint triggers)
ALTER TABLE geo_information DISABLE TRIGGER ALL;
ALTER TABLE station_names DISABLE TRIGGER ALL;
"
echo "Foreign key constraints disabled."

for table in "${TABLES[@]}"; do
    # Check if table has chunked data
    if [[ " ${CHUNKED_TABLES[@]} " =~ " ${table} " ]]; then
        # Special handling for availability based on environment variable
        if [ "$table" == "availability" ] && [ "$POSTGRES_ENABLE_AVAILABILITY" != "true" ]; then
            echo "Skipping availability data import..."
            continue
        fi
        
        echo "Importing table $table from chunked Parquet files..."
        
        # Check if this is an operator table
        if [[ " ${OPERATOR_TABLES[@]} " =~ " ${table} " ]]; then
            # Get list of operators to import
            if [ -n "$SELECTED_OPERATORS" ]; then
                operators="$SELECTED_OPERATORS"
            else
                # Get all available operators from directory structure
                operators=$(ls -d /data/${table}/*/ 2>/dev/null | xargs -n 1 basename 2>/dev/null || echo "")
                if [ -z "$operators" ]; then
                    echo "  No operator directories found for $table, skipping..."
                    continue
                fi
            fi
            
            # Import each operator
            for operator in $operators; do
                echo "  Processing operator: $operator"
                
                # Count chunks for this operator
                chunk_count=$(ls -1 /data/${table}/${operator}/*.parquet 2>/dev/null | wc -l)
                
                if [ $chunk_count -eq 0 ]; then
                    echo "    No chunk files found for operator $operator, skipping..."
                    continue
                fi
                
                echo "    Found $chunk_count chunks for operator $operator"

                # Import all chunks for this operator
                for chunk_file in /data/${table}/${operator}/*.parquet; do
                    chunk_name=$(basename "$chunk_file")
                    echo "    Importing $chunk_name..."
                    
                    duckdb -c "
                        LOAD postgres;
                        LOAD spatial;
                        SET threads TO $(nproc);
                        SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)*4}')GB';
                        ATTACH 'host=127.0.0.1 port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
                        INSERT INTO pg.$table FROM '$chunk_file';
                    "
                done
            done
        else
            # Non-operator chunked tables (like gtfs)
            # Count chunks
            chunk_count=$(ls -1 /data/${table}/*.parquet 2>/dev/null | wc -l)
            
            if [ $chunk_count -eq 0 ]; then
                echo "  No chunk files found for $table, skipping..."
                continue
            fi
            
            echo "  Found $chunk_count chunks for $table"

            # Import all chunks
            for chunk_file in /data/${table}/*.parquet; do
                chunk_name=$(basename "$chunk_file")
                echo "  Importing $chunk_name..."
                
                duckdb -c "
                    LOAD postgres;
                    LOAD spatial;
                    SET threads TO $(nproc);
                    SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)*4}')GB';
                    ATTACH 'host=127.0.0.1 port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
                    INSERT INTO pg.$table FROM '$chunk_file';
                "
            done
        fi
        
        echo "Finished importing table $table."
    else
        # Single file import for non-chunked tables
        if [ ! -f "/data/${table}/${table}.parquet" ]; then
            echo "Parquet file for $table not found, skipping..."
            continue
        fi
        
        echo "Importing table $table from Parquet file..."
        duckdb -c "
            LOAD postgres;
            LOAD spatial;
            SET threads TO $(nproc);
            SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)*4}')GB';
            ATTACH 'host=127.0.0.1 port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
            INSERT INTO pg.$table FROM '/data/${table}/${table}.parquet';
        "
        echo "Finished importing table $table."
    fi

done

psql -h "localhost" -p "5432" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
-- Enable all triggers (including foreign key constraint triggers)
ALTER TABLE geo_information ENABLE TRIGGER ALL;
ALTER TABLE station_names ENABLE TRIGGER ALL;
"
echo "Foreign key constraints enabled."

echo "Data import completed."