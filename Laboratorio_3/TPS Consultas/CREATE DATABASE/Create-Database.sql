------------------------------------------------------------------------------------------
--QUERYS ABAJO --> ALTER TABLE, DROP, ADD COLUMN, DROP COLUMN, INSERT INTO (GPT) ETC...
------------------------------------------------------------------------------------------
--BORRAR DATABASE: DROP DATABASE NOMBRE_BD

CREATE DATABASE MercadoLabo
GO
USE MercadoLabo
GO
Create Table Provincias(
    ID_Provincia tinyint not null PRIMARY key identity (1, 1),
    Provincia varchar(50) not null
)
GO
Create Table Localidades(
    ID_Localidad int not null primary key identity (1, 1),
    ID_Provincia tinyint not null foreign key references Provincias(ID_Provincia),
    Localidad varchar(200) not null
)
GO
Create Table Bancos(
    ID_Banco smallint not null primary key identity (1, 1),
    Nombre varchar (100) not null
)
GO
Create Table NivelesSituacionCrediticia(
    ID_NivelSituacionCrediticia tinyint not null primary key identity (1, 1),
    SituacionCrediticia varchar(50) not null
)
Go
Create Table MarcasTarjeta(
    ID_MarcaTarjeta tinyint not null primary key identity (1, 1),
    Marca varchar(100) not null
)
CREATE TABLE Usuarios(
    ID_Usuario bigint not null primary key identity (1 ,1),
    DNI varchar(50) not null unique  ,
    Apellido varchar(200) not null,
    Nombre varchar (200)  not null,  
    FechaNacimiento date not null check (FechaNacimiento <= getdate()),
    Genero char(1) not null CHECK(Genero='F' OR Genero ='M'),
    ID_SituacionCrediticia tinyint foreign key references NivelesSituacionCrediticia(ID_NivelSituacionCrediticia),
    Telefono varchar (20) null,
    Celular varchar (20) null,
    Mail varchar(250) not null unique,
    Domicilio varchar(500) not null,
    ID_Localidad int not null foreign key references Localidades(ID_Localidad)

)
GO
Create Table Billetera(
    ID_Billetera bigint not null primary key identity (10001, 1),
    ID_Usuario bigint not null unique foreign key references Usuarios(ID_Usuario),
    Alias varchar(30) not null unique,
    FechaCracion date not null,
    Saldo money not null default(0) --decimal(14,2) 12 digitos y 2 decimales 
)
--money es como decimal pero tiene una configuracion que en otros paises con muchos 0 esta mal usar
Go
Create Table  Tarjetas(
    ID_Tarjeta bigint not null primary key identity (1,1),
    ID_Billetera bigint not null foreign key references Billetera(ID_Billetera),
    ID_MarcaTarjeta tinyint not null foreign key references MarcasTarjeta(ID_MarcaTarjeta),
    ID_Banco smallint not null foreign key references Bancos(ID_Banco),
    Numero varchar(16) not null unique check(LEN(RTrim(LTrim(Numero))) = 16),
    FechaEmision date not null,
    FechaVencimiento date not null,
    CodigoSeguridad varchar(4) not null,
    check (FechaEmision < FechaVencimiento)  --Siempre se agrega despues de crear ambas columnas o alter table
)


-----------------------------------------------------------------------------------------------------------------------
CREATE DATABASE AppRecetas
go 
USE AppRecetas
go
Create table Ingredientes(
    IDIngrediente int not null,
    Nombre varchar(100) not null,
    EsVegano bit not null default(0),
    EsVegetariano bit not null default(0),
    EsCeliaco bit not null default(0)

)
GO
Create Table Plato(
    IDPlato int not null, 
    Nombre varchar(100) not null,
    Descripcion varchar(512) null,
    TiempoCoccion int null, -- minutos
    Calorias int null,
    Dificultad decimal (2, 1)
)
GO
Create table Recetas(
    ID int not null primary key identity(1,1),
    IDPlato int not null,
    IDIngrediente int not null,
    Cantidad decimal(6,2) not null,--4 y 2 decimales
    IDUnidadMedida TINYINT not null
)
GO
Create table UnidadesMedida(
    IDUnidadMedida TINYINT not null,
    Nombre varchar (50) not null
)

