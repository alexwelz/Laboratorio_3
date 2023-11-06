

--VISTAS

CREATE VIEW VW_NOMBREVISTA 

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
    BEGIN TRY    --> Todo lo que esta dentro del bloque try podria pasar
        BEGIN TRAN -- BEGIN TRANSACTION (es lo mismo)

        DECLARE @VARIABLE --TIPO DATO (BIGINT-SMALLINT-BIT....)
        SET @ID = (Select ID From inserted) --inserted, deleted --> son tablas temporales
        SET @ID = (Select ID From deleted)
        
       --CONSULTAS 
	
		COMMIT --COMMIT TRANSACTION (es lo mismo)
    END TRY
    BEGIN CATCH
       ROLLBACK --ROLLBACK TRANSACTION (es lo mismo)
        RAISERROR('Muestra el mensaje de error en pantalla', 16, 1)
		
		--OTRA FORMA MOSTRAR ERROR
		 --END
        --PRINT error_message()
    END CATCH

END
GO


-----------------------------------------------------------


--FUNCIONES -->  EJEMPLO RESOLUCION

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
