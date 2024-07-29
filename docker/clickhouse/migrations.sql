CREATE DATABASE analytics;

USE analytics;

----- Table for Raw events -----

CREATE TABLE analytics.events
(
    `project_id` Int64,
    `event_id` UUID,
    `event` String,
    `device_id` String,
    `user_id` String,
    `platform` Enum8(
        'ios' = 1,
        'android' = 2,
        'web' = 3,
    )
    `os` LowCardinality(String),
    `os_version` String,
    `browser` LowCardinality(String),
    `browser_version` String,
    `device_type` LowCardinality(String),
    `path_name` String,
    `properties` String CODEC(ZSTD(3)),
    `timestamp` DateTime64(6,'UTC'),
    `custom_properties` String CODEC(ZSTD(3)),
    `ingested_at` DateTime64(6,'UTC'),
    `person_properties` String CODEC(ZSTD(3)),
    `session_id` String,
)
ENGINE = Distributed('analytics',
 'analytics',
 'sharded_events',
 sipHash64(device_id));

--- Table for storing sharded events ---
--- This is the table which stores the 

 CREATE TABLE analytics.sharded_events
(
    `project_id` Int64,
    `event_id` UUID,
    `event` String,
    `device_id` String,
    `user_id` String,
    `platform` Enum8(
        'ios' = 1,
        'android' = 2,
        'web' = 3,
    )
    `os` LowCardinality(String),
    `os_version` String,
    `browser` LowCardinality(String),
    `browser_version` String,
    `device_type` LowCardinality(String),
    `path_name` String,
    `properties` String CODEC(ZSTD(3)),
    `timestamp` DateTime64(6, 'UTC'),
    `custom_properties` String CODEC(ZSTD(3)),
    `ingested_at` DateTime64(6, 'UTC'),
    `person_properties` String CODEC(ZSTD(3)),
    `session_id` String,
)
ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/posthog.sharded_events',
 '{replica}',
 _timestamp)
PARTITION BY toYYYYMM(timestamp)
ORDER BY (project_id,
 toDate(timestamp),
 event,
 cityHash64(device_id),
 cityHash64(uuid))
SAMPLE BY cityHash64(device_id)
SETTINGS index_granularity = 8192;

--- Kafka: Transformed events from flink --- 
CREATE TABLE analytics.kafka_events_json
(
    `project_id` Int64,
    `event_id` UUID,
    `event` String,
    `device_id` String,
    `user_id` String,
    `platform` Enum8(
        'ios' = 1,
        'android' = 2,
        'web' = 3,
    )
    `os` LowCardinality(String),
    `os_version` String,
    `browser` LowCardinality(String),
    `browser_version` String,
    `device_type` LowCardinality(String),
    `path_name` String,
    `properties` String CODEC(ZSTD(3)),
    `timestamp` DateTime64(6,'UTC'),
    `custom_properties` String CODEC(ZSTD(3)),
    `ingested_at` DateTime64(6,'UTC'),
    `person_properties` String CODEC(ZSTD(3)),
    `session_id` String,
)
ENGINE = Kafka('kafka',
 'clickhouse_events_json', -- Kafka Topic name
 'raw-events', -- Kafka consumer group
 'JSONEachRow') -- Data type of message
SETTINGS kafka_skip_broken_messages = 100;

---  Materialised view to insert data from kafka stream to table --- 

CREATE MATERIALIZED VIEW analytics.events_json_mv TO analytics.events
(

    `project_id` Int64,
    `event_id` UUID,
    `event` String,
    `device_id` String,
    `user_id` String,
    `platform` Enum8(
        'ios' = 1,
        'android' = 2,
        'web' = 3,
    )
    `os` LowCardinality(String),
    `os_version` String,
    `browser` LowCardinality(String),
    `browser_version` String,
    `device_type` LowCardinality(String),
    `path_name` String,
    `properties` String CODEC(ZSTD(3)),
    `timestamp` DateTime64(6,'UTC'),
    `custom_properties` String CODEC(ZSTD(3)),
    `ingested_at` DateTime64(6,'UTC'),
    `person_properties` String CODEC(ZSTD(3)),
    `session_id` String,
) AS
SELECT
    project_id,
    event_id,
    event,
    device_id,
    user_id,
    platform,
    os,
    os_version,
    browser,
    browser_version,
    device_type,
    path_name,
    properties,
    timestamp,
    custom_properties,
    now64() AS ingested_at,
    person_properties,
    session_id
FROM analytics.kafka_events_json;

-- Additional notes
-- sipHash64 is collition resistance while cityHash64 is more performant.