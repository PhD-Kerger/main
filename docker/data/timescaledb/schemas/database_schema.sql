-- Enable TimescaleDB
CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE EXTENSION IF NOT EXISTS postgis;

-- Table: geo_information
CREATE TABLE
    IF NOT EXISTS geo_information (
        location_id INTEGER,
        location geography (POINT, 4326),
        continent_name TEXT,
        country_name TEXT,
        city_name TEXT,
        federal_state_name TEXT,
        postal_code INTEGER,
        PRIMARY KEY (location_id)
    );

-- Create index on postal_code for faster lookups on this column
CREATE INDEX IF NOT EXISTS idx_geo_information_postal_code ON geo_information (postal_code);

-- Create index on location for faster lookups on this column
CREATE INDEX IF NOT EXISTS idx_geo_information_location ON geo_information USING gist (location);

-- Table: station_names
CREATE TABLE
    IF NOT EXISTS station_names (id INTEGER PRIMARY KEY, name TEXT);

-- Table: availability
CREATE TABLE
    IF NOT EXISTS availability (
        location_id INTEGER,
        timestamp TIMESTAMPTZ NOT NULL,
        network_name TEXT,
        station_name_id INTEGER,
        station_id TEXT,
        n_vehicles SMALLINT,
        PRIMARY KEY (location_id, network_name, timestamp),
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id),
        FOREIGN KEY (station_name_id) REFERENCES station_names (id)
    );

SELECT
    create_hypertable ('availability', 'timestamp');

-- Create explicit unique index for TimescaleDB compatibility
CREATE UNIQUE INDEX IF NOT EXISTS idx_availability_unique ON availability (location_id, network_name, timestamp);

-- Table: demand
CREATE TABLE
    IF NOT EXISTS demand (
        location_id INTEGER,
        timestamp TIMESTAMPTZ NOT NULL,
        network_name TEXT,
        station_name_id INTEGER,
        station_id TEXT,
        n_lends SMALLINT,
        n_returns SMALLINT,
        PRIMARY KEY (location_id, network_name, timestamp),
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id),
        FOREIGN KEY (station_name_id) REFERENCES station_names (id)
    );

SELECT
    create_hypertable ('demand', 'timestamp');

-- Create explicit unique index for TimescaleDB compatibility
CREATE UNIQUE INDEX IF NOT EXISTS idx_demand_unique ON demand (location_id, network_name, timestamp);

-- Table: trips
CREATE TABLE
    IF NOT EXISTS trips (
        vehicle_id TEXT,
        timestamp_lend TIMESTAMPTZ NOT NULL,
        timestamp_return TIMESTAMPTZ,
        station_id_lend TEXT,
        station_id_return TEXT,
        station_name_id_lend INTEGER,
        station_name_id_return INTEGER,
        network_name_lend TEXT,
        network_name_return TEXT,
        location_id_lend INTEGER,
        location_id_return INTEGER,
        pedelec_battery_lend SMALLINT,
        pedelec_battery_return SMALLINT,
        current_range_meters_lend INTEGER,
        current_range_meters_return INTEGER,
        predicted BOOLEAN,
        PRIMARY KEY (vehicle_id, timestamp_lend),
        FOREIGN KEY (location_id_lend) REFERENCES geo_information (location_id),
        FOREIGN KEY (location_id_return) REFERENCES geo_information (location_id),
        FOREIGN KEY (station_name_id_lend) REFERENCES station_names (id),
        FOREIGN KEY (station_name_id_return) REFERENCES station_names (id)
    );

SELECT
    create_hypertable ('trips', 'timestamp_lend');

-- Create explicit unique index for TimescaleDB compatibility
CREATE UNIQUE INDEX IF NOT EXISTS idx_trips_unique ON trips (vehicle_id, timestamp_lend);

-- Table: weather
CREATE TABLE
    IF NOT EXISTS weather (
        location_id INTEGER,
        timestamp TIMESTAMPTZ NOT NULL,
        temperature DOUBLE PRECISION,
        humidity DOUBLE PRECISION,
        precipitation DOUBLE PRECISION,
        wind_speed DOUBLE PRECISION,
        wind_direction INTEGER,
        PRIMARY KEY (location_id, timestamp),
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id)
    );

