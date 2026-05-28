--Sesion 10 ejercicio 1

--Crea un procedimiento actualizar_total_pedidos que reciba un ClienteID 
--(parámetro IN) y un porcentaje de aumento (parámetro IN con valor por defecto 10%). 
--Aumenta el total de todos los pedidos del cliente en el porcentaje especificado. Usa un bucle para iterar sobre los pedidos.

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_aumento IN NUMBER DEFAULT 10) IS
BEGIN
    FOR pedido IN (SELECT PedidoID, Total FROM Pedidos WHERE ClienteID = p_cliente_id) LOOP
        UPDATE Pedidos
        SET Total = Total + (Total * p_aumento / 100)
        WHERE PedidoID = pedido.PedidoID;
    END LOOP;
END;
/

--Sesion 10 ejercicio 2
--Crea un procedimiento calcular_costo_detalle que reciba un DetalleID (parámetro IN) 
--y devuelva el costo total del detalle (parámetro IN OUT). 
--El costo se calcula como Precio * Cantidad (usando las tablas DetallesPedidos y Productos). Maneja excepciones si el detalle no existe.

CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo OUT NUMBER) IS
BEGIN
    SELECT Precio * Cantidad
    INTO p_costo
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_costo := 0;
END;
/

--Respuestas profesor:

--Ejercicio 1
CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
	CURSOR pedido_cursor IS
    	SELECT PedidoID, Total
    	FROM Pedidos
    	WHERE ClienteID = p_cliente_id
    	FOR UPDATE;
BEGIN
	FOR pedido IN pedido_cursor LOOP
    	UPDATE Pedidos
    	SET Total = pedido.Total * (1 + p_porcentaje / 100)
    	WHERE CURRENT OF pedido_cursor;
    	DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
	END LOOP;
	IF SQL%ROWCOUNT = 0 THEN
    	DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
	ELSE
    	COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/
-- Prueba
EXEC actualizar_total_pedidos(1);

--Ejercicio 2

CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo IN OUT NUMBER) AS
	v_precio NUMBER;
	v_cantidad NUMBER;
BEGIN
	SELECT p.Precio, d.Cantidad INTO v_precio, v_cantidad
	FROM DetallesPedidos d
	JOIN Productos p ON d.ProductoID = p.ProductoID
	WHERE d.DetalleID = p_detalle_id;
	p_costo := v_precio * v_cantidad;
	DBMS_OUTPUT.PUT_LINE('Costo del detalle ' || p_detalle_id || ': ' || p_costo);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20003, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');
END;
/
-- Prueba
DECLARE
	v_costo NUMBER := 0;
BEGIN
	calcular_costo_detalle(1, v_costo);
	DBMS_OUTPUT.PUT_LINE('Costo calculado: ' || v_costo);
END;
/


--Sesion 11 Ejercicio de funciones almacenadas

--Ejercicio 1
--Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) 
--y devuelva la edad del cliente en años (basado en FechaNacimiento). Maneja excepciones si el cliente no existe.

CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER IS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento FROM Clientes WHERE ClienteID = p_cliente_id;
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1; -- Indica que el cliente no existe
END;
/
-- Prueba
DECLARE
    v_edad NUMBER;
BEGIN
    v_edad := calcular_edad_cliente(1);
    IF v_edad = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Cliente no encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Edad del cliente: ' || v_edad || ' años.');
    END IF;
END;
/

--Ejercicio 2
--Crea una función obtener_precio_promedio que devuelva el precio promedio de todos los productos. 
--Úsala en una consulta SQL para listar los productos cuyo precio está por encima del promedio.

CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER IS
    v_precio_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_precio_promedio FROM Productos;
    RETURN v_precio_promedio;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Prueba
SELECT * FROM Productos WHERE Precio > obtener_precio_promedio();

--Respuestas profesor:
--Ejercicio 1
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
	v_fecha_nacimiento DATE;
	v_edad NUMBER;
BEGIN
	SELECT FechaNacimiento INTO v_fecha_nacimiento
	FROM Clientes
	WHERE ClienteID = p_cliente_id;
	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
	RETURN v_edad;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
END;
/
-- Prueba
DECLARE
	v_edad NUMBER;
BEGIN
	v_edad := calcular_edad_cliente(1);
	DBMS_OUTPUT.PUT_LINE('Edad del cliente 1: ' || v_edad);
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
--Ejercicio 2
CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(Precio) INTO v_promedio
	FROM Productos;
	RETURN v_promedio;
