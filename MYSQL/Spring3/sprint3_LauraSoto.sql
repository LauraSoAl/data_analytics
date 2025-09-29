-- NIVELL 1
-- EXERCICI 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules 
-- ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document 
-- denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

    CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(8) PRIMARY KEY,
        iban VARCHAR(40),
        pan VARCHAR(20),
        pin VARCHAR(4),
        cvv VARCHAR(3),
        expiring_date VARCHAR(8)
    );
    
    -- Creamos relación de la clave foranea con primary Key
    ALTER TABLE transaction
    ADD CONSTRAINT fk_transaccion_tarjeta
    FOREIGN KEY (credit_card_id)
    REFERENCES credit_card(id);
    

-- EXERCICI 2
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

-- Modificamos el registro
UPDATE credit_card SET iban = 'TR323456312213576817699999' WHERE id = 'CcU-2938';

-- Mostramos el cambio
SELECT id, iban
FROM credit_card
WHERE id='CcU-2938';

-- EXERCICI 3
-- En la taula "transaction" ingressa un nou usuari 

-- Para poder crear el usuario en transaction, primero tenemos que crear el usuario en la tabla company. 
INSERT INTO company (id, company_name, phone, email, country, website)
VALUES ('b-9999', NULL, NULL, NULL, NULL, NULL);

-- Posteriormente, creamos el nuevo usuario con los datos aportados en la tabla transaction
INSERT INTO transaction (id,credit_card_id,company_id, user_id, lat, longitude, timestamp, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999', 'b-9999', 9999, 829.999, -117.999, NULL, 111.11, 0);

-- Creamos también el registro en la tabla credit_card 
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999', NULL, NULL, NULL, NULL, NULL);


-- EXERCICI 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card DROP COLUMN pan;

SHOW COLUMNS FROM credit_card;


-- NIVELL 2
-- EXERCICI 1
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT id
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- EXERCICI 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
-- Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
-- ordenant les dades de major a menor mitjana de compra.

-- Creamos la vista
CREATE VIEW v_VistaMarketing AS
SELECT company_name AS Nombre_compañia, phone AS Telefono, country AS Pais, AVG (amount) AS Media_Compra
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = '0'
GROUP BY company.id
ORDER BY Media_Compra DESC;

-- Visualizamos la vista
SELECT * FROM v_VistaMarketing;

-- EXERCICI 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT *
FROM v_vistamarketing
WHERE Pais = 'Germany';

-- NIVELL 3
-- EXERCICI 1
-- Establecemos la relación entre tablas
ALTER TABLE transaction
ADD CONSTRAINT fk_transaccion_usuario
FOREIGN KEY (user_id)
REFERENCES user(id);

-- Añadimos user_id a la tabla usuario para poder establecer la relación PK-FK entre tablas
INSERT INTO user (id, name, surname, phone, personal_email, birth_date, country, city, postal_code, address)
VALUES ('9999', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    
-- CAMBIOS TABLA USER
SHOW COLUMNS FROM user;
-- Cambio de nombre de tabla
ALTER TABLE user RENAME TO data_user;
-- Cambio de tipo de dato
ALTER TABLE data_user
MODIFY COLUMN id INT;
-- Cambio de nombre de columna
ALTER TABLE data_user
CHANGE email personal_email VARCHAR(150);

-- CAMBIOS TABLA COMPANY
SHOW COLUMNS FROM company;
-- Eliminamos la columna website
ALTER TABLE company DROP COLUMN website;

-- TABLA TRANSACTION
SHOW COLUMNS FROM transaction;
-- Cambiamos el límite de carácteres
 ALTER TABLE transaction
MODIFY credit_card_id VARCHAR(20);

-- TABLA CREDIT_CARD
SHOW COLUMNS FROM credit_card;
-- Cambiamos longitud VARCHAR
 ALTER TABLE credit_card
MODIFY id VARCHAR(20);

 ALTER TABLE credit_card
MODIFY iban VARCHAR(50);

 ALTER TABLE credit_card
MODIFY expiring_date VARCHAR(20);

-- Cambiamos tipo de dato
ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

-- Añadimos la columna de fecha_actual
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- Eliminamos la VistaMarketing
DROP VIEW v_vistamarketing;

-- EXERCICI 2
-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació: ID de la transacció
-- Nom de l'usuari/ària, Cognom de l'usuari/ària, IBAN de la targeta de crèdit usada., Nom de la companyia de la transacció realitzada.
-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
CREATE VIEW v_informetecnico AS
SELECT transaction.id AS ID_transacción, data_user.name AS Nombre_usuario, data_user.surname AS Apellido_usuario, iban AS IBAN, company_name 
AS Nombre_compañía
FROM transactionv_vistamarketing
JOIN data_user ON transaction.user_id = data_user.id
JOIN credit_card ON  transaction.credit_card_id = credit_card.id
JOIN company ON transaction.company_id = company.id
ORDER BY transaction.id DESC;

SELECT *
FROM v_informetecnico;
