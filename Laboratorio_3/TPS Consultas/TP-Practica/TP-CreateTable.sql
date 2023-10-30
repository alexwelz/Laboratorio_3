
USE UTN_LABO3
go
Create Table Areas(
    ID tinyint PRIMARY KEY not null identity(1, 1), 
    Nombre varchar(50) not null,
    Presupuesto money not null check(Presupuesto > 0),
    Mail varchar(100) not null unique 
)
go 
Create Table Empleados(
    Legajo int primary key not null,
    IDArea tinyint null foreign key references Areas(ID),
    Apellido varchar(100) not null,
    Nombre varchar(100) not null,
    FechaNacimiento date null check(FechaNacimiento <= getdate()),
    Mail varchar(100) not null unique,
    Telefono varchar(100),
    Sueldo money not null check(Sueldo > 0) 
)


create table Articulos(
	ID_Articulo int not null primary key identity(1,1),
	Codigo varchar(20) not null unique,
	Marca varchar(50) null, 
	PrecioCompra decimal(1,1) not null default(0),
	PrecioVenta decimal(1,1) not null default(0),
	Ganancia money not null default(0),
	Tipo varchar(50) not null,
	Stock int not null default(0),
	Estado bit not null default(0)
)
go 
create table Clientes(
	ID_Cliente int not null primary key identity(1,1),
	DNI varchar(11) not null unique,
	Apellido varchar(30) null,
	Nombre varchar(30) null,
	Sexo char(1) null check(Sexo = 'F'or Sexo ='M'),
	Telefono varchar (50) null,
	Mail varchar (50) null,
	FechaAlta DATETIME DEFAULT GETDATE() NOT NULL,
	FechaNacimiento date null,
	Edad tinyint null,
	Direccion varchar(100) null,
	CodigoPostal tinyint null,
	Localidad varchar(100) not null,
	Provincia varchar(100) not null
)