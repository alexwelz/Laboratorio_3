
/*1) Realizar el código SQL que genere la base de datos con sus tablas y columnas.
Agregar todas las restricciones necesarias.*/


CREATE DATABASE Punto1_ResolucionAfterExamen
GO
USE Punto1_ResolucionAfterExamen
GO
CREATE TABLE Carreras(
   IDCarrera INT NOT NULL PRIMARY KEY IDENTITY(1,1),
   Nombre VARCHAR(100) NOT NULL
)
GO
CREATE TABLE Materias(
   IDMateria bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
   IDCarrera INT NOT NULL FOREIGN KEY REFERENCES Carreras(IDCarrera),
   Nombre VARCHAR(100) NOT NULL,
   Anio SMALLINT NOT NULL CHECK(Anio>0),
   Cuatrimestre SMALLINT 

)
GO
CREATE TABLE Alumnos(
    Legajo BIGINT NOT NULL PRIMARY KEY,
    Apellido VARCHAR(100) NOT NULL,
    Nombres VARCHAR(100) NOT NULL
)
GO
CREATE TABLE Examenes(
   IDExamen bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
   IDMateria BIGINT NOT NULL FOREIGN KEY REFERENCES Materias(IDMateria),
   Legajo BIGINT NOT NULL FOREIGN KEY REFERENCES Alumnos(Legajo),
   Fecha Datetime  NOT NULL,
   Nota DECIMAL(4,2) NOT NULL CHECK(Nota BETWEEN 0.00 and 10.00),
)
GO
CREATE TABLE Sanciones(
    IDSancion int NOT NULL PRIMARY KEY IDENTITY(1,1),
    Legajo BIGINT NOT NULL FOREIGN KEY REFERENCES Alumnos(Legajo),
    Fecha Datetime  NOT NULL,
    Observacion VARCHAR(500)
)

/*2) Listar los mejores 5 estudiantes entre las carreras "Tecnicatura en Programación" e
"Ingeniería Mecánica" para otorgarles una beca. Para seleccionarlos a la beca, el
criterio de aceptación es el promedio general de los últimos dos años (es decir, el
año actual y el anterior) y no haber registrado nunca una sanción.*/

SELECT TOP(5) A.Legajo, A.Apellido, A.Nombres, AVG(E.Nota) AS PromedioGeneral
FROM Alumnos A 
LEFT JOIN Examenes E ON A.Legajo = E.Legajo
INNER JOIN Materias M ON E.IDMateria = M.IDMateria
INNER JOIN Carreras C ON M.IDCarrera = C.IDCarrera
WHERE 
C.Nombre IN('Tecnicatura en Programación','Ingeniería Mecánica') 
AND
A.Legajo NOT IN(SELECT S.Legajo FROM Sanciones S)
AND (YEAR(E.Fecha) BETWEEN YEAR(GETDATE())-1 AND GETDATE()) 
AND  A.Legajo = E.Legajo
GROUP BY A.Legajo, A.Apellido, A.Nombres
ORDER BY PromedioGeneral DESC


/*Realizar un listado con legajo, nombre y apellidos de alumnos que no hayan
registrado aplazos (nota menor a 6) en ningún examen. El listado también debe
indicar la cantidad de sanciones que el alumno registra.*/




SELECT A.Legajo,
	   A.Apellido,
	   A.Nombres, 
	   (
			 SELECT COUNT(S.IDSancion) from Sanciones S
			 Where A.Legajo = S.Legajo
		)AS Sanciones
FROM Alumnos A
WHERE A.Legajo NOT IN (SELECT E.Legajo From Examenes E Where E.Nota < 6 )
GROUP BY A.Legajo, A.Apellido, A.Nombres



SELECT A.Legajo, A.Apellido, A.Nombres, 
COUNT(S.IDSancion) 
AS 'Sanciones'
FROM Alumnos A
INNER JOIN Sanciones S ON A.Legajo = S.Legajo
WHERE 
A.Legajo NOT IN(SELECT E.Legajo FROM Examenes E WHERE E.Nota<=6 AND A.Legajo = E.Legajo)
AND 
S.Legajo = A.Legajo
GROUP BY A.Legajo, A.Apellido, A.Nombres

/*4) Hacer un listado con nombre de carrera, nombre de materia y año de aquellas
materias que tengan un promedio general mayor a 8. No se deben promediar los
aplazos.*/

SELECT C.Nombre AS Carrera,
       M.Nombre AS Materia,
       M.Anio,
       AVG(E.Nota) AS PromedioGral
FROM Alumnos A
INNER JOIN Examenes E ON E.Legajo = A.Legajo
INNER JOIN Materias M ON M.IDMateria = E.IDMateria
INNER JOIN Carreras C ON C.IDCarrera = M.IDCarrera
WHERE E.Nota >= 6 
GROUP BY C.Nombre, M.Nombre, M.Anio
HAVING AVG(E.Nota) > 8


