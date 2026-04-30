if [ "$POSTGRES_CREATE_MATVIEWS" == "true" ]; then
    echo "POSTGRES_CREATE_MATVIEWS is set to true. Creating policies for continuous aggregates."
    echo "Creating policies for demand..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/policies/policies_demand.sql
    echo "Creating policies for trips..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/policies/policies_trips.sql
    echo "Creating policies for others..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/policies/policies_others.sql

    if [ "$POSTGRES_ENABLE_AVAILABILITY" == "true" ]; then
        echo "POSTGRES_ENABLE_AVAILABILITY is set to true. Creating policies for availability. This takes a long time..."
        psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /schemas/policies/policies_availability.sql
    else
        echo "Skipping policies for availability..."
    fi
    
else
    echo "Skipping policies creation..."
fi



