--Actividad Practica Sesión 23
--1. Diseña un modelo NoSQL para el esquema curso_topicos. Documenta en comentarios cómo 
--estructurarías los datos en MongoDB (por ejemplo, qué datos embebes y por qué). 
--Proporciona un ejemplo de un documento.

--Desarrollo:
--Modelo NoSQL para el Esquema curso_topicos en MongoDB:
--En MongoDB, estructuraría los datos utilizando una colección principal llamada "cursos", donde cada documento representaría un curso. Dentro de cada documento de curso, embebiría los datos relacionados con los tópicos y las ventas para facilitar las consultas y mejorar el rendimiento. La estructura del documento podría ser la siguiente:
{
    "_id": ObjectId("..."), // ID único generado por MongoDB
    "curso_id": 1,
    "nombre_curso": "Curso de SQL",
    "descripcion": "Aprende SQL desde cero",
    "topicos": [
        {
            "topico_id": 1,
            "nombre_topico": "Introducción a SQL",
            "contenido": "Conceptos básicos de SQL, sintaxis y ejemplos."
        },
        {
            "topico_id": 2,
            "nombre_topico": "Consultas Avanzadas",
            "contenido": "Joins, subconsultas y funciones agregadas."
        }
    ],
    "ventas": [
        {
            "venta_id": 1,
            "cliente_id": 101,
            "monto": 100.00,
            "fecha_venta": ISODate("2024-01-15T00:00:00Z")
        },
        {
            "venta_id": 2,
            "cliente_id": 102,
            "monto": 150.00,
            "fecha_venta": ISODate("2024-02-20T00:00:00Z")
        }
    ]
}

--2.Escribe dos consultas en MongoDB: 
--a) Una para obtener los clientes de una ciudad específica (por ejemplo, Santiago).
--b) Otra para calcular el número total de productos vendidos por producto.

--Desarrollo:
--a) Consulta para obtener los clientes de una ciudad específica (por ejemplo, Santiago):
db.clientes.find({ ciudad: "Santiago" });
--b) Consulta para calcular el número total de productos vendidos por producto:
db.ventas.aggregate([
    {
        $group: {
            _id: "$producto_id",
            total_vendido: { $sum: "$cantidad" }
        }
    },
    {
        $project: {
            producto_id: "$_id",
            total_vendido: 1,
            _id: 0
        }
    }
]);
