CREATE MATERIALIZED VIEW IF NOT EXISTS hourly_trips_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 hour', t.timestamp_lend) AS hour,
    count(*) AS trip_count,
    t.location_id_lend,
    t.location_id_return,
    t.station_id_lend,
    t.station_id_return,
    g.location AS location_lend,
    g2.location AS location_return,
    sn_lend."name" AS station_name_lend,
    sn_return."name" AS station_name_return,
    t.network_name_lend,
    t.network_name_return
FROM
    trips t
    LEFT JOIN public.station_names sn_lend ON t.station_name_id_lend = sn_lend.id
    LEFT JOIN public.station_names sn_return ON t.station_name_id_return = sn_return.id
    LEFT JOIN public.geo_information g ON t.location_id_lend = g.location_id
    LEFT JOIN public.geo_information g2 ON t.location_id_return = g2.location_id
GROUP BY
    hour,
    t.network_name_lend,
    t.network_name_return,
    g.location,
    g2.location,
    t.location_id_lend,
    t.location_id_return,
    t.station_id_lend,
    t.station_id_return,
    sn_lend."name",
    sn_return."name"
ORDER BY
    hour;

-- Trips per 12h by `network_name_lend` and `network_name_return`
CREATE MATERIALIZED VIEW IF NOT EXISTS half_daily_trips_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('12 hours', hour) AS half_day,
    sum(trip_count) AS trip_count,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
FROM
    hourly_trips_agg
GROUP BY
    half_day,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
ORDER BY
    half_day;

-- Trips per day by `network_name_lend` and `network_name_return`
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_trips_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 day', half_day) AS day,
    sum(trip_count) AS trip_count,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
FROM
    half_daily_trips_agg
GROUP BY
    day,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
ORDER BY
    day;

-- Trips per week by `network_name_lend` and `network_name_return`
CREATE MATERIALIZED VIEW IF NOT EXISTS weekly_trips_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 week', day) AS week,
    sum(trip_count) AS trip_count,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
FROM
    daily_trips_agg
GROUP BY
    week,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
ORDER BY
    week;

-- Trips per month by `network_name_lend` and `network_name_return`
CREATE MATERIALIZED VIEW IF NOT EXISTS monthly_trips_agg
WITH
    (timescaledb.continuous) AS
SELECT
    time_bucket ('1 month', day) AS month,
    sum(trip_count) AS trip_count,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
FROM
    daily_trips_agg
GROUP BY
    month,
    network_name_lend,
    network_name_return,
    location_lend,
    location_return,
    station_id_lend,
    station_id_return,
    station_name_lend,
    station_name_return
ORDER BY
    month;