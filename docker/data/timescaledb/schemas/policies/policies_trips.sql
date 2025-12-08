SELECT
    add_continuous_aggregate_policy (
        'hourly_trips_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'half_daily_trips_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'daily_trips_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'weekly_trips_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'monthly_trips_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'monthly_demand_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );
