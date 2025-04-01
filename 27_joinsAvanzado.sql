-- Ejercicio Avanzado #1: Análisis de Desempeño con Window Functions
llamadas (llamada_id, agente_id, duracion_seg, fecha_hora, satisfaccion)
agentes (agente_id, nombre, fecha_contratacion, equipo)
-- El call center necesita identificar a los agentes cuyo Average Handle Time (AHT) está empeorando mes a mes. Escribe una consulta que muestre para cada agente:

-- Su AHT (duración promedio) en el mes actual

-- Su AHT en el mes anterior

-- La diferencia porcentual entre ambos meses

-- Solo para agentes con un empeoramiento > 10%

WITH CTE_aht_mensual AS (
    SELECT 
        a.agent_id,
        a.nombre AS agente_nombre,
        DATE_TRUNC(l.fecha_hora, MONTH) AS mes,
        AVG(l.duracion_seg) AS promedio_aht_mes,
        COUNT(*) AS llamadas_atendidas
    FROM agentes a 
    INNER JOIN llamadas l ON a.agente_id = l.agent_id
    WHERE l.fecha_hora >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH)
    GROUP BY a.agent_id,
        a.nombre, 
         DATE_TRUNC(l.fecha_hora, MONTH)
),
    CTE_aht_comparativo AS (
        agent_id,
        agente_nombre,
        mes,
        promedio_aht_mes,
        LAG(promedio_aht_mes) OVER(PARTITION BY agente_id ORDER BY mes) AS aht_mes_anterior,
        llamadas_atendidas
    FROM CTE_aht_mensual
    )
SELECT 
    agente_id,
    agente_nombre,
    mes,
    promedio_aht_mes,
    aht_mes_anterior,
    llamadas_atendidas,
    ROUND(
    (promedio_aht_mes - aht_mes_anterior) / aht_mes_anterior * 100, 1) AS diferencia_porcentual,
    CASE 
        WHEN (promedio_aht_mes - aht_mes_anterior) / aht_mes_anterior > 0.1 THEN 'Empeoramiento > al 10%'
        WHEN (promedio_aht_mes - aht_mes_anterior) / aht_mes_anterior < -0.1 THEN 'Mejoramiento significativo'
        ELSE 'Estable'
    END AS estado
FROM CTE_aht_comparativo 
WHERE aht_mes_anterior IS NOT NULL
    AND (promedio_aht_mes - aht_mes_anterior) / aht_mes_anterior > 0.1
ORDER BY diferencia_porcentual DESC;