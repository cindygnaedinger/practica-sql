-- 📝 Ejercicio 1: INNER JOIN
-- Pregunta:
-- "Necesitamos un reporte de todas las llamadas que terminaron en venta, mostrando: ID de llamada, nombre del agente, nombre del cliente y monto de venta."

-- Tu tarea:
-- Escribe la consulta SQL usando INNER JOIN.

SELECT 
    l.llamada_id,
    a.nombre AS nombre_agente,
    c.nombre AS nombre_cliente,
    v.monto
FROM llamadas l
INNER JOIN ventas v ON l.agente_id = v.agente_id AND l.cliente_id = v.cliente_id
INNER JOIN agentes a ON l.agente_id = a.agente_id 
INNER JOIN clientes c ON l.cliente_id = c.cliente_id;

-- 📝 Ejercicio 2: LEFT JOIN
-- Pregunta:
-- "Queremos saber qué agentes NO han realizado ninguna venta. Muestra su nombre y fecha de contratación."

-- Tu tarea:
-- Usa LEFT JOIN para resolverlo.

SELECT
    a.nombre AS nombre_agente,
    a.fecha_contratacion
FROM agentes a 
LEFT JOIN ventas v ON a.agente_id = v.agente_id 
WHERE v.venta_id IS NULL;

-- 📝 Ejercicio 3: RIGHT JOIN
-- Pregunta:
-- "Identifica clientes que han hecho compras pero NO tienen registros de llamadas en el sistema. Muestra su nombre y plan contratado."

-- Tu tarea:
-- Usa RIGHT JOIN (o LEFT JOIN si prefieres).

SELECT 
    c.nombre AS nombre_cliente,
    c.plan_contratado
FROM clientes c
INNER JOIN ventas v ON c.cliente_id = v.cliente_id
LEFT JOIN llamadas l ON c.cliente_id = l.cliente_id
WHERE l.llamada_id IS NULL;

-- 📝 Ejercicio 4: FULL OUTER JOIN
-- Pregunta:
-- "Genera un listado completo de agentes y llamadas, incluso si algunos agentes no tienen llamadas registradas o algunas llamadas no tienen agente asignado (por errores de datos)."
-- "Modifica la consulta para incluir solo agentes del equipo 'Premium' o llamadas con duración > 300 segundos."

-- Tu tarea:
-- Usa FULL OUTER JOIN (en BigQuery es FULL JOIN).
SELECT
    a.nombre AS agente_nombre,
    l.llamada_id
FROM agentes a 
FULL JOIN llamadas l ON a.agente_id = l.agent_id
WHERE (a.equipo = 'Premium' AND a.agente_id IS NOT NULL)
   OR (l.duracion_seg > 300 AND l.agente_id IS NOT NULL)
   OR (a.agente_id IS NULL OR l.agente_id IS NULL)

-- 📝 Ejercicio 5: SELF JOIN
-- Pregunta:
-- "Encuentra agentes que pertenecen al mismo equipo y fueron contratados en el mismo mes. Muestra sus nombres y el equipo."

-- Tu tarea:
-- Usa SELF JOIN sobre la tabla agentes.
WITH agentes_filtrados AS (
  SELECT * FROM agentes WHERE equipo = 'Premium' 
) -- hacemos una tabla temporal para filtrar por equipos y reducir el costo de la consulta
SELECT 
    a1.nombre AS agente_uno,
    a2.nombre AS agente_uno,
    a1.equipo,
    a1.fecha_contratacion
FROM agentes a1 
INNER JOIN agentes a2 ON a1.equipo = a2.equipo
AND DATETRUNC(a1.fecha_contratacion, MONTH) = DATETRUNC(a2.fecha_contratacion, MONTH) -- encunetra agentes del mismo equipo contratados el mismo mes, no necesariamente la misma fecha
AND a1.agent_id > a2.agent_id; -- para que no empareje al mismo agente consigo mismo o que repita a-b, b-a

-- 📝 Ejercicio 6: CROSS JOIN
-- Pregunta:
-- "Para una campaña especial, queremos asignar a todos los agentes del equipo 'Premium' a todos los clientes con plan 'Empresarial'. Genera todas las combinaciones posibles."

-- Tu tarea:
-- Usa CROSS JOIN.

SELECT 
    a.nombre AS agente_nombre,
    c.nombre AS cliente_nombre
FROM (SELECT * FROM agentes WHERE equipo = 'Premium') a 
CROSS JOIN (SELECT * FROM clientes WHERE equipo = 'Empresarial') c
LIMIT 10000; -- Para grandes volúmenes de datos, generalmente es mejor usar subconsultas directamente en el FROM en lugar de WITH

-- 📝 Ejercicio 7: JOIN con Múltiples Tablas
-- Pregunta:
-- "Muestra todas las ventas realizadas, incluyendo: nombre del agente, nombre del cliente, duración de la llamada asociada (si existe) y monto."

-- Tu tarea:
-- Combina JOINs entre 3 tablas: ventas, agentes, clientes y llamadas.

SELECT 
    v.venta_id,
    a.nombre AS agente_nombre,
    c.nombre AS cliente_nombre,
    l.duracion_seg,
    v.monto,
    v.fecha AS fecha_venta,
    l.fecha_hora AS fecha_llamada
FROM ventas v 
INNER JOIN agentes a ON v.agente_id = a.agente_id 
INNER JOIN clientes c ON v.cliente_id = c.cliente_id 
LEFT JOIN llamadas l ON v.agente_id = l.agente_id
    AND v.cliente_id = l.cliente_id
    AND DATE(l.fecha_hora) = DATE(v.fecha) -- asume la venta en el mismo día
WHERE v.fecha BETWEEN '2023-01-01' AND '2023-12-31'; -- filtro temporal para performance, reducir la cantidad de datos procesados

-- para optimizar la query puedo hacer dos cte que filtren por los utlimos 30 días:
WITH ventas_recientes AS (
  SELECT * FROM ventas 
  WHERE fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
),
llamadas_recientes AS (
  SELECT * FROM llamadas
  WHERE fecha_hora >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
)

SELECT 
    v.venta_id,
    a.nombre AS agente_nombre,
    c.nombre AS cliente_nombre,
    l.duracion_seg,
    v.monto
FROM ventas_recientes v
INNER JOIN agentes a ON v.agente_id = a.agente_id
INNER JOIN clientes c ON v.cliente_id = c.cliente_id
LEFT JOIN llamadas_recientes l ON v.agente_id = l.agente_id 
                   AND v.cliente_id = l.cliente_id
                   AND DATE(l.fecha_hora) = DATE(v.fecha)


-- INFORMATION_SCHEMA.JOBS: es una vista metadatos en BigQuery que te permite:

-- Monitorear el consumo de tus consultas

-- Identificar consultas costosas

-- Optimizar el uso de recursos

SELECT
  job_id,
  query,
  total_bytes_processed,
  total_bytes_billed,
  total_slot_ms,
  TIMESTAMP_DIFF(end_time, start_time, MILLISECOND) AS duration_ms,
  user_email,
  creation_time
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE DATE(creation_time) = CURRENT_DATE()
  AND job_type = 'QUERY'
ORDER BY total_bytes_billed DESC
LIMIT 10;