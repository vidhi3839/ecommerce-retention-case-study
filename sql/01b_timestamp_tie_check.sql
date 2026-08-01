WITH ordered_events AS (
  SELECT
    CONCAT(user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)
    ) AS session_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN ('page_view', 'view_item')
),
step_timestamps AS (
  SELECT
    session_id,
    MIN(IF(event_name = 'page_view', event_timestamp, NULL)) AS t_pageview,
    MIN(IF(event_name = 'view_item', event_timestamp, NULL)) AS t_viewitem
  FROM ordered_events
  GROUP BY session_id
)
SELECT
  COUNTIF(t_viewitem = t_pageview) AS tied_timestamps,
  COUNTIF(t_viewitem > t_pageview) AS strictly_after,
  COUNTIF(t_viewitem < t_pageview) AS before_pageview,
  COUNT(*) AS total_sessions_with_both
FROM step_timestamps
WHERE t_pageview IS NOT NULL AND t_viewitem IS NOT NULL;