-- Calcular las siguientes métricas:
-- Crecimiento mensual de ventas por región.
-- Rendimiento de cada vendedor comparado con el promedio de su región.
-- Categorías de productos más vendidas por región.

WITH ventas_mensuales AS (
    SELECT
        EXTRACT(YEAR FROM v.fecha_venta) AS año,
        EXTRACT(MONTH FROM v.fecha_venta) AS mes,
        ve.region,
        SUM(v.monto) AS total_ventas
    FROM
        `nombre_proyecto.nombre_dataset.ventas` v
    JOIN
        `nombre_proyecto.nombre_dataset.vendedores` ve
    ON
        v.vendedor_id = ve.vendedor_id
    GROUP BY
        año, mes, ve.region
),
crecimiento_ventas AS (
    SELECT
        año,
        mes,
        region,
        total_ventas,
        LAG(total_ventas) OVER (PARTITION BY region ORDER BY año, mes) AS ventas_mes_anterior,
        (total_ventas - LAG(total_ventas) OVER (PARTITION BY region ORDER BY año, mes)) / LAG(total_ventas) OVER (PARTITION BY region ORDER BY año, mes) * 100 AS crecimiento_porcentual
    FROM
        ventas_mensuales
),
rendimiento_vendedores AS (
    SELECT
        v.vendedor_id,
        ve.nombre_vendedor,
        ve.region,
        SUM(v.monto) AS total_ventas_vendedor,
        AVG(SUM(v.monto)) OVER (PARTITION BY ve.region) AS promedio_ventas_region
    FROM
        `nombre_proyecto.nombre_dataset.ventas` v
    JOIN
        `nombre_proyecto.nombre_dataset.vendedores` ve
    ON
        v.vendedor_id = ve.vendedor_id
    GROUP BY
        v.vendedor_id, ve.nombre_vendedor, ve.region
),
categorias_populares AS (
    SELECT
        ve.region,
        v.categoria,
        COUNT(v.venta_id) AS total_ventas_categoria
    FROM
        `nombre_proyecto.nombre_dataset.ventas` v
    JOIN
        `nombre_proyecto.nombre_dataset.vendedores` ve
    ON
        v.vendedor_id = ve.vendedor_id
    GROUP BY
        ve.region, v.categoria
)
SELECT
    cv.año,
    cv.mes,
    cv.region,
    cv.total_ventas,
    cv.crecimiento_porcentual,
    rv.nombre_vendedor,
    rv.total_ventas_vendedor,
    rv.promedio_ventas_region,
    CASE
        WHEN rv.total_ventas_vendedor > rv.promedio_ventas_region THEN 'Por encima del promedio'
        WHEN rv.total_ventas_vendedor < rv.promedio_ventas_region THEN 'Por debajo del promedio'
        ELSE 'En el promedio'
    END AS rendimiento_vendedor,
    cp.categoria,
    cp.total_ventas_categoria
FROM
    crecimiento_ventas cv
JOIN
    rendimiento_vendedores rv
ON
    cv.region = rv.region
JOIN
    categorias_populares cp
ON
    cv.region = cp.region
ORDER BY
    cv.año, cv.mes, cv.region;

