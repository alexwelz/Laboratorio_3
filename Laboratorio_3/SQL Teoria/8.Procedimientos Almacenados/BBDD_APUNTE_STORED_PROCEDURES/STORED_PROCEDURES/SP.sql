-- Clientes por sucursal
CREATE PROCEDURE sp_ClientesPorSucursal(
@idSucursal INT
)
AS
BEGIN
SELECT * FROM CLIENTES WHERE idsucursal = @idSucursal
END

--Nuevo cliente
CREATE PROCEDURE sp_IngresarCliente(
@Apellido VARCHAR(50),
@Nombre VARCHAR(50),
@sexo CHAR,
@idSucursal INT
)
AS
BEGIN
INSERT INTO clientes (apellido, nombre, sexo, idSucursal, estado)
VALUES(@Apellido, @Nombre, @sexo, @idSucursal, 1)
END

-- Registrar movimiento

CREATE PROCEDURE spRegistrarMovimiento(
@nroCuenta VARCHAR(20),
@tipoMovimiento CHAR,
@descripcion VARCHAR(50),
@importe DECIMAL(10, 2)
)
AS
BEGIN
--Comenzamos con el manejo de errores
BEGIN TRY
--Verificamos si el tipo de movimiento es Extracción
IF @tipoMovimiento = 'E' OR @tipoMovimiento ='e'
BEGIN
--Declaramos las variables
DECLARE @saldo DECIMAL(10, 2)
DECLARE @tipoCuenta INT
DECLARE @descubierto DECIMAL(10, 2)
--Le asignamos valores que provienen de una consulta SQL
SELECT @saldo = C.saldo, @tipoCuenta = C.idTipoCuenta, @descubierto =
C.limite_descubierto FROM cuentas C WHERE C.nroCuenta = @nroCuenta
--Verificamos si se puede hacer la Extracción
IF @saldo - @importe < 0 AND @tipoCuenta = 1
BEGIN
RAISERROR ('NO SE PUEDE REALIZAR EL MOVIMIENTO, SALDO ES INSUFICIENTE', 16, 1)
END
IF @saldo - @importe < (0 - @descubierto)
BEGIN
RAISERROR ('NO SE PUEDE REALIZAR EL MOVIMIENTO, SALDO ES INSUFICIENTE', 16, 1)
END
END
--Registramos el movimiento en la tabla de Movimientos
INSERT INTO movimientos (fecha, nrocuenta, descripcion, tipomovimiento,
importe) VALUES(GETDATE(), @nroCuenta, @descripcion, @tipoMovimiento, @importe)
--Si es Extracción el importe debe restarse
IF @tipoMovimiento = 'E' OR @tipoMovimiento = 'e'
BEGIN
SET @importe = @importe * -1
END
--Actualizamos el saldo de la cuenta
UPDATE cuentas SET saldo = saldo + @importe WHERE nroCuenta = @nroCuenta
END TRY
BEGIN CATCH
PRINT ERROR_MESSAGE()
END CATCH
--Finaliza el manejo de errores
END

