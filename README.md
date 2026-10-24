# AtliQ Hardware SQL Data Analysis

## Project Overview

This project analyzes AtliQ Hardware's sales, products, customers, pricing, manufacturing costs, and pre-invoice discounts using SQL.

It is based on the **AtliQ Hardware Ad-hoc Requests** from the Codebasics Resume Project Challenge. The goal is to answer business questions with SQL and turn relational data into insights that can support business decisions.

## Objectives

- Analyze customer markets and regional presence.
- Compare the number of unique products across fiscal years and product segments.
- Identify products with the highest and lowest manufacturing costs.
- Find customers receiving the highest average pre-invoice discounts.
- Calculate monthly gross sales and quarterly sales volume.
- Measure each sales channel's contribution to gross sales.
- Rank the top-selling products within each division.

## Tools and Technologies

- **MySQL 8.0+** — SQL querying and analysis
- **MySQL Workbench** — query execution and result validation
- **Git and GitHub** — version control and project sharing

## Database

The project uses the `gdb023` database and the following tables:

| Table | Purpose |
|---|---|
| `dim_customer` | Customer details, market, region, and sales channel |
| `dim_product` | Product details, division, segment, and category |
| `fact_gross_price` | Product gross prices by fiscal year |
| `fact_manufacturing_cost` | Product manufacturing costs by cost year |
| `fact_pre_invoice_deductions` | Customer pre-invoice discount percentages by fiscal year |
| `fact_sales_monthly` | Monthly sales date, product, customer, sold quantity, and fiscal year |

### Main relationships

- `fact_sales_monthly.product_code` joins to `dim_product.product_code`.
- `fact_sales_monthly.customer_code` joins to `dim_customer.customer_code`.
- Sales rows join to `fact_gross_price` using both `product_code` and `fiscal_year`.
- Customer discount records join to `dim_customer` using `customer_code`.

## Business Questions and SQL Analysis

The SQL file contains solutions for these 10 questions:

1. **Markets in APAC:** Find the markets where Atliq Exclusive operates in the APAC region.
2. **Unique products year over year:** Count unique products in fiscal years 2020 and 2021 and calculate the percentage change.
3. **Products by segment:** Count unique products in each segment and sort the segments by product count.
4. **Segment product growth:** Compare unique product counts between fiscal years 2020 and 2021 for each segment.
5. **Manufacturing cost extremes:** Identify the products with the highest and lowest manufacturing costs.
6. **Highest average discounts:** Find the top five customers by average pre-invoice discount in India for fiscal year 2021.
7. **Monthly gross sales:** Calculate monthly gross sales for Atliq Exclusive.
8. **Quarterly sales quantity:** Find quarterly sold quantities in fiscal year 2020 and identify the quarter with the highest volume.
9. **Channel contribution:** Calculate gross sales by channel and each channel's percentage contribution in fiscal year 2021.
10. **Top products by division:** Rank products by total sold quantity within each division for fiscal year 2021 and return ranks up to three.

## SQL Concepts Demonstrated

- `SELECT`, `WHERE`, and `ORDER BY`
- Aggregate functions: `COUNT()`, `SUM()`, and `AVG()`
- `GROUP BY`
- `JOIN` operations
- Conditional aggregation with `CASE`
- Common Table Expressions (CTEs)
- Window functions: `SUM() OVER()` and `DENSE_RANK()`
- Date functions such as `MONTH()`, `MONTHNAME()`, and `YEAR()`
- Percentage calculations, rounding, and ranking

## How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Make sure you have authorized access to the `gdb023` database and its six tables.
3. Open `sql/atliq_hardware_analysis.sql` in MySQL Workbench.
4. Confirm the database name in the `USE gdb023;` statement.
5. Execute each numbered query separately.
6. Review the result set and compare it with the relevant business question.
7. Capture selected result screenshots if you want to include them in a `results/` folder.

> **Data access:** The SQL file contains queries, not the database itself. Obtain the challenge dataset separately and follow its applicable usage terms.

## Key Findings

The following observations are based on query outputs recorded while working through the challenge. Re-run the queries against your database to confirm the figures before presenting them publicly.

- **Unique products:** The initial count from `fact_gross_price` was 245 in fiscal year 2020 and 334 in fiscal year 2021, a 36.33% increase. The current SQL file uses `fact_sales_monthly` for this metric, so its output may differ.
- **Product segments:** The recorded product counts in `dim_product` were Notebook (129), Accessories (116), Peripherals (84), Desktop (32), Storage (27), and Networking (9).
- **Discounts in India:** The top five customers by average pre-invoice discount in fiscal year 2021 were Flipkart (30.83%), Viveks (30.38%), Ezone (30.28%), Croma (30.25%), and Amazon (29.33%).
- **Quarterly sales volume:** Fiscal Q1 had the highest total sold quantity in fiscal year 2020 in the recorded output, with 7,005,619 units.
- **Sales channel mix:** In fiscal year 2021, recorded gross sales were 1,219.08 million for Retailer (73.23%), 257.53 million for Direct (15.47%), and 188.03 million for Distributor (11.30%).
- **Top products by division:** The recorded query output returned the top three ranked products for divisions N & S, P & A, and PC. See the SQL query output for product codes and quantities.

**Important:** Gross sales is calculated as sold quantity multiplied by gross price. It is not the same as net sales, revenue after discounts, or profit.

## Validation Notes and Assumptions

- The SQL file targets **MySQL 8.0+**, because it uses CTEs and window functions.
- The current unique-product year-over-year queries (Questions 2 and 4) count products represented in `fact_sales_monthly`. Confirm that this matches the challenge's intended definition before treating the results as final.
- Question 5 returns the highest and lowest manufacturing-cost records across the years available in `fact_manufacturing_cost`. If the business question requires a particular year, add a `cost_year` filter.
- Question 7 groups by calendar year and calendar month derived from `date`. The dataset's fiscal year begins in September, so calendar-year and fiscal-year reporting should not be confused.
- Question 8 uses fiscal quarters: Q1 = September–November, Q2 = December–February, Q3 = March–May, and Q4 = June–August.
- Question 10 uses `DENSE_RANK()`. If products tie at rank three, more than three products may be returned for a division.
- The queries were prepared and reviewed, but the full SQL file has not been executed against the user's local database as part of this README creation. Validate each query and result before publishing.

## Repository Structure

```text
atliq-hardware-sql-data-analysis/
├── README.md
├── sql/
│   └── atliq_hardware_analysis.sql
└── results/
    └── (optional screenshots or summaries)
```

## Future Improvements

- Validate all query outputs against the original challenge requirements.
- Add selected result screenshots and concise explanations of each insight.
- Build a Power BI dashboard to present sales, discount, product, and channel trends.
- Add a short business recommendations section after the findings are validated.

## Author

**Jay**  
Data Analyst Portfolio Project

---

This project was completed for learning and portfolio development using the Codebasics AtliQ Hardware challenge. Follow the original challenge's terms when using or sharing its datasets and materials.
