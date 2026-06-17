--Actividad Práctica Sesión 22

--1. Diseña (sin script) una estrategia de alta disponibilidad para el esquema curso_topicos:
--Número de nodos y su ubicación geográfica.
--Tipo de replicación (síncrona o asíncrona).
--Uso de los nodos secundarios (por ejemplo, para reportes).
--Mecanismo de failover.

--Desarrollo:
--Estrategia de Alta Disponibilidad para el Esquema curso_topicos:
--Número de nodos y ubicación geográfica:
--Se implementarán tres nodos para el esquema curso_topicos, distribuidos geográficamente para garantizar la resiliencia ante fallos regionales. Los nodos estarán ubicados en:
--Nodo 1: Centro de datos en América del Norte (por ejemplo, AWS US East).
--Nodo 2: Centro de datos en Europa (por ejemplo, AWS EU West).
--Nodo 3: Centro de datos en Asia (por ejemplo, AWS AP Southeast).      
--Tipo de replicación:
--Se utilizará replicación asíncrona para los nodos secundarios (Nodo 2 y Nodo 3) para minimizar la latencia en las operaciones de escritura en el nodo principal (Nodo 1). Esto permitirá que el nodo principal maneje las transacciones de manera eficiente, mientras que los nodos secundarios se mantendrán actualizados con un retraso mínimo.
--Uso de los nodos secundarios: 
--Los nodos secundarios (Nodo 2 y Nodo 3) se utilizarán principalmente para tareas de lectura, como generación de reportes y consultas analíticas. Esto ayudará a distribuir la carga de trabajo y mejorar el rendimiento general del sistema.
--Mecanismo de failover:
--Se implementará un mecanismo de failover automático que permita la transferencia automática del rol de nodo principal a un nodo secundario en caso de fallo del nodo principal, minimizando el tiempo de inactividad y garantizando la continuidad del servicio.

--2. Escribe una consulta de solo lectura que podría ejecutarse en el nodo standby 
--para generar un reporte de ventas por cliente. Explica cómo aprovecharías Active Data Guard.

--Desarrollo:
--Consulta de solo lectura para generar un reporte de ventas por cliente:
SELECT 
    c.ClienteID,
    c.Nombre,
    SUM(v.Monto) AS TotalVentas 
FROM Clientes c
JOIN Ventas v ON c.ClienteID = v.ClienteID
GROUP BY c.ClienteID, c.Nombre
ORDER BY TotalVentas DESC;
--Aprovechamiento de Active Data Guard:
--Active Data Guard permite que el nodo standby esté disponible para consultas de solo lectura mientras se mantiene sincronizado con el nodo principal. Esto significa que se pueden ejecutar consultas como la anterior en el nodo standby sin afectar el rendimiento del nodo principal. Además, Active Data Guard garantiza que los datos en el nodo standby estén actualizados, lo que permite obtener reportes precisos y en tiempo real sin comprometer la disponibilidad del sistema.


