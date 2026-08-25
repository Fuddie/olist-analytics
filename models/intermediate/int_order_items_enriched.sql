with order_items as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value
    from {{ ref('stg_order_items') }}

),

products as (

    select
        product_id,
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    from {{ ref('stg_products') }}

),

sellers as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    from {{ ref('stg_sellers') }}

),

category_translation as (

    select
        product_category_name,
        product_category_name_english,
    from {{ ref('stg_product_category_name_translation') }}

),

enriched as (

    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,

        p.product_category_name as product_category_name_portuguese,
        ct.product_category_name_english,

        s.seller_zip_code_prefix,
        s.seller_city,
        s.seller_state,

        oi.shipping_limit_date,
        oi.price,
        oi.freight_value,
        oi.price + oi.freight_value as total_item_value,

        p.product_name_length,
        p.product_description_length,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm

    from order_items as oi

    left join products as p
        on oi.product_id = p.product_id

    left join sellers as s
        on oi.seller_id = s.seller_id

    left join category_translation as ct
        on p.product_category_name = ct.product_category_name

)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    product_category_name_portuguese,
    product_category_name_english,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    shipping_limit_date,
    price,
    freight_value,
    total_item_value,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
from enriched