SELECT
    create_hypertable ('weather', 'timestamp');

-- Create explicit unique index for TimescaleDB compatibility
CREATE UNIQUE INDEX IF NOT EXISTS idx_weather_unique ON weather (location_id, timestamp);

-- Table: osm
CREATE TABLE
    IF NOT EXISTS osm (
        id INTEGER,
        timestamp TIMESTAMPTZ NOT NULL,
        location_id INTEGER,
        entity_name TEXT,
        name TEXT,
        cuisine TEXT,
        opening_hours TEXT,
        PRIMARY KEY (id, timestamp),
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id)
    );

SELECT
    create_hypertable ('osm', 'timestamp');

-- Create explicit unique index for TimescaleDB compatibility
CREATE UNIQUE INDEX IF NOT EXISTS idx_osm_unique ON osm (id, timestamp);

CREATE TABLE
    IF NOT EXISTS foursquare (
        fsq_id TEXT PRIMARY KEY,
        name TEXT,
        location_id INTEGER,
        categories TEXT,
        popularity DOUBLE PRECISION,
        rating DOUBLE PRECISION,
        price DOUBLE PRECISION,
        hours_display TEXT,
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id)
    );

-- Table: holidays
CREATE TABLE
    IF NOT EXISTS holidays (
        name TEXT,
        start_date DATE NOT NULL,
        federal_state_name TEXT,
        end_date DATE NOT NULL,
        type TEXT,
        PRIMARY KEY (name, start_date, federal_state_name)
    );

-- Table: vacations
CREATE TABLE
    IF NOT EXISTS vacations (
        name TEXT,
        start_date DATE NOT NULL,
        federal_state_name TEXT,
        end_date DATE NOT NULL,
        type TEXT,
        PRIMARY KEY (name, start_date, federal_state_name)
    );

-- Table GTFS
CREATE TABLE
    IF NOT EXISTS gtfs (
        route_long_name TEXT,
        route_short_name TEXT,
        route_type INTEGER,
        location_id INTEGER,
        arrival_time TIMESTAMPTZ NOT NULL,
        departure_time TIMESTAMPTZ NOT NULL,
        PRIMARY KEY (
            route_long_name,
            route_short_name,
            route_type,
            arrival_time,
            departure_time,
            location_id
        ),
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id)
    );

CREATE UNIQUE INDEX IF NOT EXISTS idx_gtfs_unique ON gtfs (
    route_long_name,
    route_short_name,
    arrival_time,
    route_type,
    departure_time,
    location_id
);

-- Table: WFS
CREATE TABLE
    wfs (
        city TEXT,
        name TEXT,
        area geometry (MULTIPOLYGON, 4326)
    );

CREATE INDEX ON wfs USING GIST (area);

CREATE UNIQUE INDEX IF NOT EXISTS idx_wfs_unique ON wfs (city, name);

-- Table: demographics
CREATE TABLE
    IF NOT EXISTS demographics (
        topic TEXT,
        city TEXT,
        area TEXT,
        feature TEXT,
        year TIMESTAMPTZ,
        value DOUBLE PRECISION,
        PRIMARY KEY (city, area, feature, year)
    );

CREATE UNIQUE INDEX IF NOT EXISTS idx_demographics_unique ON demographics (city, area, feature, year);

-- Table bike_counting_stations
CREATE TABLE
    IF NOT EXISTS bike_counting_stations (
        counter_id INTEGER,
        timestamp TIMESTAMPTZ NOT NULL,
        location_id INTEGER,
        counter_name TEXT,
        in_count INTEGER,
        out_count INTEGER,
        PRIMARY KEY (counter_id, timestamp),
        FOREIGN KEY (location_id) REFERENCES geo_information (location_id)
    );

SELECT
    create_hypertable ('bike_counting_stations', 'timestamp');

CREATE UNIQUE INDEX IF NOT EXISTS idx_bike_counting_stations_unique ON bike_counting_stations (counter_id, timestamp);