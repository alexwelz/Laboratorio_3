/*es un tipo de procedimiento almacenado que se ejecuta automáticamente en respuesta a un evento específico. 
Los triggers son utilizados para mantener la integridad de los datos, automatizar tareas o 
aplicar lógica de negocio en una base de datos. 

Nomenclatura para crearlo (AFTER INSERT/DELETE/UPDATE se ejecuta despues del insert, delete o update || 
INSTEAD OF INSERT/DELETE/UPDATE se ejecutan en lugar de la acción original):
																	CREATE TRIGGER TR_AGREGAR_VENTA ON VENTAS
																	AFTER INSERT
																	AS
																	BEGIN
																		BEGIN TRY
																			BEGIN TRANSACTION
																				---
																				--- CODIGO
																				---
																			COMMIT TRANSACTION
																		END TRY
																		BEGIN CATCH
																			ROLLBACK TRANSACTION
																		END CATCH
																	END

PARA ELIMINARLO: DROP TRIGGER TR_AGREGAR_VENTA...
PARA DESABILITARLO: DISABLE TRIGGER TR_AGREGAR_VENTA ON ARTICULOS...
PARA HABILITARLO: ENABLE TRIGGER TR_AGREGAR_VENTA ON ARTICULOS...




1) Realizar un trigger que al agregar un viaje:
- Verifique que la tarjeta se encuentre activa.
- Verifique que el saldo de la tarjeta sea suficiente para realizar el viaje.
- Registre el viaje
- Registre el movimiento
- Descuente el stock de la tarjeta
*/

CREATE TRIGGER TR_AGREGAR_VIAJE ON Viajes
INSTEAD OF INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
			DECLARE @TARJETA INT
				SELECT @TARJETA = NumeroTarjeta FROM inserted
			DECLARE @Estado CHAR(1)
				SELECT @Estado = Estado FROM Tarjetas WHERE @TARJETA = Numero
			
			DECLARE @IMPORTE DECIMAL(10, 2)
				SELECT @IMPORTE = Importe FROM inserted
			DECLARE @SALDO DECIMAL(10, 2)
				SELECT @SALDO = Saldo FROM Tarjetas WHERE @TARJETA = Numero

			IF @Estado = 'A' AND @SALDO >= @IMPORTE BEGIN
				INSERT INTO Viajes (CodigoViaje, FechaHoraViaje, NumeroColectivo, NumeroTarjeta, Importe, IDUsuario)
				SELECT CodigoViaje, GETDATE(), NumeroColectivo, NumeroTarjeta, Importe, IDUsuario FROM inserted

				DECLARE @MaxNumero INT;
				SELECT @MaxNumero = MAX(NumeroMovimiento) FROM Movimientos
				SET @MaxNumero = @MaxNumero + 1
				INSERT INTO Movimientos (NumeroMovimiento, FechaHora, NumeroTarjeta, Importe, TipoMovimiento)
				VALUES(@MaxNumero, GETDATE(), @TARJETA, @IMPORTE, 'D')

				UPDATE Tarjetas SET Saldo = @SALDO - @IMPORTE WHERE Numero = @TARJETA
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('NO SE PUDO AGREGAR EL VIAJE', 16, 1)
	END CATCH
END




-- 2) Realizar un trigger que al registrar un nuevo usuario:
-- Registre el usuario
-- Registre una tarjeta a dicho usuario


CREATE TRIGGER TR_AGREGAR_USUARIO ON Usuarios
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
			DECLARE @ID INT
				SELECT @ID = IDUsuario FROM inserted

			DECLARE @NumeroTarjetaNueva INT
			SET @NumeroTarjetaNueva = ROUND(RAND() * (9999 - 1000) + 1000, 0);
			INSERT INTO Tarjetas(Numero, IDUsuario, FechaAlta, Saldo, Estado)
			VALUES(@NumeroTarjetaNueva, @ID, GETDATE(), 0, 'A')

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('NO SE PUDO AGREGAR LA TARJETA A EL USUARIO NUEVO', 16, 1)
	END CATCH
END



/* 3) Realizar un trigger que al registrar una nueva tarjeta:
- Le realice baja lógica a la última tarjeta del cliente.
- Le asigne a la nueva tarjeta el saldo de la última tarjeta del cliente.
- Registre la nueva tarjeta para el cliente (con el saldo de la vieja tarjeta, la fecha de alta de la tarjeta deberá ser la del sistema).
*/


CREATE TRIGGER TR_AGREGAR_TARJETA ON Tarjetas
INSTEAD OF INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
			DECLARE @ID INT
			SELECT @ID = IDUsuario FROM inserted
			UPDATE Tarjetas SET Estado = 'B' WHERE IDUsuario = @ID AND Numero = (SELECT TOP 1 Numero FROM Tarjetas WHERE IDUsuario = @ID ORDER BY Numero DESC)

			DECLARE @SALDO DECIMAL(10, 2)
			SELECT @SALDO = Saldo FROM Tarjetas WHERE IDUsuario = @ID AND Numero = (SELECT TOP 1 Numero FROM Tarjetas WHERE IDUsuario = @ID ORDER BY Numero DESC)

			INSERT INTO Tarjetas(Numero, IDUsuario, FechaAlta, Saldo, Estado)
			SELECT Numero, @ID, GETDATE(), @SALDO, Estado FROM inserted

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('NO SE PUDO AGREGAR LA TARJETA', 16, 1)
	END CATCH
END



/* 4) Realizar un trigger que al eliminar un cliente:
- Elimine el cliente
- Elimine todas las tarjetas del cliente
- Elimine todos los movimientos de sus tarjetas
- Elimine todos los viajes de sus tarjetas
*/

CREATE TRIGGER TR_ELIMINAR_CLIENTE ON Usuarios
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Movimientos WHERE NumeroTarjeta IN (SELECT Numero FROM Tarjetas WHERE IDUsuario IN (SELECT IDUsuario FROM deleted))

    DELETE FROM Viajes WHERE IDUsuario IN (SELECT IDUsuario FROM deleted)

    DELETE FROM Tarjetas WHERE IDUsuario IN (SELECT IDUsuario FROM deleted)

    DELETE FROM Usuarios WHERE IDUsuario IN (SELECT IDUsuario FROM deleted)
END
