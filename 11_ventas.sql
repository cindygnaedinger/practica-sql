-- Escribe una consulta SQL que calcule el total de ventas (en dinero) para cada región.
-- Luego, escribe una consulta que muestre el producto más vendido (en cantidad) en cada región.
ventas
| id_venta | id_cliente | fecha_venta  | producto       | cantidad | precio_unitario | region  |
|----------|------------|--------------|----------------|----------|-----------------|---------|
| 1        | 101        | 2023-10-01   | Laptop         | 2        | 1200            | Norte   |
| 2        | 102        | 2023-10-02   | Smartphone     | 5        | 800             | Sur     |
| 3        | 103        | 2023-10-02   | Tablet         | 3        | 500             | Norte   |
| 4        | 104        | 2023-10-03   | Laptop         | 1        | 1200            | Este    |
| 5        | 101        | 2023-10-03   | Smartphone     | 2        | 800             | Oeste   |
| 6        | 105        | 2023-10-04   | Tablet         | 4        | 500             | Sur     |

SELECT
    region,
    SUM(cantidad * precio_unitario) AS total_ventas
    FROM ventas
    GROUP BY region;

WITH CTE_producto_cantidad AS (SELECT
    producto,
    region,
    SUM(cantidad) AS total_cantidad 
    FROM ventas
    GROUP BY producto, region
)
    ranking_ventas AS (
        SELECT 
        region, 
        producto,
        total_cantidad,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_cantidad DESC) AS ranking
        FROM CTE_producto_cantidad
    )
SELECT
    region,
    producto,
    total_cantidad
FROM ranking_ventas
WHERE ranking = 1;


