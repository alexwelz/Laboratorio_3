
SET DATEFORMAT 'MDY'
INSERT INTO CONTACTOS (apellido, nombre, fecha_Nacimiento)
VALUES ('Welz', 'Alex','09/10/1996')



DATEDIFF(YEAR, U.FechaNacimiento, GETDATE()) AS EDAD FROM Usuarios U

SELECT Legajo, Apellido, Nombre DATEDIFF(YEAR,0, GETDATE()-fecha_Nacimiento)
AS EDAD FROM ALUMNOS


SELECT APELLIDO, 1 AS UNO, 'Hola mundo' AS HOLA, MONTH(FECHA_NACIMIENTO) AS
MES, YEAR(FECHA_NACIMIENTO) AS ANIO FROM ALUMNOS


LIKE 'Ale_' --> Busca todos los que tengan Ale y despues 1 carater cualquiera

LIKE'[a-m]ario' --> Busca registros que comiencen con a y m y luego continue con ario

LIKE '[kcmh]arina' --> comiencen con k,c,m o h y luego continue con ariana

LIKE 'an[^g]%' --> comience con an que la 3er letra no sea g y continue con cualquier caracter

--De esta forma podemos obtener nombres que tengan la 3er letra con una R por tener 2 guion bajo
SELECT * FROM CONTACTOS WHERE NOMBRE LIKE '__R%'

--Busca mails que tengan como 2do carater una vocal y despues cualquier caracter
SELECT * FROM CONTACTOS WHERE MAIL LIKE '_[AEIOU]%'

--Busca todas las direcciones que no tengan N°s 
SELECT * FROM CONTACTOS WHERE DIRECCION NOT LIKE '%[0-9]%'




CODIGOS (FUNCIONES INTERNAS) ORACLE SQL
  -- consultar numero de caracter en codigo ASCII
select chr(100) from dual;--dice el caracter que tiene ese numero
select ascii('d') from dual;--dice que numero tiene ese caracter

--funcion concat: sirve para unir cadenas de carácteres
select concat('buenas','tardes') from dual;

--funcion initcap: coloca primera letra en mayúscula
select initcap('buenas tardes') from dual;

--funcion lower: coloca todas las letras en minúscula
select lower('BUENAS TARDES') from dual;

--funcion upper: coloca todas las letras en mayúscula
select upper('buenas tardes') from dual;

--funcion lpad: completa los carácteres del lado derecho con la cantidad que le indiquen
select lpad('oracle',8,'abc') from dual;

--funcion rpad: completa los carácteres del lado izquierdo con la cantidad que le indiquen
select rpad('oracle',12,'abc') from dual;

--funcion ltrim: corta del lado derecho los carácteres que le indiquen
select ltrim('curso de oracle','cur')from dual;

--funcion rtrim: corta del lado izquierdo los carácteres que le indiquen
select rtrim('curso de oracle','cle')from dual;

--funcion trim: corta de ambos lados los carácteres que le indiquen
select trim('  oracle  ') from dual;

--funcion replace: reemplaza la letra indicada con la que se requiera
select replace('www.oracle.com','o','a') from dual;

--funcion substr: busca la o las letras dentro de la palabra indicada en el rango que se le indique
select substr('www.oracle.com',1,14) from dual;--de izquierda a derecha

select substr('www.oracle.com',-13) from dual;--de derecha a izquerda

--funcion length: dice cuantas letras tiene una palabra
select length('www.oracle.com') as cantidad from dual;

--funcion instr: dice en que punto esta una palabra o letra dentro de la indicada
select instr('curso de oracle sql','ma') from dual;

--funcion translate: reemplaza las letras indicadas con las requeridas
select translate('CURSO DE ORACLE','AOE','XYZ') from dual;

FUNCIONES MATEMATICAS EN ORACLE SQL

SCRIPTS:
--función abs: trae el valor absoluto de un número
select abs(50) from dual;

--función ceil: redondea hacia arriba una cifra decimal
select ceil(15.50) from dual;

--función floor: redondea hacia abajo una cifra decimal
select floor(13.30) from dual;

--función mod: muestra el residuo de dividir dos enteros
select mod(10,2) from dual;

--función power: muestra un valor elevado a la potencia
select power(10,3) from dual;

--función round: redondea un valor decimal tantas posiciones como se le indique -- en este caso mostraria 123.45
select round(123.456,2) from dual;

--función sign: identifica la naturaleza de una cifra (1)positivo, (-1)negativo
select sign(100) from dual;

--función trunc:corta la cantidad decimal tanto como se le indique
select trunc(1234.1234,1) from dual;

--función sqrt: trae raiz cuadrada de un entero
select round(sqrt(27)) from dual;


EJECUCIONES
--funcion add_months: busca la fecha en la cantidad de meses indicada
select add_months(to_date('10/10/2020','dd/mm/yyyy'),5) from dual;--agrega meses

select add_months(to_date('10/1z0/2020','dd/mm/yyyy'),-5) from dual;--resta meses
-------------------------------------------------------------
--funcion last_day: trae el ultimo dia del mes de la fecha ingresada
select last_day(to_date('09/02/2020','dd/mm/yyyy')) from dual;
----------------------------
--funcion months_between: indica cuantos meses hay entre las fechas colocadas
select months_between(to_date('19/05/2020','dd/mm/yyyy'),to_date('19/06/2020','dd/mm/yyyy')) as meses from dual;
-------------------------
--funcion next_day: indica la fecha del próximo dia indicado en el argumento
select next_day(to_date('17/08/2020','dd/mm/yyyy'),'TUESDAY') from dual;
------------------------------
--funcion current_date: indica la fecha calendario
select current_date from dual;
------------------------------
--funcion sysdate: indica la fecha de la base datos
select sysdate from dual;
-------------------------------
--funcion current_timestamp: indica la fecha y hora regional
select current_timestamp from dual;
-----------------------------------
--funcion systimestamp: indica la fecha y hora en la base de datos
select systimestamp from dual;
------------------------------------
--funcion to_char: trae la fecha colocada en modo de string
select to_char('10/10/2020') from dual;