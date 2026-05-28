--Actividad Practica sesion 18

--Ejercicio 1

--Crea un paquete gestion_clientes con:
--Un procedimiento registrar_cliente que reciba ClienteID, Nombre, Ciudad y FechaNacimiento, y valide que la fecha de nacimiento sea anterior a la fecha actual.
--Una función obtener_edad que reciba un ClienteID y devuelva la edad del cliente.
--Usa una variable global para contar los clientes registrados.

CREATE OR REPLACE PACKAGE gestion_clientes AS
    PROCEDURE registrar_cliente(p_cliente_id IN NUMBER, p_nombre IN VARCHAR2, p_ciudad IN VARCHAR2, p_fecha_nacimiento IN DATE);
    FUNCTION obtener_edad(p_cliente_id IN NUMBER) RETURN NUMBER;
    g_total_clientes NUMBER := 0; -- Variable global para contar clientes registrados
END gestion_clientes;
/
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

    PROCEDURE registrar_cliente(p_cliente_id IN NUMBER, p_nombre IN VARCHAR2, p_ciudad IN VARCHAR2, p_fecha_nacimiento IN DATE) IS
    BEGIN
        IF p_fecha_nacimiento >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
        END IF;
        
        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
        VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);
        
        g_total_clientes := g_total_clientes + 1; -- Incrementar el contador de clientes registrados
        DBMS_OUTPUT.PUT_LINE('Cliente registrado: ' || p_nombre || '. Total clientes: ' || g_total_clientes);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al registrar cliente: ' || SQLERRM);
    END registrar_cliente;

    FUNCTION obtener_edad(p_cliente_id IN NUMBER) RETURN NUMBER IS
        v_fecha_nacimiento DATE;
        v_edad NUMBER;
    BEGIN
        SELECT FechaNacimiento INTO v_fecha_nacimiento FROM Clientes WHERE ClienteID = p_cliente_id;
        
        IF v_fecha_nacimiento IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
        END IF;
        
        v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
        RETURN v_edad;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
    END obtener_edad;

END gestion_clientes;
/
--Para probar:
BEGIN
    gestion_clientes.registrar_cliente(1, 'Juan Perez', 'Madrid', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
    gestion_clientes.registrar_cliente(2, 'Maria Lopez', 'Barcelona', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
    
    DBMS_OUTPUT.PUT_LINE('Edad de Juan Perez: ' || gestion_clientes.obtener_edad(1));
    DBMS_OUTPUT.PUT_LINE('Edad de Maria Lopez: ' || gestion_clientes.obtener_edad(2));
END;
/

--Ejercicio 2
--Modifica el paquete gestion_clientes para incluir una excepción personalizada 
--e_edad_invalida que se lance si el cliente tiene menos de 18 años al registrarlo. 
--Prueba el paquete con un cliente menor de edad.

CREATE OR REPLACE PACKAGE gestion_clientes AS
    PROCEDURE registrar_cliente(p_cliente_id IN NUMBER, p_nombre IN VARCHAR2, p_ciudad IN VARCHAR2, p_fecha_nacimiento IN DATE);
    FUNCTION obtener_edad(p_cliente_id IN NUMBER) RETURN NUMBER;
    g_total_clientes NUMBER := 0; -- Variable global para contar clientes registrados
    e_edad_invalida EXCEPTION; -- Excepción personalizada para edad inválida
END gestion_clientes;
/
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

    PROCEDURE registrar_cliente(p_cliente_id IN NUMBER, p_nombre IN VARCHAR2, p_ciudad IN VARCHAR2, p_fecha_nacimiento IN DATE) IS
        v_edad NUMBER;
    BEGIN
        IF p_fecha_nacimiento >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
        END IF;
        
        v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, p_fecha_nacimiento) / 12);
        
        IF v_edad < 18 THEN
            RAISE e_edad_invalida; -- Lanzar excepción si el cliente es menor de edad
        END IF;
        
        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
        VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);
        
        g_total_clientes := g_total_clientes + 1; -- Incrementar el contador de clientes registrados
        DBMS_OUTPUT.PUT_LINE('Cliente registrado: ' || p_nombre || '. Total clientes: ' || g_total_clientes);
    EXCEPTION
        WHEN e_edad_invalida THEN
            DBMS_OUTPUT.PUT_LINE('Error: El cliente debe tener al menos 18 años para ser registrado.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al registrar cliente: ' || SQLERRM);
    END registrar_cliente;

    FUNCTION obtener_edad(p_cliente_id IN NUMBER) RETURN NUMBER IS
        v_fecha_nacimiento DATE;
        v_edad NUMBER;
    BEGIN
        SELECT FechaNacimiento INTO v_fecha_nacimiento FROM Clientes WHERE ClienteID = p_cliente_id;
        
        IF v_fecha_nacimiento IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
        END IF;
        
        v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
        RETURN v_edad;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
    END obtener_edad;

END gestion_clientes;
/
--Para probar:
BEGIN
    gestion_clientes.registrar_cliente(3, 'Carlos Sanchez', 'Valencia', TO_DATE('2008-03-10', 'YYYY-MM-DD')); -- Cliente menor de edad
END;
/

