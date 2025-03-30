-- 📌 Module 1: SQL Fundamentals in BigQuery
-- SELECT, FROM, WHERE

-- BigQuery’s fully qualified table names (project.dataset.table)

-- Timestamp handling (vs. standard SQL DATETIME)

SELECT * FROM `project.dataset.customers` 
WHERE country = 'USA';

-- Filter by date (BigQuery uses TIMESTAMP)
SELECT * FROM `project.dataset.orders` 
WHERE order_date BETWEEN TIMESTAMP('2023-01-01') AND TIMESTAMP('2023-12-31');