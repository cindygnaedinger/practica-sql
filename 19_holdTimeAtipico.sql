-- 📌 Ejercicio 1: Identificar Llamadas con Hold Time Atípico
-- Contexto:
-- Algunas llamadas tienen tiempos de espera (hold_time) anormalmente altos, lo que afecta la experiencia del cliente.

-- Objetivo:
-- Encontrar llamadas donde el hold_time sea mayor al percentil 95 de todos los tiempos de espera.
-- En Big Query no existe PERCENTIL_COUNT, pero tenemos dos opciones:
-- Opción 1: APPROX_QUANTILES (recomendada)
SELECT 
  APPROX_QUANTILES(hold_time, 100)[OFFSET(90)] AS p90_hold_time
FROM `tu_proyecto.tu_dataset.calls`;

-- Opción 2: Si necesitas exactitud (menos eficiente)
SELECT
  hold_time AS p90_hold_time
FROM (
  SELECT 
    hold_time,
    PERCENT_RANK() OVER (ORDER BY hold_time) AS percentile
  FROM `tu_proyecto.tu_dataset.calls`
)
WHERE percentile >= 0.9
LIMIT 1;