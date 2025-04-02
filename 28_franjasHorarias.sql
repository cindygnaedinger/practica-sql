-- El call center necesita identificar las franjas horarias con mayor volumen de llamadas y cómo varía el CSAT promedio en cada una para optimizar la asignación de agentes.
llamadas (llamada_id, agente_id, cliente_id, duracion_seg, fecha_hora, satisfaccion)
agentes (agente_id, nombre, equipo, nivel_experiencia)
-- Clasifica las llamadas en 3 franjas horarias:
-- Mañana: 8:00 - 11:59
-- Tarde: 12:00 - 17:59
-- Noche: 18:00 - 22:00
-- Calcula para cada franja:
-- Volumen total de llamadas
-- Duración promedio (AHT)
-- CSAT promedio
-- Comparación porcentual vs. el promedio general
-- Filtra solo los últimos 3 meses.

WITH datos_franjas AS (
  SELECT
    CASE
      WHEN EXTRACT(HOUR FROM fecha_hora) BETWEEN 8 AND 11 THEN 'Mañana'
      WHEN EXTRACT(HOUR FROM fecha_hora) BETWEEN 12 AND 17 THEN 'Tarde'
      WHEN EXTRACT(HOUR FROM fecha_hora) BETWEEN 18 AND 22 THEN 'Noche'
      ELSE 'Fuera de horario'
    END AS franja_horaria,
    duracion_seg,
    satisfaccion
  FROM llamadas
  WHERE fecha_hora >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
    AND EXTRACT(HOUR FROM fecha_hora) BETWEEN 8 AND 22  -- Filtra solo horario operativo
),

metricas_generales AS (
  SELECT
    AVG(duracion_seg) AS aht_general,
    AVG(satisfaccion) AS csat_general
  FROM datos_franjas
  WHERE franja_horaria != 'Fuera de horario'
)

SELECT
  df.franja_horaria,
  COUNT(*) AS total_llamadas,
  ROUND(AVG(df.duracion_seg), 0) AS aht_promedio,
  ROUND(AVG(df.satisfaccion), 1) AS csat_promedio,
  ROUND((AVG(df.satisfaccion) - mg.csat_general) / mg.csat_general * 100, 1) || '%' AS vs_promedio_csat,
  RANK() OVER(ORDER BY COUNT(*) DESC) AS ranking_volumen
FROM datos_franjas df
CROSS JOIN metricas_generales mg
WHERE df.franja_horaria != 'Fuera de horario'
GROUP BY df.franja_horaria, mg.csat_general, mg.aht_general
ORDER BY total_llamadas DESC;