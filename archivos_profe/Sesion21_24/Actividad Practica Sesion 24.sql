--Actividad Practica Sesión 23

--1. Define al menos dos roles (por ejemplo, "Usuario", "Administrador").
--Asigna permisos específicos a cada rol.
--Crea usuarios y asigna los roles.
--Documenta los cambios en mejoras_proyecto.sql.

--Desarrollo:
--Definición de Roles:
CREATE ROLE Usuario;
CREATE ROLE Administrador;
--Asignación de Permisos:
--Permisos para el rol Usuario:
GRANT SELECT ON curso_topicos TO Usuario;
GRANT SELECT ON clientes TO Usuario;
--Permisos para el rol Administrador:
GRANT ALL PRIVILEGES ON curso_topicos TO Administrador;
GRANT ALL PRIVILEGES ON clientes TO Administrador;
--Creación de Usuarios y Asignación de Roles:
CREATE USER usuario1 IDENTIFIED BY password1;
CREATE USER administrador1 IDENTIFIED BY password1;
--Asignación de Roles a Usuarios:
GRANT Usuario TO usuario1;
GRANT Administrador TO administrador1

--2. 