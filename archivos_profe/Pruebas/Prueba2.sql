--Prueba 2 Topicos Avanzados de Datos
--Nombre: Javier Jesús Vera Montalván

--PARTE 1, Teorica

--Ejercicio 1
--Explica la diferencia entre un procedimiento almacenado 
--y una funcion almacenada en PL/SQL.
--Da un ejemplo de cuando usuaria cada uno en el contexto de la base de datos
--de la prueba.

--Respuesta:
--Un procedimiento almacenado es un bloque de codigo que realiza una tarea especifica y no devuleve un 
--valor, mientras que una funcion almacenada realiza una tarea especifica y devuelve un valor.

--En el contexto de la base de datos de la prueba, se usaria un procedimiento almacenado para 
--realizar una tarea como insertar un nuevo registro en una tabla, mientras que se usaria una 
--funcion almacenada para realizar algun calculo o consulta que devuelva un valor.

----------------------------------------------------------------------------------------------

--Ejercicio 2
--Describe como usarias un parametro IN OUT en un procedimiento almacenado.
--Escribe un ejemplo de un procedimiento que use un parametro IN OUT para actualizar
--y devolver las horas de una asignacion despues de un ajuste.

--Respuesta:
--En un procedimiento almacenado se podria utilizar un parametro IN OUT para que el procedimiento reciba un valor de entrada
--y luego lo actualice para devolverlo a la entidad que lo llame.

--Ejemplo:
CREATE OR REPLACE PROCEDURE actualizar_horas( --Se crea el procedimiento con los parametros IN OUT
    p_asignacion_id IN NUMBER, --Entra (IN) el id del dato a actualizar
    p_horas_ajustadas IN OUT NUMBER --Entra (IN) el valor a actualizar
) AS 
BEGIN
    --Se toma el valor actual de la hora antes de actualizar o modificar
    UPDATE Asignaciones
    SET horas = horas + p_horas_ajustadas --Se actualiza el valor de las horas
    WHERE AsignacionID = p_asignacion_id;

    --Despues de la actualizacion de las horas, se obtiene el nuevo valor
    --de las horas ajustadas.
    SELECT horas INTO p_horas_ajustadas --Se inserta el valor nuevo de las horas
    FROM Asignaciones
    WHERE AsignacionID = p_asignacion_id;
END;
/

----------------------------------------------------------------------------------------------

--Ejercicio 3
--¿Como se puede usar una funcion almacenada dentro de una consulta SQL?
--Escribe un ejemplo de una funcion que calcule el total de horas asignadas
--a un incidente y usala en una consulta para listar los incidentes
--con su total de horas.

--Respuesta:
--Una funcion almacenada se puede usar dentro de una consulta SQL llamando 
--a la funcion y enviandole los parametros que sean necesarios para que desarrolle su tarea
--y devuelva un resultado adecuado.

--Ejemplo
CREATE OR REPLACE FUNCTION calcular_horas_totales(p_incidente_id IN NUMBER)
RETURN NUMBER AS
    v_total_horas NUMBER; --Almacena calculo de horas totales
BEGIN
    SELECT SUM(horas) INTO v_total_horas --Se calcula el total de horas sumando las horas de las asignaciones
    FROM Asignaciones
    WHERE IncidenteID = p_incidente_id;

    RETURN v_total_horas; --Devuelve el total de horas calculado
END;
/
--Consulta para listar los incidentes con su total de horas
SELECT i.IncidenteID, i.Descripcion, calcular_horas_totales(i.IncidenteID) AS total_horas
FROM Incidentes i;  

----------------------------------------------------------------------------------------------

--Ejercicio 4 
--Explica que es un trigger y menciona dos tipos de eventos que puedan dispararlo
--Da un ejemplo de un trigger que se dispare despues de insertar una asignacion
--en la tabla Asignaciones y actualice el estado del incidente a "En Proceso"
--si estaba en "Abierto".

