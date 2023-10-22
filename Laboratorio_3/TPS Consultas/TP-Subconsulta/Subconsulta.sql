--6
--Los nombres de bancos que no hayan entregado tarjetas a ningún cliente con nivel de situación crediticia
--Mala, Muy Mala o No Confiable.

SELECT Ba.Nombre AS Bancos, NSC.SituacionCrediticia
FROM Usuarios U
INNER JOIN Billeteras Bi ON Bi.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera = Bi.ID_Billetera
INNER JOIN Bancos Ba ON Ba.ID_Banco = T.ID_Banco
INNER join NivelesSituacionCrediticia NSC ON NSC.ID_NivelSituacionCrediticia = U.ID_SituacionCrediticia
WHERE ID_NivelSituacionCrediticia NOT IN (
	SELECT ID_NivelSituacionCrediticia WHERE ID_NivelSituacionCrediticia in (5,6,7)
)

SELECT * FROM NivelesSituacionCrediticia 

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

--NOTA: Sólo aplica a los movimientos registrados en el mes de Agosto de 2023.     ---> VER
SELECT B.Alias,
    ISNULL(
        (
            SELECT SUM(
                CASE 
                    WHEN M.TipoMovimiento = 'D' THEN 50
                    WHEN M.TipoMovimiento = 'C' THEN 10
                    ELSE 0
                END
            )
            FROM Movimientos M
            WHERE M.ID_Billetera = B.ID_Billetera
            AND M.FechaHora >='2023-08-05 00:00:00.000' AND M.FechaHora <='2023-08-06 23:59:59.999'
        ), 0) AS CantidadAbonar, Mo.FechaHora, Mo.TipoMovimiento
		

FROM Billeteras B
INNER JOIN Movimientos Mo ON B.ID_Billetera = Mo.ID_Billetera

SELECT B.Alias, Mo.Importe,
    ISNULL(
        (
            SELECT SUM(
                CASE 
                    WHEN M.TipoMovimiento = 'D' AND DATEPART(WEEKDAY, M.FechaHora) IN (1, 7) THEN 50  -- Sábado (7) y Domingo (1)
                    WHEN M.TipoMovimiento = 'C' THEN 10
                    ELSE 0
                END
            )
            FROM Movimientos M
            WHERE M.ID_Billetera = B.ID_Billetera
              AND M.FechaHora >= '2023-08-01 00:00:00.000'
              AND M.FechaHora <= '2023-08-31 23:59:59.999'
        ), 0) AS CantidadAbonar, Mo.FechaHora, Mo.TipoMovimiento

FROM Billeteras B
INNER JOIN Movimientos Mo ON B.ID_Billetera = Mo.ID_Billetera

--10 
--El total acumulado en concepto de recargo (ver Punto 9)      ---> VER
SELECT B.Alias,
    ISNULL(
        (
            SELECT SUM(
                CASE 
                    WHEN M.TipoMovimiento = 'D' AND DATEPART(WEEKDAY, M.FechaHora) IN (1, 7) THEN 50  -- Sábado (7) y Domingo (1)
                    WHEN M.TipoMovimiento = 'C' THEN 10
                    ELSE 0
                END
            )
            FROM Movimientos M
            WHERE M.ID_Billetera = B.ID_Billetera
              AND M.FechaHora >= '2023-08-01 00:00:00.000'
              AND M.FechaHora <= '2023-08-31 23:59:59.999'
        ), 0) AS CantidadAbonar
FROM Billeteras B;


SELECT SUM(CantidadAbonar) AS TotalAcumuladoRecargo
FROM (
    SELECT B.Alias,
        ISNULL(
            (
                SELECT SUM(
                    CASE 
                        WHEN M.TipoMovimiento = 'D' AND DATEPART(WEEKDAY, M.FechaHora) IN (1, 7) THEN 50
                        WHEN M.TipoMovimiento = 'C' THEN 10
                        ELSE 0
                    END
                )
                FROM Movimientos M
                WHERE M.ID_Billetera = B.ID_Billetera
                  AND M.FechaHora >= '2023-08-01 00:00:00.000'
                  AND M.FechaHora <= '2023-08-31 23:59:59.999'
            ), 0) AS CantidadAbonar
    FROM Billeteras B
) AS Recargos;

--11
--Las marcas de tarjeta que hayan otorgado igual cantidad de tarjetas a clientes con situación crediticia favorable 
--que a clientes con situación crediticia desfavorable.

--12
--La cantidad de marcas de tarjeta que hayan otorgado más del doble de cantidad de tarjetas a clientes con situación
--crediticia favorable que a clientes con situación crediticia desfavorable.
--13
--Las billeteras que hayan operado, en total, más dinero en agosto que en septiembre de 2023.
--14
--La cantidad de billeteras que hayan operado en Agosto pero no en Septiembre.
--15
--Las billeteras que pagaron más de $100 en total en concepto de recargo (Ver Punto 9)

