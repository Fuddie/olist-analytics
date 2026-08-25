{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
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

    item_count,
    distinct_product_count,
    distinct_seller_count,

    total_product_value,
    total_freight_value,
    total_order_item_value,

    payment_count,
    payment_method_count,
    max_payment_installments,
    total_payment_value,

    review_count,
    average_review_score,
    minimum_review_score,
    maximum_review_score,
    review_comment_count,

    first_review_creation_date,
    latest_review_creation_date,
    latest_review_answer_timestamp

from {{ ref('int_orders_enriched') }}

{% if is_incremental() %}

where order_purchase_timestamp >= (
    select dateadd(
        'day',
        -7,
        max(order_purchase_timestamp)
    )
    from {{ this }}
)

{% endif %}