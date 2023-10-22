--A
-- El trofeo de oro del torneo es para aquel que haya capturado el pez más pesado
--entre todos los peces. Puede haber más de un ganador del trofeo. Listar Apellido
--y nombre, especie de pez que capturó y el pesaje del mismo.

SELECT TOP(1) WITH TIES
       CONCAT(P.APELLIDO,' ',P.NOMBRE) AS GanadorTrofeo,
       E.ESPECIE,
       C.PESO
FROM PARTICIPANTES P
INNER JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
ORDER BY C.PESO DESC;

--B 
--Listar todos los participantes que no hayan pescado ningún tipo de bagre.
--Subconsulta
SELECT DISTINCT CONCAT(P.APELLIDO,' ',P.NOMBRE) AS Participantes, E.ESPECIE
FROM PARTICIPANTES P
INNER JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
WHERE E.ESPECIE NOT IN (SELECT ESPECIE FROM ESPECIES WHERE ESPECIE like '%BAGRE%')


SELECT  CONCAT(P.APELLIDO,' ',P.NOMBRE) AS Participantes
FROM PARTICIPANTES P
INNER JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
WHERE E.ESPECIE NOT LIKE '%BAGRE%'

--C
--Listar los participantes cuyo promedio de pesca (en kilos) sea mayor a 30. Listar
--apellido, nombre y promedio de kilos.

SELECT DISTINCT CONCAT(P.APELLIDO,' ',P.NOMBRE) AS Participantes,
AVG(C.PESO) AS PromedioKilos
FROM PARTICIPANTES P
INNER JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
GROUP BY CONCAT(P.APELLIDO,' ',P.NOMBRE)
HAVING AVG(C.PESO) > 30.0

--D) Por cada especie, listar la cantidad de participantes que la han capturado.SELECT  E.ESPECIE , COUNT(DISTINCT C.IDPARTICIPANTE) AS CantParticipantes
FROM PARTICIPANTES P
INNER JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
GROUP BY E.ESPECIE

--Revision
SELECT C.*, E.ESPECIE FROM CAPTURAS C
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE


--E) Listar apellido y nombre del participante y nombre de la especie de cada pez que
--haya capturado el pescador/a. 
--Si alguna especie de pez no ha sido pescado
--nunca entonces deberá aparecer en el listado de todas formas pero sin
--relacionarse con ningún pescador. El listado debe aparecer ordenado por nombre
--de especie de manera creciente. La combinación apellido y nombre y nombre de
--la especie debe aparecer sólo una vez este listado.

SELECT DISTINCT CONCAT( P.APELLIDO, ' ', P.NOMBRE) AS Participante,  E.ESPECIE
FROM PARTICIPANTES P
LEFT JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
LEFT JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
GROUP BY CONCAT(P.APELLIDO, ' ', P.NOMBRE), E.ESPECIE
ORDER BY E.ESPECIE ASC;

--F) El trofeo de plata de la competencia se lo adjudica quien haya capturado la mayor
--cantidad de kilos en total y nunca haya capturado un pez por debajo del peso
--mínimo de la especie.

SELECT TOP (1) P.IDPARTICIPANTE, CONCAT(P.APELLIDO, ' ', P.NOMBRE) AS TrofeoPlata,
SUM(C.PESO) AS CantidadKilos
FROM PARTICIPANTES P
INNER JOIN CAPTURAS C ON C.IDPARTICIPANTE = P.IDPARTICIPANTE
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
WHERE P.IDPARTICIPANTE NOT IN (
    SELECT DISTINCT Ca.IDPARTICIPANTE
    FROM CAPTURAS Ca
    INNER JOIN ESPECIES Es ON Es.IDESPECIE = Ca.IDESPECIE
    WHERE Ca.PESO < Es.PESO_MINIMO
)
GROUP BY P.IDPARTICIPANTE,CONCAT(P.APELLIDO, ' ', P.NOMBRE)

--Revision
SELECT C.*, E.PESO_MINIMO FROM Capturas C
INNER JOIN ESPECIES E ON E.IDESPECIE = C.IDESPECIE
