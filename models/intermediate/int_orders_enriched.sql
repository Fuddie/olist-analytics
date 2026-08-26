with orders as (

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        _loaded_at
    from {{ ref('stg_orders') }}

),

customers as (

    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        _loaded_at
    from {{ ref('stg_customers') }}

),

order_items as (

    select
        order_id,
        item_count,
        distinct_product_count,
        distinct_seller_count,
        total_product_value,
        total_freight_value,
        total_order_item_value,
        record_loaded_at
    from {{ ref('int_order_items_aggregated') }}

),

payments as (

    select
        order_id,
        payment_count,
        payment_method_count,
        max_payment_installments,
        total_payment_value,
        record_loaded_at
    from {{ ref('int_order_payments_aggregated') }}

),

reviews as (

    select
        order_id,
        review_count,
        average_review_score,
        minimum_review_score,
        maximum_review_score,
        review_comment_count,
        first_review_creation_date,
        latest_review_creation_date,
        latest_review_answer_timestamp,
        record_loaded_at
    from {{ ref('int_order_reviews_aggregated') }}

),

enriched as (

    select
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        datediff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) as delivery_days,
        datediff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) as delivery_delay_days,
        oi.item_count,
        oi.distinct_product_count,
        oi.distinct_seller_count,
        oi.total_product_value,
        oi.total_freight_value,
        oi.total_order_item_value,
        p.payment_count,
        p.payment_method_count,
        p.max_payment_installments,
        p.total_payment_value,
        r.review_count,
        r.average_review_score,
        r.minimum_review_score,
        r.maximum_review_score,
        r.review_comment_count,
        r.first_review_creation_date,
        r.latest_review_creation_date,
        r.latest_review_answer_timestamp,
        greatest_ignore_nulls(
            o._loaded_at,
            c._loaded_at,
            oi.record_loaded_at,
            p.record_loaded_at,
            r.record_loaded_at
        ) as record_loaded_at
    from orders as o
    left join customers as c
        on o.customer_id = c.customer_id
    left join order_items as oi
        on o.order_id = oi.order_id
    left join payments as p
        on o.order_id = p.order_id
    left join reviews as r
        on o.order_id = r.order_id

)

select
    order_id,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
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
    latest_review_answer_timestamp,
    record_loaded_at
from enriched
