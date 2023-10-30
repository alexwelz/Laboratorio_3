CREATE DATABASE Consultas
GO
USE Consultas 
GO
CREATE TABLE Paises(
    ID_Pais int not null primary key identity(1,1),
    Pais nvarchar(50) not null
)
GO
CREATE TABLE Provincias(
    ID_Provincia int not null primary key identity(1,1),
    Provincia nvarchar(50) not null,
    ID_Pais int not null foreign key references Paises(ID_Pais)
)
GO 
CREATE TABLE Ciudades(
    ID_Ciudad int not null primary key identity (1,1),
    Ciudad nvarchar(50) not null,
    ID_Provincia int not null foreign key references Provincias(ID_Provincia)
)
GO
CREATE TABLE Alumnos(
    Legajo int not null primary key,
    Apellido nvarchar(100) not null,
    Nombre nvarchar(100) not null,
    Fecha_Nacimiento smalldatetime not null,
    Direccion nvarchar(100) not null,
    ID_CiudadNacimento int not null foreign key references Ciudades(ID_Ciudad),
    Telefono varchar(20) null,
    Email varchar(50) null,
    Sexo char(1) null
)



INSERT INTO Paises (Pais)
VALUES ('Argentina'), ('Estados Unidos'), ('España'), ('Brasil'), ('México'), ('Francia');

INSERT INTO Provincias (Provincia, ID_Pais)
VALUES
    ('Buenos Aires', 1),
    ('California', 2),
    ('Madrid', 3),
    ('Sao Paulo', 4),
    ('Jalisco', 5),
    ('Île-de-France', 6);


INSERT INTO Ciudades (Ciudad, ID_Provincia)
VALUES
    ('CABA', 1),
    ('Los Angeles', 2),
    ('Madrid Capital', 3),
    ('Sao Paulo Capital', 4),
    ('Guadalajara', 5),
    ('París', 6);


INSERT INTO Alumnos (Legajo, Apellido, Nombre, Fecha_Nacimiento, Direccion, ID_CiudadNacimento, Telefono, Email, Sexo)
VALUES
    (1001, 'Perez', 'Juan', '2000-05-15', 'Calle 123, CABA', 1, '123-456-7890', 'juan@example.com', 'M'),
    (1002, 'Smith', 'Emma', '1999-08-22', '123 Main St, Los Angeles', 2, '555-123-4567', 'emma@example.com', 'F'),
    (1003, 'García', 'Luis', '2001-02-10', 'Calle Mayor 45, Madrid Capital', 3, '123-789-4560', 'luis@example.com', 'M'),
    (1004, 'Ferreira', 'Maria', '2000-07-10', 'Rua 123, Sao Paulo', 4, '123-555-7890', 'maria@example.com', 'F'),
    (1005, 'López', 'Carlos', '1998-04-18', 'Avenida Principal 456, Guadalajara', 5, '333-789-1234', 'carlos@example.com', 'M'),
    (1006, 'Dubois', 'Sophie', '2002-01-25', 'Rue de la Paix 789, París', 6, '555-999-8888', 'sophie@example.com', 'F');


---------------------------------------------------------------------------------------------------------

--UPDATES 

--Modificar el email a NULL a todos los alumnos que hayan nacido entre 1980 y 1985

UPDATE Alumnos SET Email = NULL WHERE YEAR(Fecha_Nacimiento) BETWEEN 1980 AND 1985

--Modificar el nombre a 'Juan Carlos' y la dirección a 'Belgrano 4567'  al alumno con legajo 9000

UPDATE Alumnos SET Nombre = 'Juan Carlos', direccion = 'Belgrano 4567' WHERE legajo = 9000


---------------------------------------------------------------------------------------------------------

--DELETE

--La forma general de las consultas de DELETE es la siguiente:
DELETE FROM <tabla> WHERE condicion

--Ejemplos:

--Eliminar el registro del alumno con legajo 9000

DELETE FROM alumnos WHERE legajo = 9000

--Eliminar todos los registros de alumnos de sexo masculino que no tengan telefono o mail

DELETE FROM alumnos WHERE sexo = 'M' AND (email IS NULL OR telefono IS NULL)

--Eliminar todos los registros de alumnos cuyo nombre comience con 'J' y su apellido termina con 'Z'

DELETE FROM alumnos WHERE nombre LIKE 'J%' AND apellido LIKE '%Z'

--Eliminar todos los registros de alumnos

DELETE FROM alumnos
