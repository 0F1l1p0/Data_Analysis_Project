/*
This script performs cumulative and trend analysis on sales data over time using window functions.

It calculates a running total of sales per month within each year, resetting at the start of a new year using PARTITION BY. This helps track how sales accumulate over time on a yearly basis.

Additionally, it computes a yearly sales trend, including:

Cumulative yearly sales
A moving average of average prices across years

The queries aggregate key metrics such as total sales, unique customers, total quantity sold, and average price, while excluding records with missing order dates. This provides a clear view of growth patterns and pricing trends over time.
*/

--Cumulative analysis

--Calculating the sales over time 
--(with the partition by year function it resets the count everytime theres a new year)
SELECT 
	CAST(order_year as NVARCHAR)+'-'+CAST(order_month AS NVARCHAR) AS order_date,
	SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_year,order_month) AS sales_over_time
	--Partitioning it by year to see each years running total
FROM
(
SELECT 
	DATEPART(YEAR,order_date) as order_year,
	DATEPART(MONTH,order_date) as order_month,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_id) as customer_total,
	SUM(quantity) as total_quantity,
	AVG(sls_price) as avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR,order_date),DATEPART(MONTH,order_date)
) as t
ORDER BY order_year,order_month

--Calculating the moving average of sales per year
SELECT 
	CAST(order_year as NVARCHAR) as order_date,
	SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_year) AS sales_over_time, 
	AVG(avg_price) OVER (ORDER BY order_year) as moving_average_year
FROM
(
SELECT 
	DATEPART(YEAR,order_date) as order_year,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_id) as customer_total,
	SUM(quantity) as total_quantity,
	AVG(sls_price) as avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR,order_date)
) as t
ORDER BY order_year
