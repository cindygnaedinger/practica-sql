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