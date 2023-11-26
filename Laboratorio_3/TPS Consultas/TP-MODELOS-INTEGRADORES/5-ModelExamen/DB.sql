use master
go
Create Database ModeloExamen_PRACTICAINTEGRADOR
go
Use ModeloExamen_PRACTICAINTEGRADOR
go
Create Table Clientes(
    ID bigint not null primary key identity (1, 1),
    Apellidos varchar(100) not null,
    Nombres varchar(100) not null,
    Telefono varchar(30) null,
    Email varchar(120) null,
    TelefonoVerificado bit not null,
    EmailVerificado bit not null
)
go
Create Table Vehiculos(
    ID bigint not null primary key identity (1, 1),
    Patente varchar(8) not null unique,
    AñoPatentamiento smallint not null,
    Marca varchar(50) not null,
    Modelo varchar(50) not null 
)
go
Create Table Choferes(
    ID bigint not null primary key identity (1, 1),
    Apellidos varchar(100) not null,
    Nombres varchar(100) not null,
    FechaRegistro date not null,
    FechaNacimiento date not null,
    IDVehiculo bigint not null foreign key references Vehiculos(ID),
    Suspendido bit not null default(0)
)
go
Create Table FormasPago(
    ID int not null primary key identity (1, 1),
    Nombre varchar(50) not null
)
go
Create Table Viajes(
    ID bigint not null primary key identity(1, 1),
    IDCliente bigint null foreign key references Clientes(ID),
    IDChofer bigint not null foreign key references Choferes(ID),
    FormaPago int null foreign key references FormasPago(ID),
    Inicio datetime null,
    Fin datetime null,
    Kms decimal(10, 2) not null,
    Importe money not null,
    Pagado bit not null
)
go
Create Table Puntos(
    ID bigint not null primary key identity (1, 1),
    IDCliente bigint not null foreign key references Clientes(ID),
    IDViaje bigint null foreign key references Viajes(ID),
    Fecha datetime not null default(getdate()),
    PuntosObtenidos int not null,
    FechaVencimiento date not null
)
GO
--1.41
--1)
create table CalificacionesViajes(
	IDViaje bigint not null foreign key references Viajes(ID),
	CalificacionAlChofer tinyint null CHECK(CalificacionAlChofer between 1 And 10),
	ObservacionAlChofer varchar(200) null,
	CalificacionAlCliente tinyint null CHECK(CalificacionAlCliente between 1 And 10),
	ObservacionAlCliente varchar(200) null
)
GO
--2)
CREATE VIEW  VW_ClientesDeudores 
AS
SELECT P2.* FROM (
	SELECT C.Apellidos+' '+C.Nombres AS Clientes,
	COALESCE(C.Email, C.Telefono, 'Sin datos de contacto') AS Contacto,
	(SELECT COUNT(*) FROM Viajes V WHERE V.IDCliente = C.ID) AS CantViajesTotales,
	(SELECT COUNT(*) FROM Viajes V WHERE V.Pagado=0 AND V.IDCliente = C.ID) AS 'Cant Viajes NO Abonados',
	(SELECT COALESCE(SUM(V.Importe),0) FROM Viajes V WHERE V.Pagado=0 AND V.IDCliente = C.ID) AS TotalAdeudado
	FROM Clientes C
) AS P2
WHERE P2.[Cant Viajes NO Abonados] > P2.CantViajesTotales /2

--3)

CREATE PROCEDURE SP_ChoferesEfectivo (
@Año smallint
)
AS 
BEGIN
SELECT P3.Choferes FROM(

	SELECT C.Apellidos+' '+C.Nombres AS Choferes,
	(SELECT COUNT(*) FROM Viajes V WHERE V.IDChofer =C.ID AND YEAR(V.Inicio) = @Año) AS CantViajesPorAnio,
	(SELECT COUNT(*)FROM Viajes V WHERE V.IDChofer = C.ID 
		AND V.FormaPago = (
			Select FP.ID FROM FormasPago FP 
			where V.IDChofer = C.ID and FP.Nombre = 'Efectivo' and  YEAR(V.Inicio) = @Año
		)
	
	)AS ViajesEnEfectivo
	FROM Choferes C
	
) AS P3
WHERE P3.CantViajesPorAnio = P3.ViajesEnEfectivo and P3.CantViajesPorAnio >0

END
-- VERR 2.22 comeer -4.04 volvi

--4)
CREATE TRIGGER TR_BorrarCliente ON Clientes
INSTEAD OF DELETE
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @IDCliente bigint
			SET @IDCliente = (SELECT ID FROM deleted)

			DELETE FROM Puntos WHERE IDCliente = @IDCliente
			UPDATE Viajes SET IDCliente = NULL where IDCliente = @IDCliente
			DELETE FROM Clientes WHERE ID = @IDCliente

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
		RAISERROR('Error al borrar cliente',16,1)
		RETURN
	END CATCH
	PRINT ('Cliente eliminado con exito!');
END
--DELETE FROM Puntos WHERE IDCliente = @IDCliente
--			UPDATE Viajes SET IDCliente = NULL where IDCliente = @IDCliente
--			DELETE FROM Clientes WHERE ID = @IDCliente
INSERT INTO Puntos
SELECT ID, NULL, GETDATE(),100, DATEADD(DAY, 10, GETDATE()) FROM Clientes
WHERE ID <=50

INSERT INTO Puntos
SELECT ID,Null, GETDAtE(), 100 *ID, DATEADD(MONTH, 5, GETDATE()) FROM Clientes
DELETE FROM Clientes WHERE ID = 10 


SELECT * FROM Puntos WHERE ID in(10,110)
SELECT * FROM Viajes WHERE ID in (425,1668,1943)
SELECT * FROM Clientes WHERE ID =10

--5)
--IDViaje bigint not null foreign key references Viajes(ID),
--	CalificacionAlChofer tinyint null CHECK(CalificacionAlChofer between 1 And 10),
--	ObservacionAlChofer varchar(200) null,
--	CalificacionAlCliente tinyint null CHECK(CalificacionAlCliente between 1 And 10),
--	ObservacionAlCliente varchar(200) null
CREATE TRIGGER TR_CalificarChofer on CalificacionesViajes
After insert
AS
BEGIN 
	BEGIN TRY
		BEgin tran
			DECLARE @IDViaje bigint
			DECLARE @Pagado bit

			SELECT @IDViaje = IDViaje FROM inserted

			SELECT @Pagado = V.Pagado FROM Viajes V where V.ID = @IDViaje

			IF @Pagado =0
			BEGIN
				RAISERROR('No se pudo calificar al chofer', 16,1)
				Rollback
			
			END

		Commit
	END TRY
	BEGIN CATCH
		ROLLBACK
		RAISERROR('Error al ejecutar trigger', 16,1)

	END CATCH

END
--5.05 tiempo finalizado