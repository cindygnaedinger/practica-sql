-- 📌 Percentil vs. Porcentaje vs. Ranking
-- 🔢 Percentil = "El lugar donde caes en una fila ordenada"
-- Imagina que 100 agentes de call center están ordenados en una fila del más rápido al más lento resolviendo llamadas.

-- Percentil 90 (P90): Es el agente que está en el puesto 90 de la fila.

-- Interpretación: El 90% de los agentes son igual o más rápidos que él, y solo el 10% es más lento.

-- Ejemplo práctico: Si el P90 de AHT (tiempo de llamada) es 300 segundos, significa que el 10% de las llamadas duran más de 300 segundos.

-- ↔️ Diferencia con Ranking
-- Ranking te dice "el puesto número X" de un elemento (ej: "Pedro es el agente #5 en velocidad").

-- Percentil te dice "qué porcentaje del total está por debajo de este valor" (ej: "Pedro está en el percentil 95" = es más rápido que el 95% de los agentes).

-- Key: El percentil normaliza los datos en una escala de 0 a 100, mientras que el ranking es un número fijo.

-- 🎯 ¿Para qué sirve el percentil en un call center?
-- Identificar outliers:

-- "¿Qué llamadas están en el top 10% de duración (P90+) para analizar por qué se demoran?"

-- Establecer metas:

-- "Queremos que el 80% de las llamadas (P80) se resuelvan en menos de 200 segundos."

-- Comparar agentes:

-- "María está en el P75 de CSAT (supera al 75% de sus compañeros)."

-- 📊 Ejemplo con SQL Sencillo
-- Tabla calls:

-- call_id	duration_sec
-- 1	120
-- 2	180
-- ...	...
-- 100	600
-- sql
-- Copy
-- -- Percentil 90 de duración de llamadas
-- SELECT 
--   PERCENTILE_CONT(duration_sec, 0.9) OVER() AS p90
-- FROM calls;
-- Resultado: 350 (segundos).

-- Interpretación: El 90% de las llamadas duran ≤350 segs, y el 10% dura más.

-- ❌ Error Frecuente
-- Confundir percentil con porcentaje:

-- ❌ "El P90 es el 90% del total de llamadas." → Falso.

-- ✅ "El P90 es el valor que separa al 90% de las llamadas más rápidas del 10% más lento."

-- 🔄 Percentil vs. Ranking: Batalla de Ejemplos
-- Agente	Duración (sec)	Ranking	Percentil
-- Ana	100	#1	P99
-- Luis	200	#30	P70
-- Pedro	400	#95	P5
-- Ana (P99): Es más rápida que el 99% de los agentes.

-- Pedro (P5): Solo supera al 5% (es de los más lentos).

-- 🏆 Desafío Práctico
-- "Si el P75 de CSAT es 4.5 (en escala de 1-5), ¿qué significa?"

-- Que el 75% de las llamadas tienen un CSAT ≤4.5, y el 25% restante tiene scores más altos (4.6, 5, etc.). 
-- ✅ En resumen
-- Percentil: Te dice cómo se compara un valor frente al resto (útil para umbrales).

-- Ranking: Te dice la posición exacta en una lista (útil para top 10, #1, etc.).

-- Porcentaje: Es una proporción cruda (ej: "10% de llamadas son quejas").

📊 Percentiles en BigQuery 
(Como si fuera una fila de agentes en un call center)

🎯 ¿Qué es un percentil?
Imagina que ordenas a 100 agentes del más rápido al más lento atendiendo llamadas:

Percentil 50 (P50): El agente #50 (la mediana).

Percentil 90 (P90): El agente #90 (solo el 10% es más lento que él).

🔢 Los 3 Tipos de Percentiles en BigQuery
1. PERCENTILE_CONT → "El justo"
Calcula el valor exacto del percentil, incluso si no existe en tus datos (interpola).

Ejemplo:

sql
Copy
SELECT PERCENTILE_CONT(duration_sec, 0.5) OVER() AS mediana
FROM calls;
Si el P50 cae entre dos valores (ej: 200 y 210 segs), devuelve 205 (promedio).

2. PERCENTILE_DISC → "El realista"
Elige el valor real más cercano en tus datos.

Ejemplo:

SELECT PERCENTILE_DISC(duration_sec, 0.9) OVER() AS p90
FROM calls;
Si tus datos son [100, 200, 300], el P90 es 300 (no interpola).

3. APPROX_QUANTILES → "El rápido para big data"
Aproximado pero eficiente (ideal para millones de filas).

Ejemplo:

SELECT APPROX_QUANTILES(duration_sec, 100)[OFFSET(90)] AS p90_aproximado
FROM calls;
100 = divide los datos en 100 partes (percentiles).

[OFFSET(90)] = devuelve el P90.

📌 ¿Cuándo Usar Cada Uno?
PERCENTILE_CONT: Para métricas continuas (ej: tiempo, dinero). ✅

PERCENTILE_DISC: Para datos enteros (ej: número de llamadas, ratings). ✅

APPROX_QUANTILES: Cuando tienes muchísimos datos y no necesitas precisión extrema. ✅

❌ Error Común
Usar PERCENTILE_DISC para duraciones de llamadas (ej: 150.5 segs) puede dar resultados menos precisos que PERCENTILE_CONT.

🏆 Ejemplo Real en un Call Center
Pregunta: "¿Cuál es el tiempo máximo que dura el 95% de las llamadas?"

-- Respuesta con PERCENTILE_CONT
SELECT PERCENTILE_CONT(duration_sec, 0.95) OVER() AS p95
FROM calls;
Resultado: 320 segundos → Solo el 5% de las llamadas supera este tiempo.

💡 Truco Visual
Imagina una escalera donde cada escalón es un percentil:

CONT suaviza los escalones (interpola).

DISC mantiene los escalones tal cual.

✅ Resumen Final
Función	¿Qué hace?	Ejemplo de Uso
PERCENTILE_CONT	Interpola valores	Duración promedio de llamadas
PERCENTILE_DISC	Toma valores existentes	Ratings de CSAT (1, 2, 3, 4, 5)
APPROX_QUANTILES	Aproximación rápida	Big Data (millones de filas)
