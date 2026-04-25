/*
  This script analyzes how total sales are distributed across different dimensions by calculating each segment’s percentage contribution to overall sales.
  
  It includes:
  
  Category-level distribution: Shows how much each product category contributes to total sales.
  Country-level distribution: Breaks down sales by customer location.
  Gender-level distribution: Compares sales contribution across customer genders.
  Age group distribution: Segments customers into age groups (based on their age at the time of purchase) and calculates their share of total sales.
  
  All calculations use window functions to derive overall totals and compute percentage contributions, providing a clear view of which segments drive the most revenue.
*/

--Proportional analysis

--Calculating the percentage of sales for each category 
WITH CTE_Category AS
(
SELECT 
	category,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
GROUP BY category
)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CAST(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100,2) AS nvarchar)+'%' AS percentage_of_sales
FROM CTE_Category
ORDER BY total_sales DESC

--Calculating the percentage of sales for each country

WITH CTE_Country AS
(
SELECT 
	country,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
LEFT JOIN gold.dim_customers c
ON c.customer_id=f.customer_id
GROUP BY country
)
SELECT
	country,
	total_sales,
	CAST(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100,2) AS nvarchar)+'%' AS percentage_of_sales
FROM CTE_Country
ORDER BY total_sales DESC

--Calculating the percentage of sales by gender

WITH CTE_Gender AS
(
SELECT 
	gender,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
LEFT JOIN gold.dim_customers c
ON c.customer_id=f.customer_id
GROUP BY gender
)
SELECT
	gender,
	total_sales,
	CAST(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100,2) AS nvarchar)+'%' AS percentage_of_sales
FROM CTE_Gender
ORDER BY total_sales DESC

--Calculating the percentage of sales by age group
--Additional checks have been inserted to see if they've had their 
--birthday in the current year(You always take the order date because it shows
--the actual age of the customer when they placed an order

WITH CTE_AgeGroup AS
(
SELECT 
	CASE 
        
		WHEN DATEDIFF(YEAR,birth_date, order_date)
			-CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,birth_date, order_date),birth_date)>order_date
			THEN 1 ELSE 0
			END
		<18 THEN '<18'

		WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 18 AND 24 THEN '18-24'

		WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 25 AND 34 THEN '25-34'

        WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 35 AND 44 THEN '35-44'

        WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 45 AND 54 THEN '45-54'

		WHEN DATEDIFF(YEAR,birth_date, order_date)
			-CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,birth_date, order_date),birth_date)>order_date
			THEN 1 ELSE 0
			END
		>64 THEN '65+'

	    ELSE 'Age Not Specified'
	END AS age_group,

	SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
LEFT JOIN gold.dim_customers c
ON c.customer_id=f.customer_id
GROUP BY 
CASE 

        WHEN DATEDIFF(YEAR,birth_date, order_date)
            -CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,birth_date, order_date),birth_date)>order_date
            THEN 1 ELSE 0
            END
        <18 THEN '<18'

        WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 18 AND 24 THEN '18-24'

        WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 25 AND 34 THEN '25-34'

        WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 35 AND 44 THEN '35-44'

        WHEN DATEDIFF(YEAR, birth_date, order_date)
            - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, birth_date, order_date), birth_date) > order_date
            THEN 1 ELSE 0
            END 
        BETWEEN 45 AND 54 THEN '45-54'

        WHEN DATEDIFF(YEAR,birth_date, order_date)
            -CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,birth_date, order_date),birth_date)>order_date
            THEN 1 ELSE 0
            END
        >64 THEN '65+'

        ELSE 'Age Not Specified'
    END
)
SELECT
	age_group,
	total_sales,
	CAST(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100,2) AS nvarchar)+'%' AS percentage_of_sales
FROM CTE_AgeGroup
ORDER BY total_sales DESC
