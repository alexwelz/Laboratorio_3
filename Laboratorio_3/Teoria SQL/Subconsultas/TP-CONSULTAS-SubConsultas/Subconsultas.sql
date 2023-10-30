--1 Apellidos y nombres, alias, fecha de creación y saldo de aquellas cuentas que
--tengan un saldo mayor al saldo promedio.

SELECT * FROM Billeteras WHERE Saldo > (SELECT AVG(Saldo) FROM Billeteras)


--Se optimiza con una sola variable 
DECLARE @SaldoPromedio money
SET @SaldoPromedio = (SELECT AVG(Saldo) FROM Billeteras)
SELECT * FROM Billeteras WHERE Saldo > @SaldoPromedio


SELECT CONCAT(U.Apellidos, ' ',U.Nombres) AS Usuarios, B.Alias, B.FechaCreacion, B.Saldo
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
WHERE B.Saldo > (SELECT AVG(Saldo) FROM Billeteras)

--2 Marca de las tarjetas y límite de compras de aquellas tarjetas que tengan un límite
--mayor al de cualquier tarjeta del 'Banco Santander Rio'
------------------------------------------------------
--script que agrega limite para la tabla de tarjetas 
--ALTER TABLE Tarjetas 
--ADD Limite money not null default(0)

--Inventar limites para cada tarjeta
--UPDATE Tarjetas SET Limite = ID_Tarjeta * 100000
-----------------------------------------------------

SELECT MT.Marca, T.Limite AS 'Limite Compra'
FROM Tarjetas T
INNER JOIN MarcasTarjeta MT ON MT.ID_MarcaTarjeta = T.ID_MarcaTarjeta 
INNER JOIN Bancos B ON B.ID_Banco = T.ID_Banco
WHERE B.ID_Banco != 2 AND T.Limite > (SELECT MAX(Limite) FROM Tarjetas WHERE ID_Banco = 2)

--Revision
SELECT MAX(Limite) FROM Tarjetas Where ID_Banco =2-- 1.300.000.00


--3 Marca de las tarjetas y límite de compras de aquellas tarjetas que tengan un límite
--mayor al de alguna tarjeta del 'Banco HSBC'
SELECT MT.Marca, T.Limite AS 'Limite Compra'
FROM Tarjetas T
INNER JOIN MarcasTarjeta MT ON MT.ID_MarcaTarjeta = T.ID_MarcaTarjeta 
INNER JOIN Bancos B ON B.ID_Banco = T.ID_Banco
WHERE B.ID_Banco != 7 AND T.Limite > (SELECT MAX(Limite) FROM Tarjetas WHERE ID_Banco = 7)

--Revision
SELECT * FROM Bancos where Nombre like '%HSBC%'
SELECT MAX(Limite) FROM Tarjetas Where ID_Banco =7-- 1.700.000.00 HSBC es la que mayor limite tiene 



--4 Los apellidos y nombres y alias de las billeteras que no hayan registrado
--movimientos en la segunda quincena de Agosto de 2023.
SELECT CONCAT(U.Apellidos, ' ', U.Nombres) AS Usuarios, B.Alias
FROM Usuarios U 
JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
WHERE B.ID_Billetera NOT IN (
    SELECT DISTINCT M.ID_Billetera
    FROM Movimientos M
    WHERE M.FechaHora BETWEEN '2023-08-15 00:00:00.000' AND '2023-08-31 23:59:59.999'
)



--5 Los apellidos y nombres de clientes que no tengan registrada ninguna tarjeta de la
--marca 'Zelev''
SELECT CONCAT(U.Apellidos, ' ', U.Nombres) AS Usuarios,      T.ID_MarcaTarjeta, MT.Marca--Revision
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
INNER JOIN MarcasTarjeta MT ON MT.ID_MarcaTarjeta = T.ID_MarcaTarjeta
WHERE T.ID_MarcaTarjeta NOT IN (
	SELECT MT.ID_MarcaTarjeta FROM MarcasTarjeta MT
	WHERE MT.ID_MarcaTarjeta = 9
)


