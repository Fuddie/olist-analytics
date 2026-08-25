{{ config(
    materialized='table'
) }}

with products as (

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

category_translation as (

    select
        product_category_name,
        product_category_name_english
    from {{ ref('stg_product_category_name_translation') }}

),

final as (

    select
        p.product_id,
        p.product_category_name as product_category_name_portuguese,
        ct.product_category_name_english,
        p.product_name_length,
        p.product_description_length,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm

    from products as p

    left join category_translation as ct
        on p.product_category_name = ct.product_category_name

)

select
    product_id,
    product_category_name_portuguese,
    product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
from final