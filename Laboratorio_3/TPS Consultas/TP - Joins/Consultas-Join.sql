--1 Por cada tarjeta obtener el número, la fecha de emisión, el nombre del banco y la
--marca de la tarjeta. Incluir al listado la cantidad de días restantes para el
--vencimiento de la tarjeta.
SELECT T.Numero, T.FechaEmision, B.Nombre, MT.Marca,DATEDIFF(DAY, T.FechaVencimiento, GETDATE()) AS 'Vencimieto Tarjeta'
FROM Tarjetas T
INNER JOIN Bancos B ON B.ID_Banco = T.ID_Banco
INNER JOIN MarcasTarjetas MT ON MT.ID_MarcaTarjeta = T.ID_MarcaTarjeta 

--2 Por cada usuario indicar Apellidos, Nombres, Edad, Alias de la billetera, la
--antigüedad de la billetera en días y el saldo de la misma.
SELECT 
	U.Apellidos,
	U.Nombres,
	YEAR(GETDATE()) - YEAR(U.FechaNacimiento) - CASE
	WHEN MONTH(GETDATE()) > MONTH(U.FechaNacimiento) THEN 0
	WHEN MONTH(GETDATE()) = MONTH(U.FechaNacimiento) and  DAY(GETDATE()) >= DAY(U.FechaNacimiento) THEN 0
	ELSE 1
	END AS 'Edad',
	B.Alias,
	DATEDIFF(DAY, B.Fcreacion, GETDATE()) AS 'Antigüedad Billetera',
	B.Saldo
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario

--3 Por cada usuario indicar Apellidos, Nombre y una categorización a partir del saldo
--de la billetera. La categorización es:
--- 'Gold' → Más de un millón de pesos
--- 'Silver' → Más de 500 mil y hasta un millón de pesos
--- 'Bronze' → Entre 50 mil y 500 mil
--- 'Copper' → Menos de 50 mil
SELECT U.Apellidos, U.Nombres, B.Saldo,
CASE
	WHEN B.Saldo > 1000000 THEN 'Gold'
	WHEN B.Saldo > 500000 and B.Saldo <= 1000000  THEN 'Silver'
	WHEN B.Saldo >= 50000 and B.Saldo <= 500000 THEN 'Bronze'
	ELSE 'Copper'
	END AS 'Categoria'
FROM Usuarios U 
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario

SELECT * FROM Billeteras
--UPDATE Billeteras set Saldo=49999 where ID_Billetera=10008

--4 Por cada usuario indicar apellidos, nombres, domicilio, nombre de la localidad y
--provincia.
SELECT U.Apellidos, U.Nombres, U.Domicilio, L.Localidad, P.Provincia
FROM Usuarios U
LEFT JOIN Localidades L ON L.ID_Localidad = U.ID_Localidad
LEFT JOIN Provincias P ON P.ID_Provincia = L.ID_Provincia

--5 Listar los usuarios con nivel de situación crediticia Excelente y que residan en
--Buenos Aires.
SELECT U.*
FROM Usuarios U
INNER JOIN NivelesSituacionCrediticia NSC ON NSC.ID_NivelSituacionCrediticia = U.ID_SituacionCrediticia
INNER JOIN Localidades L ON L.ID_Localidad = U.ID_Localidad
INNER JOIN Provincias P ON P.ID_Provincia = L.ID_Provincia
WHERE NSC.SituacionCrediticia = 'Excelente' and P.Provincia = 'Buenos Aires'

--6 Listar los nombres, apellidos y celulares de los usuarios que residan en Córdoba
SELECT U.Nombres +' '+ U.Apellidos AS 'Usuarios', U.Celular
FROM Usuarios U 
INNER JOIN Localidades L ON L.ID_Localidad = U.ID_Localidad
INNER JOIN Provincias P ON P.ID_Provincia = L.ID_Provincia
WHERE  P.Provincia = 'Cordoba'

--7 Listar los nombres y apellidos de los clientes que no posean tarjeta
SELECT U.Nombres +' '+ U.Apellidos AS 'Clientes'
FROM Usuarios U 
LEFT JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
LEFT JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
WHERE T.ID_Tarjeta is NULL

--8 Listar los nombres, apellidos, alias de billetera, nombres de tarjetas y bancos de
--todos los usuarios. Si el usuario no tiene tarjetas debe figurar igualmente en el
--listado.
SELECT U.Nombres +' '+ U.Apellidos AS 'Usuarios', B.Alias AS 'Alias Billetera', MT.Marca AS 'Tarjeta', BA.Nombre AS 'Banco'
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
LEFT JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
LEFT JOIN MarcasTarjetas MT ON MT.ID_MarcaTarjeta = T.ID_MarcaTarjeta
LEFT JOIN Bancos BA ON BA.ID_Banco = T.ID_Banco

--9 Listar nombres y apellidos del usuario que tenga la tarjeta que más tiempo falta que
--llegue a su vencimiento.
SELECT U.Nombres +' '+ U.Apellidos AS 'Usuarios'--, T.FechaVencimiento
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
WHERE T.FechaVencimiento = (SELECT MAX(T.FechaVencimiento) FROM Tarjetas T)

--10 Listar las distintas marcas de tarjeta, sin repetir, de los usuarios.
SELECT DISTINCT MT.Marca 
FROM Usuarios U
INNER JOIN Billeteras B ON B.ID_Usuario = U.ID_Usuario
INNER JOIN Tarjetas T ON T.ID_Billetera = B.ID_Billetera
INNER JOIN MarcasTarjetas MT ON MT.ID_MarcaTarjeta = T.ID_MarcaTarjeta

--11 Listar todos los datos de los usuarios que tengan una situación crediticia diferente
--de 'Excelente', 'Regular' y 'No confiable'
SELECT U.*
FROM Usuarios U
INNER JOIN NivelesSituacionCrediticia NSC ON NSC.ID_NivelSituacionCrediticia = U.ID_SituacionCrediticia
WHERE  NSC.SituacionCrediticia NOT in ('Excelente', 'Regular', 'No Confiable')

SELECT * FROM NivelesSituacionCrediticia
--UPDATE NivelesSituacionCrediticia SET SituacionCrediticia='No Confiable' WHERE ID_NivelSituacionCrediticia = 5




--PREGUNTAS DE FINAL

--HAVING 
-- Filtrar lo resumido por una o varias condiciones
-- Filtra sobre el resultado de un resumen
--Permite que informacion que se encuentra resumida y agrupada se pueda filtrar a partir de una o varias condiciones