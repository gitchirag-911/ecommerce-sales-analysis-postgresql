
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