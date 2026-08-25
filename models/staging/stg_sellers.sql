with source as (
    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    from {{ source('olist_raw', 'sellers') }}

),
 
 cleaned as  (
     select
        seller_id,
        seller_zip_code_prefix,
        trim(seller_city) as seller_city,
        upper(trim(seller_state)) as seller_state
    from source
 )

 select
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
from cleaned