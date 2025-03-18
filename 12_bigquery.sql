-- Supongamos que trabajas en una empresa de comercio electrónico y tienes una base de datos que contiene información sobre transacciones, clientes y productos. Quieres analizar las ventas mensuales por categoría de producto para identificar tendencias y tomar decisiones estratégicas.
WITH ventas_mensuales AS (
    SELECT
        DATE_TRUNC(t.transaction_date, MONTH) AS mes,
        p.category AS categoria,
        SUM(t.amount) AS total_ventas
    FROM
        `nombre_proyecto.nombre_dataset.transacciones` t
    JOIN
        `nombre_proyecto.nombre_dataset.productos` p
    ON
        t.product_id = p.product_id
    WHERE
        t.transaction_date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY
        mes, categoria
)
SELECT
    mes,
    categoria,
    total_ventas,
    ROUND(total_ventas / SUM(total_ventas) OVER (PARTITION BY mes) * 100, 2) AS porcentaje_del_total
FROM
    ventas_mensuales
ORDER BY
    mes, categoria;

-- Calcular la duración promedio de las llamadas atendidas por cada agente.
SELECT
    a.nombre AS agente,
    AVG(l.duracion_segundos) AS promedio_duracion_llamada
FROM 
`nombre_proyecto.nombre_dataset.agentes` a 
INNER JOIN `nombre_proyecto.nombre_dataset.llamadas` l 
ON a.agente_id = l.agente_id 
GROUP BY a.nombre
ORDER BY promedio_duracion_llamada DESC;

-- Contar el número de llamadas atendidas por cada departamento.
SELECT
    a.departamento,
    COUNT(l.llamada_id) AS cantidad_llamadas 
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id 
GROUP BY a.departamento 
ORDER BY cantidad_llamadas DESC;

-- Calcular la satisfacción promedio del cliente para cada agente.
SELECT
    a.nombre AS agente,
    AVG(l.satisfaccion_cliente) AS promedio_satisfaccion_cliente
FROM agente a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id 
GROUP BY a.nombre
ORDER BY promedio_satisfaccion_cliente DESC;

-- Calcular el tiempo de espera promedio por llamada, asumiendo que el tiempo de espera es la diferencia entre la hora de inicio de la llamada y la hora en que el agente la atendió.
SELECT 
    AVG(TIMESTAMP_DIFF(fecha_hora_inicio, fecha_hora_atencion, SECOND)) AS tiempo_espera_promedio 
FROM llamadas 
WHERE fecha_hora_atencion IS NOT NULL;

-- Análisis de Rendimiento de Agentes con Métricas Clave
-- En un call center, es crucial medir el rendimiento de los agentes utilizando múltiples métricas, como la duración promedio de las llamadas, la satisfacción del cliente y la eficiencia (llamadas por hora). Además, queremos identificar a los agentes que están por encima o por debajo del promedio en estas métricas.
WITH metricas_agentes AS( 
    SELECT
    a.agente_id,
    a.agente_nombre,
    COUNT(l.llamada_id) AS total_llamadas,
    AVG(l.satisfaccion_cliente) AS satisfaccion_promedio,
    AVG(l.duracion_segundos) AS duracion_promedio,
    COUNT(l.llamada_id) / (SUM(l.duracion_segundos) / 3600) AS llamadas_por_hora 
FROM llamadas l 
INNER JOIN agentes a 
ON l.agente_id = a.agente_id 
GROUP BY a.agente_id = a.agente_nombre
),
 promedios AS (
    SELECT
        AVG(duracion_promedio) AS duracion_promedio_global,
        AVG(satisfaccion_promedio) AS satisfaccion_promedio_global,
        AVG(llamadas_por_hora) AS llamadas_por_hora_global
    FROM metricas_agentes
 )
 SELECT
    m.agente_id,
    m.agente_nombre,
    m.total_llamadas,
    m.duracion_promedio,
    CASE 
        WHEN m.duracion_promedio < p.duracion_promedio_global THEN 'Por debajo del promedio'
        WHEN m.duracion_promedio > p.duracion_promedio_global THEN 'Por encima del promedio'
        ELSE 'En el promedio'
    END AS rendimiento_duracion,
    m.satisfaccion_promedio, 
    CASE 
        WHEN m.satisfaccion_promedio < p.satisfaccion_promedio_global THEN 'Por debajo del promedio'
        WHEN m.satisfaccion_promedio > p.satisfaccion_promedio_global THEN 'Por encima del promedio'
        ELSE 'En el promedio'
    END AS rendimiento_satisfaccion,
    m.llamadas_por_hora,
    CASE 
        WHEN m.llamadas_por_hora < m.llamadas_por_hora_global THEN 'Por debajo del promedio'
        WHEN m.llamadas_por_hora > m.llamadas_por_hora_global THEN 'Por encima del promedio'
        ELSE 'En el promedio'
    END AS rendimiento_eficiencia
