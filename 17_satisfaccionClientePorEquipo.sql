-- Ejercicio: Análisis de Tendencia de Satisfacción del Cliente por Equipo
-- Contexto:
-- La gerencia del call center quiere identificar qué equipos han mejorado o empeorado en la satisfacción del cliente (CSAT) durante el último trimestre (Octubre, Noviembre y Diciembre de 2023).
-- Se necesita un reporte que muestre:

-- Equipo (team_name).

-- Mes.

-- CSAT promedio del mes.

-- Comparación con el mes anterior (diferencia porcentual).

-- Requerimientos técnicos:
-- Usa funciones de ventana (Window Functions) para calcular la diferencia porcentual.

-- Filtra solo los equipos con más de 50 llamadas atendidas por mes.

-- Ordena los resultados por equipo y mes.
WITH CTE_llamadas_por_mes AS (
    SELECT
        t.team_id,
        t.team_name,
        EXTRACT(MONTH FROM c.call_date) AS month,
        AVG(c.satisfaction_score) AS promedio_csat,
        COUNT(c.call_id) AS total_llamadas
    FROM calls c 
    INNER JOIN agents a ON c.agent_id = a.agent_id
    INNER JOIN teams t ON a.team_id = t.team_id
    WHERE c.call_date BETWEEN '2023-10-01' AND '2023-12-31'
    GROUP BY t.team_id, t.team_name, EXTRACT(MONTH FROM c.call_date) AS month
    HAVING COUNT(c.call_id) > 50
)
SELECT
    team_name,
    CASE month
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name,
    promedio_csat,
    ROUND(
    (promedio_satisfaccion_equipo - LAG(promedio_satisfaccion_equipo) OVER(PARTITION BY t.team_name ORDER BY month)) / LAG(promedio_satisfaccion_equipo) OVER(PARTITION BY t.team_name ORDER BY month) * 100, 1) AS porcentaje_cambio
FROM CTE_llamadas_por_mes
ORDER BY team_name, month;