END;
/
-- Consulta SQL
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();


--Sesion 12 Ejercicio de Procedimientos, funciones y triggers

--Ejercicio 1

--Crea una función calcular_total_con_descuento que reciba un PedidoID (parámetro IN) y 
--devuelva el total del pedido con un descuento del 10% si el total supera 1000. 
--Usa la función en un procedimiento aplicar_descuento_pedido que actualice el total del pedido.

CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT Total INTO v_total FROM Pedidos WHERE PedidoID = p_pedido_id;
    IF v_total > 1000 THEN
        RETURN v_total * 0.9; -- Aplica un descuento del 10%
    ELSE
        RETURN v_total; -- No aplica descuento
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1; -- Indica que el pedido no existe
END;
/
CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedido_id IN NUMBER) IS
    v_total_con_descuento NUMBER;
BEGIN
    v_total_con_descuento := calcular_total_con_descuento(p_pedido_id);
    IF v_total_con_descuento = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Pedido no encontrado.');
    ELSE
        UPDATE Pedidos
        SET Total = v_total_con_descuento
        WHERE PedidoID = p_pedido_id;
        DBMS_OUTPUT.PUT_LINE('Total del pedido ' || p_pedido_id || ' actualizado a: ' || v_total_con_descuento);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- Prueba
EXEC aplicar_descuento_pedido(1);

--Ejercicio 2
--Crea un trigger validar_cantidad_detalle que se dispare antes de insertar o actualizar en 
--DetallesPedidos y verifique que la Cantidad sea mayor a 0. Si no, lanza un error.

CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La cantidad debe ser mayor a 0.');
    END IF;
END;
/
-- Prueba
BEGIN
    INSERT INTO DetallesPedidos (PedidoID, ProductoID, Cantidad)
    VALUES (1, 1, -5);  -- Esto debería lanzar un error
    INSERT INTO DetallesPedidos (PedidoID, ProductoID, Cantidad)
    VALUES (1, 1, 2);  -- Esto no debería lanzar un error
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;        

--Respuestas profesor:
--Ejercicio 1
-- Función
CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) RETURN NUMBER AS
	v_total NUMBER;
BEGIN
	SELECT Total INTO v_total
	FROM Pedidos
	WHERE PedidoID = p_pedido_id;
	IF v_total > 1000 THEN
    	v_total := v_total * 0.9; -- 10% de descuento
	END IF;
	RETURN v_total;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' || p_pedido_id || ' no encontrado.');
END;
/
-- Procedimiento
CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedido_id IN NUMBER) AS
	v_nuevo_total NUMBER;
BEGIN
	v_nuevo_total := calcular_total_con_descuento(p_pedido_id);
	UPDATE Pedidos
	SET Total = v_nuevo_total
	WHERE PedidoID = p_pedido_id;
	DBMS_OUTPUT.PUT_LINE('Total del pedido ' || p_pedido_id || ' actualizado a: ' || v_nuevo_total);
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/
-- Prueba
EXEC aplicar_descuento_pedido(101);

--Ejercicio 2
CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
	IF :NEW.Cantidad <= 0 THEN
    	RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0.');
	END IF;
END;
/
-- Prueba
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (3, 105, 2, -1);
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (3, 105, 2, 3);


--Sesion 13 Ejercicios de transacciones y diseño de data warehouse

--Ejercicio 1
--Crea un procedimiento actualizar_inventario_pedido que reciba un PedidoID 
--(parámetro IN) y reduzca la cantidad de productos en una tabla Inventario (crea la tabla si no existe) 
--según los detalles del pedido. Usa savepoints para manejar errores si no hay suficiente inventario.

CREATE TABLE Inventario (
    ProductoID NUMBER PRIMARY KEY,
    CantidadDisponible NUMBER
);      
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) IS
    v_producto_id NUMBER;
    v_cantidad NUMBER;
