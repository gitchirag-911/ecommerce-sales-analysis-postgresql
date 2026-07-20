CREATE DATABASE project_1;CREATE DATABASE project_1;


--adding tables
-- Puraani tables ko clear karne ke liye (Taki conflicts na aayen)
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS geolocation CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS order_reviews CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS order_payments CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(20),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- 2. Geolocation Table
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(20),
    geolocation_lat DOUBLE PRECISION,
    geolocation_lng DOUBLE PRECISION,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- 3. Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

-- 4. Order Reviews Table
-- Note: Dates ko VARCHAR rakha hai safe load ke liye.
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_creation_date VARCHAR(50), 
    review_answer_timestamp VARCHAR(50)
);

-- 5. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 6. Order Payments Table
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10,2)
);

-- 7. Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(20),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- 8. Products Table
DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

