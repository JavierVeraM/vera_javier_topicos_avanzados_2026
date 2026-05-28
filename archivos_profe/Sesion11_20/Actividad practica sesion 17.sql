--Actividad sesion 17

--Implementacion de Seguridad con roles y permisos

--Ejercicio 1

--Crea un usuario user_analista y un rol rol_analista. 
--El rol debe tener permisos para consultar (SELECT) todas las tablas de curso_topicos 
--y para insertar (INSERT) en la tabla Pedidos. Asigna el rol al usuario y prueba los permisos.

-- Crear usuario
CREATE USER user_analista IDENTIFIED BY password123;
-- Crear rol
CREATE ROLE rol_analista;
-- Asignar permisos al rol
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT INSERT ON Pedidos TO rol_analista;
-- Asignar rol al usuario
GRANT rol_analista TO user_analista;
-- Probar permisos
-- Iniciar sesión como user_analista
-- Probar SELECT
SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM DetallesPedidos;
SELECT * FROM Productos;
-- Probar INSERT
INSERT INTO Pedidos (PedidoID, ClienteID, FechaPedido) VALUES (1001, 1, TO_DATE('2025-03-15', 'YYYY-MM-DD'));


--Ejercicio 2

--Configura auditoría para monitorear las acciones de user_analista al consultar la tabla 
--Clientes y al insertar en la tabla Pedidos. Realiza algunas acciones y verifica los registros de auditoría.

-- Configurar auditoría
AUDIT SELECT ON Clientes BY user_analista;
AUDIT INSERT ON Pedidos BY user_analista;
-- Realizar acciones
SELECT * FROM Clientes;
INSERT INTO Pedidos (PedidoID, ClienteID, FechaPedido) VALUES (1002, 2, TO_DATE('2025-03-16', 'YYYY-MM-DD'));
-- Verificar registros de auditoría
SELECT * FROM DBA_AUDIT_TRAIL
WHERE USERNAME = 'USER_ANALISTA'
AND (ACTION_NAME = 'SELECT' OR ACTION_NAME = 'INSERT')
ORDER BY TIMESTAMP DESC;
