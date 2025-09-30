-- NIVELL 1
-- EXERCICI 1
SELECT *
FROM company;

SELECT *
FROM transaction; 

-- EXERCICI 2
-- Llistat dels països que estan generant vendes.
SELECT country, ROUND (SUM(transaction.amount), 2) AS TotalVentas
FROM company
JOIN transaction
ON company.id = company_id
WHERE declined = '0'
GROUP BY country;

-- Des de quants països es generen les vendes.
SELECT ROUND (SUM(transaction.amount), 2) AS TotalVentas, COUNT(distinct company.country) AS CantidadPaises
FROM transaction
INNER JOIN company
ON company_id = company.id
WHERE declined = '0';

-- Identifica la companyia amb la mitjana més gran de vendes
SELECT company_name, ROUND (AVG(amount), 2) AS MediaDeVentas
FROM company
INNER JOIN transaction
ON company.id = company_id
WHERE declined = '0'
GROUP BY company_name
ORDER BY MediaDeVentas DESC
LIMIT 1;

-- EXERCICI 3
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT transaction.id, country
FROM transaction, company
WHERE company_id = company.id AND company_id IN (SELECT id
												FROM company
												WHERE country = 'Germany');
                                
-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes 
-- les transaccions. 
SELECT amount, company_name
FROM transaction, company
WHERE company_id = company.id AND amount > (SELECT AVG(amount)
											FROM transaction);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat 
-- d'aquestes empreses.
SELECT company_name
FROM company
WHERE company.id NOT IN (SELECT company_id
			                FROM transaction);
               
               
-- NIVELL 2
-- EXERCICI 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE_FORMAT(timestamp,'%Y-%m-%d') as Fecha, ROUND (SUM(amount), 2) as Ventas
FROM transaction
WHERE declined = '0'
GROUP BY Fecha
ORDER BY Ventas DESC
LIMIT 5;

-- EXERCICI 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT country, ROUND (AVG(amount), 2) as MediaVentas
FROM company
JOIN transaction
ON company.id = company_id
WHERE declined = '0'
GROUP BY country
ORDER BY MediaVentas DESC;

-- EXERCICI 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a 
-- fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les 
-- transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT transaction.id, country
FROM transaction
JOIN company
ON company_id = company.id
WHERE country IN (SELECT country
                  FROM company
                  WHERE country = 'United Kingdom') ;


-- Mostra el llistat aplicant solament subconsultes.
SELECT transaction.id, country
FROM transaction, company
WHERE company_id = company.id 
AND company_id IN (SELECT id
				   FROM company
				   WHERE country = 'United Kingdom');

-- NIVELL 3
-- EXERCICI 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
-- i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor 
-- quantitat.

SELECT company_name, phone, country, DATE_FORMAT(timestamp,'%Y-%m-%d') AS Fecha, ROUND (amount, 2)
FROM company
JOIN transaction
ON company.id = company_id
WHERE amount BETWEEN 350 AND 400
AND DATE_FORMAT(timestamp,'%Y-%m-%d') IN ('2015-04-29','2018-07-20','2024-03-13')
ORDER BY amount DESC;

-- EXERCICI 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen 
-- la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i 
-- vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

SELECT company_name,
CASE
	WHEN COUNT(transaction.id) > 400 THEN 'Más de 400'
    ELSE 'Menos de 400'
END AS CantidadTransacciones
FROM company
JOIN  transaction
ON company.id = company_id
GROUP BY company.id;


	
