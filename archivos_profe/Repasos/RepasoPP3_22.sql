Clase 22 

Replicacion en bases de datos

¿Que es la replicación en bases de datos?
La replicación en bases de datos es un proceso mediante el cual los datos de una base de datos se copian y mantienen sincronizados en múltiples ubicaciones o servidores. Esto permite que los usuarios accedan a los mismos datos desde diferentes lugares, mejorando la disponibilidad, la redundancia y el rendimiento del sistema. La replicación puede ser unidireccional o bidireccional, y puede configurarse para que sea sincrónica o asincrónica, dependiendo de las necesidades del sistema y de la tolerancia a la latencia.
Objetivo: Mejorar la disponibilidad, escalabilidad y tolerancia a fallos.

Tipos de replicación:
Sincrona: Los cambios de aplican simultaneamente en todos los nodos.
Ventaja: Garantiza que todos los nodos tengan la misma información en tiempo real.
Desventaja: Puede generar latencia y afectar el rendimiento si los nodos están geográficamente dispersos.

Asincrona: Los cambios se aplican al nodo principal y luego se propagan a los demas nodos.
Ventaja: Menor latencia en el nodo principal.
Desventaja: Posible perdida de datos si el nodo principal falla.

Logica vs Fisica: 
Fisica: Copia Exacta de los archivos de datos.
Logica: Copia de datos a nivel SQL.

Casos de uso:
1. Alta disponibilidad: La replicación permite que los sistemas continúen funcionando incluso si uno de los servidores falla, ya que los datos están disponibles en otros nodos.
2. Balanceo de carga: Al tener múltiples réplicas de la base de datos, se puede distribuir la carga de trabajo entre los diferentes servidores, mejorando el rendimiento y la capacidad de respuesta del sistema.
3. Recuperación ante desastres: La replicación facilita la recuperación de datos en caso de fallos catastróficos, ya que los datos pueden restaurarse desde una réplica en otro servidor.

Tecnologias de Oracle
Oracle Data Guard: Replicacion fisica para alta disponibilidad y recuperacion ante desastres.
Soporta modos asincrono y sincrono.
Incluye Failover automatico.
Oracle GoldenGate: Replicacion logica para entornos heterogeneos. --> Ideal para migraciones y sincronizacion en timepo real.

Alta disponibilidad en bases de datos
¿Que es la alta disponibilidad HA?
Capacidad de un sistema para permanecer operativo y accesible incluso ante fallos.
Objetivo: Minimizar tiempo de inactividad y garantizar la continuidad del negocio.

Metricas Clave:
Disponibilidad: Porcentaje de tiempo que el sistema está operativo.
Failover: Proceso de cambiar a un nodo secundario cuando el principal falla.
MTTR: Tiempo promedio para recuperarse de un fallo.
MTBF: Tiempo promedio entre fallos.

Estrategias de Alta Disponibilidad
Clustering: Multiples servidores trabajando como uno solo.
Replicacion: mantener copias sincronizadas.
Balanceo de carga: Distribuir consultas entre nodos.
Failover automatico: Detectar fallos y cambiar al nodo secundario sin intervencion manual.

Tecnologias de Oracle para HA
Oracle Data Guard: Proporciona un nodo standby(secundario) que puede tomar el control en caso de falla.
Oracle RAC: Permite multiples nodos trabajen simultaneamente, comparatiendo almacenamiento.
Active data guard: Permite al nodo standy sea usado para consultas de solo lectura mientars se sincroniza.