with source as (

    select
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        _loaded_at
    from {{ source('olist_raw', 'order_reviews') }}

),

cleaned as (

    select
        review_id,
        order_id,
        review_score,
        nullif(trim(review_comment_title), '') as review_comment_title,
        nullif(trim(review_comment_message), '') as review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        _loaded_at
    from source

)

select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    _loaded_at
from cleaned
