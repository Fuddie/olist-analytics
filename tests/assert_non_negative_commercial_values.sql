select
    order_id,
    total_product_value,
    total_freight_value,
    total_order_item_value,
    total_payment_value
from {{ ref('fct_orders') }}
where total_product_value < 0
   or total_freight_value < 0
   or total_order_item_value < 0
   or total_payment_value < 0