--Respuesta:
--Un trigger se ejecuta automaticamente durante ciertos eventos o instancias en la base de datos,
--como puede ser despues de insertar, actualizar o eliminar un dato de una tabla. Esto puede depender de
--alguna accion especifica o un cambio en los datos.

--Tipos de eventos que lo pueden disparar:
--1. AFTER INSERT: Se dispara despues de insertar un nuevo registro o dato en una tabla
--2. BEFORE UPDATE: Se dispara antes de actualizar un registro o dato.

--Ejemplo
CREATE OR REPLACE TRIGGER actualizar_estado --Se crea el trigger de manera similar a como se crea un procedimiento
AFTER INSERT ON Asignaciones --Se dispara despues de insertar una asignacion (Recordar que se disparan despues de insertar, actualizar o eliminar un dato)
FOR EACH ROW
BEGIN
    UPDATE Incidentes
    SET Estado = 'En Proceso' --Estado del incidente a "En Proceso"
    WHERE IncidenteID = :NEW.IncidenteID --Solo y solo SI el incidente estaba en "Abierto", ":NEW" se usa cuando se referencia a un nuevo valor que esta insertandodse o actualizandose
    AND Estado = 'Abierto';
END;
/

----------------------------------------------------------------------------------------------

--PARTE 2, Practica

--1. Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (Parametros IN).
--El procedimiento debe:
--Insertar una nueva asignacion de en la tabla Asignaciones(Usa el proximo AsignacionID disponible)
--Actualizar el estado del incidente a "En Proceso" si estaba en "Abierto"
--Manejar excepciones si el agente o incidente no existen, o si el agente ya esta asignado a ese incidente.

--Desarrollo

CREATE OR REPLACE PROCEDURE registrar_asignacion(
    p_agente_id IN NUMBER,
    p_incidente_id IN NUMBER,
    p_horas IN NUMBER,
    p_rol IN VARCHAR2(30),
    p_asignacion_id OUT NUMBER
)AS
BEGIN
    DECLARE
        v_agente_count NUMBER; --¿Existe el agente?(Punto 3)
        v_incidente_count NUMBER; --¿Existe el incidente?(Punto 2)
        v_asignacion_count NUMBER; --¿El agente ya esta asignado a ese incidente o no?(Punto 1)
    BEGIN
        --Verificar si el agente existe 
        SELECT COUNT(*) INTO v_agente_count
        FROM Agentes
        WHERE AgenteID = p_agente_id;
        IF v_agente_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El agente no existe.'); --Si el agente no existe, se lanza una excepcion
        END IF;
        --Verificar si el incidente existe
        SELECT COUNT(*) INTO v_incidente_count
        FROM Incidentes
        WHERE IncidenteID = p_incidente_id;
        IF v_incidente_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El incidente no existe.'); --Si el incidente no existe, se lanza una excepcion
        END IF;
        --El agente ya esta asignado a ese incidente?
        SELECT COUNT(*) INTO v_asignacion_count
        FROM Asignaciones
        WHERE AgenteID = p_agente_id AND IncidenteID = p_incidente_id;
        IF v_asignacion_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'El agente ya esta asignado.'); --Se lanza una excepcion
        END IF;
        --Insertar nueva asignacion
        SELECT NVL(MAX(AsignacionID),0) + 1 INTO p_asignacion_id FROM Asignaciones; --Se obtiene el proximo AsignacionID disponible, por eso "+ 1"; se mueve una posicion
        INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
        VALUES (p_asignacion_id, p_agente_id, p_incidente_id, p_horas, p_rol);
        --Actualizar estado de incidente "En Proceso" --> si estaba "Abierto" (Similar a mostrado en el ejercicio 4 de la Parte 1 de Teoria)
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = p_incidente_id AND Estado = 'Abierto'; --p_incidente_id es el incidente que se esta asignando
    END;
EXCEPTION
    WHEN OTHERS THEN
        RAISE; --Dejar lista la excepcion para cuando se llame al procedimiento.
