-- Supongamos que trabajas en una empresa de comercio electrónico y tienes una base de datos que contiene información sobre transacciones, clientes y productos. Quieres analizar las ventas mensuales por categoría de producto para identificar tendencias y tomar decisiones estratégicas.
WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC(t.transaction_date, MONTH) AS mes,
        p.category AS categoria,
        SUM(t.amount) AS total_ventas
    FROM
        `nombre_proyecto.nombre_dataset.transacciones` t
    JOIN
        `nombre_proyecto.nombre_dataset.productos` p
    ON
        t.product_id = p.product_id
    WHERE
        t.transaction_date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY
        mes, categoria
)
SELECT
    mes,
    categoria,
    total_ventas,
    ROUND(total_ventas / SUM(total_ventas) OVER (PARTITION BY mes) * 100, 2) AS porcentaje_del_total
FROM
    ventas_mensuales
ORDER BY
    mes, categoria;