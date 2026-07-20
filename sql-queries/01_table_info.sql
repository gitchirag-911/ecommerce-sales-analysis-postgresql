-- 1. Customers Data Load
COPY customers(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\customers.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 2. Geolocation Data Load
COPY geolocation(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\geolocation.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 3. Order Items Data Load
COPY order_items(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\order_items.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- table4 order reviews
COPY order_reviews(review_id, order_id, review_score, review_comment_title, review_creation_date, review_answer_timestamp)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\order_reviews.csv'
DELIMITER ','
CSV HEADER
ENCODING 'LATIN1';



-- 5. Orders Data Load
COPY orders(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\orders (1).csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 6. Order Payments Data Load
COPY order_payments(order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\payments.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 7. Sellers Data Load
COPY sellers(seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\sellers.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 8. Products Data Load
COPY products(product_id, product_category, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
FROM 'D:\TARGET-eCommerce-Sales-Analysis-PostgreSQL\dataset\products.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';


