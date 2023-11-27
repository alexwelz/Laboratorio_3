

--1)A partir del siguiente DER, realizar mediante código T-SQL la creación de las tablas y restricciones que permitan representar la base de datos.
--Elegir el tipo de dato más acorde para cada atributo.

CREATE TABLE Actividades (
    ID_Actividad INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    FechaDisponibleDesde DATE NOT NULL,
    CostoActividad DECIMAL(10, 2) NOT NULL CHECK (CostoActividad >= 0),
    Estado VARCHAR(50) NOT NULL
);

CREATE TABLE Socios (
    ID_Socio INT PRIMARY KEY,
    Apellidos VARCHAR(100) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    FechaAsociacion DATE NOT NULL,
    Estado VARCHAR(50) NOT NULL
);

CREATE TABLE ActividadesxSocio (
    ID_Socio INT,
    ID_Actividad INT,
    FechaInscripcion DATE NOT NULL,
    PRIMARY KEY (ID_Socio, ID_Actividad),
    FOREIGN KEY (ID_Socio) REFERENCES Socios (ID_Socio),
    FOREIGN KEY (ID_Actividad) REFERENCES Actividades (ID_Actividad)
);

--2)Haciendo uso de las tablas realizadas en el punto anterior resolver la siguiente consulta de selección:
-- Listar todos los datos de todos los socios que hayan realizado todas las actividades que ofrece el club.

SELECT S.ID_Socio, S.Apellidos, S.Nombre, S.FechaNacimiento, S.FechaAsociacion, S.Estado
FROM Socios S
WHERE NOT EXISTS (
    SELECT A.ID_Actividad
    FROM Actividades A WHERE NOT EXISTS (
        SELECT ActPorSoc.ID_Socio
        FROM ActividadesxSocio ActPorSoc
        WHERE ActPorSoc.ID_Socio = S.ID_Socio AND ActPorSoc.ID_Actividad = A.ID_Actividad
    )
);

--3)Haciendo uso de la base de datos que se encuentra en el Campus Virtual resolver:
--Hacer un trigger que al ingresar un registro no permita que un docente pueda tener una materia con el 
--cargo de profesor (IDCargo = 1) si no tiene una antigüedad de al menos 5 años. Tampoco debe permitir que haya más de un 
--docente con el cargo de profesor (IDCargo = 1) en la misma materia y año. Caso contrario registrar el docente a la planta docente.

CREATE TRIGGER TG_InsertDocente
ON PlantaDocente
AFTER INSERT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @LegajoDocente bigint;
        DECLARE @FechaRegistro int;
        DECLARE @Cargo tinyint;
        DECLARE @Materia bigint;

        SELECT @LegajoDocente = Legajo, @FechaRegistro = Año, @Cargo = ID_Cargo, @Materia = ID_Materia
        FROM inserted;

        IF @Cargo = 1
        BEGIN
            IF (SELECT YEAR(GETDATE()) - AñoIngreso FROM Docentes WHERE Legajo = @LegajoDocente) < 5
            BEGIN
                RAISERROR('El docente no cumple con la antiguedad mínima requerida.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;

            IF (SELECT COUNT(*) FROM PlantaDocente WHERE ID_Materia = @Materia AND Año = @FechaRegistro AND ID_Cargo = 1) > 1
            BEGIN
                RAISERROR('Ya hay un registro en la misma materia y el mismo año.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;

--4)Hacer una función SQL que a partir de un legajo docente y un año devuelva la cantidad de horas semanales que dedicará esa persona a la docencia ese año.
-- La cantidad de horas es un número entero >= 0.
--NOTA: No hace falta multiplicarlo por la cantidad de semanas que hay en un año.

CREATE FUNCTION CalculoHsDocencia(@Legajo bigint, @Año int)
RETURNS INT
AS
BEGIN
    DECLARE @HsSemanales INT 
    SELECT @HsSemanales = (
        SELECT SUM(HorasSemanales)
        FROM Materias
        WHERE ID_Materia IN 
        (
            SELECT ID_Materia
            FROM PlantaDocente
            WHERE Legajo = @Legajo AND Año = @Año
        )
    )
    RETURN ISNULL(@HsSemanales, 0)
END

-- DECLARE @LegajoDocente bigint = 4
-- DECLARE @Año int = 2021
-- SELECT dbo.CalcularHorasDocencia(@LegajoDocente, @Año) AS HorasSemanales



--5)Hacer un procedimiento almacenado que reciba un ID de Materia y liste la cantidad de docentes distintos que han trabajado en ella.

CREATE PROCEDURE CantDocentesXMateria
    @ID_Materia bigint
AS
BEGIN
    SELECT COUNT(DISTINCT PlantaDocente.Legajo) AS CantidadDocentes
    FROM PlantaDocente
    WHERE ID_Materia = @ID_Materia;
END

-- DECLARE @ID_Materia bigint = 1;
-- EXEC CantDocentesXMateria @ID_Materia;