

--RESTRICCIONES
ALTER TABLE Ingredientes
ADD CONSTRAINT PK_Ingrediente PRIMARY key (IDIngrediente)
go 
ALTER TABLE Platos
ADD CONSTRAINT PK_Platos PRIMARY key(IDPlatos)
go 
ALTER TABLE Platos
ADD CONSTRAINT CHK_TiempoPreparacion CHECK (TiempoPreparacion>0)
go 
ALTER TABLE Platos
ADD CONSTRAINT CHK_Calorias CHECK (Calorias > 0)
go 
ALTER TABLE Platos
ADD CONSTRAINT CHK_Dificultad CHECK (Dificultad >= 0 and Dificultad <= 5)
go 
ALTER TABLE Recetas
ADD CONSTRAINT PK_Recetas PRIMARY key (IDPlato, IDIngrediente)
go 
ALTER TABLE Recetas
ADD CONSTRAINT FK_Recetas_Platos FOREIGN key (IDPlato) REFERENCES Platos(IDPlato)
go 
ALTER TABLE Recetas
ADD CONSTRAINT FK_Recetas_Ingredientes FOREIGN key (IDIngrediente) REFERENCES Ingredientes(IDIngrediente)
go 
ALTER TABLE Recetas
ADD CONSTRAINT FK_Recetas_UnidadMedida FOREIGN key (IDUnidadMedida) REFERENCES UnidadMedida(IDUnidadMedida)
go 
ALTER TABLE Recetas
ADD CONSTRAINT CHK_Cantidad CHECK (Cantidad > 0)