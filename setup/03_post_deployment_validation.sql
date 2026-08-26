-- Post-deployment validation for the hardened analytics schemas.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM PROD.ANALYTICS_MARTS.FCT_ORDERS;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id || '-' || order_item_id) AS unique_order_items
FROM PROD.ANALYTICS_MARTS.FCT_ORDER_ITEMS;

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS row_count
FROM PROD.ANALYTICS_MARTS.FCT_ORDER_ITEMS
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
    COUNT_IF(record_loaded_at IS NULL) AS null_order_watermarks
FROM PROD.ANALYTICS_MARTS.FCT_ORDERS;

SELECT
    COUNT_IF(record_loaded_at IS NULL) AS null_order_item_watermarks
FROM PROD.ANALYTICS_MARTS.FCT_ORDER_ITEMS;

SELECT
    table_schema,
    table_name,
    table_type
FROM PROD.INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('ANALYTICS_STAGING', 'ANALYTICS_INTERMEDIATE', 'ANALYTICS_MARTS')
ORDER BY table_schema, table_name;
