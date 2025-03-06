/*
Lista los empleados que han cambiado de departamento al menos una vez. Para esto, asume que tienes una tabla llamada historial_empleados con las siguientes columnas:

empleado_id (identificador único del empleado)

departamento_id (identificador del departamento)

fecha_inicio (fecha en la que el empleado empezó en ese departamento)

fecha_fin (fecha en la que el empleado dejó ese departamento, puede ser NULL si aún está en ese departamento)

Debes listar el empleado_id y el número de veces que ha cambiado de departamento. Ordena el resultado por el número de cambios de departamento de forma descendente.
*/
SELECT
    empleado_id,
    COUNT(DISTINCT departamento_id) AS cambios_empleado
FROM historial_empleados
GROUP BY empleado_id
HAVING COUNT(DISTINCT departamento_id) > 1
ORDER BY cambios_empleado DESC;

/* 
    En la misma tabla historial_empleados, encuentra el tiempo total (en días) que cada empleado ha pasado en cada departamento. Asume que si fecha_fin es NULL, significa que el empleado aún está en ese departamento, y debes usar la fecha actual para calcular el tiempo.

Debes listar:

empleado_id

departamento_id

tiempo_total_dias (tiempo total en días que el empleado ha estado en ese departamento)

Ordena el resultado por empleado_id y departamento_id.
*/
SELECT
    empleado_id,
    departamento_id,
    SUM(
        DATEDIFF(
            COALESCE(fecha_fin, CURRENT_DATE), -- si la fecha es null, usa la fecha actual
            fecha_inicio
        )
    ) AS tiempo_total 
FROM historial_empleados
GROUP BY empleado_id, departamento_id
ORDER BY empleado_id, departamento_id;
/* Si estás usando PostgreSQL, la función DATEDIFF no existe. En su lugar, puedes restar las fechas directamente:
            SUM(
            (COALESCE(fecha_fin, CURRENT_DATE) - fecha_inicio)
        ) AS tiempo_total_dias
*/
--
/*
    En la misma tabla historial_empleados, encuentra el departamento en el que cada empleado ha pasado más tiempo. Si un empleado ha estado en varios departamentos el mismo número de días, elige el departamento con el departamento_id más bajo.

Debes listar:

empleado_id

departamento_id (el departamento en el que ha pasado más tiempo)

tiempo_total_dias (el tiempo total en días que ha estado en ese departamento)

Ordena el resultado por empleado_id.
*/
WITH CTE_tiempo_mayor AS(
    SELECT
        empleado_id,
        departamento_id,
        SUM(
            DATEDIFF(
                COALESCE(fecha_fin, CURRENT_DATE), -- si la fecha es null, usa la fecha actual
                fecha_inicio
            )
    ) AS tiempo_total 
FROM historial_empleados
GROUP BY empleado_id, departamento_id;
),
    CTE_ranking_tiempo AS(
        empleado_id,
        departamento_id
        tiempo_total,
        ROW_NUMBER() OVER(PARTITION BY empleado_id ORDER BY tiempo_total DESC, departamento_id ASC) AS ranking 
    FROM CTE_tiempo_mayor
    )

SELECT
    empleado_id,
    departamento_id,
    tiempo_total
FROM CTE_ranking
WHERE ranking = 1;
ORDER BY empleado_id;

/*
    En la misma tabla historial_empleados, encuentra el empleado que ha estado en más departamentos diferentes. Si hay empates, lista todos los empleados que cumplen con esa condición.

Debes listar:

empleado_id

cantidad_departamentos (el número de departamentos diferentes en los que ha estado)

Ordena el resultado por cantidad_departamentos de forma descendente.
*/
SELECT
    empleado_id,
    departamento_id,
    COUNT( DISTINCT departamento_id) AS cantidad_departamentos
FROM historial_empleados
GROUP BY empleado_id
ORDER BY cantidad_departamentos DESC;

/*
En la misma tabla historial_empleados, encuentra el empleado que ha estado en más departamentos y también ha pasado más tiempo en total en todos los departamentos combinados. Si hay empates, lista todos los empleados que cumplen con esa condición.

Debes listar:

empleado_id

cantidad_departamentos (el número de departamentos diferentes en los que ha estado)

tiempo_total_dias (el tiempo total en días que ha estado en todos los departamentos)

Ordena el resultado por cantidad_departamentos de forma descendente y, en caso de empate, por tiempo_total_dias de forma descendente.
*/
WITH CTE_cantidad_departamentos AS(
    SELECT
        empleado_id,
        COUNT(DISTINCT departamento_id) AS total_departamentos
        FROM historial_empleados
        GROUP BY empleado_id
),
    CTE_tiempo_total AS (
        SELECT 
        empleado_id,
        SUM( 
            DATEDIFF( 
                COALESCE(fecha_fin, CURRENT_DATE),
                fecha_inicio
            )
        ) AS tiempo_total
 FROM historial_empleados
 GROUP BY empleado_id
    )
SELECT
    c.empleado_id,
    c.total_departamentos
    t.tiempo_total
FROM CTE_cantidad_departamentos c 
INNER JOIN CTE_tiempo_total t 
    ON c.empleado_id = t.empleado_id
ORDER BY c.total_departamentos DESC,
t.tiempo_total DESC;

/*
En la misma tabla historial_empleados, encuentra el departamento en el que los empleados han pasado en promedio más tiempo. Si hay empates, lista todos los departamentos que cumplen con esa condición.
*/
WITH CTE_tiempo_total AS (
        SELECT 
        departamento_id,
        empleado_id,
        SUM( 
            DATEDIFF( 
                COALESCE(fecha_fin, CURRENT_DATE),
                fecha_inicio
            )
        ) AS tiempo_total
 FROM historial_empleados
 GROUP BY departamento_id, empleado_id
    )
SELECT
    departamento_id,
    AVG(tiempo_total) AS promedio_tiempo_total
FROM CTE_tiempo_total
GROUP BY departamento_id
ORDER BY promedio_tiempo_total;
