--Actividad practica sesion 15
--INDICES Y PARTICIONES

--Ejercicio 1
--Crear un indice compuesto en la tabla DetallesPedidos para las columnas
--PedidoID y ProductoID. Luego, escribe una consulta que use este índice
--y analiza su plan de ejecucion.

--Indice compuesto
CREATE INDEX idx_detalles_pedido_producto ON 
DetallesPedidos(PedidoID, ProductoID);

--Consulta que usa el indice
EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Ejecucion
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;

--Ejercicio 2
--Crear una tabla ventas particionada por hash usando la columna
--ClienteID (4 particiones). Inserta datos Pedidos y escribe una consulta
--que muestre el total de ventas por cliente, verificando
--que las particiones se usen.

--Crear tabla ventas con particion por hash
CREATE TABLE Ventas(
    VentaID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaVenta DATE,
)
PARTITION BY HASH (ClienteID)
PARTITIONS 4; --Cuantas particiones

--Datos desde pedidos
INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)
SELECT PedidoID, ClienteID, Total, FechaPedido FROM Pedidos;

--Que usa las particiones
EXPLAIN PLAN FOR
SELECT ClienteID, SUM(Total) AS TotalVentas
FROM Ventas
GROUP BY ClienteID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Ejecucion
SELECT ClienteID, SUM(Total) AS TotalVentas FROM Ventas
GROUP BY ClienteID;