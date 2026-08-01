WITH session_level AS (
  SELECT
    CONCAT(user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)
    ) AS session_id,
    ANY_VALUE(device.category) AS device_category,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS did_begin_checkout,
    MAX(IF(event_name = 'purchase', 1, 0)) AS did_purchase,
    MAX(IF(event_name = 'page_view', 1, 0)) AS did_page_view
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY session_id
)
SELECT
  device_category,
  COUNT(*) AS sessions,
  SUM(did_begin_checkout) AS checkouts_started,
  SUM(did_purchase) AS purchases,
  ROUND(SAFE_DIVIDE(SUM(did_purchase), SUM(did_begin_checkout)) * 100, 2) AS checkout_to_purchase_pct,
  ROUND(SAFE_DIVIDE(SUM(did_purchase), SUM(did_page_view)) * 100, 2) AS overall_conversion_pct
FROM session_level
GROUP BY device_category
ORDER BY sessions DESC;