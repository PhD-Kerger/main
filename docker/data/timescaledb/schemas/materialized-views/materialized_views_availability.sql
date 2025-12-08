-- Average Availability per 15min by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS quarter_hourly_availability_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('15 minutes', a."timestamp") AS quarter_hour,
    a.location_id,
    a.network_name,
    a.station_name_id,
    a.station_id,
    AVG(a.n_vehicles) AS avg_availability,
    sn."name" AS station_name,
    g.location
FROM
    public.availability a
    LEFT JOIN public.station_names sn ON a.station_name_id = sn.id
    LEFT JOIN public.geo_information g ON a.location_id = g.location_id
GROUP BY
    quarter_hour,
    a.location_id,
    a.network_name,
    a.station_id,
    a.station_name_id,
    sn."name",
    g.location
ORDER BY
    quarter_hour;

-- Average Availability per hour by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW hourly_availability_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 hour', "quarter_hour") AS hour,
    location_id,
    network_name,
    station_name_id,
    station_id,
    AVG(avg_availability) AS avg_availability,
    station_name,
    location
FROM
    quarter_hourly_availability_agg
GROUP BY
    hour,
    location_id,
    network_name,
    station_id,
    station_name_id,
    station_name,
    location
ORDER BY
    hour;

-- Average Availability per 12h by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW half_daily_availability_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('12 hours', "hour") AS half_day,
    location_id,
    network_name,
    station_name_id,
    station_id,
    AVG(avg_availability) AS avg_availability,
    station_name,
    location
FROM
    hourly_availability_agg
GROUP BY
    half_day,
    location_id,
    network_name,
    station_id,
    station_name_id,
    station_name,
    location
ORDER BY
    half_day;

-- Average Availability per day by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW daily_availability_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 day', "half_day") AS day,
    location_id,
    network_name,
    station_name_id,
    station_id,
    AVG(avg_availability) AS avg_availability,
    station_name,
    location
FROM
    half_daily_availability_agg
GROUP BY
    day,
    location_id,
    network_name,
    station_id,
    station_name_id,
    station_name,
    location
ORDER BY
    day;

-- Average Availability per week by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW weekly_availability_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 week', "day") AS week,
    location_id,
    network_name,
    station_name_id,
    station_id,
    AVG(avg_availability) AS avg_availability,
    station_name,
    location
FROM
    daily_availability_agg
GROUP BY
    week,
    location_id,
    network_name,
    station_id,
    station_name_id,
    station_name,
    location
ORDER BY
    week;

-- Average Availability per month by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW monthly_availability_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 month', "week") AS month,
    location_id,
    network_name,
    station_name_id,
    station_id,
    AVG(avg_availability) AS avg_availability,
    station_name,
    location
FROM
    weekly_availability_agg
GROUP BY
    month,
    location_id,
    network_name,
    station_id,
    station_name_id,
    station_name,
    location
ORDER BY
    month;