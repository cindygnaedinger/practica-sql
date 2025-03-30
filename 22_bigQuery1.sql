-- 📌 Module 1: SQL Fundamentals in BigQuery
-- 1.1 Basic Queries & Filtering

SELECT * FROM `project.dataset.customers` 
WHERE country = 'USA';

-- Filter by date (BigQuery uses TIMESTAMP)
SELECT * FROM `project.dataset.orders` 
WHERE order_date BETWEEN TIMESTAMP('2023-01-01') AND TIMESTAMP('2023-12-31');
-- SELECT, FROM, WHERE

-- BigQuery’s fully qualified table names (project.dataset.table)

-- Timestamp handling (vs. standard SQL DATETIME)

-- 1.2 Aggregations & GROUP BY

SELECT 
  category,
  SUM(sales) AS total_sales,
  COUNT(DISTINCT order_id) AS order_count
FROM `project.dataset.sales` 
GROUP BY category;