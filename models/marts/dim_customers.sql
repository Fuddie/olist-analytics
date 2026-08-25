{{ config(
    materialized='table'
) }}

with customers as (

    select
        customer_unique_id,
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        order_purchase_timestamp
    from {{ ref('int_orders_enriched') }}
    where customer_unique_id is not null

),

ranked_customers as (

    select
        customer_unique_id,
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        order_purchase_timestamp,

        row_number() over (
            partition by customer_unique_id
            order by order_purchase_timestamp desc
        ) as customer_record_rank

    from customers

),

customer_summary as (

    select
        customer_unique_id,
        count(distinct customer_id) as customer_record_count,
        min(order_purchase_timestamp) as first_order_timestamp,
        max(order_purchase_timestamp) as latest_order_timestamp
    from customers
    group by customer_unique_id

),

final as (

    select
        r.customer_unique_id,
        r.customer_zip_code_prefix,
        r.customer_city,
        r.customer_state,
        s.customer_record_count,
        s.first_order_timestamp,
        s.latest_order_timestamp

    from ranked_customers as r

    inner join customer_summary as s
        on r.customer_unique_id = s.customer_unique_id

    where r.customer_record_rank = 1

)

select
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    customer_record_count,
    first_order_timestamp,
    latest_order_timestamp
from final