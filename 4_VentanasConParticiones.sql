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
    region,
    total_pedidos,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY total_pedidos DESC) AS ranking
FROM CTE_pedidos_completados
WHERE total_pedidos > 1
ORDER BY region, ranking;

-- Escribe una consulta SQL que devuelva: El customer_id. El número total de pedidos completados por cada cliente. El ranking de cada cliente basado en el número de pedidos completados, calculado dentro de su grupo de región (usando PARTITION BY). El porcentaje que representa el total de pedidos completados de cada cliente respecto al total de pedidos completados en su región. Filtra los resultados para incluir solo aquellos clientes que tienen más de 1 pedido completado.
WITH CTE_pedidos_completados AS (
    SELECT
        o.customer_id,
        c.region,
        COUNT(o.order_id) AS total_pedidos 
        SUM(COUNT(order_id)) OVER (PARTITION BY c.region) AS total_pedidos_region
    FROM orders o 
    INNER JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
    GROUP BY o.customer_id, c.region
)
SELECT
    customer_id,
    region,
    RANK() OVER (PARTITION BY region ORDER BY total_pedidos DESC) AS ranking 
    ROUND((total_pedidos * 1.0 / total_pedidos_region) * 100, 2) AS percentage_pedidos
    FROM CTE_pedidos_completados
    WHERE total_pedidos > 1
    ORDER BY region, ranking;

-- Escribe una consulta SQL que devuelva: El customer_id. El número total de pedidos completados por cada cliente. El ranking de cada cliente basado en el número de pedidos completados, calculado dentro de su grupo de región (usando PARTITION BY). El porcentaje que representa el total de pedidos completados de cada cliente respecto al total de pedidos completados en su región. Filtra los resultados para incluir solo aquellos clientes que tienen más de 1 pedido completado.
WITH CTE_pedidos_completados AS (
    SELECT
        o.customer_id,
        c.region,
        COUNT(o.order_id) AS total_pedidos,
        SUM(COUNT(o.order_id)) OVER (PARTITION BY c.region) AS total_region
    FROM orders o 
    INNER JOIN customers c 
        ON o.customer_id = c.customer_id 
    WHERE o.status = 'completed'
    GROUP BY o.customer_id, c.region
)
SELECT 
    customer_id,
    region,
    RANK() OVER (PARTITION BY region ORDER BY total_pedidos DESC) AS ranking, 
    ROUND((total_pedidos * 1.0 / total_region, 2) * 100) AS percentage_pedidos 
FROM CTE_pedidos_completados
WHERE total_pedidos > 1
ORDER BY ranking, region;

--¿Puedes modificar la consulta anterior para calcular el porcentaje sin usar * 1.0, pero asegurándote de que el resultado sea decimal? (Pista: Usa CAST o CONVERT).
WITH CTE_pedidos_completados AS (
    SELECT
        o.customer_id,
        c.region,
        COUNT(o.order_id) AS total_pedidos,
        SUM(COUNT(o.order_id)) OVER (PARTITION BY c.region) AS total_region
    FROM orders o 
    INNER JOIN customers c 
        ON o.customer_id = c.customer_id 
    WHERE o.status = 'completed'
    GROUP BY o.customer_id, c.region
)
SELECT 
    customer_id,
    region,
    RANK() OVER (PARTITION BY region ORDER BY total_pedidos DESC) AS ranking, 
    CAST((total_pedidos * 100.0 / total_region) AS DECIMAL(10, 2)) AS percentage_pedidos 
FROM CTE_pedidos_completados
WHERE total_pedidos > 1
ORDER BY ranking, region;

-- en vez de CAST, podemos usar CONVERT:
SELECT CONVERT(DECIMAL(10, 2), 3 * 100.0 / 5);
/*

Características	                CAST	                                                CONVERT
Sintaxis	    CAST(expresión AS tipo_de_dato)	                        CONVERT(tipo_de_dato, expresión [, estilo])
Flexibilidad	Menos flexible (solo conversión básica).	            Más flexible (admite estilos en algunos motores).
Portabilidad	Es estándar SQL (funciona en casi todos los motores).	No es estándar SQL (es específico de algunos motores como SQL Server).
Uso común	    Conversiones simples y portables.	                    Conversiones complejas o con formatos específicos (por ejemplo, fechas).
*/