--Actividad practica sesion 16
--Optimizacion y analisis de consultas

--Ejercicio 1
--Analiza el plan de ejecucion de la siguiente consulta
--y optimizala para que use indices y particiones.

--Consulta:
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
AND c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;

--Analisis y optimizacion:

-- Plan de ejecución
EXPLAIN PLAN FOR
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
AND c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Optimizacion
CREATE INDEX idx_clientes_ciudad ON Clientes(Ciudad);

-- Consulta optimizada
EXPLAIN PLAN FOR
SELECT /*+ INDEX(c idx_clientes_ciudad) INDEX(p idx_pedidos_clienteid) */
   	c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ejecutacion
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;

--Ejercicio 2
--Optimiza la siguiente consulta para evitar un FULL TABLE SCAN en DetallesPedidos
--y analiza el plan de ejecucion antes y despues de la optimizacion

--Consulta:

SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;

--Optimizacion y analisis:

-- Plan de ejecución
EXPLAIN PLAN FOR
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Optimizacion
-- (idx_detalles_productoid ya fue creado en el ejemplo práctico)
EXPLAIN PLAN FOR
SELECT /*+ INDEX(dp idx_detalles_productoid) */
   	p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ejecucion
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
