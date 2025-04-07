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

-- "Calcula el total de ventas (amount) por mes en 2023, usando solo datos de la partición de ese año. Muestra el mes (formato 'YYYY-MM') y el monto total, ordenado cronológicamente."
SELECT
  EXTRACT(YEAR FROM order_date) AS año,
  EXTRACT(MONTH FROM order_date) AS mes,
  SUM(amount) AS total_ventas
FROM 
  `ecommerce.orders`
WHERE 
  _PARTITIONDATE BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
  año, mes
ORDER BY 
  año, mes;

-- "Encuentra los 5 productos más vendidos (por cantidad de órdenes) en cada categoría durante el Q1 de 2024, mostrando categoría, nombre de producto y total de órdenes."

WITH ventas_por_producto AS (
    SELECT 
    p.categoria,
    p.nombre,
    COUNT(o.order_id) AS total_ordenes,
    RANK() OVER(PARTITION BY p.categoria ORDER BY COUNT(o.order_id) DESC) AS ranking
FROM ecommerce.orders o 
JOIN ecommerce.products p ON o.product_id = p.product_id
WHERE o._PARTITIONDATE BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY p.categoria, p.nombre
)
SELECT 
categoria,
nombre,
total_ordenes
FROM 
ventas_por_producto
WHERE
ranking <= 5
ORDER BY 
categoria,
total_ordenes DESC;

-- "Para cada categoría, muestra:

-- Ventas del mes actual

-- Ventas del mes anterior

-- Diferencia porcentual vs mes anterior

-- Ranking de categorías por ventas dentro de cada mes

-- Usa solo datos de 2024 y ordena por mes (nuevo a viejo) y luego por ranking."

WITH ventas_mes AS (
    SELECT 
    month,
    category,
    total_sales AS ventas_actuales,
    LAG(total_sales) OVER(PARTITION BY category ORDER BY month) AS ventas_previas,
    RANK() OVER(PARTITION BY month ORDER BY total_sales DESC) AS ranking_mes
FROM ecommerce.monthly_sales
WHERE
EXTRACT(YEAR FROM month) = '2024'
)
SELECT 
month,
category,
ventas_actuales,
ventas_previas,
ROUND(SAFE_DIVIDE((ventas_actuales - ventas_previas), ventas_previas) * 100, 2) AS incremento_porcentual,
ranking_mes
FROM ventas_mes
ORDER BY month DESC, ranking_mes;

-- Escribe una consulta que obtenga todas las llamadas del 1 de noviembre de 2023 que duraron más de 2 minutos (120 segundos), mostrando solo:

-- llamada_id

-- fecha_hora

-- duracion_segundos

-- tipo_llamada

-- Ordena los resultados por duración (de mayor a menor).

SELECT 
  llamada_id, 
  fecha_hora, 
  duracion_segundos, 
  tipo_llamada 
FROM llamadas 
WHERE fecha_hora BETWEEN TIMESTAMP('2023-11-01') AND TIMESTAMP('2023-11-02')
  AND duracion_segundos > 120 
ORDER BY duracion_segundos DESC;

-- Mostrar para cada agente:

-- Su ID

-- Cantidad total de llamadas atendidas

-- Duración promedio por llamada (en minutos)

-- Solo agentes con más de 10 llamadas
SELECT 
  agente_id, 
  COUNT(llamada_id) AS cantidad_llamadas, 
  ROUND(AVG(duracion_segundos)/60, 2) AS duracion_promedio_minutos  
FROM llamadas 
GROUP BY agente_id 
HAVING cantidad_llamadas > 10
ORDER BY cantidad_llamadas DESC;