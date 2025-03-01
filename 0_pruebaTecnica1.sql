/*
    20/01/2025
    Ecribe una query que traiga los datos tal y como se presentan en la tabla.
*/
SELECT 
    e.nombre AS Empresa,  /* busco la columna empresa */
   CONCAT(c.nombre, '  ', c.apellido) AS Cliente, /* concateno los datos de las columnas nombre y apellido y los traigo como cliente */
    dl.tipo AS TipoDocumento, /* traigo la columna tipo de docuemnto legal como TipoDocumento */
    CONCAT('$ ', FORMAT(SUM(dl.total), 2, 'es_AR')) AS Total   /* sumo el total de cada cliente en docuemnto legal, cambio el formato a pesos argentinos y le concateno el signo pesos para que sea igual al mostrado en la tabla de referencia   */
    /* FORMAT -> solo se puede usar con MySQL */
    /* CONCAT -> no se usa en todos, algunos usan el signo + como SQL Server */
FROM 
    documento_legal dl /* tabla principal */
JOIN 
    empresa e ON dl.id_empresa = e.id_empresa /* inner join con tabla empresa */
JOIN 
    cliente c ON dl.id_cliente = c.id_cliente /* inner join con tabla cliente */
GROUP BY 
    e.nombre, c.id_cliente, c.nombre, dl.tipo /* agrupo los resultados segun nombre de empresa, id de cliente, nombre de cliente y tipo de documento legal */
    /* Acá no haría falta poner que lo agrupo por nombre porque ya puse el id del cliente, pero ponerlo no afectó el resultado */
ORDER BY 
    c.id_cliente; /* los ordeno por el id de documento legal */