-- Ejercicios Practica

--Ejercicio 1

DECLARE
    CURSOR pedido_cursor IS
    SELECT Pedidos.PedidoID, Pedidos.Total, Clientes.Nombre 
    FROM Pedidos
    JOIN Clientes ON Pedidos.ClienteID = Clientes.ClienteID
    WHERE Pedidos.Total > 500;
    v_pedido_id NUMBER;
    v_total NUMBER;
    v_nombre VARCHAR2(50);

BEGIN
    OPEN pedido_cursor;
    LOOP
    FETCH pedido_cursor INTO v_pedido_id, v_total, v_nombre;
    EXIT WHEN pedido_cursor%NOTFOUND
    DBMS_OUTPUT.PUT_LINE('Pedido '|| v_pedido_id || ' Total '|| v_total || ' Cliente '|| v_nombre);
    END LOOP;
    CLOSE pedido_cursor;
END;
/


------------------------


DECLARE
    -- Mismo Cursor
    CURSOR pedido_cursor IS
        SELECT p.PedidoID, p.Total, c.Nombre 
        FROM Pedidos p
        JOIN Clientes c ON p.ClienteID = c.ClienteID
        WHERE p.Total > 500;
        
    -- Una sola variable que contiene todas las columnas de la consulta
    v_reg pedido_cursor%ROWTYPE; 

BEGIN
    OPEN pedido_cursor;
    LOOP
        FETCH pedido_cursor INTO v_reg; -- Cargamos toda la fila en el registro
        EXIT WHEN pedido_cursor%NOTFOUND;
        
        -- Accedemos a los datos mediante el punto
        DBMS_OUTPUT.PUT_LINE('Pedido '|| v_reg.PedidoID || 
                             ' Total '|| v_reg.Total || 
                             ' Cliente '|| v_reg.Nombre);
    END LOOP;
    CLOSE pedido_cursor;
END;
/

--Ejercicio 2

DECLARE 
    CURSOR producto_cursor IS
    SELECT ProductoID, Precio FROM Productos
    WHERE Precio < 1000
    FOR UPDATE;
    v_productoid NUMBER;
    v_precio NUMBER;
BEGIN
    OPEN producto_cursor;
    LOOP
    FETCH producto_cursor INTO v_productoid, v_precio;
    EXIT WHEN 