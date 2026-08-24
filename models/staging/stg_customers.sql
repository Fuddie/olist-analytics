with source as (

    select *
    from RAW.OLIST.CUSTOMERS

),

renamed as (

    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        trim(customer_city) as customer_city,
        upper(trim(customer_state)) as customer_state

    from source

)

select *
from renamed