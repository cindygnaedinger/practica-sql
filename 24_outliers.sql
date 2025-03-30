-- ¿Qué es un Outlier? 
-- Un outlier (o valor atípico) es un dato que se desvía mucho del resto de los datos en un conjunto. Son como esos agentes en el call center que destacan demasiado (para bien o para mal) comparados con el promedio.

-- 📌 Ejemplos Prácticos en un Call Center
-- Outlier de Tiempo de Llamada (AHT):

-- Promedio de duración: 200 segundos.

-- Outlier: Una llamada que dura 1,200 segundos (20 minutos). ¿Por qué? Quizás el agente tuvo un problema técnico o el cliente fue excepcionalmente complejo.

-- Outlier de CSAT (Satisfacción):

-- Promedio de CSAT: 4.2 (en escala de 1-5).

-- Outlier negativo: Un score de 1.0. ¿Motivo? Tal vez un cliente extremadamente insatisfecho por un error grave.

-- Outlier de Llamadas Atendidas:

-- Promedio por agente: 100 llamadas/día.

-- Outlier positivo: Un agente que atiende 300 llamadas/día. ¿Cómo lo hace? Quizás usa shortcuts o no documenta bien las llamadas.

-- 🔍 ¿Cómo Identificar Outliers?
-- En SQL o Python, hay métodos comunes:

-- 1. Regla del IQR (Rango Intercuartílico)
-- Calculas los percentiles 25 (Q1) y 75 (Q3).

-- Cualquier valor fuera de este rango es un outlier:

-- Copy
-- Límite inferior = Q1 - 1.5 * IQR  
-- Límite superior = Q3 + 1.5 * IQR  
-- *(IQR = Q3 - Q1)*
-- Ejemplo en SQL (BigQuery):

-- sql
-- Copy
-- WITH stats AS (
--   SELECT
--     APPROX_QUANTILES(duration_sec, 100)[OFFSET(25)] AS q1,
--     APPROX_QUANTILES(duration_sec, 100)[OFFSET(75)] AS q3
--   FROM calls
-- )
-- SELECT 
--   call_id,
--   duration_sec
-- FROM calls, stats
-- WHERE duration_sec < (q1 - 1.5 * (q3 - q1)) -- Outliers bajos
--    OR duration_sec > (q3 + 1.5 * (q3 - q1)); -- Outliers altos
-- 2. Z-Score (Desviación Estándar)
-- Si un dato está a ±3 desviaciones estándar del promedio, es un outlier.
-- Ejemplo en Python:

-- python
-- Copy
-- import numpy as np
-- z_scores = (df['duration_sec'] - df['duration_sec'].mean()) / df['duration_sec'].std()
-- outliers = df[abs(z_scores) > 3]
-- ❌ ¿Por qué son Importantes los Outliers?
-- Negativos: Pueden indicar errores (ej: llamadas demasiado cortas = agentes colgando).

-- Positivos: Pueden revelar mejores prácticas (ej: agente con CSAT perfecto).

-- Sesgan análisis: Si no se tratan, distorsionan promedios y modelos.

-- 🛠 ¿Qué Hacer con Outliers?
-- Investigarlos: ¿Es un error de datos? ¿O un caso real excepcional?

-- Filtrarlos: Si son errores, limpiarlos.

-- sql
-- Copy
-- -- Ejemplo: Eliminar llamadas con duración > 1 hora (probable error)
-- DELETE FROM calls WHERE duration_sec > 3600;
-- Segmentarlos: Analizarlos por separado.

-- python
-- Copy
-- # En Python: Crear un DataFrame solo para outliers
-- q1 = df['duration_sec'].quantile(0.25)
-- q3 = df['duration_sec'].quantile(0.75)
-- iqr = q3 - q1
-- outliers = df[(df['duration_sec'] < (q1 - 1.5 * iqr)) | (df['duration_sec'] > (q3 + 1.5 * iqr))]
-- 📊 Ejemplo Visual
-- Imagina un gráfico de caja (boxplot) de las duraciones de llamadas:

-- Copy
--    |-----*----|     |     *|
--    Q1   Mediana    Q3    Outlier (1,200 segs)
-- El asterisco (*) es el outlier: ¡está fuera de los "bigotes" del boxplot!

-- 🏆 Desafío Práctico
-- "Encuentra los outliers de CSAT en tu call center (supón que el Q1=3.8, Q3=4.5). ¿Qué harías con ellos?"

-- <details> <summary>💡 Solución</summary>
-- 1. Calcular límites:

-- Copy
-- IQR = 4.5 - 3.8 = 0.7  
-- Límite inferior = 3.8 - (1.5 * 0.7) = 2.75  
-- Límite superior = 4.5 + (1.5 * 0.7) = 5.55  
-- 2. Identificar outliers:

-- Scores <2.75 (clientes furiosos).

-- Scores >4.5 (aunque el máximo es 5, aquí no hay outliers altos).

-- 3. Acción:

-- Revisar las llamadas con CSAT <2.75 para encontrar causas raíz.

-- </details>
-- ✅ Key Takeaways
-- Un outlier es un dato inusualmente alto o bajo.

-- Pueden ser errores o casos excepcionales.

-- Usa IQR o Z-Score para detectarlos.

-- Decide si filtrarlos, investigarlos o segmentarlos.