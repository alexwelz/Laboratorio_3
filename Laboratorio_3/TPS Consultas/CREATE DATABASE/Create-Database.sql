/*
- Vamos a olvidar (X)  -> Podria ir/probablemente no se use nunca
- A futuro vamos resolver (-)
- 1 usuario puede tener 1 billetera (1:1)


ALTER TABLE Tarjeta --> agregar    ID_Billetera bigint not null foreign key references Billetera(ID_Billetera)
MINUTO VIDEO 1.12.33 -->  https://www.youtube.com/watch?v=n844nX4ylrs&ab_channel=AngelSim%C3%B3n


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
-------------------------------------------------------

*/


Use MercadoLabo
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

--Trim(Numero) quita los espacios --> Evitar que pongan 16 espacios --> este se usa para verciones mas nuevas
--RTrim(Numero) quita espacios de la derecha
--LTrim(Numero) quita espacios izquierda 
--LEN() cuenta cuantos caracteres si son 16 lo acepta y si son mas o menos tira error


--crear tabla con las 3 columnas pk 
Create table demo(
    Col1 int not null,
    Col2 int not null,
    Col3 int not null
    primary key (col1,col2,col3) 
)
--borrar una tabla entera 
drop table Tarjetas;
--borrar una columna de una tabla 
Alter table demo drop column nombre
--borrar el contenido de una tabla sin borrar la tabla entera
DELETE FROM Tarjetas;


--agregar columna a tabla existente 
alter table demo 
add nombre varchar(20) 
