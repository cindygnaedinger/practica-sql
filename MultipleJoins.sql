-- MULTIPLE JOINS
SELECT c.name, fertility_rate, e.year, e.unemployment_rate
FROM countries AS c
INNER JOIN populations AS p ON c.code = p.country_code
INNER JOIN economies AS e ON p.country_code = e.code ;
--
/* 
Hay una máquina que realiza varios procesos al mismo tiempo. Escribe una query que calcule el tiempo promedio que le lleva a una máquina finalizar un proceso. El resultado tiene que traer el id de la máquina con el tiempo promedio redondeado a 3 decimales.
*/
WITH process_durations AS (
    SELECT machine_id,
    process_id,
    MAX(CASE WHEN activity_type = 'end' THEN TIMESTAMP END) -
    MAX(CASE WHEN activity_type = 'start' THEN TIMESTAMP END) AS duration
    FROM Activity
    GROUP BY machine_id, process_id
)
SELECT machine_id,
ROUND(AVG(duration), 3) AS processing_time
FROM process_durations
GROUP BY machine_id;