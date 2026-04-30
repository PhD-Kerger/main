-- Station Lifespans
CREATE MATERIALIZED VIEW station_lifespans AS
SELECT
    t.station_id_lend AS station_id,
    t.station_name_id_lend AS station_name_id,
    s.name AS station_name,
    t.location_id_lend AS location_id,
    g.location AS location,
    t.network_name_lend AS network_name,
    MIN(t.timestamp_lend) AS first_seen,
    MAX(t.timestamp_lend) AS last_seen
FROM
    trips t
    JOIN geo_information g ON t.location_id_lend = g.location_id
    JOIN station_names s ON t.station_name_id_lend = s.id
WHERE
    t.station_id_lend IS NOT NULL
GROUP BY
    t.station_id_lend,
    t.station_name_id_lend,
    s.name,
    t.location_id_lend,
    t.network_name_lend,
    g.location
ORDER BY
    t.station_id_lend;