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

/*
Ahora, modifica la consulta para resolver los siguientes problemas:
Agregar una métrica de ticket promedio:
Calcula el monto promedio por venta (SUM(monto) / COUNT(venta_id)) en la CTE de ventas mensuales.
Filtrar por un rango de fechas:
Agrega un filtro en la CTE de ventas mensuales para analizar solo las ventas del año 2023.
Calcular el rendimiento de los vendedores por año:
Modifica la CTE de rendimiento de vendedores para calcular el promedio de ventas por región y año.
*/
WITH ventas_mensuales AS (
    SELECT
        EXTRACT(YEAR FROM v.fecha_venta) AS año,
        EXTRACT(MONTH FROM v.fecha_venta) AS mes,
        ve.region,
        SUM(v.monto) AS total_ventas,
        SUM(v.monto) / COUNT(ventas_id) AS monto_promedio
    FROM
        `nombre_proyecto.nombre_dataset.ventas` v
    JOIN
        `nombre_proyecto.nombre_dataset.vendedores` ve
    ON
        v.vendedor_id = ve.vendedor_id
    WHERE
        EXTRACT(YEAR FROM v.fecha_venta) = 2023 
    GROUP BY
        año, mes, ve.region
),
rendimiento_vendedores AS (
    SELECT
        v.vendedor_id,
        ve.nombre_vendedor,
        ve.region,
        EXTRACT(YEAR FROM v.fecha_venta) AS año,
        SUM(v.monto) AS total_ventas_vendedor,
        AVG(SUM(v.monto)) OVER (PARTITION BY ve.region, EXTRACT(YEAR FROM v.fecha_venta)) AS promedio_ventas_region_año
    FROM
        `nombre_proyecto.nombre_dataset.ventas` v
    JOIN
        `nombre_proyecto.nombre_dataset.vendedores` ve
    ON
        v.vendedor_id = ve.vendedor_id
    GROUP BY
        v.vendedor_id, ve.nombre_vendedor, ve.region, EXTRACT(YEAR FROM v.fecha_venta)
),

/*
Identificar las regiones con mayor crecimiento de ventas:
Modifica la consulta para mostrar solo las regiones con un crecimiento porcentual superior al 10%.
Analizar las categorías más vendidas en cada región:
Modifica la consulta para mostrar solo las 3 categorías más vendidas por región.
Evaluar el rendimiento de los vendedores nuevos:
Agrega una columna en la CTE de rendimiento de vendedores para identificar si un vendedor es nuevo (por ejemplo, si empezó a vender en el último mes).
*/

SELECT *
FROM crecimiento_ventas
WHERE crecimiento_porcentual > 10;

--

categorias_populares AS (
    SELECT
        ve.region,
        v.categoria,
        COUNT(v.venta_id) AS total_ventas_categoria,
        ROW_NUMBER() OVER (PARTITION BY ve.region ORDER BY COUNT(v.venta_id) DESC) AS ranking
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
    region,
    categoria,
    total_ventas_categoria
FROM
    categorias_populares
WHERE
    ranking <= 3;

--

rendimiento_vendedores AS (
    SELECT
        v.vendedor_id,
        ve.nombre_vendedor,
        ve.region,
        SUM(v.monto) AS total_ventas_vendedor,
        AVG(SUM(v.monto)) OVER (PARTITION BY ve.region) AS promedio_ventas_region,
        CASE 
            WHEN ve.fecha_inicio >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
                AND ve.fecha_inicio < DATE_TRUNC('month', CURRENT_DATE)
                THEN 'Nuevo'
                ELSE 'No nuevo'
            END AS estado_vendedor
    FROM
        `nombre_proyecto.nombre_dataset.ventas` v
    JOIN
        `nombre_proyecto.nombre_dataset.vendedores` ve
    ON
        v.vendedor_id = ve.vendedor_id
    GROUP BY
        v.vendedor_id, ve.nombre_vendedor, ve.region, ve.fecha_inicio
),

--

