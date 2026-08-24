with payments as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from {{ ref('stg_order_payments') }}

),

aggregated as (

    select
        order_id,
        count(*) as payment_count,
        count(distinct payment_type) as payment_method_count,
        max(payment_installments) as max_payment_installments,
        sum(payment_value) as total_payment_value
    from payments
    group by order_id

)

select
    order_id,
    payment_count,
    payment_method_count,
    max_payment_installments,
    total_payment_value
from aggregated