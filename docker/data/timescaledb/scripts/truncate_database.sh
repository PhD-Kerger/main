for table in availability demand trips weather osm holidays vacations gtfs wfs demographics geo_information station_names;
do
    echo "Truncating table $table..."
    duckdb -c "
        INSTALL postgres;
        LOAD postgres;
        ATTACH 'host=127.0.0.1 port=5432 dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD' AS pg (TYPE postgres);
        TRUNCATE TABLE pg.$table;
    "
    echo "Finished truncating table $table."
done
