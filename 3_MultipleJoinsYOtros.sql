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
/*
    ¿Puedes escribir una consulta que calcule el número total de pedidos completados por cada cliente? La consulta debe devolver el customer_id y el número de pedidos completados (total_orders).
*/
-- cuando hacemos COUNT es mejor hacer por el id o * porque el id nunca va a tener un valor nulo y el * cuenta todo que es lo que queremos.
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
WHERE status = 'completed'
GROUP BY customer_id;
--
/*
    Escribe una consulta SQL que devuelva el nombre del cliente, su email y el número total de pedidos completados, pero solo para aquellos clientes cuyo número de pedidos completados sea mayor que el promedio de pedidos completados de todos los clientes.
*/
SELECT
    c.customer_name, 
    c.email,
    COUNT(o.order_id) AS total_orders
FROM orders o
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_name, c.email;
HAVING COUNT(o.order_id) > ( -- no se puede usar un alias, tengo que repetir el COUNT
        SELECT AVG(order_count)
        FROM (
        SELECT COUNT(order_id) AS order_count
        FROM orders
        WHERE status = 'completed'
        GROUP BY cutomer_id
    ) AS promedio_orders
);
-- Cuando usas una subconsulta en el FROM, SQL trata el resultado de esa subconsulta como una tabla temporal. Para que la consulta externa pueda acceder a las columnas de esa tabla temporal, estas deben tener nombres (alias).
/*  ¿Cuándo usar HAVING? 
        1. Si estás filtrando basado en el resultado de una función de agregación (SUM, COUNT, AVG, etc.), debes usar HAVING. Ejemplo: Filtrar clientes con más de 5 pedidos (COUNT(order_id) > 5). 
        2. Si tu consulta incluye GROUP BY, es probable que necesites HAVING para filtrar los grupos. 
        3. WHERE filtra filas antes de la agregación, mientras que HAVING filtra después. Si intentas usar WHERE con una columna agregada, SQL lanzará un error. 
        */
--
/*
    Escribe una consulta SQL que devuelva el product_id y el total de ventas (total_sales) para cada producto, pero solo para aquellos productos cuyo total de ventas sea mayor que el promedio de ventas de todos los productos.
*/
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    sale_date DATE,
    amount DECIMAL(10, 2)
);
SELECT
    product_id, 
    COUNT(sale_id) AS total_sales
FROM sales
GROUP BY product_id
HAVING COUNT(sale_id) > (
    SELECT AVG(sale_count)
    FROM (
        SELECT COUNT(sale_id) AS sale_count
        FROM sales
        GROUP BY product_id
    ) AS promedio_sales
);
--
/* 
    ¿Qué es una CTE?
Una CTE (Common Table Expression) es una consulta temporal que puedes definir dentro de una sentencia SQL. Es similar a una subconsulta, pero tiene varias ventajas:

Es más legible y fácil de mantener. / Puedes reutilizarla varias veces en la misma consulta. /Es útil para descomponer consultas complejas en partes más manejables.

?¿Cuándo usar una subconsulta?
Simplicidad: La consulta es simple y no necesita ser dividida.
Una sola vez: Solo necesitas el resultado intermedio una vez en la consulta.
Rendimiento: En algunos casos, las subconsultas pueden ser más eficientes que las CTEs (depende del motor de la base de datos).

?¿Cuándo usar una CTE?
Legibilidad: La consulta es compleja y quieres dividirla en partes más manejables.
Reutilización: Necesitas usar el mismo resultado intermedio varias veces en la consulta.
Mantenimiento: Quieres que el código sea más fácil de entender y mantener.
*/
-- Usando la tabla sales, escribe una consulta SQL que devuelva el product_id y el total de ventas (total_sales), pero solo para aquellos productos cuyo total de ventas sea mayor que el promedio de ventas de todos los productos. Usa una CTE para calcular el promedio.
WITH CTE_total_sales AS (
    SELECT product_id,
    SUM(amount) AS total_sales
    FROM sales
    GROUP BY product_id
),
    CTE_promedio_sales AS (
        SELECT product_id,
        AVG(total_sales) AS promedio_sales
        FROM CTE_total_sales
    )
SELECT
    product_id,
    total_sales
FROM 
    CTE_total_sales
WHERE total_sales > (SELECT promedio_sales FROM CTE_promedio_sales)
ORDER BY total_sales DESC;
--
-- ¿Puedes escribir una consulta que use una CTE para calcular el número total de pedidos completados por cada cliente y luego devuelva solo aquellos clientes que tienen más pedidos completados que el promedio? Usa las tablas orders y customers.
WITH CTE_total_pedidos AS (
    SELECT customer_id,
    COUNT(order_id) AS total_pedidos 
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
    CTE_promedio_pedidos AS (
        SELECT
            AVG(total_pedidos) AS promedio_pedidos 
        FROM CTE_total_pedidos
    )
SELECT
    customer_id,
    total_pedidos
FROM CTE_total_pedidos
WHERE total_pedidos > (SELECT promedio_pedidos FROM CTE_promedio_pedidos)
ORDER BY total_pedidos DESC;
--
-- Escribe una consulta SQL que devuelva el customer_id, el número total de pedidos completados y el ranking de cada cliente basado en el número de pedidos completados. Usa una función de ventana para calcular el ranking. Ordena los resultados por el ranking de forma ascendente.
WITH CTE_pedidos_completados AS (
    SELECT customer_id,
    COUNT(order_id) AS total_pedidos
    FROM orders
    WHERE status = "completed"
    GROUP BY customer_id
)
SELECT customer_id,
total_pedidos,
DENSE_RANK() OVER (ORDER BY total_pedidos DESC) AS ranking
FROM CTE_pedidos_completados
ORDER BY ranking;

-- ? RANK(): Si dos filas tienen el mismo valor, les asigna el mismo ranking, pero el siguiente ranking se salta los números correspondientes. Ejemplo: Si dos clientes tienen 3 pedidos (ranking 1), el siguiente cliente tendrá ranking 3 (se salta el 2). 
-- ? DENSE_RANK(): Si dos filas tienen el mismo valor, les asigna el mismo ranking, pero el siguiente ranking no se salta números. Ejemplo: Si dos clientes tienen 3 pedidos (ranking 1), el siguiente cliente tendrá ranking 2.