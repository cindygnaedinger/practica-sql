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

-- ?? El UNION ALL dentro de la CTE es una forma práctica de crear datos de ejemplo temporales directamente en tu consulta, sin necesidad de tener una tabla física en la base de datos. Es como una "tabla virtual" que existe solo durante la ejecución de la consulta. 
-- 🚨 Diferencia entre UNION ALL y UNION
-- UNION ALL	                                UNION
-- Combina filas incluyendo duplicados.	        Elimina filas duplicadas (usa más recursos).
-- Más rápido porque no verifica duplicados.	Más lento por el proceso de deduplicación.

WITH calls AS (
  SELECT 1 AS call_id, 101 AS agent_id, 120 AS hold_time, TIMESTAMP("2023-10-01 09:00:00") AS call_time UNION ALL
  SELECT 2, 101, 60, TIMESTAMP("2023-10-01 10:00:00") UNION ALL
  SELECT 3, 102, 300, TIMESTAMP("2023-10-02 11:00:00") UNION ALL
  SELECT 4, 103, 45, TIMESTAMP("2023-10-02 12:00:00") UNION ALL
  SELECT 5, 102, 240, TIMESTAMP("2023-10-03 13:00:00") UNION ALL
  SELECT 6, 103, 30, TIMESTAMP("2023-10-03 14:00:00")
)

-- Queryy completa con percentiles:

WITH calls AS (
  SELECT 1 AS call_id, 101 AS agent_id, 120 AS hold_time, TIMESTAMP("2023-10-01 09:00:00") AS call_time UNION ALL
  SELECT 2, 101, 60, TIMESTAMP("2023-10-01 10:00:00") UNION ALL
  SELECT 3, 102, 300, TIMESTAMP("2023-10-02 11:00:00") UNION ALL
  SELECT 4, 103, 45, TIMESTAMP("2023-10-02 12:00:00") UNION ALL
  SELECT 5, 102, 240, TIMESTAMP("2023-10-03 13:00:00") UNION ALL
  SELECT 6, 103, 30, TIMESTAMP("2023-10-03 14:00:00")
),

-- Paso 1: Calcular el percentil 95 global
percentiles AS (
  SELECT 
    APPROX_QUANTILES(hold_time, 100)[OFFSET(95)] AS p95_hold_time
  FROM calls
)

-- Paso 2: Filtrar llamadas atípicas
SELECT 
  c.call_id,
  c.agent_id,
  c.hold_time,
  p.p95_hold_time,
  ROUND((c.hold_time - p.p95_hold_time) / p.p95_hold_time * 100, 2) AS percent_over_p95
FROM calls c, percentiles p
WHERE c.hold_time > p.p95_hold_time
ORDER BY c.hold_time DESC;

