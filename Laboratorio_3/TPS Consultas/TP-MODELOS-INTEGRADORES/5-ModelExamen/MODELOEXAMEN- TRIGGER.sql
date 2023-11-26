--EXAMEN INTEGRADOR (MODELO)

--1) Hacer un procedimiento almacenado llamado SP_Ranking que a partir de un IDParticipante 
--se pueda obtener las tres mejores fotografías publicadas (si las hay). 
--Indicando el nombre del concurso, apellido y nombres del participante, 
--el título de la publicación, la fecha de publicación y 
--el puntaje promedio obtenido por esa publicación.
--(20 puntos)


ALTER PROCEDURE SP_Ranking
(@IDParticipante int) 
AS
BEGIN
	Select top 3 
		C.Titulo AS Concurso,
		P.Apellidos +' '+ P.Nombres AS Participantes,
		F.Titulo AS 'Titulo Fotografia',
		F.Publicacion As 'Fecha Publicacion', 
		AVG(V.Puntaje) AS 'Promedio Puntaje'
	from Concursos C inner join Fotografias F on F.IDConcurso = C.ID  
	inner join Votaciones V on V.IDFotografia = F.ID
	inner join Participantes P on P.ID = f.IDParticipante
	where f.IDParticipante = @IDParticipante
	group by
		C.Titulo,
		P.Apellidos +' '+ P.Nombres,
		F.Titulo,
		F.Publicacion
	order by AVG(V.Puntaje) DESC,F.Publicacion DESC
        
END



--2) Hacer un procedimiento almacenado llamado SP_Descalificar que reciba 
--un ID de fotografía y realice la descalificación de la misma. 
--También debe eliminar todas las votaciones registradas a la fotografía en cuestión. 
--Sólo se puede descalificar una fotografía si pertenece a un concurso no finalizado.
--(20 puntos)


CREATE PROCEDURE SP_Descalificar(@IDFotografia int) AS
BEGIN
	DECLARE @FIN DATE
	BEGIN TRY
		BEGIN TRANSACTION
			SELECT @FIN = C.Fin 
			From Fotografias F 
			inner join Concursos C on  c.ID = F.IDConcurso 
			where F.ID=@ID
			
			IF @FIN >= GETDATE()
			BEGIN
				UPDATE Fotografias SET Descalificada = 1 where ID = @IDFotografia
				DELETE FROM Votaciones WHERE IDFotografia = @IDFotografia
			END
			ELSE BEGIN
				RAISERROR('No se puede descalificar, Concurso Finalizado',16,1)
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END


--3) Al insertar una fotografía verificar que el usuario creador de la fotografía 
--tenga el ranking suficiente para participar en el concurso. 
--También se debe verificar que el concurso haya iniciado y no finalizado. 
--Si ocurriese un error, mostrarlo con un mensaje aclaratorio.
--De lo contrario, insertar el registro teniendo en cuenta que la 
--fecha de publicación es la fecha y hora del sistema.

--(30 puntos)


CREATE TRIGGER tr_NuevaFoto ON Fotografias INSTEAD OF INSERT 
AS
BEGIN
	DECLARE @Promedio decimal(5,2)
	DECLARE @PromedioMin decimal(5,2)
	DECLARE @InicioConcurso date
	DECLARE @FinalConcurso date

	DECLARE @IDParticipante int
	DECLARE @IDConcurso int
	DECLARE @Titulo varchar(150)
	DECLARE @Publicacion date

	SELECT @IDParticipante = IDParticipante from inserted
	BEGIN TRY
		BEGIN TRANSACTION
			SELECT @Promedio = ISNULL(avg(Puntaje),0) FROM Fotografias F 
			inner join Votaciones V on F.ID = V.IDFotografia 
			WHERE F.IDParticipante = @IDParticipante

			SELECT @InicioConcurso = C.Inicio FROM Concursos C 
			where C.ID = (Select IDConcurso from inserted)

			SELECT @FinalConcurso = C.Inicio FROM Concursos C 
			where C.ID = (Select IDConcurso from inserted)


			IF(GETDATE() BETWEEN @InicioConcurso AND @FinalConcurso)
			BEGIN
				SELECT @PromedioMin = C.RankingMinimo FROM Concursos C
				where C.ID = (SELECT IDConcurso FROM inserted)
				
				IF(@Promedio >= @PromedioMin)
				BEGIN
					SELECT @IDConcurso = IDConcurso, @Titulo = Titulo, @Publicacion = Publicacion
					from inserted
			
					INSERT INTO Fotografias(IDParticipante,IDConcurso,Titulo,Publicacion)
					VALUES (@IDParticipante,@IDConcurso,@Titulo,@Publicacion)
				END
				ELSE
				BEGIN
					RAISERROR('No cumple con el promedio minimo del concurso',16,1)
				END
			END
			ELSE
			BEGIN
				RAISERROR('Concurso no está en curso actualmente',16,1)
			END
			
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END


--4) Al insertar una votación, verificar que el usuario que vota no lo haga más 
--de una vez para el mismo concurso ni se pueda votar a sí mismo. 
--Tampoco puede votar una fotografía descalificada. 
--Si ninguna validación lo impide insertar el registro de lo contrario, 
--informarlo con un mensaje de error.
--(20 puntos)

CREATE TRIGGER tr_VotacionNueva ON Votaciones
INSTEAD OF INSERT AS
BEGIN
	DECLARE @IDVotante int
	DECLARE @IDFotografia int
	DECLARE @Fecha date
	DECLARE @Puntaje decimal(5,2)

	SELECT @IDVotante = IDVotante FROM inserted
	SELECT @IDFotografia = IDFotografia FROM inserted
	SELECT @Fecha = Fecha FROM inserted
	SELECT @Puntaje = Puntaje FROM inserted

	BEGIN TRY
		BEGIN TRANSACTION
			SELECT count(*) FROM Votaciones V inner join Fotografias F
			on V.IDFotografia = F.ID INNER JOIN Concursos C
			on C.ID=F.IDConcurso where F.IDParticipante = 1
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END


--5) Hacer un listado en el que se obtenga: ID de participante, 
--apellidos y nombres de los participantes que hayan registrado
--al menos dos fotografías descalificadas.
--(10 puntos)







