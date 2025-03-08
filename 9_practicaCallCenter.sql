-- Listar todos los agentes y la cantidad de llamadas que han atendido:
-- Muestra el nombre del agente y la cantidad de llamadas que ha atendido.
SELECT
a.nombre AS agente,
COUNT(l.llamada_id) AS cantidad_llamadas
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id
GROUP BY a.nombre;

-- Encontrar los agentes que han atendido más de 5 llamadas. 
-- Muestra el nombre del agente y la cantidad de llamadas que ha atendido.
SELECT 
a.nombre AS agente,
COUNT(l.llamada_id) AS cantidad_llamadas
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id
GROUP BY a.nombre
HAVING COUNT(l.llamada_id) > 5;

-- Calcular la satisfacción promedio del cliente por agente. 
-- Muestra el nombre del agente y la satisfacción promedio de los clientes que han atendido.

SELECT
a.nombre AS agente,
ROUND(AVG(satisfaccion_cliente)) AS promedio_satisfaccion
FROM agentes a 
INNER JOIN llamadas l
ON a.agente_id = l.agente_id
GROUP BY a.nombre;

-- Listar los agentes que han trabajado más de 8 horas en un turno. 
-- Muestra el nombre del agente, la fecha del turno y la duración del turno en horas.

SELECT 
a.nombre AS agente,
t.fecha_turno,
TIME_TO_SEC(TIMEDIFF(t.hora_fin, t.hora_inicio)) / 3600 AS total_horas
FROM turnos t 
INNER JOIN agentes a
ON t.agente_id = a.agente_id
WHERE TIME_TO_SEC(TIMEDIFF(t.hora_fin, t.hora_inicio)) >= 8 * 3600;

-- Encontrar el agente con la mayor duración total de llamadas. 
-- Muestra el nombre del agente y la duración total de sus llamadas en horas.
WITH CTE_suma_horas AS (
SELECT 
agente_id,
SUM(duracion_segundos) / 3600 AS total_horas
FROM llamadas
GROUP BY agente_id 
)
SELECT
a.nombre AS agente,
cte.total_horas
FROM CTE_suma_horas cte
INNER JOIN agentes a
ON cte.agente_id = a.agente_id
ORDER BY cte.total_horas DESC
LIMIT 1;

-- Encontrar los agentes que han recibido una puntuación de satisfacción promedio mayor a 4. 
-- Muestra el nombre del agente y la satisfacción promedio.
SELECT 
a.nombre AS agente,
AVG(l.satisfaccion_cliente) AS promedio_satisfaccion
FROM llamadas l
INNER JOIN agentes a 
ON l.agente_id = a.agente_id
GROUP BY a.nombre
HAVING AVG(l.satisfaccion_cliente) > 4
;

-- 

-- Encuentra el número total de llamadas atendidas por cada agente. 
-- Muestra el nombre del agente y la cantidad de llamadas que ha atendido.
SELECT
	a.nombre,
    COUNT(l.llamada_id) AS total_llamadas
    FROM agentes a 
    INNER JOIN llamadas l 
    ON a.agente_id = l.agente_id 
    GROUP BY a.nombre
    ORDER BY total_llamadas DESC;

-- Calcula la duración promedio de las llamadas por agente. 
-- Muestra el nombre del agente y la duración promedio en segundos.
SELECT
	a.nombre,
	AVG(l.duracion_segundos) AS promedio_llamada
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id
GROUP BY a.nombre
ORDER BY promedio_llamada DESC;

-- Encuentra los agentes que han atendido más de 5 llamadas. 
-- Muestra el nombre del agente y la cantidad de llamadas atendidas.
-- Con un LEFT JOIN podes incluir a los que no tienen ninguna llamada, por ejemplo, los agentes nuevos.
SELECT 
	a.nombre,
    COUNT(l.llamada_id) AS cantidad_llamadas
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id
GROUP BY a.nombre
HAVING cantidad_llamadas > 5;

-- Calcula la satisfacción promedio del cliente por agente. 
-- Muestra el nombre del agente y la satisfacción promedio.
SELECT
	a.nombre,
    ROUND(AVG(l.satisfaccion_cliente), 2) AS promedio_satisfaccion
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id 
GROUP BY a.nombre
ORDER BY promedio_satisfaccion DESC;

