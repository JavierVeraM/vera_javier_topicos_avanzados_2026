--Prueba 3 Topicos avanzados de datos

--Nombre: Javier Vera

--Parte 1; Teorica

--1. Explica que es una transaccion en una base de datos y describe las propiedades ACID.
--Luego, muestra a traves de un ejemplo como usarias multiples savepoints para manejar
--errores parciales en un procedimiento que asigna a un agente a un incidente y actualiza
--simultaneamente el estado del incidente.
--¿Que ocurre si falla solo la actualizacion del estado?

--Respuesta: 
--Una transaccion es una secuencia de operaciones que se ejecutan como una unidad indivisible
--de trabajo, garantizando la consistencia de los datos. Las propiedades ACID son:
--Consistencia: La transaccion lleva la base de datos de un estado valido a otro estado valido.
--Aislamiento: Las transacciones concurrentes no interfieren entre si.
--Durabilidad: Una vez que la transaccion se confirma, sus cambios son permanentes.
--Atomicidad: La transaccion se ejecuta completamente o no.

--Si falla la actualizacion del estado, se revertira la transaccion.
--Ejemplo:

CREATE PROCEDURE asignar_agente_incidente (
    @id_incidente INT,
    @id_agente INT
)
AS
BEGIN
    -- Iniciar la transacción
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Crear un Savepoint antes de la primera operación
        SAVE TRANSACTION SP1;

        -- 1. Asignar el incidente al agente (Operación A)
        UPDATE Incidentes
        SET IdAgente = id_agente
        WHERE IdIncidente = id_incidente;

        -- 2. Actualizar el estado del incidente (Operación B)
        UPDATE Incidentes
        SET Estado = 'Asignado'
        WHERE IdIncidente = id_incidente;

        -- Si ambas operaciones fueron exitosas, confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Incidente asignado exitosamente.';
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertir la transacción
        ROLLBACK TRANSACTION;
        PRINT 'Error: La asignación falló. Se revertirán todos los cambios.';

        -- Opcional: Re-lanzar el error para notificar al llamador
        THROW;
    END CATCH
END;
/

--2. ¿Que es una data warehouse y como se diferencia de una base de datos transaccional?
--Describe como diseñarias un modelo dimensional(tabla de hechos y al menos dos dimensiones)
--para analizar las horas trabajadas por agente y por severidad de incidente.
--¿Que ventajas tiene este modelo para consultas analiticas versus consultar directamente las tablas transaccionales?

--Respuesta:

--Una data warehouse es una base de datos relacional optimizada para consultas analiticas,
--su principal diferencia con una base de datos transaccional es que esta optimizada para 
--consultas analiticas y no para transacciones. 

--Para diseñar un modelo dimensional primero se tiene que crear las tablas correspondiantes:

CREATE TABLE Hechos_Tiempo_Trabajado (
    IdHecho INT PRIMARY KEY,
    IdAgente INT,
    IdSeveridad INT,
    Horas INT,
    Fecha DATE
);

CREATE TABLE Dim_Agente (
    IdAgente INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Cargo VARCHAR(50)
);

CREATE TABLE Dim_Severidad (
    IdSeveridad INT PRIMARY KEY,
    Severidad VARCHAR(50)
);

--Las ventajas que tiene este modelo sobre las tablas transaccionales 
--es que permite realizar consultas analiticas de manera mas rapida y eficiente,
--ademas de que permite realizar consultas mas complejas, otra ventaja es que es 
--más facil de mantener y entender.

--Las consultas serian para descubrir las horas trabajadas por agente usando sus id´s
--para identificarlos es: 

SELECT 
    d.Nombre,
    d.Cargo,
    s.Severidad,
    SUM(f.Horas) AS TotalHoras
FROM 
    Hechos_Tiempo_Trabajado f
JOIN 
    Dim_Agente d ON f.IdAgente = d.IdAgente
JOIN 
    Dim_Severidad s ON f.IdSeveridad = s.IdSeveridad
GROUP BY 
    d.Nombre,
    d.Cargo,
    s.Severidad
ORDER BY 
    TotalHoras DESC;