END;
/

----------------------------------------------------------------------------------------------

--2. Escribe una funcion calcular_horas_agente que reciba un AgenteID (Parametro IN)
--y devuelva el total de horas asignadas a ese agente en toos los incidentes.
--Luego, usa la funcion en un procedimiento mostrar_carga_agentes que muestre
--el total de horas por agente para todos los agentes, indicando su nombre y especialidad

--Desarrollo

CREATE OR REPLACE FUNCTION calcular_horas_agente(p_agente_id IN NUMBER)
RETURN NUMBER AS
    v_total_horas NUMBER; --Almacena el total de horas asignafas a un agente
BEGIN
    SELECT SUM(horas) INTO v_total_horas --Se calcula el total de horas del agente
    FROM Asignaciones
    WHERE AgenteID = p_agente_id;
    RETURN NVL(v_total_horas, 0); --Devuelve el total de horas, si no tiene asignaciones devuelve 0, "NVL" significa "Null Value Logic", se usa para manejar valores nulos, en vez de NULL, es 0
END;
/
CREATE OR REPLACE PROCEDURE mostrar_carga_agentes AS
BEGIN
    FOR rec IN (SELECT AgenteID, Nombre, Especialidad FROM Agentes) LOOP --Se recorre cada agente en un loop o ciclo, rec se usa para guardar temporalmente y mostrar los datos solo cuando sean pedidos
        DBMS_OUTPUT.PUT_LINE('Agente: ' || rec.Nombre || ' - Especialidad: ' || rec.Especialidad || ' - Total Horas: ' || calcular_horas_agente(rec.AgenteID)); --Se muestra el nombre, especialidad y total de horas usando la funcion "calcular_horas_agente" que se hizo antes
    END LOOP; --Termina el loop o ciclo
END;

----------------------------------------------------------------------------------------------

--3. Implementa un sistema de auditoria usando un tigger.
--Para esto, primero crea una tabla llamada AuditoriaAsignaciones con las columnas necesarias
--Luego, crea un trigger auditar_asignaciones que se dispare despues de insertar
--o eliminar una asignacion en la tabla Asignaciones. El trigger debe registrar en la tabla
--de auditoria el AsignacionID, AgenteID, IncidenteID, Horas, la accion realizada
--("INSERT" O "DELETE") y la fecha del registro

--Desarrollo: 

CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER PRIMARY KEY, --LLave primaria 
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(30),
    FechaRegistro DATE --Para formatos (YYYY-MM-DD))
);

CREATE OR REPLACE TRIGGER auditar_asignaciones --Siempre usar replace, evitara dobles triggers con nombre iguales
AFTER INSERT OR DELETE ON Asignaciones --Se le indica cuando se debe de "disparar", similar al ejercicio 4
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
    VALUES (
        (SELECT NVL(MAX(AuditoriaID), 0) + 1 FROM AuditoriaAsignaciones), --Se obtiene el proximo AuditoriaID disponible, "+ 1" para moverse 1 posicion
        :OLD.AsignacionID, --Se referencia al valor antiguo de AsignacionID, se usa ":OLD" para referenciar a un valor que esta siendo eliminado o actualizado
        :OLD.AgenteID, --Valor antiguo de AgenteID
        :OLD.IncidenteID, --Valor antiguo de IncidenteID
        :OLD.Horas, --Valor antiguo de Horas
        CASE 
            WHEN INSERTING THEN 'INSERT' --Si se esta insertando una nueva asignacion, se registra la accion como "INSERT"
            WHEN DELETING THEN 'DELETE' --Si se esta eliminando una asignacion, se registra la accion como "DELETE"
        END,
        SYSDATE --Fecha actual del sistema
    );
END;
/
--Uso de ":NEW" y ":OLD" se encunetra en las sesiones 12 y 13**

-- Commit para asegurar los cambios realizados y evitar errores o situaciones raras
COMMIT;
