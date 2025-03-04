-- Escribe una consulta que devuelva el nombre, apellido y salario de los empleados que trabajan en el departamento de Finanzas y cuyo salario sea mayor a 3600.
SELECT 
    nombre,
    apellido,
    salario
FROM empleados
WHERE departamento = 'Finanzas'
AND salario > 3600;

-- Escribe una consulta SQL que muestre el nombre, apellido y salario de todos los empleados, ordenados del salario más alto al más bajo.
SELECT 
    nombre,
    apellido, 
    salario
FROM empleados
ORDER BY salario DESC;

-- Escribe una consulta que muestre nombre, apellido y fecha_contratacion de los empleados cuya fecha de contratación sea posterior a '2018-01-01'.
SELECT 
    nombre,
    apellido,
    fecha_contratacion
FROM empleados
WHERE fecha_contratacion > '2018-01-01';

-- Escribe una consulta que devuelva una columna llamada salario_promedio con el salario promedio de todos los empleados.
SELECT 
    AVG(salario) AS salario_promedio -- No es necesario usar SUM(salario), ya que AVG() se encarga de dividir la suma entre la cantidad de empleados.
FROM empleados;

-- Escribe una consulta que muestre el departamento y el salario promedio de los empleados de cada departamento.
SELECT 
    departamento,
    AVG(salario) AS salario_promedio
FROM empleados
GROUP BY departamento;

-- Modifica tu consulta anterior para mostrar solo los departamentos con un salario_promedio mayor a 4000.
SELECT 
    departamento,
    AVG(salario) AS salario_promedio
FROM empleados
GROUP BY departamento
HAVING AVG(salario) > 4000; -- WHERE no puede filtrar sobre operaciones de agregación. No uses el alias, tenes que volver a repetir la agregacion con AVG.

-- Escribe una consulta que muestre: el departamento. La cantidad de empleados en cada uno (usa COUNT(*)).
SELECT 
    departamento,
    COUNT(*) AS total_departamento
FROM empleados
GROUP BY departamento;

-- Escribe una consulta que muestre:departamento MAX(salario) como salario_maximo
SELECT
    departamento,
    MAX(salario) AS mayor_salario
FROM empleados
GROUP BY departamento;

-- Ahora queremos saber quién gana el salario más alto en cada departamento. Escribe una consulta que muestre: departamento nombre del empleado con el salario más alto salario.
WITH CTE_salario_mayor AS(
    SELECT
        departamento,
        MAX(salario) AS salario_mayor 
    FROM empleados
    GROUP BY departamento
)
SELECT
    e.nombre,
    e.apellido,
    e.departamento,
    cte.salario_mayor 
FROM empleados e
INNER JOIN CTE_salario_mayor cte 
    ON e.departamento = cte.departamento
    AND e.salario = cte.salario_mayor
ORDER BY e.departamento;

-- Queremos clasificar los empleados según su nivel salarial: "Alto" si su salario es mayor a 6000. "Medio" si está entre 3000 y 6000. "Bajo" si es menor a 3000. Una nueva columna categoria_salarial que clasifique el salario según las reglas anteriores.
/*
Simple CASE expression:
CASE input_expression
     WHEN when_expression THEN result_expression [ ...n ]
     [ ELSE else_result_expression ]
END
*/
SELECT
    nombre,
    apellido,
    departamento,
    CASE salario
        WHEN salario > 6000 THEN "Alto",
        WHEN salario BETWEEN 3000 AND 6000 THEN "Medio",
        WHEN salario < 3000 THEN "Bajo"
    END AS categoria_salarial
FROM empleados;

-- Escribe una consulta que muestre el nombre y apellido de los empleados cuyo salario es el más bajo en los departamentos de "IT" y "Finanzas". Usa una subconsulta con IN para filtrar por los salarios más bajos.
SELECT
    nombre,
    apellido
FROM empleados
WHERE salario = (
    SELECT MIN(salario)
    FROM empleados
    WHERE departamento IN ('IT', 'Finanzas')
);

-- Queremos obtener los empleados cuyo salario está por encima del salario promedio de su departamento. Escribe una consulta que muestre el nombre, apellido, departamento y salario de los empleados cuyo salario es superior al salario promedio de su respectivo departamento.
WITH CTE_salario_promedio AS(
    SELECT
        departamento,
        AVG(salario) AS salario_promedio
    FROM empleados
    GROUP BY departamento
)
SELECT 
    e.nombre,
    e.apellido,
    e.departamento,
    e.salario
FROM empleados e 
INNER JOIN CTE_salario_promedio cte 
    ON e.departamento = cte.departamento
WHERE e.salario > cte.salario_promedio
ORDER BY departamento;

-- Queremos obtener una lista de todos los empleados y mostrar el nombre del gerente del departamento al que pertenecen. Algunos departamentos pueden no tener gerente, en ese caso, la columna de gerente debe mostrar NULL. Escribe una consulta que muestre: nombre del empleado, apellido del empleado, nombre del gerente (si existe), departamento
SELECT 
    e.nombre,
    e.apellido,
    g.nombre AS nombre_gerente,
    e.departamento
FROM empleados e 
LEFT JOIN empleados g 
    ON e.gerente_id = g.id -- autocomplejo o auto-JOIN
ORDER BY e.departamento;
-- Un auto-JOIN simplemente se realiza cuando se hace un JOIN de una tabla consigo misma. Esto se hace mediante el uso de alias para distinguir las dos instancias de la misma tabla.

-- Queremos obtener una lista de departamentos junto con los nombres de los empleados que pertenecen a cada uno, mostrando todos los empleados de un departamento en una sola fila. Escribe una consulta que muestre: departamento, nombres de los empleados separados por comas.
SELECT
    departamento,
    GROUP_CONCAT(nombre ORDER BY nombre ASC SEPARATOR ", ") AS empleados
FROM empleados
GROUP BY departamento;

-- 