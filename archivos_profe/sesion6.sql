-- sesion6.sql: Script para la Sesión 6

-- Detener la ejecución si ocurre un error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Cambiar al PDB XEPDB1
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear un nuevo usuario (esquema) para el curso en el PDB
CREATE USER curso_topicos IDENTIFIED BY curso2025;

-- Otorgar privilegios necesarios al usuario
GRANT CONNECT, RESOURCE, CREATE SESSION TO curso_topicos;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO curso_topicos;
GRANT UNLIMITED TABLESPACE TO curso_topicos;

-- Confirmar creación
SELECT username FROM dba_users WHERE username = 'CURSO_TOPICOS';

-- Cambiar al esquema curso_topicos
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- Habilitar salida de mensajes para PL/SQL
SET SERVEROUTPUT ON;

-- Crear tabla Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Clientes...');
    EXECUTE IMMEDIATE 'CREATE TABLE Clientes (
        ClienteID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Ciudad VARCHAR2(50),
        FechaNacimiento DATE
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Clientes creada.');
END;
/

-- Crear tabla Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Pedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Pedidos (
        PedidoID NUMBER PRIMARY KEY,
        ClienteID NUMBER,
        Total NUMBER,
        FechaPedido DATE,
        CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Pedidos creada.');
END;
/

-- Crear tabla Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Productos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Productos (
        ProductoID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Precio NUMBER
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Productos creada.');
END;
/

-- Insertar datos en Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Clientes...');
    INSERT INTO Clientes VALUES (1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (2, 'María Gomez', 'Valparaiso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (3, 'Ana Lopez', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Clientes.');
END;
/

-- Insertar datos en Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Pedidos...');
    INSERT INTO Pedidos VALUES (101, 1, 600, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (102, 1, 300, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Pedidos.');
END;
/

-- Insertar datos en Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Productos...');
    INSERT INTO Productos VALUES (1, 'Laptop', 1200);
    INSERT INTO Productos VALUES (2, 'Mouse', 25);
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Productos.');
END;
/

-- Confirmar los datos insertados antes de continuar
COMMIT;

-- Confirmar creación e inserción de datos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tablas creadas y datos insertados correctamente.');
END;
/

-- Verificar datos
SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM Productos;

-- Crear tabla DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla DetallesPedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE DetallesPedidos (
        DetalleID NUMBER PRIMARY KEY,
        PedidoID NUMBER,
        ProductoID NUMBER,
        Cantidad NUMBER,
        CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
        CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla DetallesPedidos creada.');
END;
/

-- Insertar datos en DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en DetallesPedidos...');
    INSERT INTO DetallesPedidos VALUES (1, 101, 1, 2); -- Pedido 101: 2 Laptops
    INSERT INTO DetallesPedidos VALUES (2, 101, 2, 5); -- Pedido 101: 5 Mouse
    DBMS_OUTPUT.PUT_LINE('Datos insertados en DetallesPedidos.');
END;
/

-- Verificar datos
SELECT * FROM DetallesPedidos;
-- Practica 6
-- Definición del Objeto (Clase)
CREATE OR REPLACE TYPE producto_obj AS OBJECT (
    producto_id NUMBER,
    nombre VARCHAR2(50),
    precio NUMBER,
    MEMBER FUNCTION aplicar_descuento(porcentaje NUMBER) RETURN NUMBER
);
/

-- Cuerpo del Objeto con lógica
CREATE OR REPLACE TYPE BODY producto_obj AS
    MEMBER FUNCTION aplicar_descuento(porcentaje NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN SELF.precio - (SELF.precio * (porcentaje / 100));
    END;
END;
/

-- Tabla de Objetos
CREATE TABLE productos_tabla_obj OF producto_obj (
    producto_id PRIMARY KEY
);

-- Inserción de datos
INSERT INTO productos_tabla_obj VALUES (1, 'Laptop Pro', 1500);
INSERT INTO productos_tabla_obj VALUES (2, 'Teclado Mecánico', 100);
INSERT INTO productos_tabla_obj VALUES (3, 'Monitor 4K', 400);

--Ejercicio1
SET SERVEROUTPUT ON;

DECLARE
    -- Cursor basado en la tabla de objetos, seleccionando 2 atributos y ordenando
    CURSOR c_productos_ordenados IS
        SELECT p.nombre, p.precio
        FROM productos_tabla_obj p
        ORDER BY p.precio DESC; -- Ordenado por precio

    v_nombre VARCHAR2(50);
    v_precio NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- LISTADO DE PRODUCTOS (ORDENADOS POR PRECIO) ---');
    
    OPEN c_productos_ordenados;
    LOOP
        FETCH c_productos_ordenados INTO v_nombre, v_precio;
        EXIT WHEN c_productos_ordenados%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre || ' | Precio: $' || v_precio);
    END LOOP;
    CLOSE c_productos_ordenados;
END;
/
--Ejercicio2
DECLARE
    -- Cursor con parámetro (umbral de precio) y bloqueo de filas
    CURSOR c_actualizar_precios(p_precio_min NUMBER) IS
        SELECT VALUE(p)
        FROM productos_tabla_obj p
        WHERE p.precio > p_precio_min
        FOR UPDATE;

    v_producto producto_obj;
    v_precio_original NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ACTUALIZACIÓN DE PRECIOS ---');
    
    -- Abrimos el cursor pasando 200 como parámetro
    OPEN c_actualizar_precios(200);
    LOOP
        FETCH c_actualizar_precios INTO v_producto;
        EXIT WHEN c_actualizar_precios%NOTFOUND;

        v_precio_original := v_producto.precio;
        
        -- Aumento del 10%
        UPDATE productos_tabla_obj p
        SET p.precio = v_precio_original * 1.10
        WHERE CURRENT OF c_actualizar_precios;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_producto.producto_id || 
                             ' | Original: ' || v_precio_original || 
                             ' | Nuevo: ' || (v_precio_original * 1.10));
    END LOOP;
    CLOSE c_actualizar_precios;
    COMMIT;
END;
/

-- Commit final
COMMIT;