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