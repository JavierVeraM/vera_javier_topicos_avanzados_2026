--Evaluacion PAR
--Nombre: Javier Vera M.
--Topicos Avanzados de Datos

--PARTE 1 - PREGUNTAS TEORICAS
--PREGUNTA 1
--Explica qué es una transacción en Oracle y las propiedades ACID. Luego, escribe un bloque PL/SQL que realice las siguientes operaciones usando
--transacciones y savepoints:
  --1) Insertar un nuevo agente en la tabla Agentes.
  --2) Insertar un nuevo incidente en la tabla Incidentes.
  --3) Insertar una asignación que vincule al agente con el incidente.
--Si falla la inserción de la asignación, solo debe revertirse esa operación (el agente y el incidente deben mantenerse). Si falla la inserción del
--incidente, deben revertirse tanto el incidente como la asignación, pero el agente debe mantenerse. Explica el flujo de ROLLBACK TO en cada caso.

--Respuesta: Una trabajo de transacción en Oracle es una unidad de trabajo, que se ejecuta como un todo, haciendo que todas las operaciones dentro de ella se completen o se revertan juntas. 
--Una transaccion puede incluir varias operaciones como inserciones, actualizaciones o eliminaciones de datos, y se asegura que la base de datos este en un estado consistente y los cambios sean permanentes.
--Las propiedades ACID son: -->(En ingles seria: Atomicity, Consistency, Isolation(Aislamiento), Durability = ACID)
--Atomicidad: Garantiza que todas las operaciones dentro de una transacción se completen con exito, si algo falla, la transaccion se revierte.
--Consistencia: Garantiza que la base de datos pase de un estado consistente a otro estado consistente sin violaciones de su propia integridad o reglas.
--Aislamiento: Garantiza que las operaciones de una transacción no sean visibles para otras transacciones hasta que sean completadas.
--Durabilidad: Garantiza que una vez que una transacción se ha completado, sus cambios se mantendrán de manera permanente en la base de datos, incluso en caso de fallos del sistema.

--Bloque PL/SQL para realizar las operaciones con transacciones y savepoints:
DECLARE
    v_agente_id NUMBER := 106; -- Nuevo ID de agente
    v_incidente_id NUMBER := 208; -- Nuevo ID de incidente
BEGIN
    -- Iniciar transacción  
    SAVEPOINT sp_inicial;

    -- Insertar un nuevo agente
    INSERT INTO Agentes (AgenteID, Nombre, Especialidad, FechaIngreso)
    VALUES (v_agente_id, 'Sofía Martínez', 'Analista SOC', TO_DATE('2024-06-01','YYYY-MM-DD'));
    SAVEPOINT sp_agente_insertado;
    
    -- Insertar un nuevo incidente
    INSERT INTO Incidentes (IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion)
    VALUES (v_incidente_id, 'Ataque de Ransomware en servidor de correo', 'Critical', 'Abierto', TO_DATE('2026-06-01','YYYY-MM-DD'));
    SAVEPOINT sp_incidente_insertado;

    -- Insertar una asignación que vincule al agente con el incidente
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (13, v_agente_id, v_incidente_id, 30, 'Lider');

    COMMIT; -- Confirmar todas las operaciones si todo es exitoso
EXCEPTION

    WHEN OTHERS THEN
        -- Si falla la inserción de la asignación, revertir solo esa operación
        ROLLBACK TO sp_incidente_insertado;
        DBMS_OUTPUT.PUT_LINE('Error al insertar la asignación. Se ha revertido solo la asignación.');

        -- Si falla la inserción del incidente, revertir tanto el incidente como la asignación
        ROLLBACK TO sp_agente_insertado;
        DBMS_OUTPUT.PUT_LINE('Error al insertar el incidente. Se han revertido el incidente y la asignación.');
END;