SELECT C.Nombre, M.Nombre, M.Anio, AVG(E.Nota) AS PromedioGeneral
FROM Materias M
INNER JOIN Carreras C ON M.IDCarrera = C.IDCarrera
LEFT JOIN Examenes E ON M.IDMateria = E.IDMateria
WHERE 
E.Nota>6 AND E.IDMateria = M.IDMateria
GROUP BY C.Nombre, M.Nombre, M.Anio
HAVING AVG(E.Nota)>8


/*Realizar un trigger que permita modificar el tipo de cuenta de un usuario si la
capacidad de la cuenta del usuario es superada cuando este sube un archivo. En ese
caso, debe modificar su tipo de cuenta a la siguiente disponible y registrar el cambio
con su respectiva fecha en la tabla de CambiosDeCuenta. En cualquier caso se debe
registrar el archivo al usuario.
Aclaraciones:
- Cuando un usuario debe hacer un "upgrade" de su cuenta, la nueva cuenta
que se le otorgará siempre será la que está identificada por su IDTipoCuenta
actual más 1.
- El tipo de cuenta "Ilimitada" no puede ser nunca superada. Los MBs son
ilimitados.*/

CREATE TRIGGER TR_AgregarArchivo ON Archivos
AFTER INSERT 
AS
BEGIN 
    BEGIN TRY
        BEGIN TRANSACTION 

        DECLARE @TamañoArchivo INT
        DECLARE @IDUsuario BIGINT
        DECLARE @IDTipoCuentaActual BIGINT
        --DECLARE @NuevaIDTipoCuenta BIGINT

        SELECT @TamañoArchivo = TamañoEnMB, @IDUsuario = IDUsuario
        FROM inserted

        SELECT @IDTipoCuentaActual = U.IDTipoCuenta
        FROM Usuarios U
        WHERE U.IDUsuarios = @IDUsuario

        IF @IDTipoCuentaActual <> (SELECT IDTipoCuenta FROM TipoCuentas WHERE Nombre = 'Ilimitada')
        BEGIN
			IF @TamañoArchivo > (SELECT CapacidadEnMB FROM TipoCuentas WHERE IDTipoCuenta = @IDTipoCuentaActual)
			BEGIN
                --SET @NuevaIDTipoCuenta = @IDTipoCuentaActual + 1

                UPDATE Usuarios SET IDTipoCuenta = @IDTipoCuentaActual + 1 WHERE IDUsuarios = @IDUsuario

                INSERT INTO CambiosDeCuenta (IDUsuario, IDTipoCuentaAnterior, IDTipoCuentaActual, Fecha)
                VALUES (@IDUsuario, @IDTipoCuentaActual, @IDTipoCuentaActual + 1, GETDATE())
            END
        END

        COMMIT TRANSACTION 
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION 
        RAISEERROR('Error al ejecutar', 16, 1)
    END CATCH
END
GO








CREATE TRIGGER TR_InsertarArchivo ON Archivos
AFTER INSERT
AS
BEGIN
   BEGIN TRY
      DECLARE @CapacidadDisponible int
      DECLARE @CapacidadOcupada int
      DECLARE @TamañoDeArchivo int
      DECLARE @NombreTC varchar(50)
      DECLARE @IDUsuario bigint
      DECLARE @TipoCuenta bigint
     -- DECLARE @

      SELECT @TamañoDeArchivo = TamañoEnMB, @IDUsuario = IDUsuario FROM inserted
      
      -- Obtengo capacidad almacenada
      SELECT @CapacidadOcupada = SUM(A.TamañoEnMB)  
      FROM Archivos A
      WHERE A.IdUsuario = @IDUsuario

      -- Obtengo capacidad disponible
      SELECT @CapacidadDisponible = TC.CapacidadEnMB - @CapacidadOcupada,@NombreTC=TC.Nombre,@TipoCuenta = TC.IDTipoCuenta
      FROM Usuarios U
      LEFT JOIN TiposCuentas TC ON U.IDTipoCuenta = TC.IDTipoCuenta
      WHERE U.IdUsuario = @IDUsuario

      BEGIN TRANSACTION
      IF @CapacidadDisponible - @TamañoDeArchivo < 0 AND @NombreTC <> 'Ilimitada'
      BEGIN
      
      -- Actualizo tipo de cuenta e inserto el cambio
      INSERT INTO CambiosDeCuenta(IDUsuario,IDTipoCuentaActual,IDTipoCuentaAnterior,Fecha)
      VALUES(@IDUsuario,@TipoCuenta +1,@TipoCuenta,GETDATE())

      -- Actualizo Usuario
      UPDATE Usuarios SET IDTipoCuenta = @TipoCuenta + 1
      WHERE IDUsuario = @IDUsuario
      PRINT('INSERT + upgrade EXITOSO ')
      END
      COMMIT TRANSACTION
   END TRY
   BEGIN CATCH
     ROLLBACK TRANSACTION
     RAISERROR('ERROR, No se pudo insertar el archivo',16,1)
   END CATCH
END