FROM metricas_agentes m 
CROSS JOIN promedios p 
ORDER BY m.total_llamadas DESC;


-- 1. Tablas Temporales y Cálculos de Métricas
-- La consulta utiliza dos Common Table Expressions (CTEs) para organizar los cálculos en etapas:

-- metricas_agentes:

-- Esta CTE calcula las métricas clave para cada agente:

-- total_llamadas: Número total de llamadas atendidas por el agente.

-- duracion_promedio: Duración promedio de las llamadas en segundos.

-- satisfaccion_promedio: Puntuación promedio de satisfacción del cliente (escala de 1 a 5).

-- llamadas_por_hora: Eficiencia del agente, calculada como el número de llamadas atendidas por hora. Se obtiene dividiendo el total de llamadas por la suma de la duración en horas (SUM(l.duracion_segundos) / 3600).

-- Se realiza un INNER JOIN entre las tablas llamadas y agentes para obtener el nombre del agente y su departamento.

-- Los resultados se agrupan por agente_id y nombre_agente.

-- promedios:

-- Esta CTE calcula los promedios globales de las métricas anteriores:

-- duracion_promedio_global: Duración promedio de todas las llamadas.

-- satisfaccion_promedio_global: Satisfacción promedio de todos los clientes.

-- llamadas_por_hora_global: Eficiencia promedio de todos los agentes.

-- Estos promedios sirven como punto de referencia para comparar el rendimiento de cada agente.

-- 2. Consulta Principal y Comparación con Promedios Globales
-- En la consulta principal:

-- Seleccionamos las métricas de cada agente desde la CTE metricas_agentes.

-- Usamos un CROSS JOIN para combinar cada fila de metricas_agentes con los promedios globales de promedios. Esto permite comparar las métricas de cada agente con los promedios globales.

-- Utilizamos la función CASE para clasificar el rendimiento de cada agente en tres categorías:

-- rendimiento_duracion: Compara la duración promedio del agente con el promedio global.

-- rendimiento_satisfaccion: Compara la satisfacción promedio del agente con el promedio global.

-- rendimiento_eficiencia: Compara las llamadas por hora del agente con el promedio global.

-- Finalmente, ordenamos los resultados por el número total de llamadas en orden descendente.

-- 3. Optimización de la Consulta
-- Para mejorar el rendimiento de la consulta en un entorno con grandes volúmenes de datos:

-- Particiones: Si la tabla llamadas contiene datos históricos, podrías particionarla por la columna fecha_hora_inicio para reducir la cantidad de datos escaneados.

-- Indexación: Asegúrate de que las columnas utilizadas en los JOIN y GROUP BY (como agente_id y llamada_id) estén indexadas.

-- Evitar Cálculos Redundantes: En lugar de calcular SUM(l.duracion_segundos) / 3600 en múltiples lugares, podrías almacenar este valor en una variable temporal.