--3. Explica como se implementa la herencia en Oracle usando tipos de objetos. 
--Da un ejemplo de una jerarquia de dos niveles: Agente --> AgenteEspecialista --> AgentePentester,
--donde cada nivel agrega atributos y sobreescribe un metodo calcular_costo().
--¿Que implicancias tiene declarar un tipo como "NOT INSTANTIABLE"? (No instanciable).

--Respuesta:
--Para implementar esta herencia usando jerarquia, lo primero que se realiza es crear la "tabla" padre:

CREATE TYPE agente_obj AS OBJECT (
    IdAgente INT,
    Nombre VARCHAR(50),
    Cargo VARCHAR(50)
) NOT INSTANTIABLE; --> Al declararlo como NOT INSTANTIABLE, implica que este tipo no puede ser usado 
--en otras tablas o funciones, ademas de que no se le puede realizar cambios.
/
--Luego se crea el subtipo agente especialista:
CREATE TYPE agente_especialista_obj AS OBJECT (
    Nombre VARCHAR(50),
    Cargo VARCHAR(50),
    Area VARCHAR(50) --Atributo Nuevo
);
/
--Luego se crea el subtipo agente pentester:
CREATE TYPE agente_pentester_obj AS OBJECT (
    Nombre VARCHAR(50),
    Cargo VARCHAR(50),
    Area VARCHAR(50),
    Certificaciones VARCHAR(50) --Atributo Nuevo
);
CREATE TYPE agente_pentester_obj UNDER agente_especialista_obj (
    OVERRIDING MEMBER FUNCTION calcular_costo() RETURN NUMBER
);
/

--Despues de haber creado las "tablas" tipo y que se sobreescribiera el metodo calcular_costo(),
-- se crea una "tabla" para cada subtipo:
--Primero la tabla padre:
CREATE TABLE Agentes OF agente_obj;
/ 
--Luego la tabla agente especialista:
CREATE TABLE Agentes_Especialistas OF agente_especialista_obj;
/ 
--Finalmente la tabla agente pentester:
CREATE TABLE Agentes_Pentester OF agente_pentester_obj;
/   

--4. Describe las ventajas y desventajas de usar indices y particiones en una
--base de datos. ¿Como usarias un indice compuesto y una particion por rango para
--mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad
--y FechaDeteccion? Explica que es el particion pruning y como impacta en el plan de
--ejecucion.

--Respuesta:

--INDICES V/S PARTICIONES EN UNA BASE DE DATOS

--INDICES
--Ventajas de usar indices: Los indices se encargan de ser una guia para poder hallar distintas variables
--y funciones con las cuales el usuario puede realizar distintas funciones en el programa.

--Desventajas de usar indices: Al usar indices a la hora de buscar las diferentes variables y funciones,
--se puede llegar a usar más recursos del sistema para hallar las varibales distintas que busca el usuario.

--PARTICIONES
--Ventajas de usar particiones: Las particiones dividen las distintas etapas de un programa, haciendo que los recursos sean
--distribuidos de mejor forma sin tener que darles un uso excesivo para cargar todo de una vez.

--Desventajas de usar particiones: Al dividir las tareas, se corre el riesgo de que si una de ellas llega a presentar fallos
--el programa siga ejecutando las demás, haciendo que al finalizar, entregue un resultado con fallas.

--¿QUE ES PARTITION PRUNING?
--Es una técnica de optimización de consultas que permite mejorar el rendimiento de consultas en bases de datos particionadas.

--¿Como usarias un indice compuesto y una particion por rango para mejorar el rendimiento de consultas 
--en la tabla Incidentes filtradas por Severidad y FechaDeteccion? Explica que es el particion pruning 
--y como impacta en el plan de ejecucion.
--Respuesta:
--Para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion, 
--usaria un indice compuesto y una particion por rango.
--El indice compuesto se crearia de la siguiente manera:

CREATE INDEX idx_incidentes_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);
/
--La particion por rango se crearia de la siguiente manera:

CREATE TABLE Incidentes (
    IdIncidente INT,
    Severidad INT,
    FechaDeteccion DATE
) PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p2022 VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD')),
    PARTITION p2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION p2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD'))
);
/

------------------------------------------------------------------------------------------------

--Parte 2; Practica

