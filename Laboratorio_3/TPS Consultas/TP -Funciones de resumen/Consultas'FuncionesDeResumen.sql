--1 Listado con la cantidad de usuarios que tienen una situación crediticia con ID menor
--a 3.
SELECT  U.Apellidos+' '+U.Nombres AS 'Usuarios' ,COUNT(*) AS 'Cantidad'
FROM Usuarios U
INNER JOIN NivelesSituacionCrediticia NSC ON NSC.ID_NivelSituacionCrediticia = U.ID_SituacionCrediticia
WHERE NSC.ID_NivelSituacionCrediticia < 3
GROUP BY U.Apellidos+' '+U.Nombres 

--2 Listado con el saldo promedio de las billeteras
SELECT  U.Apellidos+' '+U.Nombres AS 'Usuarios', AVG(B.Saldo * 1.0) AS 'Saldo' -- al agregar * 1.0 en el saldo indicamos al AVG que sea float (decimales)
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
GROUP BY U.Apellidos+' '+U.Nombres 

--Otra forma promediando con decimal
SELECT  U.Apellidos+' '+U.Nombres AS 'Usuarios', AVG(CAST(B.Saldo AS DECIMAL(10, 2))) AS 'Saldo' 
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
GROUP BY U.Apellidos+' '+U.Nombres 

--3 Listado con el saldo acumulado de las billeteras que hayan sido creadas luego del
--15 de Enero de 2022.

SELECT  U.Apellidos+' '+U.Nombres AS 'Usuarios',
B.FechaCreacion AS 'Fecha Creacion' ,AVG(B.Saldo * 1.0) AS 'Saldo' -- al agregar * 1.0 en el saldo indicamos al AVG que sea float (decimales)
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
WHERE B.FechaCreacion >= '2022-01-15'
GROUP BY U.Apellidos+' '+U.Nombres, B.FechaCreacion 

--4 Listado con la cantidad de tarjetas que se vencen en el año actual y que sean del
--Banco HSBC.
SELECT  U.Apellidos+' '+U.Nombres AS 'Usuarios',COUNT(T.FechaVencimiento) AS 'Tarjetas vencidas'
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
INNER JOIN Bancos Ba  ON Ba.ID_Banco = T.ID_Banco
WHERE YEAR(T.FechaVencimiento) = YEAR(GETDATE()) and Ba.Nombre = 'Banco HSBC'
GROUP BY  U.Apellidos+' '+U.Nombres

--5 Listado con el promedio de antigüedad expresado en días de las billeteras
SELECT U.Apellidos+' '+U.Nombres AS Usuarios, AVG(DATEDIFF(DAY, Bi.FechaCreacion, GETDATE())) AS 'Antigüedad'
FROM Usuarios U
INNER JOIN Billeteras Bi ON Bi.ID_Usuario = U.ID_Usuario 
GROUP BY  U.Apellidos+' '+U.Nombres

--6 Listado con el promedio de días que restan para el vencimiento de las tarjetas no
--vencidas.
SELECT U.Apellidos+' '+U.Nombres AS Usuarios, AVG(DATEDIFF(DAY, GETDATE(),T.FechaVencimiento)) AS 'Dias faltantes de vencimiento'
FROM Usuarios U
INNER JOIN Billeteras Bi ON Bi.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera = Bi.ID_Billetera
WHERE GETDATE() < T.FechaVencimiento  
GROUP BY  U.Apellidos+' '+U.Nombres

--7 Listado con la fecha de nacimiento de la persona más joven en tener una billetera.
SELECT TOP(1) WITH TIES U.Apellidos+' '+U.Nombres AS 'Persona joven', U.FechaNacimiento -- Si hay mas persnas con fecha igual los agrega a la lista WITH TIES
FROM Usuarios U 
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
WHERE B.ID_Billetera is NOT NULL
GROUP BY  U.Apellidos+' '+U.Nombres, U.FechaNacimiento
ORDER BY U.FechaNacimiento ASC

--8 Listado con el total de dinero acreditado mediante movimientos..
SELECT U.Apellidos+' '+U.Nombres AS 'Usuarios', SUM(M.Importe) AS 'Dinero Acreditado'
FROM Usuarios U 
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Movimientos M ON M.ID_Billetera = B.ID_Billetera
GROUP BY U.Apellidos+' '+U.Nombres

--9 Por cada cliente, apellidos, nombres, alias de la billetera y cantidad de movimientos
--registrados.
SELECT U.Apellidos+' '+U.Nombres AS 'Clientes',B.Alias AS 'Alias Billetera' , COUNT(M.ID_Movimiento) AS 'Cantidad Movimeiento'
FROM Usuarios U 
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Movimientos M ON M.ID_Billetera = B.ID_Billetera
GROUP BY U.Apellidos+' '+U.Nombres, B.Alias

--Verificacion
SELECT * FROM Usuarios where Nombres like '%Andres%' or Apellidos like '%Diaz%'
SELECT * FROM Billeteras where Alias like '%LUNA.SOL.AGUA%'
SELECT * FROM Movimientos where ID_Billetera=10009

--10 Listar los clientes que hayan registrado débitos por más de $15000
SELECT U.Apellidos+' '+U.Nombres AS 'Clientes', M.TipoMovimiento, M.Importe
FROM Usuarios U 
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Movimientos M ON M.ID_Billetera = B.ID_Billetera
WHERE M.TipoMovimiento = 'D' and M.Importe > 15000

--11 Listar el total debitado discriminado por nivel de situación crediticia
SELECT U.Apellidos+' '+U.Nombres AS 'Clientes', M.TipoMovimiento, NSC.SituacionCrediticia ,SUM(M.Importe) AS 'Importe'
FROM Usuarios U 
INNER JOIN NivelesSituacionCrediticia NSC ON NSC.ID_NivelSituacionCrediticia = U.ID_SituacionCrediticia
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Movimientos M ON M.ID_Billetera = B.ID_Billetera
WHERE M.TipoMovimiento = 'D'  and NSC.ID_NivelSituacionCrediticia IS NOT NULL
GROUP BY U.Apellidos+' '+U.Nombres, M.TipoMovimiento, NSC.SituacionCrediticia

--12 Listar el nombre y apellido del usuario que haya realizado más depósitos.
SELECT TOP (1) WITH TIES U.Apellidos + ' ' + U.Nombres AS 'Usuarios', COUNT(T.ID_BilleteraDestino) AS 'Cantidad Deposito'
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Transferencias T ON T.ID_BilleteraDestino = B.ID_Billetera
GROUP BY U.Apellidos + ' ' + U.Nombres
HAVING COUNT(T.ID_BilleteraDestino) = (
	SELECT MAX(ContDepositos)
    FROM (
        SELECT COUNT(T2.ID_BilleteraDestino) AS ContDepositos
        FROM Transferencias T2
        GROUP BY T2.ID_BilleteraDestino
    ) AS Subconsulta
)
ORDER BY COUNT(T.ID_BilleteraDestino) DESC;

--13 Listar la cantidad de usuarios que hayan registrado movimientos de tipo débito.



--14 Listar por cada billetera el alias y la cantidad de transferencias realizadas (la billetera
--es el origen de la transferencia). Si hay billeteras que no tienen transferencias
--realizadas deben figurar en el listado contabilizando 0.



--15 Listar los apellidos y nombres y el alias de billeteras de aquellos clientes que hayan
--movilizado más de $40000 durante  el mes de agosto de 2023.