--PREGUNTA 2
--¿Qué es un Data Warehouse y en qué se diferencia de una base de datos transaccional? Diseña un modelo dimensional (esquema estrella) con una
--tabla de hechos Fact_Rendimiento_Agente y al menos dos dimensiones para
--analizar el rendimiento de los agentes según la severidad de los incidentes y el período de tiempo. Explica por qué las tablas de un DW están
--desnormalizadas y qué ventaja tiene esto para consultas de agregación masiva frente a consultar las tablas OLTP directamente.

--Respuesta: Una data warehouse es un sistema de almacenamiento de datos diseñado para la consulta y el analisis de grandes volumenes de datos.
--Se diferencia de una base de datos transaccional en que esta ultima esta optimizada para operaciones rapidas, como lectura y escritura, mientras que un
--data warehouse esta optimizado para consultas complejas, analisis de datos y reportes, permitiendo a los usuarios tomar desiciones basadas en datos reales e historicos.

--Modelo dimensional (esquema estrella):
--Tabla de hechos: Fact_Rendimiento_Agente
--Dimensiones:
--Dim_Agente: Contiene información sobre los agentes, como AgenteID, Nombre, Especialidad.
--Dim_Severidad: Contiene información sobre la severidad de los incidentes, como SeveridadID, Descripción.
--Dim_Tiempo: Contiene información sobre el período de tiempo, como FechaID, Año, Mes, Día.

--Las tablas de un DW están desnormalizadas para mejorar el rendimiento de las consultas, ya que se reduce la necesidad de realizar múltiples joins entre tablas. 
--Esto permite consultas de agregación masiva más rápidas y eficientes en comparación con consultar directamente las tablas OLTP, que suelen estar normalizadas para optimizar la integridad y consistencia de los datos.

--PREGUNTA 3
--Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
--Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista → AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
--calcular_prioridad(). ¿Qué implicancias tiene declarar un tipo como NOT INSTANTIABLE y NOT FINAL?

--Respuesta: En Oracle, la herencia se implementa mediante tipos de objetos, donde un tipo puede heredar atributos y métodos de otro tipo. Esto permite crear jerarquías de objetos y reutilizar código.
--Ejemplo de jerarquía de dos niveles:

CREATE OR REPLACE TYPE Agente AS OBJECT (
    AgenteID NUMBER,
    Nombre VARCHAR2(50),
    Especialidad VARCHAR2(50),
    MEMBER FUNCTION calcular_prioridad RETURN NUMBER
) NOT INSTANTIABLE;

CREATE OR REPLACE TYPE AgenteEspecialista UNDER Agente (
    Experiencia NUMBER,
    OVERRIDING MEMBER FUNCTION calcular_prioridad RETURN NUMBER
) NOT INSTANTIABLE;

CREATE OR REPLACE TYPE AgentePentester UNDER AgenteEspecialista (
    Certificaciones VARCHAR2(100),
    OVERRIDING MEMBER FUNCTION calcular_prioridad RETURN NUMBER
) NOT FINAL;

--Declarar un tipo como NOT INSTANTIABLE significa que no se pueden crear instancias directas de ese tipo, solo se pueden crear instancias de sus subtipos. Esto es útil para definir una clase base abstracta.
--Declarar un tipo como NOT FINAL significa que se pueden crear subtipos adicionales a partir de ese tipo, permitiendo una mayor flexibilidad en la jerarquía de objetos.

--PREGUNTA 4 (10 puntos)
--Describe las ventajas y desventajas de usar índices y particiones en Oracle. Luego, explica cómo combinarías una partición por rango sobre FechaDeteccion
--(semestral para 2026) con un índice compuesto sobre (Estado, Severidad) en la tabla Incidentes para optimizar consultas que filtren por Estado='Abierto'
--y Severidad='Critical' en el primer semestre de 2026. Muestra el DDL de la tabla particionada y del índice. Explica qué es el partition pruning y qué
--operación aparecería en el plan de ejecución (EXPLAIN PLAN) al ejecutar dicha consulta.

