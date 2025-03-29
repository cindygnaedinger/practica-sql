-- 📜 Caso #1: El Misterio del Agente 357
-- Contexto:
-- Recibes este email:
-- "Hola equipo, el agente 357 tiene el mejor CSAT (4.9/5), pero los clientes escalan el 30% de sus llamadas. ¿Es un error en los datos o hay algo raro? Investiga."

--Datos:

WITH agents AS (
    SELECT 357 AS agent_id, 'Sarah K.' AS agent_name, 1 AS team_id UNION ALL
    SELECT 101, 'John D.', 1 UNION ALL
    SELECT 102, 'Emma R.', 2
),
calls AS (
    SELECT 1 AS call_id, 357 AS agent_id, 5 AS satisfaction_score, 'Resolved' AS status UNION ALL
    SELECT 2, 357, 5, 'Escalated' UNION ALL
    SELECT 3, 357, 4, 'Escalated' UNION ALL
    SELECT 4, 101, 3, 'Resolved' UNION ALL
    SELECT 5, 102, 4, 'Resolved'
)

-- Query:

SELECT 
    a.agent_id,
    a.agent_name,
    AVG(c.satisfaction_score) AS avg_csat,
    COUNT(CASE WHEN c.status = 'Escalated' THEN 1 END) * 100.0 / COUNT(*) AS escalation_rate
FROM calls c
JOIN agents a ON c.agent_id = a.agent_id
GROUP BY a.agent_id, a.agent_name;

-- "Escalar una llamada" significa transferirla a un nivel superior de soporte (otro departamento, un supervisor o un equipo especializado) porque:

-- 📌 Razones comunes para escalar una llamada:
-- El problema es muy complejo y el agente actual no puede resolverlo.

-- Ejemplo: Un cliente reporta un fallo técnico que requiere un ingeniero.

-- El cliente está insatisfecho y pide hablar con un superior.

-- Ejemplo: Una queja fuerte sobre un servicio mal gestionado.

-- Se requiere autorización especial.

-- Ejemplo: Un reembolso grande que solo un manager puede aprobar.

SELECT *
FROM calls
WHERE agent_id = 357 AND status = 'Escalated';

-- Hallazgo: Las llamadas escaladas ¡tienen CSAT alto! Esto es raro (normalmente los clientes escalan cuando están insatisfechos).

-- Paso 3 - Hipótesis:

-- Posible manipulación de datos: El agente marca llamadas como "Escaladas" pero pone CSAT alto artificialmente.

-- Error en el sistema: Las llamadas escaladas no deberían permitir evaluación CSAT.