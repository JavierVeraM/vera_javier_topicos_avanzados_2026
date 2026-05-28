--Actividad practica sesion 14

--Ejercicio 1

--Crea un supertipo Vehiculo con atributos Marca y Año,
--y un metodo obtener_antiguedad. Luego, crea
--un subtipo Automovil que herede el vehiculo, con un atributo adicional
--NumeroPuertas y un metodo descripcion que devuelva una cadena con los
--detalles del automovil.

--Vehiculo
CREATE OR REPLACE TYPE Vehiculo AS OBJECT(
    Marca VARCHAR2(50),
    Año NUMBER,
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY Vehiculo AS
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
    RETURN 2025 - Año;
    END;
END;
/
-- Automovil
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER,

);
/
CREATE OR REPLACE TYPE BODY Automovil AS 
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS 
    BEGIN
    RETURN 'Automóvil: ' || Marca || ', Año: ' || Año || ', Puertas: ' || NumeroPuertas;
    END;
END;
/

--Creacion de la tabla
CREATE TABLE Vehiculos OF Vehiculo;
INSERT INTO Vehiculos VALUES (Automovil('Suzuki', 2020, 4));
SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad, TREAT(VALUE(v) AS Automovil).descripcion() AS descripcion
FROM Vehiculos v 
WHERE VALUE(v) IS OF (Automovil);


--Ejercicio 2

--Crea un subtipo Camion que herede de Vehiculo, con un atributo adicional
--CapacidadCarga (en toneladas) y sobreescriba el metodo 
--obtener_antiguedad para sumar 2 años adicionales
--(los camiones envejecen más rapido). Inserta un camion en la tabla Vehiculos
--y consulta su antiguedad y descripcion

-- Camion
CREATE OR REPLACE TYPE Camion UNDER Vehiculo(
    CapacidadCarga NUMBER,
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY Camion AS 
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
    RETURN (2025 - Año) + 2; --(Años adicionales)
    END;
END;
/
--Insertar nuevos datos Camion en tabla Vehiculos y consltar sobre datos
INSERT INTO Vehiculos VALUES (Camion('Scania', 2014, 10));
SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad
FROM Vehiculos v 
WHERE VALUE(v) IS OF (Camion);