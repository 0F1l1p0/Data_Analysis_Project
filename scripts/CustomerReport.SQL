/*
This script creates a view that consolidates and summarizes customer-level data for reporting and analysis.

It:

Combines sales and customer data to build a unified dataset
Aggregates key metrics per customer, including total orders, total sales, total quantity, and number of products purchased
Calculates additional insights such as customer lifespan, recency (time since last purchase), and average order value
Segments customers into age groups and status categories (VIP, Regular, New) based on spending and activity
Derives metrics like average monthly spend to better understand customer value over time

The final view provides a comprehensive snapshot of customer behavior, making it suitable for dashboards, reporting, and further analysis.

In order to see the view run the command 'SELECT * FROM gold.Final_Report_Customers
*/

CREATE VIEW gold.Final_Report_Customers AS
WITH CTE_Report AS
(
---------------------------------------------------
--Retrieves the needed columns for the report
---------------------------------------------------
SELECT 
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    c.first_name+' '+c.last_name AS customer_name,
    DATEDIFF(YEAR,c.birth_date, GETDATE()) AS customer_age --This represents the current age of the customer
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
LEFT JOIN gold.dim_customers c
ON c.customer_id=f.customer_id
WHERE order_date IS NOT NULL
),
CTE_Aggregation AS
(
---------------------------------------------------
--Summarizes key columns needed for the report
---------------------------------------------------
SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    DATEDIFF (MONTH,MIN(order_date),MAX(order_date)) as lifespan
FROM CTE_Report
GROUP BY customer_key,
        customer_number,
        customer_name,
        customer_age
)
SELECT 
    customer_key,
    customer_number,
    customer_name,
    customer_age,
    CASE 
            WHEN customer_age < 18 THEN '<18'
            WHEN customer_age BETWEEN 18 AND 24 THEN '18-24'
            WHEN customer_age BETWEEN 25 AND 34 THEN '25-34'
            WHEN customer_age BETWEEN 35 AND 44 THEN '35-44'
            WHEN customer_age BETWEEN 45 AND 54 THEN '45-54'
            WHEN customer_age BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65+'
    END AS age_group,
    CASE
		WHEN lifespan>=12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan>=12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
    END AS customer_status,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    --Average order value (additionally making sure that if
    --the total_orders from a customers equals 0 the 
    --avg_order_value is 0)
    CASE
        WHEN total_orders=0 THEN 0
        ELSE total_sales/total_orders 
    END AS avg_order_value,
    CASE
        WHEN lifespan=0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM CTE_aggregation
