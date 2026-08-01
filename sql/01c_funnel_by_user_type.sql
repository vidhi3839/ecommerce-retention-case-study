WITH ordered_events AS (
  SELECT
    CONCAT(user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)
    ) AS session_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN ('page_view', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase')
),
session_meta AS (
  SELECT
    CONCAT(user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)
    ) AS session_id,
    MAX((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number')) AS session_number
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY session_id
),
step_timestamps AS (
  SELECT
    session_id,
    MIN(IF(event_name = 'page_view', event_timestamp, NULL))      AS t_pageview,
    MIN(IF(event_name = 'view_item', event_timestamp, NULL))      AS t_viewitem,
    MIN(IF(event_name = 'add_to_cart', event_timestamp, NULL))    AS t_addtocart,
    MIN(IF(event_name = 'begin_checkout', event_timestamp, NULL)) AS t_checkout,
    MIN(IF(event_name = 'purchase', event_timestamp, NULL))       AS t_purchase
  FROM ordered_events
  GROUP BY session_id
),
funnel_flags AS (
  SELECT
    s.session_id,
    IF(m.session_number = 1, 'new_user', 'returning_user') AS user_type,
    s.t_pageview IS NOT NULL AS reached_pageview,
    (s.t_viewitem IS NOT NULL AND s.t_pageview IS NOT NULL AND s.t_viewitem > s.t_pageview) AS step2,
    (s.t_addtocart IS NOT NULL AND s.t_viewitem IS NOT NULL AND s.t_addtocart > s.t_viewitem) AS step3_raw,
    (s.t_checkout IS NOT NULL AND s.t_addtocart IS NOT NULL AND s.t_checkout > s.t_addtocart) AS step4_raw,
    (s.t_purchase IS NOT NULL AND s.t_checkout IS NOT NULL AND s.t_purchase > s.t_checkout) AS step5_raw
  FROM step_timestamps s
  JOIN session_meta m USING (session_id)
),
chained AS (
  SELECT
    user_type,
    reached_pageview,
    (reached_pageview AND step2) AS reached_viewitem,
    (reached_pageview AND step2 AND step3_raw) AS reached_addtocart,
    (reached_pageview AND step2 AND step3_raw AND step4_raw) AS reached_checkout,
    (reached_pageview AND step2 AND step3_raw AND step4_raw AND step5_raw) AS reached_purchase
  FROM funnel_flags
)
SELECT
  user_type,
  COUNTIF(reached_pageview)  AS step1_page_view,
  COUNTIF(reached_viewitem)  AS step2_view_item,
  COUNTIF(reached_addtocart) AS step3_add_to_cart,
  COUNTIF(reached_checkout)  AS step4_begin_checkout,
  COUNTIF(reached_purchase)  AS step5_purchase,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_checkout), COUNTIF(reached_addtocart)) * 100, 2) AS pct_addtocart_to_checkout,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_purchase), COUNTIF(reached_checkout)) * 100, 2) AS pct_checkout_to_purchase
FROM chained
GROUP BY user_type;