BEGIN
    FOR detalle IN (SELECT ProductoID, Cantidad FROM DetallesPedidos WHERE PedidoID = p_pedido_id) LOOP
        v_producto_id := detalle.ProductoID;
        v_cantidad := detalle.Cantidad;
        
        SAVEPOINT sp_inventario;
        
        UPDATE Inventario
        SET CantidadDisponible = CantidadDisponible - v_cantidad
        WHERE ProductoID = v_producto_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            ROLLBACK TO sp_inventario;
            DBMS_OUTPUT.PUT_LINE('Error: Producto ' || v_producto_id || ' no encontrado en inventario.');
        ELSIF (SELECT CantidadDisponible FROM Inventario WHERE ProductoID = v_producto_id) < 0 THEN
            ROLLBACK TO sp_inventario;
            DBMS_OUTPUT.PUT_LINE('Error: No hay suficiente inventario para el producto ' || v_producto_id || '.');
        END IF;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/
-- Prueba
EXEC actualizar_inventario_pedido(101);

--Ejercicio 2
--Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse basado en curso_topicos. 
--Escribe una consulta analítica que muestre el total de ventas por ciudad y año.

CREATE TABLE Dim_Ciudad (
    CiudadID NUMBER PRIMARY KEY,
    NombreCiudad VARCHAR2(100)
);
CREATE TABLE Fact_Pedidos (
    PedidoID NUMBER PRIMARY KEY,
    CiudadID NUMBER,
    Año NUMBER,
    TotalVentas NUMBER,
    FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID)
);
-- Consulta analítica
SELECT c.NombreCiudad, f.Año, SUM(f.TotalVentas) AS TotalVentas
FROM Fact_Pedidos f
JOIN Dim_Ciudad c ON f.CiudadID = c.CiudadID
GROUP BY c.NombreCiudad, f.Año
ORDER BY TotalVentas DESC;

-- Respuestas profesor:
--Ejercicio 1
-- Crear tabla Inventario
CREATE TABLE Inventario (
	ProductoID NUMBER PRIMARY KEY,
	Cantidad NUMBER
);
INSERT INTO Inventario VALUES (1, 10);
INSERT INTO Inventario VALUES (2, 20);

-- Procedimiento
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) AS
	CURSOR detalle_cursor IS
    	SELECT ProductoID, Cantidad
    	FROM DetallesPedidos
    	WHERE PedidoID = p_pedido_id;
	v_cantidad_actual NUMBER;
BEGIN
	FOR detalle IN detalle_cursor LOOP
    	-- Verificar cantidad disponible
    	SELECT Cantidad INTO v_cantidad_actual
    	FROM Inventario
    	WHERE ProductoID = detalle.ProductoID;
   	 
    	SAVEPOINT antes_reducir;
   	 
    	IF v_cantidad_actual < detalle.Cantidad THEN
        	RAISE_APPLICATION_ERROR(-20001, 'No hay suficiente inventario para el producto ' || detalle.ProductoID);
    	END IF;
   	 
    	UPDATE Inventario
    	SET Cantidad = Cantidad - detalle.Cantidad
    	WHERE ProductoID = detalle.ProductoID;
   	 
    	DBMS_OUTPUT.PUT_LINE('Inventario actualizado para producto ' || detalle.ProductoID);
	END LOOP;
	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado en inventario.');
    	ROLLBACK;
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK TO antes_reducir;
    	COMMIT;
END;
/
-- Prueba
EXEC actualizar_inventario_pedido(108);

--Ejercicio 2
-- Dimensión Ciudad
CREATE TABLE Dim_Ciudad (
	CiudadID NUMBER PRIMARY KEY,
	Ciudad VARCHAR2(50)
);
INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad
FROM (SELECT DISTINCT Ciudad FROM Clientes);

