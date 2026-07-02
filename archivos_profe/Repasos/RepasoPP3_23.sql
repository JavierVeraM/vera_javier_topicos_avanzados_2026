Clase 23 

Introduccion a base de datos NOSQL(No solo sql)

Diseñadas para manejar grandes volumenes de datos no estructurados o semi-estructurados.
Priorizan la escalabilidad horizontal(agregar mas servidores) sobre la consistencia estricta de los datos.

Tipos de bases de datos NoSQL
Clave-Valor: Almacenan datos como paresq clave-valor(Por ejemplo DynamoDB, Redis).
-Uso: Ideal para almacenar datos de sesión, caché y configuraciones. 

Documentales: Almacenan datos en documentos(JSON, BSON, XML) (Por ejemplo MongoDB, CouchDB).
-Uso: Ideal para aplicaciones web, gestión de contenido y análisis de datos.

Columnas: Almacenan datos en columnas en lugar de filas (Por ejemplo Cassandra, HBase).
-Uso: Ideal para análisis de grandes volúmenes de datos y aplicaciones de inteligencia empresarial.

Grafos: Almacenan datos en nodos y relaciones (Por ejemplo Neo4j, ArangoDB).
-Uso: Ideal para redes sociales, recomendaciones y análisis de relaciones complejas.

Caracteristicas Clave:
Esquema Flexible: No requiere un esquema fijo, permite agregar campos dinamicamente.
Escalabilidad Horizontal: Facil de escalar agregando mas nodos.
Eventual consistency: En lugar de consistencia inmediata(CAP Theorem: Solo se puede garantizar dos de tres; Consistencia, Disponibilidad, Tolerancia a particiones).
No transacciones ACID compuestas: Priorizan BASE(Basically Available, Soft state, Eventually consistency).

Casos de uso:
Grandes Volumenes de datos(Big Data)
Aplicaciones con datos no estructurados(por ejemplo, redes sociales, contenido multimedia).
Sistemas que requieren alta escalabilidad y disponibilidad(Por ejemplo, netflix, uber).

Ventajas y Desventajas
- Relacionales: 
Ventajas: Consistencia, soporte para transacciones complejas, sql estandarizado.
Desventajas: Escalabilidad limitada, esquemas rigidos.
- NoSQL:
Ventajas: Escalabilidad, flexibilidad, rendimiento con grandes volumenes de datos.
Desventajas: Menor consistencia, aprendizaje de nuevas herramientas, falta de JOINs.