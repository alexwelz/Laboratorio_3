--Nombre base: WelzAlexGustavo.sql
--Legajo: 24583
--Alumno: Alex Gustavo Welz

CREATE DATABASE Punto1_Exam_Practica
GO 
USE Punto1_Exam_Practica
GO
CREATE TABLE Carreras(
	IDCarrera BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(100) NOT NULL
)
GO
CREATE TABLE Materias(
	IDMateria BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDCarrera BIGINT NOT NULL FOREIGN KEY REFERENCES Carreras(IDCarrera),
	Nombre VARCHAR(100) NOT NULL,
	Año SMALLINT NOT NULL CHECK (Año >0),
	Cuatrimestre TINYINT NULL
)
GO
CREATE TABLE Alumnos(
	Legajo BIGINT NOT NULL PRIMARY KEY,
	Apellidos VARCHAR(100) NOT NULL,
	Nombres VARCHAR(100) NOT NULL,

)
GO
CREATE TABLE Examenes(
	IDExamen BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDMateria BIGINT NOT NULL FOREIGN KEY REFERENCES Materias(IDMateria),
	Legajo BIGINT NOT NULL FOREIGN KEY REFERENCES Alumnos(Legajo),
	Fecha DATE NOT NULL,
	Nota DECIMAL(4,2) NOT NULL CHECK(Nota BETWEEN 0.00 AND 10.00)
)
GO
CREATE TABLE Sanciones(
	IDSancion BIGINT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Legajo BIGINT NOT NULL FOREIGN KEY REFERENCES Alumnos(Legajo),
	Fecha DATE NOT NULL,
	Observaciones VARCHAR(500) NOT NULL
)

GO
/* 2)
Listar los mejores 5 estudiantes entre las carreras "Tecnicatura en Programación" e
"Ingeniería Mecánica" para otorgarles una beca. Para seleccionarlos a la beca, el
criterio de aceptación es el promedio general de los últimos dos años (es decir, el
año actual y el anterior) y no haber registrado nunca una sanción
*/

SELECT DISTINCT TOP(5) A.Legajo, A.Apellidos, A.Nombres, 
		(
			Select AVG(E.Nota) FROM Examenes E
			WHERE E.Legajo = A.Legajo
			AND YEAR(E.Fecha) BETWEEN YEAR(GETDATE())-1 AND YEAR(GETDATE())
		)AS PromedioGral
FROM Alumnos A
Left Join Sanciones S On S.Legajo = A.Legajo
Inner join Examenes E ON E.Legajo = A.Legajo
INner join Materias M ON M.IDMateria = E.IDMateria
Inner join Carreras C ON C.IDCarrera = M.IDCarrera
WHERE C.Nombre IN ('Tecnicatura en Programación','Ingeniería Mecánica')
AND A.Legajo NOT IN (SELECT Legajo FROM Sanciones )
GROUP BY A.Legajo, A.Apellidos, A.Nombres
ORDER BY PromedioGral DESC
GO
/* 3)
Realizar un listado con legajo, nombre y apellidos de alumnos que no hayan
registrado aplazos (nota menor a 6) en ningún examen. El listado también debe
indicar la cantidad de sanciones que el alumno registra
*/
SELECT A.Legajo, A.Apellidos, A.Nombres, COUNT(S.IDSancion) As 'Cantidad Sanciones'
FROM Alumnos A
LEFT JOIN Sanciones S ON S.Legajo = A.Legajo
INNER JOIN Examenes E ON E.Legajo = A.Legajo
Where E.Nota >=6 And E.Legajo = A.Legajo
GROUP BY A.Legajo, A.Apellidos, A.Nombres, E.Nota
HAVING COUNT(S.IDSancion) >= 6

GO
/* 4
 Hacer un listado con nombre de carrera, nombre de materia y año de aquellas
materias que tengan un promedio general mayor a 8. No se deben promediar los
aplazos.
*/
SELECT C.Nombre AS Carrera, M.Nombre AS Materia, YEAR(M.Año) AS Año
FROM Carreras C
INNER JOIN Materias M ON M.IDCarrera = C.IDCarrera
WHERE M.IDMateria IN (
    SELECT E.IDMateria FROM Examenes E
    GROUP BY E.IDMateria
    HAVING AVG(E.Nota) > 8 
)
GO
/* 5)
Realizar un trigger que permita modificar el tipo de cuenta de un usuario si la
capacidad de la cuenta del usuario es superada cuando este sube un archivo. En ese
caso, debe modificar su tipo de cuenta a la siguiente disponible y registrar el cambio
con su respectiva fecha en la tabla de CambiosDeCuenta. En cualquier caso se debe
registrar el archivo al usuario.
*/
CREATE TRIGGER TR_SubirArchivo ON Archivos
AFTER INSERT

AS
BEGIN
    BEGIN TRY   
        BEGIN TRANSACTION 

        DECLARE @IDUsario Bigint
		DECLARE @TamañoArchivo int
		DECLARE @IDCuentaActual bigint 
		DECLARE @CapacidadActualArchivo int
		DECLARE @NombreCuenta varchar(50)

		SELECT @IDUsario = IDUsuario, @TamañoArchivo = TamañoEnMB FROM inserted i

		SELECT @IDCuentaActual = U.IDTipoCuenta, @CapacidadActualArchivo = TC.CapacidadEnMB,
		@NombreCuenta = TC.Nombre
		FROM Usuarios U
		INNER JOIN TipoCuentas TC ON TC.IDTipoCuenta = U.IDTipoCuenta
		Where U.IDUsuarios = @IDUsario
       
		IF @TamañoArchivo > @CapacidadActualArchivo AND @NombreCuenta <> 'Ilimitada'
		BEGIN 

		UPDATE Usuarios SET IDTipoCuenta = @IDCuentaActual + 1 WHERE IDUsuarios = @IDUsario

		INSERT INTO CambiosDeCuenta (IDUsuario, IDTipoCuentaAnterior, IDTipoCuentaActual, Fecha)
		VALUES(@IDUsario,@IDCuentaActual , @IDCuentaActual + 1, GETDATE())
		
		END
		COMMIT TRANSACTION 
    END TRY
    BEGIN CATCH
      ROLLBACK TRANSACTION 
        RAISERROR('Error al generar el trigger', 16, 1)
    END CATCH

END
