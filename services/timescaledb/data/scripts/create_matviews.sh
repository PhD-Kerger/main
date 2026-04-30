if [ "$POSTGRES_CREATE_MATVIEWS" == "true" ]; then
    echo "POSTGRES_CREATE_MATVIEWS is set to true. Creating materialized views."
    echo "Creating materialized views for demand..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/materialized-views/materialized_views_demand.sql
    echo "Creating materialized views for trips..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/materialized-views/materialized_views_trips.sql
    echo "Creating materialized views for others..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/materialized-views/materialized_views_others.sql
    if [ "$POSTGRES_ENABLE_AVAILABILITY" == "true" ]; then
        echo "POSTGRES_ENABLE_AVAILABILITY is set to true. Creating materialized views for availability. This takes a long time..."
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/materialized-views/materialized_views_availability.sql
    else
        echo "Skipping materialized views for availability..."
    fi
    
else
    echo "Skipping materialized views creation..."
fi



