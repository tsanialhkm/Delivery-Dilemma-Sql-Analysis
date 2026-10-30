# Data dictionary

Names and values retained from source; blank fields become NULL. IDs and postal prefixes stay TEXT. No rows removed or deduplicated. Dates retain original text; no timezone assumed.

## customers (99,441 rows)

| Column | SQLite type |
|---|---|
| customer_id | TEXT |
| customer_unique_id | TEXT |
| customer_zip_code_prefix | TEXT |
| customer_city | TEXT |
| customer_state | TEXT |
## geolocation (1,000,163 rows)

| Column | SQLite type |
|---|---|
| geolocation_zip_code_prefix | TEXT |
| geolocation_lat | REAL |
| geolocation_lng | REAL |
| geolocation_city | TEXT |
| geolocation_state | TEXT |
## order_items (112,650 rows)

| Column | SQLite type |
|---|---|
| order_id | TEXT |
| order_item_id | INTEGER |
| product_id | TEXT |
| seller_id | TEXT |
| shipping_limit_date | TEXT |
| price | REAL |
| freight_value | REAL |
## order_payments (103,886 rows)

| Column | SQLite type |
|---|---|
| order_id | TEXT |
| payment_sequential | INTEGER |
| payment_type | TEXT |
| payment_installments | INTEGER |
| payment_value | REAL |
## order_reviews (99,224 rows)

| Column | SQLite type |
|---|---|
| review_id | TEXT |
| order_id | TEXT |
| review_score | INTEGER |
| review_comment_title | TEXT |
| review_comment_message | TEXT |
| review_creation_date | TEXT |
| review_answer_timestamp | TEXT |
## orders (99,441 rows)

| Column | SQLite type |
|---|---|
| order_id | TEXT |
| customer_id | TEXT |
| order_status | TEXT |
| order_purchase_timestamp | TEXT |
| order_approved_at | TEXT |
| order_delivered_carrier_date | TEXT |
| order_delivered_customer_date | TEXT |
| order_estimated_delivery_date | TEXT |
## products (32,951 rows)

| Column | SQLite type |
|---|---|
| product_id | TEXT |
| product_category_name | TEXT |
| product_name_lenght | INTEGER |
| product_description_lenght | INTEGER |
| product_photos_qty | INTEGER |
| product_weight_g | INTEGER |
| product_length_cm | INTEGER |
| product_height_cm | INTEGER |
| product_width_cm | INTEGER |
## sellers (3,095 rows)

| Column | SQLite type |
|---|---|
| seller_id | TEXT |
| seller_zip_code_prefix | TEXT |
| seller_city | TEXT |
| seller_state | TEXT |
## product_category_name_translation (71 rows)

| Column | SQLite type |
|---|---|
| product_category_name | TEXT |
| product_category_name_english | TEXT |