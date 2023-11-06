

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
    BEGIN TRY
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
