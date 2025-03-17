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

-- Tu tarea es generar un reporte que clasifique los pedidos en tres categorías según su monto: "Alto Valor": Si el monto es mayor a 500. "Medio Valor": Si el monto está entre 100 y 500 (inclusive). "Bajo Valor": Si el monto es menor a 100 Además, debes contar cuántos pedidos hay en cada categoría y mostrar el resultado.
CREATE TABLE pedidos (
    pedido_id INT PRIMARY KEY,
    cliente_id INT,
    monto DECIMAL(10, 2),
    fecha_pedido DATE,
    estado_pedido VARCHAR(50) -- Puede ser: "Completado", "Pendiente", "Cancelado"
);

SELECT
    COUNT(pedido_id) AS cantidad_categoria,
    CASE 
    WHEN monto > 500 THEN "Alto Valor"
    WHEN monto BETWEEN 100 AND 500 THEN "Medio Valor"
    WHEN monto < 100 THEN "Bajo Valor"
        END AS monto_clasificacion
FROM pedidos
GROUP BY 
CASE 
    WHEN monto > 500 THEN "Alto Valor"
    WHEN monto BETWEEN 100 AND 500 THEN "Medio Valor"
    WHEN monto < 100 THEN "Bajo Valor"
        END;