--Respuesta: Las ventajas de usar índices en Oracle incluyen una mejora significativa en el rendimiento de las consultas, ya que permiten un acceso más rápido a los datos. 
--Sin embargo, los índices también pueden aumentar el tiempo de inserción, actualización y eliminación de datos, ya que deben mantenerse actualizados.
--Las ventajas de usar particiones incluyen una mejor gestión de grandes volúmenes de datos, ya que permiten dividir una tabla en partes más pequeñas y manejables, 
--lo que puede mejorar el rendimiento de las consultas y facilitar el mantenimiento. Sin embargo, la desventaja es que la administración de particiones puede ser compleja y requiere planificación cuidadosa.
--Para combinar una partición por rango sobre FechaDeteccion con un índice compuesto sobre (Estado, Severidad) en la tabla Incidentes, se puede crear la tabla particionada de la siguiente manera:     

CREATE TABLE Incidentes (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion)
(
    PARTITION p_2026_h1 VALUES LESS THAN (TO_DATE('2026-07-01', 'YYYY-MM-DD')),
    PARTITION p_2026_h2 VALUES LESS THAN (TO_DATE('2027-01-01', 'YYYY-MM-DD'))
);

--Crear índice compuesto sobre (Estado, Severidad)
CREATE INDEX idx_estado_severidad ON Incidentes (Estado, Severidad);
--El partition pruning es una técnica de optimización que permite a Oracle determinar qué particiones de una tabla deben ser escaneadas para satisfacer una consulta, 
--evitando así el escaneo de particiones innecesarias. Esto mejora el rendimiento de las consultas al reducir la cantidad de datos que se deben procesar.
--Al ejecutar la consulta que filtra por Estado='Abierto' y Severidad='Critical' en el primer semestre de 2026, el plan de ejecución (EXPLAIN PLAN) 
--mostraría que solo se escanea la partición p_2026_h1, ya que es la única partición que contiene datos relevantes para esa consulta.

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PARTE 2 - EJERCICIOS PRACTICOS

--EJERCICIO 1
--Escribe un procedimiento cerrar_incidente que reciba un IncidenteID (parámetro IN) y un parámetro OUT que retorne el total de horas invertidas.
--El procedimiento debe:
  --a) Validar que el incidente exista y esté en Estado 'Abierto'.
  --b) Actualizar el Estado del incidente a 'Cerrado'.
  --c) Calcular la suma total de horas de todas las asignaciones de ese incidente y retornarla en el parámetro OUT.
  --d) Si el total de horas supera 80, registrar un mensaje de advertencia con DBMS_OUTPUT indicando que fue un incidente de alto esfuerzo.
  --e) Usar savepoints para que si falla el cálculo de horas, la actualización del estado se mantenga.
  --f) Manejar las excepciones con mensajes descriptivos.

--Respuesta:
CREATE OR REPLACE PROCEDURE cerrar_incidente (
    p_IncidenteID IN NUMBER,
    p_TotalHoras OUT NUMBER
) AS
    v_Estado VARCHAR2(20);

BEGIN
    -- Validar que el incidente exista y esté en Estado 'Abierto'   
    SELECT Estado INTO v_Estado FROM Incidentes WHERE IncidenteID = p_IncidenteID;
    IF v_Estado IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El incidente no existe.');
    ELSIF v_Estado != 'Abierto' THEN
        RAISE_APPLICATION_ERROR(-20002, 'El incidente no está en estado "Abierto".');
    END IF;

    -- Iniciar transacción y establecer savepoint
    SAVEPOINT sp_estado_actual;

    -- Actualizar el Estado del incidente a 'Cerrado'
    UPDATE Incidentes SET Estado = 'Cerrado' WHERE IncidenteID = p_IncidenteID;

    -- Calcular la suma total de horas de todas las asignaciones de ese incidente
    SELECT SUM(Horas) INTO p_TotalHoras FROM Asignaciones WHERE IncidenteID = p_IncidenteID;
    -- Verificar si el total de horas supera 80
    IF p_TotalHoras > 80 THEN
        DBMS_OUTPUT.PUT_LINE('Advertencia: Incidente de alto esfuerzo con ' || p_TotalHoras || ' horas.');
    END IF;

    COMMIT; -- Confirmar la transacción si todo es exitoso

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO sp_estado_actual;
        RAISE_APPLICATION_ERROR(-20003, 'No se encontraron asignaciones para el incidente.');
    WHEN OTHERS THEN
        ROLLBACK TO sp_estado_actual;
        RAISE_APPLICATION_ERROR(-20004, 'Error al cerrar el incidente: ' || SQLERRM);
