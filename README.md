# user-analytics
This project implements analytics platform like amplitude. This project is heavily inspired from Amplitude and Posthog. 

# Technologies used
1. Clickhouse -> Stores the events and views required to power the analytics dashboard.
2. Apache Flink -> Compute engine used to process streaming events.
3. Kafka -> distrubited data source to store raw events 
4. Postgres -> for storing user profile mapping, blacklisted events, etc.

# Docs
1. [Tech spec](docs/requirements.md)

# Reading material
1. [Posthog data model](https://posthog.com/docs/how-posthog-works/data-model)
2. [User processing](https://posthog.com/docs/how-posthog-works/ingestion-pipeline#2-person-processing)
3. [Anonymous users](https://posthog.com/tutorials/identifying-users-guide)
4. [person_distinct_id](https://posthog.com/handbook/engineering/clickhouse/schema/person-distinct-id)
5. [how to speed up via materialised queries](https://posthog.com/blog/clickhouse-materialized-columns)
6. [segment measurements](https://amplitude.com/docs/analytics/charts/event-segmentation/event-segmentation-choose-measurement)
7. [Posthog ingestion pipeline](https://posthog.com/docs/how-posthog-works/ingestion-pipeline)
8. [materialised views clickhouse](https://clickhouse.com/blog/using-materialized-views-in-clickhouse)
9. [Google analytics using clickhouse](https://clickhouse.com/blog/enhancing-google-analytics-data-with-clickhouse)
10. [Realtime analytics with hex](https://clickhouse.com/blog/building-real-time-applications-with-clickhouse-and-hex-notebook-keeper-engine)
11. [kafka table engine](https://clickhouse.com/docs/en/integrations/kafka/kafka-table-engine)
12. [apache flink introduction](https://www.youtube.com/watch?v=3cg5dABA6mo&list=PLa7VYi0yPIH1UdmQcnUr8lvjbUV8JriK0)
13. [Nova db amplitude](https://amplitude.com/blog/nova-architecture-understanding-user-behavior)
14. [Nova reachitecture](https://amplitude.com/blog/nova-2-0)
15. [Scaling at Amplitude](https://amplitude.com/blog/scaling-analytics-at-amplitude)
16. 