with source as (
       select
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    from {{ source('olist_raw', 'geolocation') }}

),

cleaned as (
    select
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        trim(geolocation_city) as geolocation_city,
        upper(trim(geolocation_state)) as geolocation_state
    from source
)

select
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
from cleaned