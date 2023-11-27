--Exmen practica parcial manu

--1)
CREATE DATABASE Punto1_2doModelo_ExamenIntegrador
GO 
Use Punto1_2doModelo_ExamenIntegrador
GO 
CREATE TABLE Actividades(
	IDActividad BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombre varchar(100) NOT NULL,
	FechaDisponibleDesde DATE NOT NULL,
	CostoActividad money not null CHECK(CostoActividad > 0),
	Estado BIT NOT NULL
)
GO
CREATE TABLE Socios(
	IDSocio BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Apellidos varchar(100) NOT NULL,
	Nombres varchar(100) NOT NULL,
	FechaNacimiento date not null check (FechaNacimiento <= getdate()),
	FechaAsociacion date not null,
	Estado bit not null
)
GO
CREATE TABLE ActividadesxSocio(
	IDSocio BIGINT NOT NULL FOREIGN KEY REFERENCES Socios(IDSocio),
	IDActividad BIGINT NOT NULL FOREIGN KEY REFERENCES Actividades(IDActividad),
	FechaInscripcion date not null
)
GO
/*  2
 Listar todos los datos de todos los socios que hayan
realizado todas las actividades que ofrece el club.
*/

SELECT * 
FROM Socios S
INNER JOIN ActividadesxSocio AXS ON AXS.IDSocio = S.IDSocio
INNER JOIN Actividades A ON A.IDActividad = AXS.IDActividad
WHERE NOT EXISTS ( SELECT A.IDActividad FROM Actividades A
		WHERE NOT EXISTS (
			SELECT AXS.IDSocio FROM ActividadesxSocio AXS
			WHERE AXS.IDSocio = S.IDSocio AND AXS.IDActividad = A.IDActividad
		)
)
GO

/* 3)
Hacer un trigger que al ingresar un registro no permita que un docente pueda
tener una materia con el cargo de profesor (IDCargo = 1) si no tiene una
antigüedad de al menos 5 años. Tampoco debe permitir que haya más de un
docente con el cargo de profesor (IDCargo = 1) en la misma materia y año. Caso
contrario registrar el docente a la planta docente.
*/

CREATE TRIGGER TR_Punto3 ON PlantaDocente 
INSTEAD OF INSERT
AS
BEGIN
    BEGIN TRY  
	
        BEGIN TRANSACTION

			DECLARE @Legajo bigint;
			DECLARE @ID_Materia bigint;
			DECLARE @ID_Cargo tinyint;
			DECLARE @Año int;
			
			DECLARE @AñoActual INT = YEAR(GETDATE())

			SELECT @Legajo = Legajo, @ID_Materia = ID_Materia, @ID_Cargo = ID_Cargo, @Año = Año
			FROM inserted


			IF @ID_Cargo = 1 AND (SELECT @AñoActual - @Año FROM PlantaDocente PD Where Legajo = @Legajo) > 5
			BEGIN 
				RAISERROR('El docente no tiene mas de 5 años de antiguedad', 16, 1)
				ROLLBACK TRANSACTION
				RETURNS

			IF(SELECT COUNT(*) FROM PlantaDocente PD WHERE PD.ID_Cargo = 1 and PD.Año = @Año and PD.ID_Materia = @ID_Materia) > 1
			BEGIN 
				RAISERROR(' No puede haber mas de un doncente en la misma materia y año', 16, 1)
				ROLLBACK TRANSACTION
				RETURNS
	
		COMMIT TRANSACTION 
	END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION 
			PRINT ERROR_MESSAGE()
		 END CATCH
END




/* 4)
A partir de un legajo docente y un año devuelva la
cantidad de horas que dedicará esa persona a la docencia en el año. La cantidad
de horas es un número entero >= 0.
*/
GO
CREATE FUNCTION Cant_HorasDocencia(@Legajo bigint, @Año smallint)
RETURNS INT
AS 
BEGIN 
	DECLARE @HsSemanales int

	SELECT @HsSemanales = ISNULL(SUM(M.HorasSemanales), 0)
	FROM Materias M
	WHERE M.ID_Materia IN ( 
		SELECT ID_Materia 
		FROM PlantaDocente PD
		WHERE PD.Legajo = @Legajo AND PD.Año = @Año
	)

	RETURN @HsSemanales;
END
GO

/* 5)
Hacer un procedimiento almacenado que reciba un ID de Materia y liste la
cantidad de docentes distintos que han trabajado en ella
*/

CREATE PROCEDURE PD_CantidadDocentes( 
	@ID_Materia BIGINT
)
AS 
BEGIN 
		SELECT COUNT(DISTINCT PD.Legajo) AS 'Cantidad Docentes'
		FROM PlantaDocente PD
		WHERE PD.ID_Materia = @ID_Materia
END


