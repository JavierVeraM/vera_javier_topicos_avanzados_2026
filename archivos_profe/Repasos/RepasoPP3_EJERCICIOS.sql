Ejercicio Practicos:

1. Define qué es una transacción en una base de datos y explica cómo las propiedades ACID garantizan su integridad. 
Proporciona un ejemplo de un procedimiento que registre un pedido en la tabla Pedidos, usando savepoints para revertir 
la operación si el cliente no existe

Respuesta: 
Una transaccion en una base de datos es una unidad de trabajo que se ejecuta de manera completa o no se ejecuta en absoluto.
Las propiedades ACID garantizan la integridad de las transacciones de la siguiente manera:
- Atomicidad: Asegura todas las operaciones
- Consistencia: Garantiza que la base de datos pase de un estado valido a otro estado valido.
- Aislamiento: Asegura que las transacciones concurrentes no interfieran entre si.
- Durabilidad: Garantiza que los cambios realizados por una transaccion se mantengan en la base de datos incluso en caso de falla.

Ejemplo procedimiento para registrar un pedido en la tabla Pedidos usando savepoints:

CREATE PROCEDURE RegistrarPedido(
    IN p_cliente_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar el pedido';
    END;

    START TRANSACTION;

    -- Verificar si el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE cliente_id = p_cliente_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe';
    END IF;

    -- Crear un savepoint antes de insertar el pedido
    SAVEPOINT before_insert;

    -- Insertar el pedido en la tabla Pedidos
    INSERT INTO Pedidos (cliente_id, producto_id, cantidad)
    VALUES (p_cliente_id, p_producto_id, p_cantidad);

    COMMIT;
END;

2. ¿Qué es un Data Warehouse y cómo se diferencia de una base de datos operativa en términos de propósito y estructura? 
Diseña una tabla de hechos Fact_Inventario para analizar el movimiento de productos (entradas y salidas) en la base de datos, 
incluyendo claves foráneas y medidas adecuadas.

Respuesta: 
Un data warehouse en un sistema de almacenamiento de datos que se utiliza para el analisis y la toma de desiciones.
Se diferencia de una base de datos operativa en los siguientes aspectos: 
- Los datas warehouse estan diseñados para consultas complejas y analisis de grandes volumenes de datos, las bases de datos operativas 
se centran en las transacciones diarias.
- La estructura de un data warehouse es con tablas y dimensiones, la de una base de datos operativa es más estructurada para optimizar
las operaciones de lectura.

Ejemplo de tabla de hechos Fact_Inventario:
CREATE TABLE Fact_Inventario (
    inventario_id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    fecha_id DATE,
    cantidad_entrada INT,
    cantidad_salida INT,
    FOREIGN KEY (producto_id) REFERENCES Dim_Producto(producto_id),
    FOREIGN KEY (fecha_id) REFERENCES Dim_Fecha(fecha_id)
);  

3. Explica cómo se implementa la herencia en Oracle utilizando tipos de objetos y la cláusula UNDER. 
Diseña una jerarquía de tipos para modelar clientes (Cliente → ClientePremium) y crea un índice en la tabla 
Clientes para optimizar consultas por Ciudad. Justifica tu elección.

Respuesta:
La herencia en Oracle se implementa usando tipos de objetos y la clausula UNDER, que permite crear subtipos de un tipo de objeto base. 
Esto hace que los subtipos hereden atributos y metodos del tipo base.

Ejemplo de jerarquía de tipos para modelar clientes:
CREATE TYPE Cliente AS OBJECT (
    cliente_id INT,
    nombre VARCHAR2(100),
    ciudad VARCHAR2(50)
) NOT FINAL;
CREATE TYPE ClientePremium UNDER Cliente (
    nivel_premium VARCHAR2(20)
);

Para optimizar consultas por Ciudad, se puede crear un índice en la tabla Clientes de la siguiente manera:
CREATE INDEX idx_ciudad ON Clientes(ciudad);
Justificación: La creación de un índice en la columna Ciudad permite acelerar las consultas que filtran por esta columna, mejorando el rendimiento de las búsquedas y reduciendo el tiempo de respuesta en consultas frecuentes que involucren la ciudad del cliente.

4. Crea un índice compuesto en DetallesPedidos para PedidoID y ProductoID. Particiona Pedidos por rango de FechaPedido (mensual para 2025). 
Escribe una consulta que sume Total por ClienteID en enero de 2025.

Respuesta:
CREATE INDEX idx_composite ON DetallesPedidos(PedidoID, ProductoID);

PARTITION BY RANGE (FechaPedido) (
    PARTITION p_2025_01 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_2025_02 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    -- ... más particiones para cada mes de 2025
);

SELECT ClienteID, SUM(Total) AS TotalPorCliente
FROM Pedidos
WHERE FechaPedido >= TO_DATE('2025-01-01', 'YYYY-MM-DD') AND FechaPedido < TO_DATE('2025-02-01', 'YYYY-MM-DD')
GROUP BY ClienteID;

