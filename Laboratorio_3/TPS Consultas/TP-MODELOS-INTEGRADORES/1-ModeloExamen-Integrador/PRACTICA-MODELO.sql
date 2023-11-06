--1)
/*
Se pide agregar una modificación a la base de datos para que permita registrar la calificación (de 1 a 10) que el Cliente le 
otorga al Chofer en un viaje y además una observación opcional. Lo mismo debe poder registrar el Chofer del Cliente.
Importante:
No se puede modificar la estructura de la tabla de Viajes.
Sólo se puede realizar una calificación por viaje del Cliente al Chofer.
Sólo se puede realizar una calificación por viaje del Chofer al Cliente.
Puede haber viajes que no registren calificación por parte del Chofer o del Cliente.

*/
CREATE TABLE Calificaciones
(
	IDViajes BIGINT Primary key not null foreign key references Viajes(ID),
	CalificacionChofer TINYINT not null check (CalificacionChofer between 1 and 10),
	ObservacionChofer text null,
	CalificacionCliente tinyint not null check(CalificacionCliente between 1 and 10),
	ObservacionCliente text null

)
GO

--2)
/*
Realizar una vista llamada VW_ClientesDeudores que permita listar: Apellidos, Nombres, Contacto (indica el email 
de contacto,si no lo tiene el teléfono y de lo contrario "Sin datos de contacto"),
 cantidad de viajes totales, cantidad de viajes no abonados y total adeudado. Sólo listar aquellos 
 clientes cuya cantidad de viajes no abonados sea superior a la mitad de 
viajes totales realizados.
*/
CREATE VIEW VW_ClientesDeudores
AS
SELECT P2.* FROM (

	SELECT  C.Apellidos, C.Nombres, COALESCE(C.Email, C.Telefono, 'Sin datos de contacto') AS Contacto,
	COUNT(*) AS CantidadViajes,
	(
		SELECT COUNT(*)FROM Viajes V WHERE V.IDCliente = C.ID AND Pagado = 0
	
	)AS CantViajesNoAbonados,
	(
		SELECT SUM(Importe) FROM Viajes V WHERE V.IDCliente = C.ID and Pagado = 0

	)AS TotalAdeudado

	FROM Clientes C
	INNER JOIN Viajes V ON V.ID = C.ID
	GROUP BY C.ID,C.Apellidos, C.Nombres, COALESCE(C.Email, C.Telefono, 'Sin datos de contacto') 
)AS P2
WHERE P2.CantViajesNoAbonados > P2.CantidadViajes/2  AND P2.TotalAdeudado > 0
GO
--3)
/*
Realizar un procedimiento almacenado llamado SP_ChoferesEfectivo que reciba un (año como parámetro) y permita listar apellidos
y nombres de los choferes que en ese año (únicamente) realizaron viajes que fueron abonados con la forma de pago 'Efectivo'.

NOTA: Es indistinto si el viaje fue pagado o no. Utilizar la fecha de inicio del viaje para determinar el año del mismo.

*/


CREATE PROCEDURE SP_ChoferesEfectivo (
	@ANIO SMALLINT
)
AS
BEGIN

	SELECT DISTINCT P3.AÑO, P3.Apellidos, P3.Nombres FROM (
		SELECT YEAR(V.Inicio) AS AÑO, C.Apellidos, C.Nombres,
		(
			SELECT COUNT(*) FROM Viajes V WHERE V.IDChofer = C.ID  AND YEAR(V.Inicio) = @ANIO
			
		)AS ViajesXAño,
		(
			SELECT COUNT(*) FROM Viajes V
			INNER JOIN FormasPago FP ON FP.ID = V.FormaPago
			WHERE V.IDChofer = C.ID AND FP.ID = 1  AND YEAR(V.Inicio) = @ANIO

		)AS ViajesEfectivo 

		FROM Choferes C
		INNER JOIN Viajes V ON V.IDChofer = C.ID
	)AS P3
	WHERE P3.ViajesEfectivo > 0 AND P3.AÑO = @ANIO  AND P3.ViajesEfectivo = P3.ViajesXAño

END
GO
--4)
/*
Realizar un trigger que al borrar un cliente, primero le quite todos los puntos (baja física) y 
establecer a NULL todos los viajes de ese cliente. Luego, eliminar físicamente el cliente de la
base de datos.
*/

SELECT * FROM Puntos -- tabla vacia
--Solucion:
-----------------------Ejecutamos---------------------------------------------------
INSERT INTO Puntos
SELECT ID, NULL, GETDATE(),100, DATEADD(DAY, 10, GETDATE()) FROM Clientes
--------------------------Ejecutamos------------------------------------------------
INSERT INTO Puntos
SELECT ID, NULL, GETDATE(),100, DATEADD(DAY, 10, GETDATE()) FROM Clientes
WHERE ID <=100
------------------------------------------------------------------------------------

Create trigger TR_BorrarClientes ON Clientes
INstead OF DElete

AS 
BEGIN
	BEGIN TRY
		BEGIN TRAN
			--1.primero le quite todos los puntos (baja física) 
			DELETE FROM Puntos WHERE IDCliente = (SELECT ID FROM deleted)
			--2.establecer a NULL todos los viajes de ese cliente
			UPDATE Viajes SET IDCliente = NULL WHERE IDCliente = (SELECT ID FROM deleted) 
			--3.eliminar físicamente el cliente de la base de datos.
			DELETE FROM Clientes WHERE ID = (SELECT ID FROM deleted)
		COMMIT 
	END TRY
	BEGIN CATCH
		Rollback 
		RAISERROR ('Hubo un error al borrar el cliente ', 16,1)
	END CATCH
END

--DELETE FROM Clientes WHERE ID = 5
--SELECT * FROM  Clientes where ID=5
--SELECT * FROM Puntos WHEre IDCliente =5
--SELECT * FROM  Viajes where ID=1219 
GO
--5)
/*Realizar un trigger que garantice que el Cliente sólo pueda calificar al Chofer si el viaje se encuentra pagado.
Caso contrario indicarlo con un mensaje aclaratorio.
*/


CREATE TRIGGER TR_CalificacionAlChofer ON Calificaciones
AFTER INSERT
AS
BEGIN
	BEGIN Transaction 
		DECLARE @IDViaje BIGINT 
		DECLARE @Pagado BIT 
	
		 SET @IDViaje = (SELECT IDViajes FROM inserted)
		 SET @Pagado = (SELECT Pagado FROM Viajes WHERE ID = @IDViaje)

		IF @Pagado = 0 
		BEGIN
			Rollback transaction 
			Raiserror ('Hubo un erorr al verificar la calificacion ', 16,1)
		END 
	
	Commit transaction
END