END cerrar_incidente;

--EJERCICIO 2
--Diseña las tablas Fact_Horas_Agente, Dim_Agente y Dim_Tiempo para un Data Warehouse que permita analizar las horas trabajadas por agente a lo
--largo del tiempo. Luego, escribe una consulta analítica sobre las tablas transaccionales que muestre, para cada especialidad, el total de horas
--trabajadas y el número de incidentes atendidos por agente, ordenado de mayor a menor por total de horas.

--Respuesta: 
--Diseño de las tablas para el Data Warehouse
CREATE TABLE Dim_Agente (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50)
);

CREATE TABLE Dim_Tiempo (
    FechaID      DATE PRIMARY KEY,
    Año          NUMBER,
    Mes          NUMBER,
    Día          NUMBER
);

CREATE TABLE Fact_Horas_Agente (
    FactID       NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    FechaID      DATE,
    TotalHoras   NUMBER,
    CONSTRAINT fk_fact_agente FOREIGN KEY (AgenteID) REFERENCES Dim_Agente(AgenteID),
    CONSTRAINT fk_fact_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);

--Consulta analítica sobre las tablas transaccionales
SELECT
    a.Especialidad,
    a.Nombre AS Agente,
    SUM(asig.Horas) AS TotalHoras,
    COUNT(DISTINCT asig.IncidenteID) AS NumIncidentes   
FROM Agentes a   
JOIN Asignaciones asig ON a.AgenteID = asig.AgenteID
GROUP BY a.Especialidad, a.Nombre
ORDER BY TotalHoras DESC;    

--EJERCICIO 3
--Crea la tabla Asignaciones particionada por rango de Horas en 3 particiones: baja (0-20), media (21-50) y alta (51+). Crea un índice compuesto sobre
--(AgenteID, IncidenteID). Escribe una consulta que muestre los agentes con asignaciones de carga alta (más de 50 horas) junto con la descripción del
--incidente. Muestra el plan de ejecución con EXPLAIN PLAN y explica cómo el partition pruning beneficia esta consulta específica.

--Respuesta: 
--Crear tabla Asignaciones particionada por rango de Horas
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_asig_agente    FOREIGN KEY (AgenteID)    REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asig_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
) PARTITION BY RANGE (Horas) (
    PARTITION p_baja VALUES LESS THAN (21),
    PARTITION p_media VALUES LESS THAN (51),
    PARTITION p_alta VALUES LESS THAN (MAXVALUE)
);

--Crear índice compuesto sobre (AgenteID, IncidenteID)
CREATE INDEX idx_agente_incidente ON Asignaciones (AgenteID, IncidenteID);

--Consulta para mostrar agentes con asignaciones de carga alta junto con la descripción del incidente
SELECT
    a.Nombre AS Agente,
    i.Descripcion AS Incidente,
    asig.Horas
FROM Asignaciones asig
JOIN Agentes a ON asig.AgenteID = a.AgenteID    
JOIN Incidentes i ON asig.IncidenteID = i.IncidenteID
WHERE asig.Horas > 50;

--Explicación del partition pruning: El partition pruning es una técnica de optimización que permite a Oracle determinar qué particiones 
--de una tabla deben ser escaneadas para satisfacer una consulta, evitando así el escaneo de particiones innecesarias. En este caso, al filtrar por asig.Horas > 50, 
--Oracle solo escaneará la partición p_alta, lo que mejora significativamente el rendimiento de la consulta al reducir la cantidad de datos que se deben procesar.

