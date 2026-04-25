/*
Performance Analysis Report

This script evaluates product-level sales performance over time by comparing current results against historical benchmarks.

It includes:

Yearly performance vs. average: Compares each product’s yearly sales to its overall average and labels performance as above or below average.
Year-over-year comparison: Uses LAG to measure changes from the previous year, highlighting increases or decreases in sales.
Monthly performance vs. average: Applies the same average comparison at a monthly level for more granular insights.
Month-over-month comparison: Tracks short-term trends by comparing each month’s sales to the previous month.

The analysis uses window functions to calculate averages and differences, helping identify trends, growth patterns, and underperforming products over time.

--Performance analysis report
--Comparing the current total yearly sales to the average sales performance 
*/

WITH CTE_YearlySales AS
(
SELECT 
	DATEPART(YEAR,f.order_date) as order_year,
	p.product_name,
	SUM(f.sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY DATEPART(YEAR,f.order_date),p.product_name
)
SELECT 
	order_year,
	product_name,
	total_sales,
	AVG(total_sales) OVER (PARTITION BY product_name) as avg_sales,
	total_sales-AVG(total_sales) OVER (PARTITION BY product_name) as sales_diff,
	CASE
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Avg'
	END AS avg_change
FROM CTE_YearlySales
ORDER BY product_name,order_year

--Comparing the current years total sales to the previous years total sales
GO

WITH CTE_PriorYear AS
(
SELECT 
	DATEPART(YEAR,f.order_date) as order_year,
	p.product_name,
	SUM(f.sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY DATEPART(YEAR,f.order_date),p.product_name
)
SELECT 
	order_year,
	product_name,
	total_sales,
	AVG(total_sales) OVER (PARTITION BY product_name) as avg_sales,
	total_sales-AVG(total_sales) OVER (PARTITION BY product_name) as sales_diff,
	CASE
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Avg'
	END AS avg_change,
	LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) as previous_sales,
	total_sales-LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) as previous_diff,
	CASE
		WHEN total_sales-LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
		WHEN total_sales-LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
		ELSE 'No changes'
	END AS previous_change
FROM CTE_PriorYear
ORDER BY product_name,order_year

--Comparing the current total monthly sales to the average sales performance 

WITH CTE_MonthlySales AS
(
SELECT 
	DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1) AS order_month,
	p.product_name,
	SUM(f.sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY DATEPART(YEAR,f.order_date),DATEPART(MONTH,f.order_date),p.product_name
)
SELECT 
	order_month,
	product_name,
	total_sales,
	AVG(total_sales) OVER (PARTITION BY product_name) as avg_sales,
	total_sales-AVG(total_sales) OVER (PARTITION BY product_name) as sales_diff,
	CASE
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Avg'
	END AS avg_change
FROM CTE_MonthlySales
ORDER BY product_name,order_month

--Comparing the current monthly total sales to the previous monthly total sales

WITH CTE_PriorMonth AS
(
SELECT 
	DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1) AS order_month,
	p.product_name,
	SUM(f.sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY DATEPART(YEAR,f.order_date),DATEPART(MONTH,f.order_date),p.product_name
)
SELECT 
	order_month,
	product_name,
	total_sales,
	AVG(total_sales) OVER (PARTITION BY product_name) as avg_sales,
	total_sales-AVG(total_sales) OVER (PARTITION BY product_name) as sales_diff,
	CASE
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN total_sales-AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Avg'
	END AS avg_change,
	LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) as previous_sales,
	total_sales-LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) as previous_diff,
	CASE
		WHEN total_sales-LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) > 0 THEN 'Increase'
		WHEN total_sales-LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_month ASC) < 0 THEN 'Decrease'
		ELSE 'No changes'
	END AS previous_change
FROM CTE_PriorMonth
ORDER BY product_name,order_month
