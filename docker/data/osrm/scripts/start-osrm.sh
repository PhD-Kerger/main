#!/bin/sh

# Paths to input and output files based on the environment variable
OSM_FILE=/data/data/${OSRM_NAME}.osm.pbf
OSRM_FILE="/data/data/${OSRM_NAME}.osrm"
PROFILE="/opt/car.lua"

# Extract, partition, and customize the OSM data
if [ ! -f "${OSRM_FILE}" ]; then
    echo "Extracting OSM data..."
    osrm-extract -p "$PROFILE" "$OSM_FILE"
    echo "Partitioning OSRM data..."
    osrm-partition "$OSRM_FILE"
    echo "Customizing OSRM data..."
    osrm-customize "$OSRM_FILE"
else
    echo "OSM data already processed."
fi

# Start the OSRM routing service
echo "Starting OSRM routing service..."
osrm-routed --algorithm mld "$OSRM_FILE"