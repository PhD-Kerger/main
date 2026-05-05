#!/bin/sh

# Paths to input and output files based on the environment variable
OSM_FILE=/data/${OSRM_NAME}/${OSRM_NAME}.osm.pbf
OSRM_FILE="/data/${OSRM_NAME}/${OSRM_NAME}.osrm"
PROFILE="/opt/foot.lua"

echo "Extracting OSM data..."
osrm-extract -p "$PROFILE" "$OSM_FILE"
echo "Partitioning OSRM data..."
osrm-partition "$OSRM_FILE"
echo "Customizing OSRM data..."
osrm-customize "$OSRM_FILE"


# Start the OSRM routing service
echo "Starting OSRM routing service..."
osrm-routed --algorithm mld "$OSRM_FILE"