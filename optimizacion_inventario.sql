-- Escribe una consulta SQL que muestre:

-- Nombre del producto, categoría y margen de ganancia por unidad (precio - costo).

-- Total de unidades vendidas en los últimos 3 meses (usar fecha actual simulada como 2023-10-31).

-- Stock total actual (suma de stock_actual en todos los almacenes).

-- Días de stock restante (asumiendo que la demanda futura será igual a la demanda promedio mensual de los últimos 3 meses).

-- Solo productos con menos de 100 unidades vendidas en el período.

-- Ordenar por días de stock restante (ascendente) para priorizar productos con exceso de inventario.

WITH 