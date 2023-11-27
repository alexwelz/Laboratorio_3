

--VISTAS

CREATE VIEW VW_NOMBREVISTA 
AS
	--CONSULTA
GO

-----------------------------------------------------------


--STORED PROCEDURE
	
CREATE PROCEDURE SP_NOMBREPROCEDURE(
    @PARAMETRO --TIPO DATO (BIGINT-SMALLINT-BIT....)
)
AS
BEGIN
	
--DESARROLLO CONUSLTA
END
GO


-----------------------------------------------------------


--TRIGGER

CREATE TRIGGER TR_NOMBRETIGGER ON TABLA_DIRIGIDA
--AFTER INSERT
--INSTEAD OF DELETE / INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		COMMIT TRANSACTION
		PRINT ('Realizado con exito!');
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION 
		RAISERROR('Error al ejecutatar trigger',16,1)
		 PRINT ERROR_MESSAGE();
	END CATCH 
END


-----------------------------------------------------------


--FUNCIONES 
CREATE FUNCTION NOMBREFUNCION (@PARAMETRO TIPO DATO)
RETURNS TIPO DATO
AS 
BEGIN
	DECLARE

	RETURN @VARIABLE A DEVOLVER
END
GO
		
-----------------------------------------------------------------
		
Create Function ObtenerAlias(@ID_Usuario bigint)
returns varchar(30)
as
begin
    Declare @Alias varchar(30)
    Declare @Apellido varchar(12)
    Declare @Nombre varchar(12)
    Declare @Existe bit
    
    Select @Alias = Alias From Billeteras Where ID_Usuario = @ID_Usuario
    Select @Existe = count(*) from Usuarios Where ID_Usuario = @ID_Usuario

    If @Alias is null And @Existe = 1 begin
        Select @Apellido = Apellidos, @Nombre = Nombres From Usuarios Where ID_Usuario = @ID_Usuario
        Set @Alias = Upper(@Apellido) + '.' + Upper(@Nombre) + '.' + Cast(@ID_Usuario As Varchar(6))
    end
    return @Alias
end
