/* 
Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).
Return the result table in any order. 
*/
CREATE DATABASE practicaLeet;

USE practicaLeet;

CREATE TABLE weather(
    id INT PRIMARY KEY AUTO_INCREMENT,
    recordDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    temperature INT NOT NULL DEFAULT 0
);

INSERT INTO weather(recordDate, temperature) VALUES("2015-01-01", 10);
INSERT INTO weather(recordDate, temperature) VALUES("2015-01-02", 25);
INSERT INTO weather(recordDate, temperature) VALUES("2015-01-03", 20);
INSERT INTO weather(recordDate, temperature) VALUES("2015-01-04", 30);

SELECT * FROM weather;

SELECT id AS ID
FROM
    (
        SELECT id,
        temperature,
        LAG(temperature) OVER(ORDER BY recordDate) AS previous_temperature FROM weather
    )
AS comparison_table
WHERE temperature > previous_temperature;
/* hago una subquery para buscar las temperaturas del día anterior
uso la función LAG para obtener las temperaturas ordenadas por recordData
LAG es una función ventana que permite acceder al valor de una columna en una fila dentro de una misma partición de un conjunto de resultados, osea podes "mirar atrás" en los datos
- LAG(column_name, offset, default_value) OVER (PARTITION BY partition_column ORDER BY order_column)
*/