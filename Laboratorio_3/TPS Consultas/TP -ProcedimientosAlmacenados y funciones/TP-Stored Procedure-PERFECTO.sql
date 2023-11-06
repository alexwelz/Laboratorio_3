USE MercadoLabo 
GO
SELECT * FROM Usuarios

--INSERT INTO USUARIOS(Apellidos, Nombres, FechaNacimiento, Genero, ID_SituacionCrediticia, Telefono, Celular, Mail, Domicilio, ID_Localidad)
--VALUES
--('Sin', 'Billetera', '1998-05-04', 'M', 3, null,null,'sinbille@gmial.com', 'Sin bille 123', 1)


/*
Cerar una funcion que a partir de un ID de Usaurio devuelva un alias de billetera.
Si el usuario ya dispone de una billetera, la funcion debe devolver el actual alias de 
billetera de lo contrario deberá generar uno nuevo con el siguiente formato:
APELLIDO.NOMBRE.IDUSUARIO
*/


Alter FUNCTION ObtenerAlias(@IDUsuaro bigint)
RETURNS varchar(30)
AS
BEGIN
	DECLARE @Alias varchar(30)
	DECLARE @Apellido varchar(12)
	DECLARE @Nombre varchar(12)
	DECLARE @Existe bit 

	SELECT @Alias = Alias From Billeteras Where ID_Usuario = @IDUsuaro
	SELECT @Existe = count (*) from Usuarios where ID_Usuario = @IDUsuaro

	IF @Alias is Null and @Existe =1 begin
		SELECT @Apellido = Apellidos, @Nombre =Nombres from Usuarios where ID_Usuario = @IDUsuaro
		--CAST: convierte el bigint en varchar(6)
		SET @Alias = @Apellido+'.'+@Nombre+'.'+ CAST(@IDUsuaro AS varchar(6))
		--UPPER: todo el texto en mayuscula
		SET @Alias = UPPER(@Apellido)+'.'+UPPER(@Nombre)+'.'+ CAST(@IDUsuaro AS varchar(6))
		
	end

	RETURN @Alias

END

SELECT dbo.ObtenerAlias(21)
SELECT dbo.ObtenerAlias(22)



/*
Crear un procedimiento almacenado que permita crear una nueva billetera para un cliente
existente. 
El procedimiento debe establecer la fecha de creación de la billetera con la fecha
actual y establecer el alias de la misma con el siguiente formato:
APELLIDO.NOMBRE.IDUSUARIO
*/
CREATE PROCEDURE SP_CrearBilletera(
	@IDUsuario Bigint,
	@Saldo money
)
AS 
BEGIN
	INSERT INTO Billeteras (
		ID_Usuario,
		Alias,
		FechaCreacion,
		Saldo
	)
	Values (
		@IDUsuario,
		dbo.ObtenerAlias(@IDUsuario),
		CAST(GETDATE() AS DATE), 
		@Saldo
	)
	
END

EXEC SP_CrearBilletera 21,5000
SELECT * FROM Billeteras 




/*
Crear un procedimiento almacenado que a partir de un ID de Usuario que se reciba
como parametro permita visualizar un listado con cada uno de los movimientos
registrados por ese usuario con el siguiente esquema y ordenado por fechaen orden
ascendente.

*/



--Agregar un check para evitar saldos negativos en Billetera
Alter Table Billeteras
Add Constraint CHK_SALDO_BILLETERA check(Saldo > =0)


/*
Crear un procedimiento almacenado que permita generar un nuevo movimeinto en 
una billetera. El procedimeinto debe recibir ID de billetera, Importe y Tipo de
Movimiento. Ademas de registrar el registro de movimiento debe actualizar el saldo 
de la billetera en cuestion.
*/
Alter PROCEDURE SP_CrearMovimiento (
	@ID_Billetera bigint,
	@Importe money,
	@TipoMovimiento char
)
AS
BEGIN
	Begin try  --> Todo lo que esta dentro del bloque try podria pasar
		Begin transaction
			
			INSERT INTO Movimientos(ID_Billetera, Importe, TipoMovimiento,FechaHora, Estado)
			values(@ID_Billetera, @Importe, @TipoMovimiento, getdate(), 1)

			--Actualizamos el saldo de la billetera
			IF @TipoMovimiento = 'D' Begin
				Set @Importe = @Importe * -1
			END

			UPDATE Billeteras set Saldo = Saldo + @Importe Where ID_Billetera = @ID_Billetera

		Commit transaction
	End Try
	Begin catch
		Rollback transaction
		-- 16 seguridad -->tiene que ser de 16 para arriba 
		--1 es el estado
		Raiserror('No se pudo registrar el movimiento', 16,1)
	End catch
	--2 posibles finales
	--OK (confirma los datos que modificaste) --> Commit tran
	--MAL (retrotraer los datos que modificaste) --> Rollback tran
END

--Error:
EXEC SP_CrearMovimiento 10001,-105, 'D'