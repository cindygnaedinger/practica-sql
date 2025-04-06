-- Posible optimización (para BigQuery):

-- Si orders tiene millones de filas, filtrar antes del JOIN mejora el rendimiento:

SELECT u.name, o.order_id
FROM ecommerce.users u
INNER JOIN (
  SELECT user_id, order_id 
  FROM ecommerce.orders 
  WHERE amount > 500
) o ON u.user_id = o.user_id
ORDER BY u.name;

-- "Encuentra a los usuarios (name) cuyo gasto total (suma de amount) en órdenes sea mayor a $1000. Muestra su nombre y gasto total, ordenado de mayor a menor gasto."
SELECT 
  u.name, 
  SUM(o.amount) AS total_gasto
FROM ecommerce.users u
INNER JOIN ecommerce.orders o ON u.user_id = o.user_id
GROUP BY u.name
HAVING SUM(o.amount) > 1000
ORDER BY total_gasto DESC;

-- "Lista los países (country) con más de 50 usuarios cuyo promedio de edad sea mayor a 30 años. Muestra país, cantidad de usuarios y edad promedio, ordenado por cantidad de usuarios (desc)."
SELECT 
country, 
COUNT(user_id) AS cantidad_usuarios, 
AVG(age) 
FROM ecommerce.users 
WHERE age IS NOT NULL
GROUP BY country 
HAVING COUNT(user_id) > 50 
AND AVG(age) > 30 
ORDER BY cantidad_usuarios DESC;