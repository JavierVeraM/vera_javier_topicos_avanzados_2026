Clase 24

Revision de roles y permisos en bases de datos
Roles: Conjuntos de permisos agrupados para facilitar la administracion (Por ejemplo, Administrador o usuario).
Permisos: Privilegios especificos otrogados a usuario o roles(Por ejemplo, SELECT, INSERT, UPDATE, DELETE).

Buenas practicas:
- Principio de privilegio minimo: dar a los usuario solo los permisos necesarios para sus tareas.
- Uso de roles: asignar permisos a roles y luego asignar roles a usuarios, en lugar de permisos directos.
- Auditoria: Monitorear el uso de permisos para detectar accesos no autorizados.

CREATE ROLE: Crea un nuevo rol en la base de datos.
GRANT: Otorga permisos a un usuario o rol.
REVOKE: Revoca permisos de un usuario o rol.

Revision de Optimizacion de consultas
¿Porque?
- Mejorar el rendimiento del sistema, especialmente con grandes volumenes de datos.
- Reducir el tiempo de respuesta y el uso de recursos.

Tecnicas de Optimizacion: 
Indices: Crear indices en columnas usadas frecuentemente en WHERE, JOIN o ORDER BY.
Particiones: Dividir tablas gtandes en partes más pequeñas.
Reescritura de consultas: Simplificar consultas, evitar subconsultas innecesarias.
Uso de EXPLAIN PLAN: Analizar el plan de ejecucion para identificar cuellos de botella.
TABLE ACCESS FULL: Escaneo completo de las tablas.

