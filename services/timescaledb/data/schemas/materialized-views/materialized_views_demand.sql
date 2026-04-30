-- Demand per 15 minutes by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS quarter_hourly_demand_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('15 minutes', d."timestamp") AS quarter_hour,
    d.location_id,
    d.network_name,
    d.station_name_id,
    d.station_id,
    SUM(d.n_lends) AS total_lends,
    SUM(d.n_returns) AS total_returns,
    sn."name" AS station_name,
    g.location AS location
FROM
    public.demand d
    LEFT JOIN public.station_names sn ON d.station_name_id = sn.id
    LEFT JOIN public.geo_information g ON d.location_id = g.location_id
GROUP BY
    quarter_hour,
    d.location_id,
    d.network_name,
    d.station_id,
    d.station_name_id,
    sn."name",
    g.location
ORDER BY
    quarter_hour;

-- Demand per hour by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS hourly_demand_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 hour', "quarter_hour") AS hour,
    location_id,
    network_name,
    station_name_id,
    station_id,
    SUM(total_lends) AS total_lends,
    SUM(total_returns) AS total_returns,
    station_name,
    location
FROM
    quarter_hourly_demand_agg
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

-- Demand per 12h by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS half_daily_demand_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('12 hours', "hour") AS half_day,
    location_id,
    network_name,
    station_name_id,
    station_id,
    SUM(total_lends) AS total_lends,
    SUM(total_returns) AS total_returns,
    station_name,
    location
FROM
    hourly_demand_agg
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

-- Demand per day by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_demand_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 day', "hour") AS day,
    location_id,
    network_name,
    station_name_id,
    station_id,
    SUM(total_lends) AS total_lends,
    SUM(total_returns) AS total_returns,
    station_name,
    location
FROM
    hourly_demand_agg
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

-- Demand per week by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS weekly_demand_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 week', "day") AS week,
    location_id,
    network_name,
    station_name_id,
    station_id,
    SUM(total_lends) AS total_lends,
    SUM(total_returns) AS total_returns,
    station_name,
    location
FROM
    daily_demand_agg
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

-- Demand per month by `location_id` and `network_name`, joined with `station_names`
CREATE MATERIALIZED VIEW IF NOT EXISTS monthly_demand_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 month', "day") AS month,
    location_id,
    network_name,
    station_name_id,
    station_id,
    SUM(total_lends) AS total_lends,
    SUM(total_returns) AS total_returns,
    station_name,
    location
FROM
    daily_demand_agg
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

-- Demand pattern per hour of day and weekday for each station (not including wrong returns in Nextbike networks)
CREATE OR REPLACE VIEW hourly_weekday_pattern_demand AS
SELECT
    EXTRACT(ISODOW FROM hour)::int AS weekday,
    EXTRACT(HOUR FROM hour)::int AS hour_of_day,
    station_id,
    SUM(total_lends) AS total_lends,
    SUM(total_returns) AS total_returns
FROM
    hourly_demand_agg
WHERE
    station_id IS NOT NULL
    AND station_name NOT ILIKE '%BIKE%'
GROUP BY
    weekday,
    hour_of_day,
    station_id
