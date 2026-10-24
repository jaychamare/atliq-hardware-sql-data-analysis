/*
Project: AtliQ Hardware - SQL Data Analysis
Source: Codebasics Resume Project Challenge - Ad-hoc Requests
Database: gdb023
SQL dialect: MySQL 8.0+

Purpose
-------
Answer the 10 business questions in the Codebasics AtliQ Hardware SQL challenge.
*/

USE gdb023;

-- =========================================================
-- Q1. List markets where Atliq Exclusive operates in APAC.
-- Tables: dim_customer
-- =========================================================
SELECT DISTINCT
    market
FROM dim_customer
WHERE customer = 'Atliq Exclusive'
  AND region = 'APAC'
ORDER BY market;


-- =========================================================
-- Q2. Percentage increase in unique products in FY2021 vs FY2020.
-- Definition used here: product codes present in monthly sales for each fiscal year.
-- Tables: fact_sales_monthly
-- =========================================================
WITH yearly_product_counts AS (
    SELECT
        COUNT(DISTINCT CASE
            WHEN fiscal_year = 2020 THEN product_code
        END) AS unique_products_2020,
        COUNT(DISTINCT CASE
            WHEN fiscal_year = 2021 THEN product_code
        END) AS unique_products_2021
    FROM fact_sales_monthly
    WHERE fiscal_year IN (2020, 2021)
)
SELECT
    unique_products_2020,
    unique_products_2021,
    ROUND(
        (unique_products_2021 - unique_products_2020) * 100.0
        / NULLIF(unique_products_2020, 0),
        2
    ) AS percentage_chg
FROM yearly_product_counts;


-- =========================================================
-- Q3. Unique product-code count for each segment, descending.
-- Tables: dim_product
-- =========================================================
SELECT
    segment,
    COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC, segment;


-- =========================================================
-- Q4. Segment with the largest increase in unique product codes in FY2021 vs FY2020.
-- Definition used here: product codes present in monthly sales for each fiscal year.
-- Tables: dim_product, fact_sales_monthly
-- =========================================================
WITH segment_year_counts AS (
    SELECT
        p.segment,
        COUNT(DISTINCT CASE
            WHEN s.fiscal_year = 2020 THEN s.product_code
        END) AS product_count_2020,
        COUNT(DISTINCT CASE
            WHEN s.fiscal_year = 2021 THEN s.product_code
        END) AS product_count_2021
    FROM dim_product AS p
    JOIN fact_sales_monthly AS s
        ON p.product_code = s.product_code
    WHERE s.fiscal_year IN (2020, 2021)
    GROUP BY p.segment
)
SELECT
    segment,
    product_count_2020,
    product_count_2021,
    product_count_2021 - product_count_2020 AS difference
FROM segment_year_counts
ORDER BY difference DESC, segment;


-- =========================================================
-- Q5. Products with the highest and lowest manufacturing costs.
-- Returns the highest and lowest product-year records across all years.
-- Tables: fact_manufacturing_cost, dim_product
-- =========================================================
(
    SELECT
        p.product_code,
        p.product,
        m.manufacturing_cost
    FROM fact_manufacturing_cost AS m
    JOIN dim_product AS p
        ON p.product_code = m.product_code
    ORDER BY m.manufacturing_cost DESC, p.product_code
    LIMIT 1
)
UNION ALL
(
    SELECT
        p.product_code,
        p.product,
        m.manufacturing_cost
    FROM fact_manufacturing_cost AS m
    JOIN dim_product AS p
        ON p.product_code = m.product_code
    ORDER BY m.manufacturing_cost ASC, p.product_code
    LIMIT 1
);

-- =========================================================
-- Q6. Top 5 customers by average pre-invoice discount in India, FY2021.
-- Tables: dim_customer, fact_pre_invoice_deductions
-- =========================================================
SELECT
    c.customer_code,
    c.customer,
    ROUND(AVG(d.pre_invoice_discount_pct) * 100, 2)
        AS average_discount_percentage
FROM dim_customer AS c
JOIN fact_pre_invoice_deductions AS d
    ON c.customer_code = d.customer_code
WHERE d.fiscal_year = 2021
  AND c.market = 'India'
GROUP BY
    c.customer_code,
    c.customer
ORDER BY
    AVG(d.pre_invoice_discount_pct) DESC,
    c.customer_code
LIMIT 5;

-- =========================================================
-- Q7. Monthly gross sales amount for Atliq Exclusive.
-- Output: Month, Year, Gross_Sales_Amount.
-- Tables: fact_sales_monthly, fact_gross_price, dim_customer
-- =========================================================
SELECT
    MONTH(s.date) AS Month,
    YEAR(s.date) AS Year,
    ROUND(SUM(s.sold_quantity * gp.gross_price), 2)
        AS Gross_Sales_Amount
FROM fact_sales_monthly AS s
JOIN fact_gross_price AS gp
    ON s.product_code = gp.product_code
   AND s.fiscal_year = gp.fiscal_year
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
WHERE c.customer = 'Atliq Exclusive'
GROUP BY
    YEAR(s.date),
    MONTH(s.date)
ORDER BY
    YEAR(s.date),
    MONTH(s.date);


-- =========================================================
-- Q8. Quarter in FY2020 with maximum total sold quantity.
-- Fiscal quarters: Q1=Sep-Nov, Q2=Dec-Feb, Q3=Mar-May, Q4=Jun-Aug.
-- Tables: fact_sales_monthly
-- =========================================================
SELECT
    CASE
        WHEN MONTH(date) IN (9, 10, 11) THEN 'Q1'
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Q2'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Q3'
        WHEN MONTH(date) IN (6, 7, 8) THEN 'Q4'
    END AS Quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY Quarter
ORDER BY total_sold_quantity DESC;

-- =========================================================
-- Q9. Gross sales by channel and percentage contribution in FY2021.
-- gross_sales_mln is expressed in millions.
-- Tables: fact_sales_monthly, fact_gross_price, dim_customer
-- =========================================================
WITH channel_sales AS (
    SELECT
        c.channel,
        SUM(s.sold_quantity * gp.gross_price) AS gross_sales
    FROM fact_sales_monthly AS s
    JOIN fact_gross_price AS gp
        ON s.product_code = gp.product_code
       AND s.fiscal_year = gp.fiscal_year
    JOIN dim_customer AS c
        ON s.customer_code = c.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY c.channel
)
SELECT
    channel,
    ROUND(gross_sales / 1000000, 2) AS gross_sales_mln,
    ROUND(
        gross_sales * 100.0 / NULLIF(SUM(gross_sales) OVER (), 0),
        2
    ) AS percentage
FROM channel_sales
ORDER BY gross_sales DESC;


-- =========================================================
-- Q10. Top 3 products in each division by total sold quantity in FY2021.
-- DENSE_RANK preserves ties; tied products can result in more than 3 rows/division.
-- Tables: fact_sales_monthly, dim_product
-- =========================================================
WITH product_sales AS (
    SELECT
        p.division,
        s.product_code,
        SUM(s.sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON s.product_code = p.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY
        p.division,
        s.product_code
),
ranked_products AS (
    SELECT
        division,
        product_code,
        total_sold_quantity,
        DENSE_RANK() OVER (
            PARTITION BY division
            ORDER BY total_sold_quantity DESC
        ) AS rank_order
    FROM product_sales
)
SELECT
    division,
    product_code,
    total_sold_quantity,
    rank_order
FROM ranked_products
WHERE rank_order <= 3
ORDER BY
    division,
    rank_order,
    product_code;
