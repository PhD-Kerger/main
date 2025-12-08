SELECT
    add_continuous_aggregate_policy (
        'quarter_hourly_demand_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'hourly_demand_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'half_daily_demand_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'daily_demand_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );

SELECT
    add_continuous_aggregate_policy (
        'weekly_demand_agg',
        start_offset => NULL,
        end_offset => NULL,
        schedule_interval => INTERVAL '1 day'
    );