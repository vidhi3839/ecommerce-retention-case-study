WITH first_seen AS (
  SELECT user_pseudo_id, MIN(PARSE_DATE('%Y%m%d', event_date)) AS acquisition_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id
),
checkout_abandoners AS (
  SELECT DISTINCT user_pseudo_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'begin_checkout'
),
first_purchase AS (
  SELECT user_pseudo_id, MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_purchase_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'purchase'
  GROUP BY user_pseudo_id
)
SELECT
  COUNT(DISTINCT a.user_pseudo_id) AS total_checkout_abandoners,
  COUNT(DISTINCT p.user_pseudo_id) AS eventually_purchased,
  ROUND(SAFE_DIVIDE(COUNT(DISTINCT p.user_pseudo_id), COUNT(DISTINCT a.user_pseudo_id)) * 100, 2) AS pct_who_eventually_purchased
FROM checkout_abandoners a
LEFT JOIN first_purchase p USING (user_pseudo_id);