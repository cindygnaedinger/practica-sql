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

