--6.37
-- Legajo: 24583
--Alumno: Alex Gustavo Welz

--1)
CREATE DATABASE EXAMENPARCIAL_PRACTICA
GO
USE EXAMENPARCIAL_PRACTICA
GO 
CREATE TABLE Artefactos (
	IDArtefacto BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Descripcion VARCHAR(100) NOT NULL,
	FechaCompra DATE NOT NULL,
	Garantia TINYINT NOT NULL,
	Importe MONEY NOT NULL check(Importe >= 0) default(0)
)
go
CREATE TABLE Tecnicos(
	IDTecnico  BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Apellidos VARCHAR(100) NOT NULL,
	Nombres VARCHAR(100) NOT NULL,
	Sueldo MONEY NOT NULL check(Sueldo >= 0) default(0)
)
go
CREATE TABLE OrdenesDeTrabajo(
	IDOrden BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDArtefacto BIGINT NOT NULL FOREIGN KEY REFERENCES Artefactos(IDArtefacto),
	IDTecnico  BIGINT NOT NULL FOREIGN KEY REFERENCES Tecnicos(IDTecnico),
	Importe money not null,
	Fecha date not null DEFAULT(GETDATE()),
	Calificacion tinyint CHECK (Calificacion between 1 and 10),
	Reparado bit not null default(1)
)
GO
--2)
CREATE TRIGGER TR_OrdenDeTrabajo ON OrdenesDeTrabajo
INSTEAD OF insert

AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DECLARE @IDOrden bigint
			DECLARE @IDArtefacto bigint 
			DECLARE @IDTecnico bigint 
			DECLARE @Importe money
			DECLARE @Calificacion TINYINT
			DECLARE @Reparado BIT

			DECLARE @Garantia TINYINT
			DECLARE @CostoArtefacto MONEY
			DECLARE @FechaCompra DATE
			
			SELECT  @IDArtefacto=IDArtefacto, @IDTecnico = IDTecnico,@Importe = Importe, 
			 @Calificacion=Calificacion, @Reparado= Reparado
			FROM inserted

			SELECT @Garantia= A.Garantia, @CostoArtefacto = A.Importe, @FechaCompra = FechaCompra
			FROM Artefactos A
			where A.IDArtefacto = @IDArtefacto

			If (DATEADD(YEAR, @Garantia * 365, @FechaCompra)) >= GETDATE()
			BEGIN
				SET @Importe = 0
			END
			ELSE
			BEGIN
				If @Importe > @CostoArtefacto * 0.6
				BEGIN
					RAISERROR('El importe de la orden no puede ser mayor a 60% del costo del artefacto ', 16,1)
					Rollback
					Return
				END
				ELSE BEGIN
					INSERT INTO 
					OrdenesDeTrabajo (IDOrden,IDArtefacto, IDTecnico, Importe, Fecha,Calificacion ,Reparado)
					values (@IDOrden, @IDArtefacto, @IDTecnico, @Importe, GETDATE(),@Calificacion, @Reparado)
				END
			END

		COMMIT
	PRINT ('Ejecutado correctamente!')
	END TRY
	BEGIN CATCH
		RAISERROR('Error al ejecutar trigger', 16,1)
		ROLLBACK
		
	END CATCH
END

--3)

CREATE PROCEDURE PS_SueldoTecnico (
    @IDTecnico BIGINT,
    @NumMes TINYINT,
    @Anio SMALLINT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN

        DECLARE @Sueldo MONEY;

        --Sueldo base del tecnico
        SELECT @Sueldo = Sueldo FROM Tecnicos WHERE IDTecnico = @IDTecnico

        -- Calcular el 10% de todos los costos de las órdenes realizadas en ese mes
        SELECT @Sueldo = @Sueldo + (SUM(ISNULL(Importe, 0)) * 0.1)
        FROM OrdenesDeTrabajo
        WHERE IDTecnico = @IDTecnico AND MONTH(Fecha) = @NumMes AND YEAR(Fecha) = @Anio

        -- Acumular $2500 para órdenes con costo $0
        SELECT @Sueldo = @Sueldo + 2500 * COUNT(*)
        FROM OrdenesDeTrabajo
        WHERE IDTecnico = @IDTecnico AND MONTH(Fecha)=@NumMes AND YEAR(Fecha)=@Anio AND Importe = 0

        -- Verificar bonus de $5000 para técnicos con más de 3 arreglos y ninguna calificación menor a 5
        IF (
            SELECT COUNT(*) 
            FROM OrdenesDeTrabajo
            WHERE IDTecnico = @IDTecnico
                AND MONTH(Fecha) = @NumMes
                AND YEAR(Fecha) = @Anio
        ) > 3
        AND NOT EXISTS (
            SELECT 1
            FROM OrdenesDeTrabajo
            WHERE IDTecnico = @IDTecnico
                AND MONTH(Fecha) = @NumMes
                AND YEAR(Fecha) = @Anio
                AND Calificacion < 5
        )
        BEGIN
            SET @Sueldo = @Sueldo + 5000;
        END

        -- Mostrar el sueldo total
        PRINT ('Sueldo a pagar: $' + CAST(@Sueldo AS VARCHAR));

        COMMIT
        PRINT ('Ejecutado con éxito');
    END TRY
    BEGIN CATCH
        ROLLBACK
        RAISEERROR('Error al calcular el sueldo del técnico', 16, 1);
    END CATCH
END;


--4)
SELECT * FROM Artefactos A
WHERE DATEADD(YEAR, A.Garantia,A.FechaCompra) >= GETDATE()
AND A.IDArtefacto NOT IN (
	SELECT OT.IDArtefacto FROM OrdenesDeTrabajo OT
	WHERE OT.IDArtefacto = A.IDArtefacto
)