--1. Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (Parametros IN). 
--El procedimiento debe:
--  Insertar una nueva asignacion en Asignaciones(Usa el proximo AsignacionID disponible).
--  Validar que el agente no supere 100 horas totales (Aqui colocar if o else).
--  Validar que el incidente no tenga ya 3 o más agentes asignados (Aqui colocar if o else).
--  Usar savepoints independientes para cada validación, de modo que un fallo en una no deshaga 
--  operaciones precias validas.
--  Manejar todas la excepciones con mensajes descriptivos.

--Respuesta:

CREATE PROCEDURE registrar_asignacion (
    IN p_agenteID NUMBER,
    IN p_incidenteID NUMBER,
    IN p_horas NUMBER,
    IN p_rol VARCHAR2
)
AS 
BEGIN
    --Usar savepoints independientes para cada validación
    SAVEPOINT sp1;
    --Se insertan las nuevas asginaciones usando el proximo ID disponible
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (AsignacionID_SEQ.NEXTVAL, p_agenteID, p_incidenteID, p_horas, p_rol);

    --Se valida que el agente no supere 100 horas totales
    IF (SELECT SUM(Horas) FROM Asignaciones WHERE AgenteID = p_agenteID) > 100 THEN
        ROLLBACK TO sp1; --> Se recurre al savepoint sp1 para que en caso de fallo, no deshaga operaciones previas.
        RAISE_APPLICATION_ERROR(-20001, 'El agente ya supero las 100 horas totales');
    END IF;
    --Se valida que el incidente no tenga ya 3 o más agentes asignados
    IF (SELECT COUNT(*) FROM Asignaciones WHERE IncidenteID = p_incidenteID) > 3 THEN
        ROLLBACK TO sp1; --> Se recurre al savepoint sp1 para que en caso de fallas, no deshaga las operaciones realizadas previamente.
        RAISE_APPLICATION_ERROR(-20002, 'El incidente ya tiene 3 o más agentes asignados');
    END IF;
    --COMMIT para guardar cambios
    COMMIT;
END;
/

--2. Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para una data warehouse basado en la 
--base de datos de la prueba. Luego, escribe una consulta analitica sobre las tablas transaccionales que 
--muestre, para cada agente, el total de horas trabajadas y el numero de incidentes atendidos,
--ordenado de mayor a menor por total de horas.

--Respuesta: 

CREATE TABLE Fact_Asignaciones AS --Se crea tabla fact_asignaciones
SELECT 
    AgenteID,
    IncidenteID,
    Horas,
    Rol
FROM Asignaciones;
/

CREATE TABLE Dim_Agente AS --Se crea tabla Dim_Agente
SELECT 
    AgenteID,
    Nombre,
    Cargo
FROM Agentes;
/

CREATE TABLE Dim_Incidente AS --Se crea tabla Dim_Incidente
SELECT 
    IncidenteID,
    Severidad,
    FechaDeteccion,
    Descripcion
FROM Incidentes;
/

SELECT 
    d.Nombre,
    SUM(f.Horas) AS TotalHoras,
    COUNT(f.IncidenteID) AS NumeroIncidentes
FROM Fact_Asignaciones f
JOIN Dim_Agente d ON f.AgenteID = d.AgenteID --Se realiza un join para unir ambas id´s
GROUP BY d.Nombre
ORDER BY TotalHoras DESC; --Ordenado de Mayor a Menor en el total de horas, lo cual de descendente
/


--3. Crea un indice compuesto en Incidentes para las columnas Severidad y FechaDeteccion.
--Luego, crea la tabla Incidentes particionada por rango de FechaDeteccion (trimestral para 2026).
--Escribe una consulta que muestre el total de horas asignadas por incidente para incidentes 'Critical'
--detectados en el primer trimestre de 2026. Finalmente, muestra el plan de ejecucion con EXPLAIN PLAN e
--indica que ventaja aporta la particion para esta consulta
--Similar a Tabla e Index en ejercicio 4


--Respuesta: 
CREATE INDEX idx_incidentes_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);
CREATE TABLE Incidentes (
    IdIncidente INT,
    Severidad INT,
    FechaDeteccion DATE
) PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p2022 VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD')),
    PARTITION p2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION p2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD'))
);
/
EXPLAIN PLAN FOR 
SELECT 
    i.IdIncidente,
    SUM(a.Horas) AS TotalHoras
FROM Incidentes i
JOIN Asignaciones a ON i.IdIncidente = a.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
  AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
GROUP BY i.IdIncidente;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
