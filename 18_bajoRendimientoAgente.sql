-- Problema:
-- "Identifica a los agentes cuyo AHT empeoró más de un 10% entre la primera y la última semana de noviembre, mostrando su equipo y diferencia porcentual."

WITH CTE_llamadas_noviembre AS(
    SELECT
       agent_id,
       call_date,
       TIMESTAMPDIFF(SECOND, start_time, end_time) + hold_time + after_work_call_time AS handle_time
    FROM calls
    WHERE call_date BETWEEN '2023-11-01' AND '2023-11-30'
),
    CTE_aht_semanal AS(
        SELECT
            agent_id,
            WEEK(call_date, 1) AS semana,
            AVG(handle_time) AS promedio_aht,
        FROM CTE_llamadas_noviembre 
        WHERE WEEK(call_date, 1) IN (1, 5)
        GROUP BY agent_id, WEEK(call_date, 1)
    ),
    CTE_comparacion_semanas AS (
        SELECT 
        agent_id,
        MAX(CASE WHEN semana = 1 THEN promedio_aht END) AS aht_semana1,
        MAX(CASE WHEN semana = 5 THEN promedio_aht END) AS aht_semana5,
        ( MAX(CASE WHEN semana = 5 THEN promedio_aht END) -  MAX(CASE WHEN semana = 1 THEN promedio_aht END)) / (
             MAX(CASE WHEN semana = 1 THEN promedio_aht END) * 100 AS cambio_porcentual
        FROM CTE_aht_semanal 
        GROUP BY agent_id
        HAVING aht_semana1 IS NOT NULL AND aht_semana5 IS NOT NULL
    )
SELECT 
    a.agent_name,
    t.team_name,
    cs.aht_semana1 AS semana_inicial,
    cs.aht_semana5 AS semana_final,
    ROUND(cs.cambio_porcentual, 2) AS emperamiento_porcentual
FROM CTE_comparacion_semanas cs 
JOIN agents a ON cs.agent_id = a.agent_id
JOIN teams t ON a.team_id = t.team_id
WHERE cs.cambio_porcentual > 10
ORDER BY cs.cambio_porcentual DESC;
