#!/bin/bash
set -euo pipefail

TABLES=(geo_information station_names availability demand trips weather osm holidays vacations gtfs wfs demographics bike_counting_stations)
CHUNK_TABLES=(availability demand trips gtfs)
OPERATOR_TABLES=(availability demand trips)

# Compression codec (SNAPPY, GZIP, ZSTD, BROTLI, LZ4, UNCOMPRESSED)
COMPRESSION=${COMPRESSION:-BROTLI}

# Whether to order data before export (true/false)
ORDER_DATA=${ORDER_DATA:-false}

# Create backup directory if it doesn't exist
mkdir -p /data/backup

# Function to get ORDER BY clause for each table
get_order_clause() {
    local table=$1
    
    if [ "$ORDER_DATA" != "true" ]; then
        echo ""
        return
    fi
    
    case "$table" in
        availability)
            echo "ORDER BY location_id, timestamp"
            ;;
        demand)
            echo "ORDER BY location_id, timestamp"
            ;;
        trips)
            echo "ORDER BY location_id_lend, timestamp_lend"
            ;;
        geo_information)
            echo "ORDER BY continent_name, country_name, city_name"
            ;;
        weather)
            echo "ORDER BY location_id, timestamp"
            ;;
        osm)
            echo "ORDER BY entity_name"
            ;;
        station_names)
            echo "ORDER BY id"
            ;;
        holidays)
            echo "ORDER BY federal_state_name, start_date"
            ;;
        vacations)
            echo "ORDER BY federal_state_name, start_date"
            ;;
        gtfs)
            echo "ORDER BY arrival_time, route_short_name"
            ;;
        wfs)
            echo "ORDER BY city"
            ;;
        demographics)
            echo "ORDER BY topic, city"
            ;;
        bike_counting_stations)
            echo "ORDER BY counter_id, timestamp"
            ;;
        *)
            echo ""
            ;;
    esac
}

get_operator_list() {
    local table=$1
    
    case "$table" in
        availability|demand)
            operators=$(duckdb -noheader -list -c "
                INSTALL postgres;
                LOAD postgres;
                SET threads TO $(nproc);
                SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)}')GB';
                ATTACH 'host=localhost port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
                SELECT DISTINCT network_name 
                FROM pg.$table 
                WHERE network_name IS NOT NULL
                ORDER BY network_name;
            " 2>/dev/null)
            ;;
        trips)
            operators=$(duckdb -noheader -list -c "
                INSTALL postgres;
                LOAD postgres;
                SET threads TO $(nproc);
                SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)}')GB';
                ATTACH 'host=localhost port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
                SELECT DISTINCT network_name_lend
                FROM pg.$table 
                WHERE network_name_lend IS NOT NULL
                ORDER BY network_name_lend;
            " 2>/dev/null)
            ;;
        *)
            operators=""
            ;;
    esac
    
    echo "$operators"
}

# Function to get timestamp column for each table
get_timestamp_column() {
    local table=$1
    
    case "$table" in
        availability)
            echo "timestamp"
            ;;
        demand)
            echo "timestamp"
            ;;
        trips)
            echo "timestamp_lend"
            ;;
        gtfs)
            echo "arrival_time"
            ;;
        *)
            echo ""
            ;;
    esac
}

for table in "${TABLES[@]}"; do
    # Create subdirectory for this table
    mkdir -p "/data/backup/${table}"
    
    # Get ORDER BY clause for this table
    order_clause=$(get_order_clause "$table")   
    
    # Check if table should be exported in chunks
    if [[ " ${CHUNK_TABLES[@]} " =~ " ${table} " ]]; then
        echo "Dumping table $table in monthly chunks (compression: $COMPRESSION)..."
        if [ "$table" == "availability" ] && [ "$POSTGRES_ENABLE_AVAILABILITY" != "true" ]; then
            echo "  Skipping availability data dump..."
            continue
        fi
        
        # Get timestamp column for this table
        timestamp_col=$(get_timestamp_column "$table")

        echo "  Using timestamp column: $timestamp_col"
        
        if [ -z "$timestamp_col" ]; then
            echo "  Error: No timestamp column defined for $table"
            continue
        fi

        # if availability, demand or trips, get operators; otherwise set to single empty value for loop
        if [[ " ${OPERATOR_TABLES[@]} " =~ " ${table} " ]]; then
            operators=$(get_operator_list "$table")
            echo "  Found operators: $(echo $operators | tr '\n' ' ')"
        else
            operators="_no_operator_"
            echo "  No operators for table $table"
        fi
        
        # Loop through operators (or single iteration for non-operator tables)
        for operator in $operators; do
            # Set operator filter based on table and whether it has operators
            if [[ " ${OPERATOR_TABLES[@]} " =~ " ${table} " ]]; then
                echo "  Processing operator: $operator"
                operator_suffix="/${operator}"
                
                # Set the appropriate column name for filtering
                case "$table" in
                    availability|demand)
                        operator_where="AND network_name = '$operator'"
                        ;;
                    trips)
                        operator_where="AND network_name_lend = '$operator'"
                        ;;
                esac
            else
                operator_suffix=""
                operator_where=""
            fi
            
            # Create subdirectory for operator if needed
            if [ -n "$operator_suffix" ]; then
                mkdir -p "/data/backup/${table}${operator_suffix}"
            fi
            
            # Get list of year-months available in the data for this operator
            year_months=$(duckdb -noheader -list -c "
                INSTALL postgres;
                LOAD postgres;
                SET threads TO $(nproc);
                SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)}')GB';
                ATTACH 'host=localhost port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
                SELECT DISTINCT strftime($timestamp_col, '%Y-%m') AS year_month 
                FROM pg.$table 
                WHERE $timestamp_col IS NOT NULL $operator_where
                ORDER BY year_month;
            " 2>/dev/null)

            if [ -z "$year_months" ]; then
                echo "    Warning: No date data found for $table${operator_suffix}"
                continue
            fi
            
            echo "    Found months: $(echo $year_months | tr '\n' ' ')"
            
            # Export each month separately
            for year_month in $year_months; do
                echo "    Exporting month $year_month..."
                
                duckdb -c "
                    INSTALL postgres;
                    LOAD postgres;
                    SET threads TO $(nproc);
                    SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)}')GB';
                    ATTACH 'host=localhost port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
                    COPY (
                        SELECT * FROM pg.$table 
                        WHERE strftime($timestamp_col, '%Y-%m') = '$year_month' $operator_where
                        $order_clause
                    ) TO '/data/backup/${table}${operator_suffix}/${year_month}.parquet' (FORMAT PARQUET, COMPRESSION $COMPRESSION);
                "
            done
        done
    else
        echo "Dumping table $table to Parquet file (compression: $COMPRESSION)..."
        
        # Use DuckDB to export PostgreSQL table directly to Parquet
        duckdb -c "
            INSTALL postgres;
            LOAD postgres;
            INSTALL spatial;
            LOAD spatial;
            SET threads TO $(nproc);
            SET memory_limit = '$(free -g | awk '/^Mem:/{print int($2*0.8)}')GB';
            ATTACH 'host=localhost port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
            COPY (SELECT * FROM pg.$table $order_clause) TO '/data/backup/${table}/${table}.parquet' (FORMAT PARQUET, COMPRESSION $COMPRESSION);
        "
    fi
done