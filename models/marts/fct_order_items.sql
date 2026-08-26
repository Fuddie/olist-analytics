{{ config(
    materialized='incremental',
    unique_key=['order_id', 'order_item_id'],
    incremental_strategy='merge',
    on_schema_change='fail'
) }}

with order_items as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value,
        total_item_value,
        record_loaded_at
    from {{ ref('int_order_items_enriched') }}

),

orders as (

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        _loaded_at
    from {{ ref('stg_orders') }}

),

customers as (

    select
        customer_id,
        customer_unique_id,
        _loaded_at
    from {{ ref('stg_customers') }}

)

select
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    c.customer_unique_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.shipping_limit_date,
    oi.price,
    oi.freight_value,
    oi.total_item_value,
    greatest_ignore_nulls(
        oi.record_loaded_at,
        o._loaded_at,
        c._loaded_at
    ) as record_loaded_at
from order_items as oi
inner join orders as o
    on oi.order_id = o.order_id
left join customers as c
    on o.customer_id = c.customer_id

{% if is_incremental() %}
where greatest_ignore_nulls(
    oi.record_loaded_at,
    o._loaded_at,
    c._loaded_at
) > coalesce(
    (select max(record_loaded_at) from {{ this }}),
    '1900-01-01'::timestamp_ntz
)
{% endif %}
