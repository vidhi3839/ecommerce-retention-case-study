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
raw_steps AS (
  SELECT
    t_pageview IS NOT NULL AS reached_pageview,
    (t_viewitem IS NOT NULL AND t_pageview IS NOT NULL AND t_viewitem > t_pageview) AS step2,
    (t_addtocart IS NOT NULL AND t_viewitem IS NOT NULL AND t_addtocart > t_viewitem) AS step3,
    (t_checkout IS NOT NULL AND t_addtocart IS NOT NULL AND t_checkout > t_addtocart) AS step4,
    (t_purchase IS NOT NULL AND t_checkout IS NOT NULL AND t_purchase > t_checkout) AS step5
  FROM step_timestamps
),
chained AS (
  SELECT
    reached_pageview,
    (reached_pageview AND step2) AS reached_viewitem,
    (reached_pageview AND step2 AND step3) AS reached_addtocart,
    (reached_pageview AND step2 AND step3 AND step4) AS reached_checkout,
    (reached_pageview AND step2 AND step3 AND step4 AND step5) AS reached_purchase
  FROM raw_steps
)
SELECT
  COUNTIF(reached_pageview)  AS step1_page_view,
  COUNTIF(reached_viewitem)  AS step2_view_item,
  COUNTIF(reached_addtocart) AS step3_add_to_cart,
  COUNTIF(reached_checkout)  AS step4_begin_checkout,
  COUNTIF(reached_purchase)  AS step5_purchase,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_viewitem),  COUNTIF(reached_pageview))  * 100, 2) AS pct_pageview_to_viewitem,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_addtocart), COUNTIF(reached_viewitem))  * 100, 2) AS pct_viewitem_to_addtocart,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_checkout),  COUNTIF(reached_addtocart)) * 100, 2) AS pct_addtocart_to_checkout,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_purchase),  COUNTIF(reached_checkout))  * 100, 2) AS pct_checkout_to_purchase,
  ROUND(SAFE_DIVIDE(COUNTIF(reached_purchase),  COUNTIF(reached_pageview))  * 100, 2) AS overall_conversion_rate
FROM chained;