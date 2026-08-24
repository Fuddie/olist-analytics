with reviews as (

    select
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp
    from {{ ref('stg_order_reviews') }}

),

aggregated as (

    select
        order_id,
        count(*) as review_count,
        avg(review_score) as average_review_score,
        min(review_score) as minimum_review_score,
        max(review_score) as maximum_review_score,
        count_if(review_comment_message is not null) as review_comment_count,
        min(review_creation_date) as first_review_creation_date,
        max(review_creation_date) as latest_review_creation_date,
        max(review_answer_timestamp) as latest_review_answer_timestamp
    from reviews
    group by order_id

)

select
    order_id,
    review_count,
    average_review_score,
    minimum_review_score,
    maximum_review_score,
    review_comment_count,
    first_review_creation_date,
    latest_review_creation_date,
    latest_review_answer_timestamp
from aggregated