-- Encuentra los agentes que han trabajado más de 8 horas en un turno. 
-- Muestra el nombre del agente, la fecha del turno y la duración del turno en horas.
SELECT
	a.nombre,
    t.fecha_turno,
    TIME_TO_SEC(TIMEDIFF(t.hora_fin, t.hora_inicio)) / 3600 AS horas_totales
FROM agentes a 
INNER JOIN turnos t 
ON a.agente_id = t.agente_id
WHERE TIME_TO_SEC(TIMEDIFF(t.hora_fin, t.hora_inicio)) > 8 * 3600;

-- Encuentra el agente con la mayor duración total de llamadas. 
-- Muestra el nombre del agente y la duración total en horas.
WITH CTE_suma_llamadas AS (
	SELECT
		agente_id,
        SUM(duracion_segundos) / 3600 AS total_horas
	FROM llamadas
    GROUP BY agente_id
)
SELECT 
	a.nombre AS agente,
    cte.total_horas
FROM CTE_suma_llamadas cte
INNER JOIN agentes a 
ON cte.agente_id = a.agente_id 
ORDER BY total_horas DESC
LIMIT 1;

-- Calcula la cantidad de llamadas atendidas por día. 
-- Muestra la fecha y la cantidad de llamadas atendidas ese día.
SELECT
    fecha_llamada,
    COUNT(llamada_id) AS cantidad_llamadas
FROM llamadas
GROUP BY fecha_llamada
ORDER BY fecha_llamada;

-- Encuentra los agentes que han recibido una puntuación de satisfacción promedio mayor a 4. 
-- Muestra el nombre del agente y la satisfacción promedio.
WITH CTE_suma_llamada AS (
	SELECT
		agente_id,
        ROUND(AVG(satisfaccion_cliente), 2) AS promedio_satisfaccion
	FROM llamadas
    GROUP BY agente_id
)
SELECT
	a.nombre,
    cte.promedio_satisfaccion
FROM CTE_suma_llamada cte
INNER JOIN agentes a
ON cte.agente_id = a.agente_id
WHERE cte.promedio_satisfaccion > 4;

-- Encuentra el día con la mayor cantidad de llamadas atendidas. 
-- Muestra la fecha y la cantidad de llamadas, con manejo de empates.
SELECT 
	fecha_llamada,
    COUNT(llamada_id) AS total_llamadas
FROM llamadas
GROUP BY fecha_llamada
HAVING COUNT(llamada_id) = (
	SELECT MAX(total_llamadas)
    FROM (
    SELECT COUNT(llamada_id) AS total_llamadas
    FROM llamadas
    GROUP BY fecha_llamada
    ) AS max_llamadas
);

-- Encuentra los agentes que han atendido llamadas con una duración total superior a 10,000 segundos. 
-- Muestra el nombre del agente y la duración total en horas.
SELECT
	a.nombre AS agente,
    SUM(duracion_segundos) / 3600 AS total_llamadas_horas
FROM agentes a 
INNER JOIN llamadas l 
ON a.agente_id = l.agente_id
GROUP BY a.nombre
HAVING SUM(duracion_segundos) > 10000;

-- Encuentra los agentes que han trabajado más de 8 horas en un turno y han atendido al menos 5 llamadas. 
-- Muestra el nombre del agente, la fecha del turno, la duración del turno en horas y la cantidad de 
-- llamadas atendidas.
SELECT
    a.nombre AS agente,
    t.fecha_turno,
    TIME_TO_SEC(TIMEDIFF(t.hora_fin, t.hora_inicio)) / 3600 AS duracion_turno_horas,
    COUNT(l.llamada_id) AS cantidad_llamadas_atendidas
FROM agentes a
INNER JOIN turnos t
    ON a.agente_id = t.agente_id
INNER JOIN llamadas l
    ON a.agente_id = l.agente_id
    AND l.fecha_llamada = t.fecha_turno  -- Asegura que la llamada ocurrió en el mismo día del turno
GROUP BY a.nombre, t.fecha_turno, t.hora_inicio, t.hora_fin
HAVING duracion_turno_horas > 8
   AND COUNT(l.llamada_id) >= 5;