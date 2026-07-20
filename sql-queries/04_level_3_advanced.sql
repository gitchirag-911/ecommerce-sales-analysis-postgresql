
/*							LEVEL 3: ADVANCED (SUBQUERIES & CTEs)


11. orders canceled but payment deducted, refund required
logic:- refund tracking system */
WITH canceled_orders AS (
			SELECT
					order_status,order_id
			FROM 	orders o
			WHERE 	order_status = 'canceled')
SELECT
			canceled_orders.order_id,
			canceled_orders.order_status,
			op.payment_value 
FROM 		canceled_orders
JOIN 		order_payments op ON op.order_id = canceled_orders.order_id
WHERE 		op.payment_value > 0
ORDER BY 	op.payment_value  DESC;


/*
 12.correlation between late delivery and bad reviews(1-2 stars)
*/
WITH late_delivery AS (
			SELECT
						order_id,
						EXTRACT(DAYS FROM(order_delivered_customer_date - order_estimated_delivery_date)) AS dd
			FROM 		orders 
			WHERE 		order_delivered_customer_date > order_estimated_delivery_date
)

SELECT 
		    r.review_score,
		    COUNT(l.order_id)
FROM 		late_delivery l
JOIN 		order_reviews r ON r.order_id = l.order_id
WHERE 		r.review_score <= 2
GROUP BY 	r.review_score;


/*
13.Find out top 10 sellers who collected the highest freight/shipping charges
*/


SELECT
			seller_id,
			SUM(freight_value) AS total_freight
FROM 		order_items 
GROUP BY 	seller_id 
ORDER BY 	total_freight DESC
LIMIT 		10;



/*
 14. what is customer repetition rate and what number of customers have ordered more than once ?
 */
--		VERY IMPORTANT QUERY 

WITH customer_orders AS (
		SELECT
					c.customer_unique_id ,
					COUNT(o.order_id) AS total_orders
		FROM 		customers c
		LEFT JOIN   orders o ON c.customer_id = o.customer_id
		GROUP BY    c.customer_unique_id
		ORDER BY 	total_orders DESC )
SELECT 
		COUNT(CASE 
				WHEN cro.total_orders > 1 
				THEN 1
		END) * 100 / COUNT(cro.customer_unique_id) AS repeat_pct
FROM customer_orders cro


/*
 15.month over month revenue trend 
 loigc:- P&L growth check
 */
--		VERY IMPORTANT QUERY 

SELECT 
			EXTRACT(YEAR FROM(o.order_purchase_timestamp)) AS year_order,
			EXTRACT(MONTH FROM(o.order_purchase_timestamp))AS month_order,
			SUM(p.payment_value) AS revenue
FROM		orders o
JOIN		order_payments p ON o.order_id = p.order_id
GROUP BY 	EXTRACT(YEAR FROM(o.order_purchase_timestamp)) ,
			EXTRACT(MONTH FROM(o.order_purchase_timestamp))
ORDER BY 	EXTRACT(YEAR FROM(o.order_purchase_timestamp)),
			EXTRACT(MONTH FROM(o.order_purchase_timestamp))ASC