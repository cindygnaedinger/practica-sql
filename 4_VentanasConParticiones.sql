-- Escribe una consulta SQL que devuelva: El customer_id. El número total de pedidos completados por cada cliente. El ranking de cada cliente basado en el número de pedidos completados, pero calculado dentro de su grupo de región (usando PARTITION BY).
WITH CTE_pedidos_completados AS(
    SELECT o.customer_id,
    c.region,
    COUNT(o.order_id) AS total_pedidos
    FROM orders o 
    INNER JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
    GROUP BY o.customer_id, c.region
)
SELECT 
    customer_id,
    region,
    total_pedidos,
    RANK() OVER(PARTITION BY region ORDER BY total_pedidos DESC) AS ranking
    FROM CTE_pedidos_completados
    ORDER BY region, ranking;

-- Escribe una consulta SQL que devuelva: El customer_id. El número total de pedidos completados por cada cliente. El ranking de cada cliente basado en el número de pedidos completados, calculado dentro de su grupo de región (usando PARTITION BY). Filtra los resultados para incluir solo aquellos clientes que tienen más de 1 pedido completado.
WITH CTE_pedidos_completados AS (
    SELECT
        o.customer_id,
        c.region,
        COUNT(o.order_id) AS total_pedidos 
    FROM orders o 
    INNER JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
    GROUP BY o.customer_id, c.region
)
SELECT
    customer_id,
    total_pedidos,
    RANK() OVER (PARTITION BY region ORDER BY total_pedidos DESC) AS ranking
FROM CTE_pedidos_completados
WHERE total_pedidos > 1
ORDER BY region, ranking;