--Ejercicios parte 1

--Ejercicio 1
--Relación Muchos a Muchos (10 pts): Explica qué es una relación muchos a muchos y 
--cómo se implementa en una base de datos relacional. Usa un ejemplo basado en las tablas del esquema creado para la prueba.

--Una relación muchos a muchos se refiere a una relación entre dos tablas las cuales al interactuar entre sí, ambas pueden tener un valor de 1 a muchos, como pueden ser:
-- En muchas estanterias hay muchos libros
-- En varios colegios hay varios alumnos

--En una base de datos relacional se puede implementar de modo que entre ambas tablas, este una tabla que sirva como puente rompiendo la relación de muchos a muchos
--Al hacer esto no tendra conflictos entre ellas y la base de datos entregará resultados basados en esta tabla, ejemplo:
-- En las estanterias hay secciones para distintos libros, haciendo que la relacion de muchos a muchos pase a ser, Varias estanterias, a una seccion, a varios libros.


--Ejercicio 2
--Vistas (10 pts): Describe qué es una vista y cómo la usarías para mostrar el total de horas dedicadas por incidente, 
--incluyendo la descripción del incidente y su severidad. Escribe la consulta SQL para crear la vista (no es necesario ejecutarla).

--Un vista es una forma en que se le puede hacer "zoom" a una o varias tablas, tomando solo informacion que el programador desee que sea visible, asegurando que
--datos sensibles queden dentro de la base de datos.

--Si queremos mostrar el total de horas dedicadas por incidente, con la descripcion y su severidad, se debe hacer lo siguiente:

CREATE VIEW Vista_Incidentes AS
SELECT inc.IncidenteID, inc.Horas, inc.Severidad FROM Incidentes inc
JOIN Asignaciones asi ON inc.IncidenteID = asi.IncidenteID

--Luego para ejecutarlam se tiene que usar este comando:
SELECT * FROM Vista_Incidentes


--Ejercicios parte 2

--Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo promedio de horas 
--asignadas a incidentes sea mayor a 30, mostrando la especialidad y el promedio de horas. Usa un JOIN entre Agentes y Asignaciones.

SET SERVEROUTPUT ON;

DECLARE 
    CURSOR c_especialidades_agentes IS
        SELECT a.Nombre, a.AgenteID, asi.Horas FROM Agentes a 
        JOIN Asignaciones asi ON a.AgenteID = asi.AgenteID
        JOIN Incidentes inc ON asi.IncidenteID = inc.IncidenteID
        WHERE asi.Horas > 30;

    a_nombre VARCHAR2(50);
    a_agenteid VARCHAR2(50);
    asi_horas NUMBER;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Especialidades Agentes');

    OPEN c_especialidades_agentes;
    LOOP
        FETCH c_especialidades_agentes INTO a_nombre, a_agenteid, asi_horas;
        EXIT WHEN c_especialidades_agentes%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Agente: ' || a_nombre || ' ID del agente:'|| a_agenteid ||' | Horas: ' || asi_horas);
    END LOOP;
    CLOSE c_especialidades_agentes;
END;


COMMIT;
