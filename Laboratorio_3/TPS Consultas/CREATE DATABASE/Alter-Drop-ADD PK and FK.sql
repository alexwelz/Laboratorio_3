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
--borrar una columna de una tabla 
ALTER TABLE Usuarios
DROP COLUMN nombre
--agregar columna a tabla existente 
ALTER TABLE Usuarios 
ADD Nombre varchar(20) 
    
--crear tabla con las 3 columnas primary key 
Create table demo(
    Col1 int not null,
    Col2 int not null,
    Col3 int not null
    primary key (col1,col2,col3) 
)

--Mostrar solo el año de la fecha de nacimiento }
SELECT DatePart(YEAR, FechaNacimiento) AS Año From Usuarios
SELECT YEAR(FechaNacimiento) AS Año FROM Usuarios

--Trim(Numero) quita los espacios --> Evitar que pongan 16 espacios --> este se usa para verciones mas nuevas
--RTrim(Numero) quita espacios de la derecha
--LTrim(Numero) quita espacios izquierda 
--LEN() cuenta cuantos caracteres si son 16 lo acepta y si son mas o menos tira error
