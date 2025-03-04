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