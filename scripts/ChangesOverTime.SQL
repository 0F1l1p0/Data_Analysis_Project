/*
  This script analyzes sales data over time by aggregating monthly metrics from the gold.fact_sales table.
  It calculates total sales, number of unique customers, and total quantity of products sold, grouped by month and year.
  Additional comments are provided within the code
*/


--Overtime analysis

--Finding the total amount of customers per month per year and the total amount of products bought
SELECT 
	DATEPART(YEAR,order_date) as order_year,
	DATEPART(MONTH,order_date) as order_month,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_id) as customer_total,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR,order_date),DATEPART(MONTH,order_date)
ORDER BY DATEPART(YEAR,order_date),DATEPART(MONTH,order_date)

--Finding the total amount of customers per month per year and the total amount of products bought 
--with a format change to 'yyyy-MM'
SELECT 
	FORMAT(order_date, 'yyyy-MM') as order_date,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_id) as customer_total,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY FORMAT(order_date, 'yyyy-MM')

--Finding the total amount of customers per month per year and the total amount of products bought 
--with a format change to 'yyyy-MMM' where it shows the year and the name of the month, which for
--business reports would be the preferred method
WITH CTE_Analysis AS
(
SELECT 
	FORMAT(order_date, 'yyyy-MMM') as order_date_string,
	FORMAT(order_date, 'yyyy-MM') as order_date_format,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_id) as customer_total,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MM'),FORMAT(order_date, 'yyyy-MMM')
)
SELECT 
	order_date_string as order_date,
	total_sales, 
	customer_total,
	total_quantity
FROM CTE_Analysis
ORDER BY order_date_format
