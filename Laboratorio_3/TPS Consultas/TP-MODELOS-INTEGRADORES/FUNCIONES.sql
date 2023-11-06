

--EJEMPLOS DE EJERCICIOS CON FUNCIONES


/*
Crear una función que a partir de un ID de Usuario devuelva un alias de billetera.
Si el usuario ya dispone de una billetera, la función debe devolver el actual alias de
billetera de lo contrario deberá devolver un alias con el siguiente formato:
APELLIDO.NOMBRE.IDUSUARIO
*/

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



--4)
/*
Hacer una función SQL que a partir de un legajo docente y un año devuelva la cantidad de horas semanales que dedicará esa 
persona a la docencia ese año. La cantidad de horas es un número entero >= 0.

NOTA: No hace falta multiplicarlo por la cantidad de semanas que hay en un año.

*/

CREATE FUNCTION CantidadHorasSemanales(
@Legajo bigint,
@Año int
)

RETURNS INT
AS 
BEGIN
	DECLARE @HorasSemanales TINYINT

	SELECT @HorasSemanales = SUM(HorasSemanales) FROM Materias M
	INNER JOIN PlantaDocente PD ON PD.ID_Materia = M.ID_Materia
	INNER JOIN Docentes D ON PD.Legajo = D.Legajo
	WHERE @Año = PD.Año AND PD.Legajo = @Legajo

	IF @HorasSemanales < 0 BEGIN
		--PRINT ('No puede tener horas semanales negativas')
		SET @HorasSemanales = NULL
	END
	  RETURN @HorasSemanales
END
--Verificar:
SELECT dbo.CantidadHorasSemanales(4,2021)
