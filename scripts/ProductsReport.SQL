/*
  This script creates a view that aggregates and summarizes product-level performance for reporting and analysis.
  
  It:
  
  Combines sales and product data into a unified dataset
  Calculates key metrics per product, including total sales, total orders, total quantity sold, and number of unique customers
  Tracks product activity with last sale date, recency, and lifespan (time between first and last sale)
  Computes pricing insights such as average selling price and average order revenue
  Segments products into performance categories (High-Performer, Mid-Range, Low-Performer) based on total sales
  Derives average monthly revenue to evaluate consistent product performance over time
  
  The final view provides a comprehensive overview of product performance, making it useful for business reporting, product analysis, and decision-making.

  
*/

CREATE VIEW gold.Final_Report_Products AS
WITH CTE_Report AS (
---------------------------------------------------
--Retrieves the needed columns for the report
---------------------------------------------------
    SELECT
        f.order_number,
        f.order_date,
        f.customer_id,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
    ON p.product_key=f.product_key
    LEFT JOIN gold.dim_customers c
    ON c.customer_id=f.customer_id
    WHERE order_date IS NOT NULL -- only consider valid sales dates
),
CTE_Aggregation AS
(
SELECT
---------------------------------------------------
--Summarizes key columns needed for the report
---------------------------------------------------
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM CTE_Report
GROUP BY 
    product_key,
    product_name,
    category,
    subcategory,
    product_cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Average order revenue
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average monthly revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM CTE_Aggregation


