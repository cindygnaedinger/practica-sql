/*
    LA CIUDAD MÁS LARGA Y MÁS CORTA EN CARACTERES
*/
(
    SELECT CITY AS city_name, LENGTH(CITY) AS city_length 
    FROM STATION 
    ORDER BY LENGTH(CITY) ASC, CITY ASC 
    LIMIT 1)
UNION ALL 
(
    SELECT CITY AS city_name, LENGTH(CITY) AS city_length
    FROM STATION
    ORDER BY LENGTH(CITY) DESC, CITY ASC
    LIMIT 1
);

/*
    CIUDADES QUE EMPIEZAN CON VOCALES
*/
SELECT DISTINCT CITY 
FROM STATION
WHERE LOWER(LEFT(CITY, 1)) IN ("a", "e", "i", "o", "u"); /* En otros sistemas (como PostgreSQL, SQL Server, Oracle):
- En lugar de LEFT, se puede usar SUBSTRING o SUBSTR.
- En lugar de LOWER, se puede usar LOWER o UPPER dependiendo del caso. 
*/

/*
    CON REGEXP
*/
SELECT DISTINC CITY
FROM STATION
WHERE CITY '^[aeiouAEIOU]'; /* 
- PostgreSQL: Usa ~ para expresiones regulares.
- SQL Server: No soporta expresiones regulares nativamente, pero puedes usar LIKE con patrones.
- Oracle: Usa REGEXP_LIKE. 
*/