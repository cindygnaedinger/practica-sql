-- Encuentra todos los empleados y sus managers, 
-- pero solo muestra a los empleados que tienen un manager asignado (es decir, excluye al jefe principal).
SELECT
    a.nombre AS agente,
    m.nombre AS manager
FROM agentes a
INNER JOIN agentes m
    ON a.superior_id = m.agente_id;
-- La autounión es una técnica poderosa para trabajar con relaciones jerárquicas en una tabla, como empleados 
-- y managers o agentes y sus superiores.
-- Usar INNER JOIN o LEFT JOIN depende de si deseas incluir o excluir filas sin coincidencias.

-- Encuentra los agentes que han atendido más llamadas que el promedio de llamadas atendidas por todos los agentes. 
-- Muestra el nombre del agente y la cantidad de llamadas atendidas.
SELECT
    a.nombre AS agente,
    COUNT(l.llamada_id) AS conteo_llamada
FROM agentes a
INNER JOIN llamadas l
    ON a.agente_id = l.agente_id
GROUP BY a.nombre
HAVING COUNT(l.llamada_id) > (
    SELECT AVG(conteo_llamadas)
    FROM (
        SELECT COUNT(llamada_id) AS conteo_llamadas
        FROM llamadas
        GROUP BY agente_id
    ) AS promedio_llamadas
);

-- Asigna un ranking a los agentes basado en la cantidad de llamadas atendidas. 
-- Muestra el nombre del agente, la cantidad de llamadas atendidas y su ranking.
WITH CTE_ranking AS (
	SELECT
		a.agente_id,
        a.nombre AS agente,
        COUNT(l.llamada_id) AS conteo_llamada,
        DENSE_RANK() OVER(ORDER BY  COUNT(l.llamada_id)) AS ranking
        FROM agentes a 
        INNER JOIN llamadas l 
        ON a.agente_id = l.agente_id
        GROUP BY a.agente_id, a.nombre
)
SELECT
agente,
conteo_llamada,
ranking
FROM CTE_ranking
ORDER BY ranking DESC;