--6 Los nombres de bancos que no hayan entregado tarjetas a ningún cliente con nivel
--de situación crediticia Mala, Muy Mala o No Confiable.
SELECT Ba.Nombre,     NSC.SituacionCrediticia --Revision
FROM Usuarios U 
INNER JOIN NivelesSituacionCrediticia NSC ON NSC.ID_NivelSituacionCrediticia = U.ID_SituacionCrediticia
INNER JOIN Billeteras Bi ON Bi.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera  = Bi.ID_Billetera
INNER JOIN Bancos Ba ON Ba.ID_Banco = T.ID_Banco
WHERE NSC.ID_NivelSituacionCrediticia NOT IN(
	SELECT ID_NivelSituacionCrediticia FROM NivelesSituacionCrediticia 
	WHERE ID_NivelSituacionCrediticia in (5,6,7)
)


--7 Por cada marca de tarjeta listar el nombre, la cantidad de clientes con situación
--crediticia favorable (de Excelente a Buena) y situación crediticia desfavorable (de
--Regular a No Confiable)

SELECT MT.Marca,
(
	SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
	INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
	INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
	INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
	WHERE NSC.SituacionCrediticia in ('Exelente', 'Muy Buena', 'Buena') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta

) AS CantUsuariosCreditoFavorable,
(
	SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
	INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
	INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
	INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
	WHERE NSC.SituacionCrediticia in ('Regular', 'Mala', 'Muy Mala', 'No confiable') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta

) AS CantUsuariosCreditoDesfavorable
FROM MarcasTarjeta MT

SELECT * FROM NivelesSituacionCrediticia


--7.2 Por cada marca de tarjeta listar el nombre, la cantidad de clientes con situación
--crediticia favorable (de Excelente a Buena) y situación crediticia desfavorable (de
--Regular a No Confiable) de aquellas marcas que tengan mas clientes con situacion crediticia favorable que desfavorable
SELECT Aux.*
FROM(
		SELECT MT.Marca,
		(
			SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
			INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
			INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
			INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
			WHERE NSC.SituacionCrediticia in ('Exelente', 'Muy Buena', 'Buena') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta

		) AS CantUsuariosCreditoFavorable,
		(
			SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
			INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
			INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
			INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
			WHERE NSC.SituacionCrediticia in ('Regular', 'Mala', 'Muy Mala', 'No confiable') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta

		) AS CantUsuariosCreditoDesfavorable
		FROM MarcasTarjeta MT
	)AS Aux
WHERE Aux.CantUsuariosCreditoFavorable > Aux.CantUsuariosCreditoDesfavorable


--8
--Por cada billetera, listar el alias y la cantidad total de dinero operado en el mes de agosto de 2023 y la 
--cantidad total de dinero operado en el mes de septiembre de 2023. Si no registró movimientos debe totalizar 0.
SELECT B.Alias,
	ISNULL(
		(
			SELECT SUM(M.Importe)
			FROM Movimientos M
			WHERE M.ID_Billetera = B.ID_Billetera 
			AND	M.FechaHora BETWEEN '2023-08-01 00:00:00.000' AND '2023-08-31 23:59:59.999'
		)
		,0) AS TotalAgosto,
	ISNULL(
		(
			SELECT SUM(M.Importe) FROM Movimientos M
			WHERE M.ID_Billetera = B.ID_Billetera
			AND M.FechaHora BETWEEN '2023-09-01 00:00:00.000' AND '2023-09-30 23:59:59.999'
		)
		,0) AS TotalDineroSeptiembre

FROM Billeteras B


--9   
--El banco decidió cobrar en el mes de Agosto el monto de $50 a cada movimiento de débito realizado 
--en un fin de semana y $10 a los movimientos de crédito realizados. Listar para cada billetera, el alias y la 
--cantidad a abonar por este disparatado recargo. Si no registra recargos debe totalizar 0.

--NOTA: Sólo aplica a los movimientos registrados en el mes de Agosto de 2023.    
SELECT B.Alias, 
       (
           CASE 
               WHEN M.TipoMovimiento = 'D' AND DATEPART(WEEKDAY, M.FechaHora) IN (1, 7) THEN 50  -- Sábado (7) y Domingo (1)
               WHEN M.TipoMovimiento = 'C' THEN 10
               ELSE 0
           END
		   
       ) AS CantidadAbonar
FROM Billeteras B
INNER JOIN Movimientos M ON B.ID_Billetera = M.ID_Billetera
WHERE M.FechaHora >= '2023-08-01' AND M.FechaHora < '2023-09-01'
ORDER BY M.FechaHora asc


