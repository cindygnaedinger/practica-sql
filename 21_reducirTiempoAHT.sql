-- A call center for an electronics retailer wants to reduce Average Handle Time (AHT) by identifying agents who struggle with high-volume product categories (e.g., laptops, smartphones). They need a query to pinpoint agents with below-average performance in these categories.

-- Los que tienen una performance mala suelen tener una duracion de llamada mayor y un puntaje de satisfaccion bajo.

WITH promedio_categoria AS (
    SELECT
    product_category,
    AVG(duration_sec) AS promedio_duracion
FROM calls
WHERE product_category IN ('laptop', 'smartphone')
GROUP BY product_category
)
SELECT 
    a.agent_id,
    c.product_category,
    c.duration_sec,
    pc.promedio_duracion,
    (c.duration_sec - pc.promedio_duracion) AS exceso_duracion
FROM calls c 
JOIN agents a ON c.agent_id = a.agent_id 
JOIN promedio_categoria pc ON c.product_category = pc.product_category
WHERE duration_sec > pc.promedio_duracion
AND c.product_category IN ('laptop', 'smartphone')
ORDER BY excess_duration DESC;