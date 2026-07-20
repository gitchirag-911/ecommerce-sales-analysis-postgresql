/*					LEVEL 1: BASIC EXPLORATION 
 
	->  focus is to understand scale of the data 

1. total numbers of orders processed and current status ALTER */

SELECT 
			order_status,
			COUNT(order_id) AS order_count
FROM 		orders
GROUP BY 	order_status 
ORDER BY 	order_count DESC;


/*
2. which is the most popular payment method ?
logic :- to track the cashflow ALTER */

SELECT
			payment_type,
			COUNT(order_id) AS count,
			SUM(op.payment_value ) AS total_revenue
FROM		order_payments op 
GROUP BY 	payment_type
ORDER BY 	total_revenue DESC;


/* 
3. from what unique city and state do the customers come from 
logic :- to identify marketing reach 
 */

SELECT 
			customer_state,
			COUNT(DISTINCT customer_city) AS unique_city,
			COUNT(customer_id) AS customer_count
FROM 		customers c 
GROUP BY
			customer_state 
ORDER BY 	customer_count DESC;


/*
4. average order value (AOV) 
logic :- how much avg money a customer spents*/

SELECT 
			AVG(payment_value ) AS avg_payments
FROM 		order_payments ;


/*
 5. customers' review distribution 
 logic :- to get an overview of customer satisfaction 
 */

SELECT 
			review_score,
			COUNT(order_id) AS review_count
FROM 		order_reviews
GROUP BY 	review_score 
ORDER BY 	review_score DESC;