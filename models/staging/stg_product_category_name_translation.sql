with source as (

    select
        product_category_name,
        product_category_name_english
    from {{ source('olist_raw', 'product_category_name_translation') }}

),

cleaned as (

    select
        nullif(trim(product_category_name), '') as product_category_name,
        nullif(trim(product_category_name_english), '') as product_category_name_english
    from source

)

select
    product_category_name,
    product_category_name_english
from cleaned