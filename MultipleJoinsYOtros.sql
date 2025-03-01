--MULTIPLE JOINS
SELECT c.name, fertility_rate, e.year, e.unemployment_rate
FROM countries AS c
INNER JOIN populations AS p ON c.code = p.country_code
INNER JOIN economies AS e ON p.country_code = e.code;
--
/* 
Hay una máquina que realiza varios procesos al mismo tiempo. Escribe una query que calcule el tiempo promedio que le lleva a una máquina finalizar un proceso. El resultado tiene que traer el id de la máquina con el tiempo promedio redondeado a 3 decimales.
*/
WITH process_durations AS(
    SELECT machine_id,
    process_id,
    MAX(CASE WHEN activity_type = 'end'
        THEN TIMESTAMP END) -
    MAX(CASE WHEN activity_type = 'start'
        THEN TIMESTAMP END) AS duration FROM Activity GROUP BY machine_id, process_id
)
SELECT machine_id,
ROUND(AVG(duration), 3) AS processing_time
FROM process_durations
GROUP BY machine_id;
--
/*
    En SQL es buena práctica usar comillas simples.
    Consulta básica: el comercio electrónico tiene una tabla orders. Busca los pedidos que tengan el status completado ordenados por la cantidad total de forma descendente.
*/
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20) --'completed', 'pending', 'cancelled'
);

SELECT
order_id,
customer_id,
order_date,
total_amount
FROM orders
WHERE status = 'completed'
ORDER BY total_amount DESC;
--
/*
    Agregación y agrupación: un informe que muestre el total gastado por cada cliente en pedidos completados. La consulta tiene que devolver el customer_id y el total_gastado ordenados de forma descendente.
*/
SELECT 
    customer_id, 
    SUM(total_amount) AS TotalGastado
FROM orders
WHERE status = "completed"
GROUP BY customer_id
ORDER BY TotalGastado DESC;
--
/*
    Escribe una consulta SQL que devuelva el nombre del cliente (customer_name), su email y el total gastado (total_amount) en pedidos completados. Ordena los resultados por el total gastado de forma descendente.
*/
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);
SELECT
    c.customer_name, c.email, SUM(o.total_amount) AS TotalGastado
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.email
ORDER BY TotalGastado DESC;

-- Usamos GROUP BY cuando tenemos funciones de agregación en la query para agrupar las columnas restantes.
-- ? Regla clave: Todas las columnas que aparecen en el SELECT y no están dentro de una función de agregación deben estar en el GROUP BY.
--
