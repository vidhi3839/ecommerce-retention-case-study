-- 1. Confirm which events actually exist and their volume
SELECT
  event_name,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY event_name
ORDER BY event_count DESC;

-- 2. Check specifically for refund/return events (settles the guardrail question from Phase 1)
SELECT DISTINCT event_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND (LOWER(event_name) LIKE '%refund%' OR LOWER(event_name) LIKE '%return%');

-- 3. Null / placeholder rates in key segmentation fields
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(device.category IS NULL OR device.category = '') AS device_category_missing,
  COUNTIF(geo.country IS NULL OR geo.country IN ('(not set)', '<Other>')) AS geo_country_missing,
  COUNTIF(traffic_source.source IS NULL OR traffic_source.source = '') AS traffic_source_missing
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';

-- 4. Sanity check: are event timestamps within a user's session actually increasing?
-- (validates that funnel step ordering is trustworthy — spot-check on a small sample)
SELECT
  user_pseudo_id,
  event_name,
  event_timestamp,
  LAG(event_timestamp) OVER (
    PARTITION BY user_pseudo_id ORDER BY event_timestamp
  ) AS prev_timestamp
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX = '20201201'
  AND user_pseudo_id = (
    SELECT user_pseudo_id
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX = '20201201' AND event_name = 'purchase'
    LIMIT 1
  )
ORDER BY event_timestamp;

--5
SELECT geo.country, COUNT(*) AS row_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY geo.country
ORDER BY row_count DESC
LIMIT 20;