-- Tabla de hechos (usando las dimensiones ya creadas)
CREATE TABLE Fact_Pedidos (
	PedidoID NUMBER,
	ClienteID NUMBER,
	CiudadID NUMBER,
	FechaID NUMBER,
	Total NUMBER,
	CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
	CONSTRAINT fk_pedido_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
	CONSTRAINT fk_pedido_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad
JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

-- Consulta analítica
SELECT dc.Ciudad, dt.Año, SUM(fp.Total) AS TotalVentas
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.Ciudad, dt.Año;

--Sesión 10: Procedimientos Almacenados Avanzados

--Esta sesión profundiza en la estructura y el control de flujo dentro de los procedimientos en PL/SQL:
--Concepto básico:** Un procedimiento es un bloque de código con nombre almacenado en la base de datos. Puede recibir parámetros de tipo `IN`, `OUT` e `IN OUT`, y procesar excepciones.
--Lógica Condicional y Bucles:** Se detalla el uso de condiciones (`IF`, `ELSIF`, `ELSE`) y bucles (`LOOP`, `WHILE`, `FOR`) para realizar iteraciones sobre colecciones o cursores.
--Parámetros Avanzados:** * `IN OUT`: Funciona simultáneamente como variable de entrada y de salida, permitiendo modificar el valor original enviado al procedimiento.
--Valores por Defecto:** Se pueden definir valores predeterminados para los parámetros (`DEFAULT`), de modo que si no se especifican al invocar el procedimiento, toma el valor configurado.
--Cursores para Modificación:** Introducción al uso de cursores con la cláusula `FOR UPDATE`, que permite bloquear registros temporalmente para asegurar la consistencia durante actualizaciones concurrentes.

--Sesión 11: Funciones Almacenadas

--Se enfoca en la creación, ventajas y aplicación de las funciones dentro de la base de datos:
--Definición:** Bloque PL/SQL que, a diferencia de un procedimiento, está diseñado específicamente para **retornar un único valor** utilizando la instrucción `RETURN`.
--Diferencia Clave con Procedimientos:** * *Funciones:* Devuelven un valor y se pueden invocar directamente dentro de expresiones o consultas SQL (como en un `SELECT` o `WHERE`).
--Procedimientos:* No devuelven un valor directamente; se usan para ejecutar acciones o transacciones complejas en la base de datos.
--Integración en Consultas:** Permiten encapsular fórmulas u operaciones comunes (ej. `calcular_costo_detalle` o `calcular_descuento`) y llamarlas dentro de instrucciones normales de SQL estándar (por ejemplo: `SELECT cliente, total_pedidos(id) FROM clientes`).

--Sesión 12: Combinación de Objetos e Introducción a Triggers

--Muestra cómo integrar los componentes anteriores y presenta las bases de los disparadores automáticos:
--Combinación de Objetos:** Se ejemplifica cómo un procedimiento de actualización puede mandar a llamar internamente a una función para procesar cálculos complejos antes de impactar los datos.
--Triggers (Disparadores):** Bloques PL/SQL asociados a una tabla que se ejecutan automáticamente cuando ocurre un evento específico de manipulación de datos (DML: `INSERT`, `UPDATE`, `DELETE`).
--Clasificación de Triggers:**
--Por momento:* `BEFORE` (antes del evento) o `AFTER` (después del evento).
--Por nivel:* `ROW` (se ejecuta por cada fila afectada) o `STATEMENT` (se ejecuta una única vez por comando ejecutado).
--Variables de Contexto:** En los triggers de tipo fila (`FOR EACH ROW`), se dispone de los modificadores `:NEW` (para leer el nuevo valor que se intentará registrar) y `:OLD` (para consultar el valor anterior al cambio).

--Sesión 13: Control de Transacciones y Data Warehouse

--Aborda cómo garantizar la persistencia e integridad de datos operacionales, además de introducir arquitecturas analíticas:
--Control de Transacciones (Propiedades ACID):** Aseguran que un bloque de cambios DML opere bajo los principios de *Atomicidad*, *Consistencia*, *Aislamiento* y *Durabilidad*.
--Comandos de Transacción:**
--`COMMIT`: Guarda de manera definitiva y permanente los cambios en la base de datos.
--`ROLLBACK`: Deshace y revierte todas las modificaciones de la transacción actual si ocurre un error.
--`SAVEPOINT`: Crea marcas o puntos de control intermedios para poder hacer un rollback parcial (`ROLLBACK TO savepoint_name`) sin perder todo el progreso de la transacción completa.

--Data Warehouse (DW):** Bases de datos históricas optimizadas exclusivamente para consultas complejas, reportes y análisis (sistemas OLAP), a diferencia de las bases operacionales rutinarias (sistemas OLTP).
--Modelo Estrella (Star Schema):** Diseño común de un DW que consta de:
--Tablas de Hechos (Fact Tables):* Contienen métricas cuantitativas o numéricas (ej. totales, cantidades).
--Tablas de Dimensiones:* Contienen los datos descriptivos del contexto (ej. datos del cliente, producto o tiempo).
--Proceso ETL:** Siglas de *Extract* (Extraer de las fuentes), *Transform* (Limpiar y formatear) y *Load* (Cargar los datos limpios en el Data Warehouse).