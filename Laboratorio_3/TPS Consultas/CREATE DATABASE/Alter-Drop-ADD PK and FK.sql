--------------------------------------------------------------------------------------------------------
-- ALTER TABLE, DROP, ADD COLUMN, DROP COLUMN, INSERT INTO (GPT) ETC... check(LEN(RTrim(LTrim(Numero)))
---------------------------------------------------------------------------------------------------------
    
-- Minuto 1.31.57 --> INSERT INTO con Chat GPT
--https://www.youtube.com/watch?v=n844nX4ylrs&ab_channel=AngelSim%C3%B3n
    
--Borrar una base de datos:
DROP DATABASE MercadoLabo
--Borrar una tabla entera:
DROP TABLE Provincias
--Borrar el contenido de una tabla sin borrar los campos:
DELETE FROM Provincias
--borrar una columna de una tabla:
ALTER TABLE Usuarios
DROP COLUMN nombre
--agregar columna a tabla existente:
ALTER TABLE Usuarios 
ADD Nombre varchar(20) 

--Restricciones:
ALTER TABLE Ingredientes
ADD CONSTRAINT PK_Ingrediente PRIMARY KEY (IDIngrediente)
GO
ALTER TABLE Recetas
ADD CONSTRAINT FK_Recetas_Platos FOREIGN KEY (IDPlato) REFERENCES Platos(IDPlato)
GO
ALTER TABLE Platos
ADD CONSTRAINT CHK_TiempoPreparacion CHECK (TiempoPreparacion>0)

--crear tabla con 3 CAMPOS CON PRIMARY KEY:
Create table demo(
    Col1 int not null,
    Col2 int not null,
    Col3 int not null
    primary key (col1,col2,col3) 
)

--Mostrar solo el año de la fecha de nacimiento 
SELECT DatePart(YEAR, FechaNacimiento) AS Año From Usuarios
SELECT YEAR(FechaNacimiento) AS Año FROM Usuarios

--Trim(Numero) quita los espacios --> Evitar que pongan 16 espacios --> este se usa para verciones mas nuevas
--RTrim(Numero) quita espacios de la derecha
--LTrim(Numero) quita espacios izquierda 
--LEN() cuenta cuantos caracteres si son 16 lo acepta y si son mas o menos tira error


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


--------------------------------------------------------------------------------------------------------------

--UPDATES 
--Modificar el email a NULL a todos los alumnos que hayan nacido entre 1980 y 1985
UPDATE Alumnos SET Email = NULL WHERE YEAR(Fecha_Nacimiento) BETWEEN 1980 AND 1985
--Modificar el nombre a 'Juan Carlos' y la dirección a 'Belgrano 4567'  al alumno con legajo 9000
UPDATE Alumnos SET Nombre = 'Juan Carlos', direccion = 'Belgrano 4567' WHERE legajo = 9000

