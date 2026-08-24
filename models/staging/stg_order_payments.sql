with source as (
    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
    from {{ source('olist_raw', 'order_payments') }}
),


    renamed as (

    select
        order_id,
        payment_sequential,
        lower(trim(payment_type)) as payment_type,
        payment_installments,
        payment_value,
    from source
)

select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
from renamed
