/*					LEVEL 1: BASIC EXPLORATION 
 
	->  focus is to understand scale of the data 

1. total numbers of orders processed and current status ALTER */

SELECT 
			order_status ,
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
FROM 	order_payments op 
GROUP BY CASE 
			WHEN op.payment_installments > 1
			THEN 'EMI'
			ELSE 'UPFRONT'
		END ;




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
			EXTRACT(MONTH FROM(o.order_purchase_timestamp))ASC;
			
			

/*						LEVEL 4: MASTER (WINDOW FUNCTIONS, COHORTS & ANALYSIS)
 		
 16.on the basis of revenue find top three sellers from every state
 */
--		VERY IMPORTANT QUERY     
WITH seller_rank AS (
			SELECT 
				s.seller_state,
				COUNT(s.seller_id),
				SUM(oi.price) AS total_price,
				RANK() OVER(PARTITION BY s.seller_state ORDER BY SUM(oi.price) DESC) AS rank
			FROM sellers s 
			JOIN order_items oi ON oi.seller_id = s.seller_id 
			GROUP BY s.seller_state,
				s.seller_id
			ORDER BY total_price DESC )
SELECT 		*
FROM 		seller_rank sr
WHERE 		sr."rank" <= 3 ;


/* 
 17.first purchase year & month of every unique customer
LOGIC:- FIND COHORT YEAR
 */
WITH first_purchase AS (
		    SELECT 
				        c.customer_unique_id,
				        MIN(o.order_purchase_timestamp) AS first_purchase_timestamp,
				        
				        -- PRO HACK: DATE_TRUNC creates a clean 'YYYY-MM-01' date format. 
				        -- This is the industry standard for Cohort grouping.
				        DATE_TRUNC('month', MIN(o.order_purchase_timestamp))::DATE AS cohort_month
		        
		    FROM 		customers c
		    JOIN 		orders o 
		        	ON 	c.customer_id = o.customer_id
		    GROUP BY 
		        		c.customer_unique_id
)
SELECT 	    * 
FROM 		first_purchase;


/*
 18. RFM(RECENCY FREQUENCY MONETARY) ANALYSIS: How many days ago did each customer place their last order?
 */

WITH latest_purchase AS (			
			SELECT  
						c.customer_unique_id ,
						MAX(o.order_purchase_timestamp) AS last_order_date
			FROM 		orders o 
			LEFT JOIN 	customers c ON c.customer_id = o.customer_id 
			GROUP BY 	c.customer_unique_id 
			)
SELECT
			customer_unique_id,
			last_order_date,
			EXTRACT(DAY FROM ('2018-09-01'::TIMESTAMP - last_order_date)) AS days_since_last_order
FROM 		latest_purchase
;




/*19. Moving Average of Revenue (7-Day Rolling).
Logic: Finance teams sales chart smooth karne ke liye moving averages dekhti hain.


*/
WITH DailyRevenue AS (
 SELECT
 DATE(o.order_purchase_timestamp) AS order_date,
 SUM(p.payment_value) AS daily_revenue
 FROM orders o
 JOIN order_payments p ON o.order_id = p.order_id
 GROUP BY DATE(o.order_purchase_timestamp)
)
SELECT
 order_date,
 daily_revenue,
 AVG(daily_revenue) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7d_avg
FROM DailyRevenue
GROUP BY order_date,
 daily_revenue
ORDER BY order_date;


/* 20. Cohort Retention Matrix (Advanced): Of the customers who visited in 2018, how many returned for a purchase in the next three months?
Logic: Core Cohort Retention.
*/
WITH FirstPurchase AS (
 SELECT
 c.customer_unique_id,
 DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
 FROM customers c
 JOIN orders o ON c.customer_id = o.customer_id
 GROUP BY c.customer_unique_id
),
OrderActivity AS (
 SELECT
 f.customer_unique_id,
 f.cohort_month,
 DATE_TRUNC('month', o.order_purchase_timestamp) AS activity_month
 FROM FirstPurchase f
 JOIN customers c ON f.customer_unique_id = c.customer_unique_id
 JOIN orders o ON c.customer_id = o.customer_id
)
SELECT
 cohort_month,
 EXTRACT(MONTH FROM age(activity_month, cohort_month)) AS month_number,
 COUNT(DISTINCT customer_unique_id) AS active_customers
FROM OrderActivity
GROUP BY 1, 2
ORDER BY 1, 2;



