{{ config(severity='warn') }}

select
    order_id,
    total_order_item_value,
    total_payment_value,
    abs(total_order_item_value - total_payment_value) as value_difference
from {{ ref('fct_orders') }}
where abs(total_order_item_value - total_payment_value) > 1