--10 
--El total acumulado en concepto de recargo (ver Punto 9)     
SELECT B.Alias, 
       SUM(
           CASE 
               WHEN M.TipoMovimiento = 'D' AND DATEPART(WEEKDAY, M.FechaHora) IN (1, 7) THEN 50  -- Sábado (7) y Domingo (1)
               WHEN M.TipoMovimiento = 'C' THEN 10
               ELSE 0
           END
		   
       ) AS Recargo
FROM Billeteras B
INNER JOIN Movimientos M ON B.ID_Billetera = M.ID_Billetera
WHERE M.FechaHora >= '2023-08-01' AND M.FechaHora < '2023-09-01'
GROUP BY B.Alias


--11 Las marcas de tarjeta que hayan otorgado igual cantidad de tarjetas a clientes con
--situación crediticia favorable que a clientes con situación crediticia desfavorable.
SELECT MT.Marca
FROM MarcasTarjeta MT
WHERE
(
    SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
    INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
    INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
    INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
    WHERE NSC.SituacionCrediticia in ('Exelente', 'Muy Buena', 'Buena') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta
) =
(
    SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
    INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
    INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
    INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
    WHERE NSC.SituacionCrediticia in ('Regular', 'Mala', 'Muy Mala', 'No confiable') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta
)


--12 La cantidad de marcas de tarjeta que hayan otorgado más del doble de cantidad de
--tarjetas a clientes con situación crediticia favorable que a clientes con situación
--crediticia desfavorable.
SELECT COUNT(*) AS CantidadMarcas
FROM (
    SELECT MT.ID_MarcaTarjeta
    FROM MarcasTarjeta MT
    WHERE
    (
        SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
        INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
        INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
        INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
        WHERE NSC.SituacionCrediticia IN ('Exelente', 'Muy Buena', 'Buena') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta
    ) > 2 * (
        SELECT COUNT(*) FROM NivelesSituacionCrediticia NSC
        INNER JOIN Usuarios U ON U.ID_SituacionCrediticia = NSC.ID_NivelSituacionCrediticia
        INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
        INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
        WHERE NSC.SituacionCrediticia IN ('Regular', 'Mala', 'Muy Mala', 'No confiable') AND T.ID_MarcaTarjeta = MT.ID_MarcaTarjeta
    )
) AS Subconsulta;



--13 Las billeteras que hayan operado, en total, más dinero en agosto que en septiembre
--de 2023.
SELECT B.Alias
FROM Billeteras B
WHERE
	(
		SELECT SUM(M.Importe)
		FROM Movimientos M
		WHERE M.ID_Billetera = B.ID_Billetera 
		AND	M.FechaHora BETWEEN '2023-08-01 00:00:00.000' AND '2023-08-31 23:59:59.999'
	)  >
	(
		SELECT SUM(M.Importe) FROM Movimientos M
		WHERE M.ID_Billetera = B.ID_Billetera
		AND M.FechaHora BETWEEN '2023-09-01 00:00:00.000' AND '2023-09-30 23:59:59.999'
	) 


--14 La cantidad de billeteras que hayan operado en Agosto pero no en Septiembre.
SELECT COUNT(*) AS CantidadBilleteras
FROM Billeteras B
WHERE EXISTS (
    SELECT *
    FROM Movimientos M
    WHERE M.ID_Billetera = B.ID_Billetera
    AND M.FechaHora BETWEEN '2023-08-01 00:00:00.000' AND '2023-08-31 23:59:59.999'
) 
AND NOT EXISTS (
    SELECT *
    FROM Movimientos M
    WHERE M.ID_Billetera = B.ID_Billetera
    AND M.FechaHora BETWEEN '2023-09-01 00:00:00.000' AND '2023-09-30 23:59:59.999'
)


--15 Las billeteras que pagaron más de $100 en total en concepto de recargo (Ver Punto 9)
SELECT Alias, Recargo
FROM (
    SELECT B.Alias, 
           SUM(
               CASE 
                   WHEN M.TipoMovimiento = 'D' AND DATEPART(WEEKDAY, M.FechaHora) IN (1, 7) THEN 50  -- Sábado (7) y Domingo (1)
                   WHEN M.TipoMovimiento = 'C' THEN 10
                   ELSE 0
               END
           ) AS Recargo
    FROM Billeteras B
    INNER JOIN Movimientos M ON B.ID_Billetera = M.ID_Billetera
    GROUP BY B.Alias
) AS Subconsulta
WHERE Recargo >= 100


--string interpolation $ --> googlear