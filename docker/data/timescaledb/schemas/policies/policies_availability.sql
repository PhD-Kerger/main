SELECT
    add_continuous_aggregate_policy (
        'quarter_hourly_availability_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'hourly_availability_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'half_daily_availability_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'daily_availability_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'weekly_availability_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'monthly_availability_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );