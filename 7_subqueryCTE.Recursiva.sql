WITH RECURSIVE cte AS(
    SELECT CAST('2025-01-01' AS DATE) AS date
                UNION ALL
                SELECT dt + INTERVAL 1 DAY
                FROM cte
                WHERE dt < CAST('2025-01-01' AS DATE)
    )
SELECT cte.dt, sales.num_sales,
        COALESCE(sales.num_sales, 
        (LAG(sales.num_sales) OVER() + LEAD(sales.num_sales) OVER()) / 2 ) AS sales_estimates
FROM cte 
LEFT JOIN sales 
ON cte.dt = sales.dt;