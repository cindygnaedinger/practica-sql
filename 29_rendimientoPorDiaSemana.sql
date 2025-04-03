-- El call center quiere saber qué días de la semana tienen:
-- Mayor volumen de llamadas
-- Menor satisfacción del cliente (CSAT)
-- Mayor tiempo de espera promedio
llamadas (llamada_id, agente_id, cliente_id, duracion_seg, tiempo_espera_seg, fecha_hora, satisfaccion)
-- Extrae el día de la semana (Lunes a Domingo) de cada llamada
-- Calcula para cada día:
-- Total de llamadas
-- Tiempo de espera promedio
-- CSAT promedio
-- Porcentaje de llamadas con satisfacción < 3 (insatisfechas)
-- Ordena los resultados por día de semana (no alfabéticamente)
WITH datos_dias AS (
    SELECT
        CASE EXTRACT(DAYOFWEEK FROM fecha_hora)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Lunes'
        WHEN 3 THEN 'Martes'
        WHEN 4 THEN 'Miércoles'
        WHEN 5 THEN 'Jueves'
        WHEN 6 THEN 'Viernes'
        WHEN 7 THEN 'Sábado'
    END AS dia_semana,
    CASE WHEN satisfaccion < 3 THEN 1 ELSE 0 END AS llamada_insatisfecha,
    tiempo_espera_seg,
    satisfaccion
FROM llamadas 
WHERE fecha_hora >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 MONTH)
    AND tiempo_espera_seg BETWEEN 0 AND 1800  
)
SELECT 
    dia_semana,
    COUNT(*) AS total_llamadas,
    ROUND(AVG(satisfaccion), 1) AS promedio_satisfaccion,
    ROUND(AVG(tiempo_espera_seg), 0) AS promedio_tiempo_espera,
    ROUND(SUM(llamada_insatisfecha) / COUNT(*) * 100, 1) || '%' AS porcentaje_insatisfechas,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS ranking_volumen
FROM datos_dias
GROUP BY dia_semana
ORDER BY 
  CASE dia_semana
    WHEN 'Lunes' THEN 1
    WHEN 'Martes' THEN 2
    WHEN 'Miércoles' THEN 3
    WHEN 'Jueves' THEN 4
    WHEN 'Viernes' THEN 5
    WHEN 'Sábado' THEN 6
    WHEN 'Domingo' THEN 7
  END;