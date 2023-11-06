--1)
/*Ver consigna en la actividad*/
CREATE TABLE Actividades (
	ID_Actividad int primary key not null identity (1, 1),
	Nombre varchar(50) not null,
	FechaDisponibleDesde DATETIME not null,
	CostoActividad decimal not null check(CostoActividad > 0),
	Estado bit not null

)
GO
CREATE TABLE Socios(
	ID_Socio bigint  not null primary key identity(1,1),
	Apellidos varchar (200)  not null,  
	Nombres varchar (200)  not null,  
	FechaNacimiento date not null check (FechaNacimiento <= getdate()),
	FechaAsociacion  date not null
)
GO
CREATE TABLE ActividadesxSocio
(
	ID_Socio bigint not null  foreign key references Socios(ID_Socio),
	ID_Actividad int not null  foreign key references Actividades (ID_Actividad),
	FechaInscripcion DATETIME not null
)


--2)
/*
Haciendo uso de las tablas realizadas en el punto anterior resolver la siguiente consulta de selección: Listar
todos los datos de todos los socios que hayan realizado todas las actividades que ofrece el club.
*/

SELECT S.Apellidos,S.Nombres
FROM Socios S 
WHERE 
(
SELECT COUNT(Distinct A.ID_Actividad) FROM Actividades A
) = 
(
	 SELECT COUNT(DISTINCT AXS.ID_Actividad)
    FROM ActividadesxSocio AXS
    WHERE AXS.ID_Socio = S.ID_Socio
)

--3)
/*
3)
Hacer un trigger que al ingresar un registro no permita que un docente pueda tener una materia con el cargo de 
profesor (IDCargo = 1) si no tiene una antigüedad de al menos 5 años. Tampoco debe permitir que haya más de un docente 
con el cargo de profesor (IDCargo = 1) en la misma materia y año. Caso contrario registrar el docente a la planta
docente.

*/
CREATE TRIGGER TR_AgregarDocentePlantaDocente ON PlantaDocente
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @DocenteLegajo BIGINT
			DECLARE @IDMateria BIGINT 
			DECLARE @ANIO INT

			SELECT @DocenteLegajo = Legajo, @IDMateria = ID_Materia, @ANIO = Año FROM inserted

			DECLARE @Antiguedad INT
			SELECT @Antiguedad = @ANIO - D.AñoIngreso 
			FROM PlantaDocente PD
			INNER JOIN Docentes D ON D.Legajo = PD.Legajo 
			WHERE PD.Legajo = @DocenteLegajo

			IF @Antiguedad < 5
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR ('El docente tiene que tener al menos 5 años de antigüedad para ser profesor de una materia', 16, 1)
			END

			IF EXISTS (
				SELECT 1 FROM PlantaDocente
				WHERE ID_Materia = @IDMateria AND Año = @Anio AND Legajo <> @DocenteLegajo AND ID_Cargo = 1
			)
			BEGIN
				ROLLBACK;
				RAISERROR ('Ya existe otro profesor en la misma materia y año', 16, 1);
			END

			INSERT INTO PlantaDocente (Legajo, ID_Materia, ID_Cargo, Año)
			VALUES (@DocenteLegajo, @IDMateria, 1, @Anio);

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END

--4)
/*
Hacer una función SQL que a partir de un legajo docente y un año devuelva la cantidad de horas semanales que dedicará esa 
persona a la docencia ese año. La cantidad de horas es un número entero >= 0.

NOTA: No hace falta multiplicarlo por la cantidad de semanas que hay en un año.

*/

CREATE FUNCTION CantidadHorasSemanales(
@Legajo bigint,
@Año int
)

RETURNS INT
AS 
BEGIN
	DECLARE @HorasSemanales TINYINT

	SELECT @HorasSemanales = SUM(HorasSemanales) FROM Materias M
	INNER JOIN PlantaDocente PD ON PD.ID_Materia = M.ID_Materia
	INNER JOIN Docentes D ON PD.Legajo = D.Legajo
	WHERE @Año = PD.Año AND PD.Legajo = @Legajo

	IF @HorasSemanales < 0 BEGIN
		--PRINT ('No puede tener horas semanales negativas')
		SET @HorasSemanales = NULL
	END
	  RETURN @HorasSemanales
END
--Verificar:
SELECT dbo.CantidadHorasSemanales(4,2021)




--5)
/*
Hacer un procedimiento almacenado que reciba un ID de Materia y liste la cantidad de docentes distintos que han trabajado en ella.
*/
CREATE PROCEDURE PS_DocentesDistintos (
@IDMATERIA BIGINT
)
AS
BEGIN
	
	SELECT COUNT(Distinct D.Legajo) FROM Docentes D
	INNER JOIN PlantaDocente PD ON PD.Legajo = D.Legajo
	INNER JOIN Materias M ON M.ID_Materia = PD.ID_Materia
	WHERE @IDMATERIA = M.ID_Materia
END

SELECT * FROM PlantaDocente where ID_Materia =1
EXEC PS_DocentesDistintos 1