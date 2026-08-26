{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='fail'
) }}

select
    order_id,
    customer_unique_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    delivery_days,
    delivery_delay_days,
    coalesce(item_count, 0) as item_count,
    coalesce(distinct_product_count, 0) as distinct_product_count,
    coalesce(distinct_seller_count, 0) as distinct_seller_count,
    coalesce(total_product_value, 0) as total_product_value,
    coalesce(total_freight_value, 0) as total_freight_value,
    coalesce(total_order_item_value, 0) as total_order_item_value,
    coalesce(payment_count, 0) as payment_count,
    coalesce(payment_method_count, 0) as payment_method_count,
    coalesce(max_payment_installments, 0) as max_payment_installments,
    coalesce(total_payment_value, 0) as total_payment_value,
    coalesce(review_count, 0) as review_count,
    average_review_score,
    minimum_review_score,
    maximum_review_score,
    coalesce(review_comment_count, 0) as review_comment_count,
    first_review_creation_date,
    latest_review_creation_date,
    latest_review_answer_timestamp,
    record_loaded_at
from {{ ref('int_orders_enriched') }}

{% if is_incremental() %}
where record_loaded_at > coalesce(
    (select max(record_loaded_at) from {{ this }}),
    '1900-01-01'::timestamp_ntz
)
{% endif %}
