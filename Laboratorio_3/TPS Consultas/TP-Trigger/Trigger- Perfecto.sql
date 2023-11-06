--Al eliminar (DELETE) una billetera. Realizar la baja lógica de la misma y tambien 
--los movimientos y tarjetas asociadas a la billetera (UPDATE)

--ALTER TABLE Billeteras
--ADD Estado bit not null default (1)

--ALTER TABLE Tarjetas 
--ADD Estado bit not null default (1)

CREATE TRIGGER TR_BajaLogica_Billetera ON Billeteras
INSTEAD OF DELETE
AS
BEGIN
	
	DECLARE @IDBilletera bigint
	Select @IDBilletera = ID_Billetera FROM deleted

	UPDATE Billeteras SET Estado = 0 Where ID_Billetera = @IDBilletera
	UPDATE Movimientos SET Estado = 0 WHere ID_Billetera = @IDBilletera 
	UPDATE Tarjetas SET Estado = 0 WHERE ID_Billetera = @IDBilletera

END

DELETE FROM Billeteras WHERE ID_Billetera =10001

--Verificacion:
--SELECT * FROM Billeteras WHere ID_Billetera =10001
--SELECT * FROM Movimientos WHere ID_Billetera =10001
--SELECT * FROM Tarjetas WHere ID_Billetera =10001

--Borramos trigger
DROP TRIGGER TR_BajaLogica_Billetera
--Desactivamos el trigger
DISABLE TRIGGER TR_BajaLogica_Billetera ON Billeteras
--Activamos el trigger
ENABLE TRIGGER TR_BajaLogica_Billetera ON Billeteras


--ALTER TABLE Usuarios 
--ADD Estado bit not null default (1)

CREATE TRIGGER TR_BajaLogica_Cliente ON Usuarios
INSTEAD OF DELETE
AS 
BEGIN
	UPDATE Usuarios SET Estado = 0 Where ID_Usuario = (SELECT ID_Usuario From deleted)

	Delete FROM Billeteras WHERE ID_Usuario = (SELECT ID_Usuario From deleted)
END

DELETE FROM Usuarios WHERE ID_Usuario = 2

SELECT * FROM Usuarios WHERE ID_Usuario =2
SELECT * FROM Billeteras WHERE ID_Usuario =2



--Al crear un movimiento, realizar la actualizacion del saldo de la billetera
ALTER TRIGGER TR_InsertarMovimiento ON Movimientos
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @IDBilletera bigint 
			DECLARE @Importe money
			DECLARE @TipoMovimiento char

			SELECT @IDBilletera = ID_Billetera, @Importe = Importe,  
			@TipoMovimiento = TipoMovimiento FROM inserted
			
			--Actualizamos el saldo de la billetera
			IF @TipoMovimiento = 'D' Begin
				Set @Importe = @Importe * -1
			END

			UPDATE Billeteras set Saldo = Saldo + @Importe Where ID_Billetera = @IDBilletera

		COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('Error al insertar movimiento',16,1)
	END CATCH
		
END

SELECT * FROM Billeteras 
INSERT INTO Movimientos (ID_Billetera, FechaHora, Importe, TipoMovimiento, Estado)
VALUES(10003, getdate(), 400,'C', 1)

--Error:
INSERT INTO Movimientos (ID_Billetera, FechaHora, Importe, TipoMovimiento, Estado)
VALUES(10003, getdate(), 2500,'D', 1)

