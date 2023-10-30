/*
Elaborar una base de datos para una app que suguiere recetas de cocina

*/
-- Platos
-- Recetas
-- UnuidadesDeMedida
-- Ingredientes



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
