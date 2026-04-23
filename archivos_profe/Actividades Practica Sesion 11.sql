--Actividades Practica Sesion 11

--Ejercicio 1
--Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) 
--y devuelva la edad del cliente en años (basado en FechaNacimiento). 
--Maneja excepciones si el cliente no existe.

CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliende_id IN NUMBER) RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento FROM  Clientes
    WHERE ClienteID = p_cliende_id;
    v_edad := FLOOR(MONTHS_BETWEEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID '||p_cliende_id|| ' no encontrado.');
END;
/

--Para probar
DECLARE
    v_edad NUMBER;
BEGIN
    v_edad := calcular_edad_cliente(1);
    DBMS_OUTPUT.PUT_LINE('Edad del cliente 1: '||v_edad);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
END;
/


--Ejercicio 2
--Crea una función obtener_precio_promedio que devuelva el precio promedio 
--de todos los productos. Úsala en una consulta SQL para listar los productos 
--cuyo precio está por encima del promedio.

CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
    v_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_promedio FROM Productos
    RETURN v_promedio;
END;
/

--Consultar SQL
SELECT Nombre, Precio FROM Productos
WHERE Precio > obtener_precio_promedio();
