/*
  This script segments data into meaningful groups to better understand product distribution and customer behavior.
  
  It includes:
  
  Product price segmentation: Groups products into price ranges (e.g., <100, 100-500, etc.) and counts how many products fall into each category.
  Customer segmentation: Classifies customers based on their total spending and lifespan (time between first and last purchase).
  
  Customers are grouped into:
  
  VIP: Long-term customers with high spending
  Regular: Long-term customers with lower spending
  New: Customers with shorter purchase history
*/

--Data Segmentation

--Segmenting the data based off of its price

WITH CTE_Segment AS
(
SELECT 
	product_key,
	product_name,
	product_cost,
	CASE 
		WHEN product_cost<100 THEN '<100'
		WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE '>1000'
	END AS price_range
FROM gold.dim_products
)
SELECT 
price_range,
COUNT(product_key) AS total_products
FROM CTE_Segment
GROUP BY price_range
ORDER BY total_products DESC

--Segmenting the data based off of the customers spending and lifespan,
--lifespan meaning the difference between the first and the latest
--order date

WITH CTE_Spending AS
(
SELECT
c.customer_key,
SUM(f.sales_amount) as total_spending,
MIN(order_date) AS first_order,
MAX(order_date) as last_order,
DATEDIFF (MONTH,MIN(order_date),MAX(order_date)) as lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_id=c.customer_id
GROUP BY c.customer_key 
)

SELECT
customer_status,
COUNT(customer_key) as total_customers
FROM(
	SELECT 
	customer_key,
	CASE
		WHEN lifespan>=12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan>=12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
END AS customer_status
FROM CTE_Spending 
) AS t
GROUP BY customer_status
ORDER BY total_customers DESC
--NOTE: Putting the customer status in a subquerry due to possible changes
--in the future so you dont have to change it twice (once in the select statement
--and once in the GROUP BY clause)
