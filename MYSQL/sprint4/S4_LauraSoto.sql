-- NIVELL 1
-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
-- almenys 4 taules de les quals puguis realitzar les següents consultes:

-- Creamos la base de datos
 CREATE DATABASE tienda_s4;
 
 -- Comprobamos donde podemos poner los archivos en local para poder subirlos:
SHOW VARIABLES LIKE "secure_file_priv"; -- encuentra el directorio en el que tienes permitido guardar.
SHOW VARIABLES LIKE "LOCAL_INFILE"; -- verifica si está ON o OFF.
SET GLOBAL LOCAL_INFILE = "ON"; -- Se cambia a ON y se verifica con la instrucción anterior.
-- Se vuelve a cargar los datos de la tabla, especificando la ruta y colocando dos barras.

 -- Creamos la tabla COMPANIES
CREATE TABLE IF NOT EXISTS companies (
company_id VARCHAR(50) PRIMARY KEY,
company_name VARCHAR(250),
phone VARCHAR(20),
email VARCHAR(100),
country VARCHAR(100),
website VARCHAR(100)
);

-- Subimos los datos de companies
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ITACADEMY/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Creamos la tabla CREDIT_CARDS
CREATE TABLE IF NOT EXISTS credit_cards (
id VARCHAR(50) PRIMARY KEY,
user_id VARCHAR(20),
iban VARCHAR(50),
pan VARCHAR(40),
pin VARCHAR(4),
cvv INT,
track1 VARCHAR(255),
track2 VARCHAR(255),
expiring_date VARCHAR(255)
);

-- Subimos datos
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ITACADEMY/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Unificamos tablas european_users y american_users:
-- Creamos la tabla y añadimos una columna nueva
CREATE TABLE IF NOT EXISTS users (
id VARCHAR(50) PRIMARY KEY,
name VARCHAR(100),
surname VARCHAR(100),
phone VARCHAR(150),
email VARCHAR(150),
birth_date VARCHAR(100),
country VARCHAR(150),
city VARCHAR(150),
postal_code VARCHAR(100),
address VARCHAR (255),
continent VARCHAR (50)
);

-- Subimos archivo european_users especificando con SET el contenido de la nueva columna
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ITACADEMY/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SET continent = 'EUROPE';

-- Subimos archivo american_users
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ITACADEMY/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SET continent = 'AMERICA';

-- Creamos tabla TRANSACTIONS
CREATE TABLE IF NOT EXISTS transactions (
id VARCHAR(100) PRIMARY KEY,
card_id VARCHAR(20),
business_id VARCHAR(255),
timestamp TIMESTAMP,
amount DECIMAL(10,2),
declined TINYINT,
product_ids VARCHAR(255),
user_id VARCHAR(20),
lat FLOAT,
longitude FLOAT,
FOREIGN KEY (card_id) REFERENCES credit_cards(id),
FOREIGN KEY (business_id) REFERENCES companies(company_id),
FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Subimos los datos de transactions
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ITACADEMY/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);	


-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
SELECT name, surname
FROM users
WHERE users.id IN (SELECT user_id 
				   FROM transactions
				   GROUP BY user_id
				   HAVING COUNT(transactions.id) > 80);
                   

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT ROUND(AVG(amount), 2) AS AvgAmount, iban, company_name
FROM credit_cards
JOIN transactions ON credit_cards.id = card_id
JOIN companies ON company_id = business_id
WHERE company_name = 'Donec Ltd'
GROUP BY iban;


-- NIVELL 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en: si les tres últimes transaccions han estat 
-- declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:

-- Realizamos consulta que nos haga columna con el id de tarjeta y columna con estado de tarjeta
SELECT card_id,
CASE
	WHEN SUM(declined) = 3 THEN 'Inactivated'
    ELSE 'Activated'
 END AS status_card   
FROM 
	(SELECT card_id, declined, ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS row_card
    FROM transactions
    ) AS transactions_date
 WHERE transactions_date.row_card <= 3
 GROUP BY card_id;

 
 
 -- Creamos nueva tabla
CREATE TABLE status_cards AS
SELECT card_id,
CASE
	WHEN SUM(declined) = 3 THEN 'Inactivated'
    ELSE 'Activated'
 END AS status_card   
FROM 
	(SELECT card_id, declined, ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS row_card
    FROM transactions
    ) AS transactions_date
 WHERE transactions_date.row_card <= 3
 GROUP BY card_id;

-- Comprobamos tabla creada
SHOW COLUMNS FROM
status_cards;

SELECT *
FROM status_cards;

-- Asignamos relación tablas
-- El PK
ALTER TABLE status_cards
ADD PRIMARY KEY (card_id);

-- El FK
ALTER TABLE status_cards
ADD CONSTRAINT fk_status_cards_a_credit_cards
FOREIGN KEY (card_id)
REFERENCES credit_cards(id);


-- EXERCICI 1
-- Quantes targetes estan actives?
SELECT COUNT(status_card)
FROM status_cards
WHERE status_card = 'Activated';



 -- NIVELL 3
 -- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
 -- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
 
-- Creamos la tabla PRODUCTS
CREATE TABLE IF NOT EXISTS products (
id VARCHAR(50) PRIMARY KEY,
product_name VARCHAR(250),
price VARCHAR(20),
colour VARCHAR(100),
weight DECIMAL(10,2),
warehouse_id VARCHAR(100)
);

-- Subimos datos
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ITACADEMY/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Creamos nueva tabla de productos por transacciones
CREATE TABLE transaction_products(
transaction_id VARCHAR(255),
product_id VARCHAR(50),
FOREIGN KEY (transaction_id) REFERENCES transactions(id),
FOREIGN KEY (product_id) REFERENCES products(id)
);

ALTER TABLE transaction_protransaction_idducts
ADD PRIMARY KEY (transaction_id, product_id);


-- Procedemos a subir datos de la tabla

-- Probar este:
INSERT IGNORE INTO transaction_products(transaction_id, product_id) 
SELECT transactions.id, products.id
FROM transactions
JOIN products ON FIND_IN_SET(products.id, replace(product_ids,' ',' '));

SELECT *
FROM transaction_products;

-- EXERCICI 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT product_name, COUNT(transaction_id) AS Sales
FROM transaction_products
JOIN products ON product_id = products.id
JOIN transactions ON transactions.id = transaction_id
WHERE declined = 0
GROUP BY product_id;