--Restricciones
Alter Table Ingredientes
add CONSTRAINT PK_Ingrediente PRIMARY key (IDIngrediente)
go 
Alter Table Platos
add CONSTRAINT PK_Platos PRIMARY key(IDPlatos)
go 
Alter Table Platos
add CONSTRAINT CHK_TiempoPreparacion CHECK (TiempoPreparacion>0)
go 
Alter Table Platos
add CONSTRAINT CHK_Calorias CHECK (Calorias > 0)
go 
Alter Table Platos
add CONSTRAINT CHK_Dificultad CHECK (Dificultad >= 0 and Dificultad <= 5)
go 
Alter Table Recetas
add CONSTRAINT PK_Recetas PRIMARY key (IDPlato, IDIngrediente)
go 
Alter Table Recetas
add CONSTRAINT FK_Recetas_Platos FOREIGN key (IDPlato) REFERENCES Platos(IDPlato)
go 
Alter Table Recetas
add CONSTRAINT FK_Recetas_Ingredientes FOREIGN key (IDIngrediente) REFERENCES Ingredientes(IDIngrediente)
go 
Alter Table Recetas
add CONSTRAINT FK_Recetas_UnidadMedida FOREIGN key (IDUnidadMedida) REFERENCES UnidadMedida(IDUnidadMedida)
go 
Alter Table Recetas
add CONSTRAINT CHK_Cantidad CHECK (Cantidad > 0)
----------------------------------------------------------------------------------------------------------------

CREATE DATABASE Punto1_ExamenIntegrador
GO
USE Punto1_ExamenIntegrador
GO
CREATE TABLE  Carreras (
	IDCarrera Bigint not null primary key identity(1,1),
	Nombre varchar(200) not null 

)
GO 
CREATE TABLE Materias(
	IDMateria Bigint not null primary key identity(1,1),
	IDCarrera Bigint not null foreign key references Carreras(IDCarrera),
	Nombre varchar(200) not null,
	Año tinyint not null CHECK (Año > 0),
	Cuatrimestre  tinyint not null
)

GO 
CREATE TABLE Alumnos(
	Legajo bigint not null primary key,
	Apellidos varchar(200) not null,
	Nombres varchar(200) not null
)
GO
CREATE TABLE Examenes(
	IDExamen Bigint not null primary key identity(1,1),
	IDMateria Bigint not null foreign key references Materias(IDMateria),
	Legajo bigint not null foreign key references Alumnos(Legajo),
	Fecha date not null,
	Nota decimal(4,2) not null check(Nota between 1.00 and 10.00)
	
)
GO
CREATE TABLE Sanciones
(
	IDSancion Bigint not null primary key identity(1,1),
	Legajo bigint not null foreign key references Alumnos(Legajo),
	Fecha date not null,
	Observaciones varchar(600) not null

)
Go 

-----------------------------------------------------------------------------------------------

CREATE DATABASE Punto5_PracticaExamenIntegrador
GO 
USE Punto5_PracticaExamenIntegrador
GO
CREATE TABLE TipoCuentas(
	IDTipoCuenta bigint not null primary key identity(1,1),
	Nombre varchar(50) not null ,
	CapacidadEnMB int not null
)
GO 
CREATE TABLE Usuarios (
	IDUsuarios bigint not null primary key identity(1,1),
	IDTipoCuenta bigint not null foreign key references TipoCuentas(IDTipoCuenta),
	NombreUsuario varchar(50) not null
)
GO
CREATE TABLE CambiosDeCuenta(
	IDUsuario bigint not null foreign key references Usuarios(IDUsuarios),
	IDTipoCuentaAnterior  bigint not null foreign key references TipoCuentas(IDTipoCuenta),
	IDTipoCuentaActual  bigint not null foreign key references TipoCuentas(IDTipoCuenta),
	Fecha date not null
)
GO 
CREATE TABLE Archivos(
	IDArchivo bigint not null primary key identity(1,1),
	IDUsuario bigint not null foreign key references Usuarios(IDUsuarios),
	NombreArchivo varchar(50) not null,
	Descripcion varchar(250) not null,
	Extension varchar(5) not null,
	TamañoEnMB int not null,
	FechaPublicacion date not null

)


    
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

------------------------------------------------------------------------------------------


/*
**Deducciones consigna enunciado MercadLabo**
Entidads:
----------
Provincias
Localidades 
Bancos
NivelesSituacionCrediticia
MarcasTarjeta
Usuarios (1:1) 
Billeteras (1:1)
Tarjetas 

Domicilios (X)
Movimientos (-) 
Pagos (-) 
DatosDeContacto (X)

- Vamos a olvidar (X)  -> Podria ir/probablemente no se use nunca
- A futuro vamos resolver (-)
- 1 usuario puede tener 1 billetera (1:1)
-------------------------------------------------------
*/
