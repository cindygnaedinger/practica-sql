-- Muestra el nombre del empleado y el nombre del departamento al que pertenece.
SELECT 
	e.nombre,
    d.nombre
FROM empleados e 
INNER JOIN departamentos d
	on e.departamento_id = d.departamento_id;
   
-- Muestra el nombre del departamento y el salario promedio de sus empleados.
SELECT
	d.nombre,
    AVG(e.salario) AS salario_promedio_depto
    FROM empleados e 
    INNER JOIN departamentos d 
		ON e.departamento_id = d.departamento_id
	GROUP BY d.nombre;
    
-- Listar los empleados que han cambiado de departamento al menos una vez. 
-- Muestra el nombre del empleado y la cantidad de departamentos en los que ha estado.
SELECT
	e.nombre,
    COUNT(DISTINCT he.departamento_id) AS cantidad_departamento
FROM historial_empleados he
INNER JOIN empleados e
	ON he.empleado_id = e.empleado_id
GROUP BY e.empleado_id
HAVING COUNT(DISTINCT he.departamento_id) > 1;

-- Encontrar el empleado que ha estado en más departamentos. 
-- Muestra el nombre del empleado y la cantidad de departamentos en los que ha estado.
SELECT
	e.nombre,
	h.empleado_id,
    COUNT(DISTINCT h.departamento_id) AS total_departamentos
FROM historial_empleados h
INNER JOIN empleados e 
	ON h.empleado_id = e.empleado_id
GROUP BY h.empleado_id
ORDER BY total_departamentos DESC
LIMIT 1;

-- Calcular el tiempo total que cada empleado ha pasado en cada departamento. 
-- Muestra el nombre del empleado, el nombre del departamento y el tiempo total en días.
SELECT
	e.nombre AS empleado,
    d.nombre AS departamento,
    SUM(
		DATEDIFF(
			COALESCE(h.fecha_fin, CURRENT_DATE),
            h.fecha_inicio)) AS tiempo_total_dias
FROM historial_empleados h
INNER JOIN empleados e
	ON h.empleado_id = e.empleado_id
INNER JOIN departamentos d
	ON h.departamento_id = d.departamento_id
GROUP BY e.nombre, d.nombre
ORDER BY tiempo_total_dias DESC;

-- Encontrar el departamento en el que los empleados han pasado más tiempo en promedio. 
-- Muestra el nombre del departamento y el tiempo promedio en días.
WITH CTE_total_tiempo AS (
	SELECT
    departamento_id,
    empleado_id,
    SUM(
		DATEDIFF(
			COALESCE(fecha_fin, CURRENT_DATE),
            fecha_inicio)) AS tiempo_total_dias
FROM historial_empleados
GROUP BY departamento_id, empleado_id
),
	CTE_promedio_dias AS(
	SELECT
		departamento_id,
		ROUND(AVG(tiempo_total_dias)) AS promedio_departamento
	FROM CTE_total_tiempo
    GROUP BY departamento_id
)
SELECT
    d.nombre AS departamento,
    cte.promedio_departamento
FROM CTE_promedio_dias cte
INNER JOIN departamentos d 
	ON cte.departamento_id = d.departamento_id
ORDER BY cte.promedio_departamento DESC;

-- Encontrar los empleados que han estado en más de un departamento y han pasado más de 365 días en 
-- total en todos los departamentos combinados. 
-- Muestra el nombre del empleado, la cantidad de departamentos y el tiempo total en días.
SELECT
	e.nombre,
	h.empleado_id,
    COUNT(DISTINCT h.departamento_id) AS total_departamentos
FROM historial_empleados h
INNER JOIN empleados e 
	ON h.empleado_id = e.empleado_id
    WHERE COUNT(DISTINCT h.departamento_id) > 1
GROUP BY h.empleado_id
ORDER BY total_departamentos DESC
;

-- Encontrar los empleados que han estado en más de un departamento y han pasado más de 365 días 
-- en total en todos los departamentos combinados. 
-- Muestra el nombre del empleado, la cantidad de departamentos y el tiempo total en días.
WITH CTE_cantidad_departamento AS (
SELECT
	empleado_id,
    COUNT(DISTINCT departamento_id) AS cantidad_departamento
    FROM historial_empleados
    GROUP BY empleado_id),
    CTE_tiempo_total AS (
    SELECT
    empleado_id,
    SUM(
		DATEDIFF(
			COALESCE(fecha_fin, CURRENT_DATE),
				fecha_inicio)) AS tiempo_total
	FROM historial_empleados
    GROUP BY empleado_id
    )
SELECT 
	e.nombre AS empleado,
    cte1.cantidad_departamento,
    cte2.tiempo_total
FROM CTE_cantidad_departamento cte1
INNER JOIN CTE_tiempo_total cte2
ON cte1.empleado_id = cte2.empleado_id
INNER JOIN empleados e 
ON cte2.empleado_id = e.empleado_id
WHERE cte1.cantidad_departamento > 1
AND cte2.tiempo_total > 365
;