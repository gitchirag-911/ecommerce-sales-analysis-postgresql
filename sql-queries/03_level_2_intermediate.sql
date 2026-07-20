/*
								LEVEL 2: INTERMEDIATE (JONS & DATE FUNCTIONS )
					-> focus is to understannd basics of SQL even better and more exploration into SQL 

6. which product category generates the highest revenue 
logic:- better inventory planning */

SELECT 
			p.product_category,
			COUNT(DISTINCT p.product_id ) AS category_count,
			SUM(oi.price) AS total_revenue
FROM 		products p
JOIN 		order_items AS oi ON oi.product_id = p.product_id
GROUP BY	p.product_category
ORDER BY 	total_revenue DESC;


/*
 7. what is the avg delivery time (in days)
 logic:- for better efficiency in logistics & supply chain 
 */

SELECT
			ROUND(AVG(EXTRACT( DAYS FROM( order_delivered_customer_date - order_purchase_timestamp))),0) AS delivery_time
FROM 		orders
WHERE 		order_status = 'delivered';


/*
 8. what are the top 5 states with highest active sellers
 logic:- vendor management 
 */

SELECT 
			s.seller_state,
			COUNT(DISTINCT s.seller_id ) AS seller_count
FROM 		sellers s 
GROUP BY 	s.seller_state 
ORDER BY 	seller_count DESC
LIMIT 5;


/*
 9. what percentage of orders are delivered after estimates delivery date
 logic:- check performance of shipping partners 
 */
-- CASE EXPRESSION USED 
--VERY IMPORTANT QUERY 
SELECT 
		COUNT(
		CASE 
				WHEN o.order_delivered_customer_date > order_estimated_delivery_date 
				THEN 1
		END)*100 /COUNT(order_id) AS late_delivery_pct
FROM orders o
WHERE o.order_status = 'delivered';


/*
 10. price difference between products bought on EMI & cash/UPI
 logic:- to know consuemrs buying behaviour
*/

SELECT 
		CASE 
			WHEN op.payment_installments > 1
			THEN 'EMI'
			ELSE 'UPFRONT'
		END AS payment_mode,
		AVG(payment_value) AS avg_value
FROM order_payments op 
GROUP BY CASE 
			WHEN op.payment_installments > 1
			THEN 'EMI'
			ELSE 'UPFRONT'
		END ;

