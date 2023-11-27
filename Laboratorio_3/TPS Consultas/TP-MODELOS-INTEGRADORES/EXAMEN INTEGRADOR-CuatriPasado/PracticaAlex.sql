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
INSERT INTO Actividades (Nombre, FechaDisponibleDesde, CostoActividad, Estado)
VALUES 
( 'Clase de Yoga', '2023-01-01', 15.00, 1),
( 'Entrenamiento en Grupo', '2023-02-01', 20.00, 1),
( 'Natación', '2023-03-01', 25.00, 1),
( 'Ciclismo', '2023-04-01', 18.00, 1),
( 'Pilates', '2023-05-01', 22.00, 1),
( 'Running', '2023-06-01', 15.00, 1),
( 'Entrenamiento Funcional', '2023-07-01', 30.00, 1),
( 'Spinning', '2023-08-01', 25.00, 1)
GO


INSERT INTO Socios ( Apellidos, Nombres, FechaNacimiento, FechaAsociacion, Estado)
VALUES 
( 'López', 'Juan', '1990-05-15', '2022-01-01', 1),
( 'González', 'María', '1985-09-22', '2022-02-01', 1),
( 'Martínez', 'Carlos', '1995-07-10', '2022-03-01', 1),
( 'Rodríguez', 'Ana', '1988-12-05', '2022-04-01', 1),
( 'Díaz', 'Pedro', '1992-08-20', '2022-05-01', 1),
( 'Fernández', 'Laura', '1983-06-12', '2022-06-01', 1),
( 'Gómez', 'Luis', '1998-03-25', '2022-07-01', 1),
( 'Pérez', 'Carolina', '1987-11-18', '2022-08-01', 1)

GO
INSERT INTO ActividadxSocio(IDSocio, IDActividad, FechaInscripcion)
VALUES 
(1, 1, '2023-01-05'),
(1, 2, '2023-02-10'),
(2, 3, '2023-03-15'),
(2, 4, '2023-04-20'),
(3, 5, '2023-05-25'),
(3, 6, '2023-06-30'),
(4, 7, '2023-07-05'),
(4, 8, '2023-08-10')
GO
/*  2
 Listar todos los datos de todos los socios que hayan
realizado todas las actividades que ofrece el club.
*/

SELECT DISTINCT P2.IDSocio, P2.Apellidos, P2.Nombres,P2.FechaNacimiento ,P2.FechaAsociacion, P2.Estado FROM (
    SELECT 
        S.*,
        COUNT(AXS.IDActividad) AS CantidadActividadesxSocio,
        (SELECT COUNT(*) FROM Actividades A WHERE A.Estado = 1) AS TotalActividades
    FROM Socios S
    LEFT JOIN ActividadxSocio AXS ON AXS.IDSocio = S.IDSocio
    LEFT  JOIN Actividades A ON A.IDActividad = AXS.IDActividad
    GROUP BY S.IDSocio, S.Apellidos, S.Nombres,S.FechaNacimiento ,S.FechaAsociacion, S.Estado
) P2
WHERE P2.CantidadActividadesxSocio = P2.TotalActividades
AND P2.Estado = 1
	
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


GO

/* 4)
A partir de un legajo docente y un año devuelva la
cantidad de horas que dedicará esa persona a la docencia en el año. La cantidad
de horas es un número entero >= 0.
*/

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


