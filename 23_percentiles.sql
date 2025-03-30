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