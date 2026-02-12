-- Creamos a mano las estructuras que tendrán cada tabla de catálogo para poder subir datos a través de Python
-- NETFLIX
CREATE TABLE netflix_titles (
    show_id VARCHAR(20),
    type VARCHAR(20),
    title TEXT,
    director TEXT,
    cast TEXT,
    country TEXT,
    date_added TEXT,
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in TEXT,
    description TEXT
);

-- AMAZON PRIME
CREATE TABLE amazon_titles (
    show_id VARCHAR(20),
    type VARCHAR(20),
    title TEXT,
    director TEXT,
    cast TEXT,
    country TEXT,
    date_added TEXT,
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in TEXT,
    description TEXT
);

-- DISNEY PLUS
CREATE TABLE disney_titles (
    show_id VARCHAR(20),
    type VARCHAR(20),
    title TEXT,
    director TEXT,
    cast TEXT,
    country TEXT,
    date_added TEXT,
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in TEXT,
    description TEXT
);

#HULU
CREATE TABLE hulu_titles (
    show_id VARCHAR(20),
    type VARCHAR(20),
    title TEXT,
    director TEXT,
    cast TEXT,
    country TEXT,
    date_added TEXT,
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in TEXT,
    description TEXT
);

-- LIMPIEZA DE DATOS ANTES DE UNIFICAR TABLAS:
#Eliminamos las columnas Unnamed de la tabla Netflix que no aportan información
ALTER TABLE netflix_titles DROP COLUMN `Unnamed: 12`, DROP COLUMN `Unnamed: 13`, DROP COLUMN `Unnamed: 14`;
ALTER TABLE netflix_titles DROP COLUMN `Unnamed: 15`, DROP COLUMN `Unnamed: 16`, DROP COLUMN `Unnamed: 17`, DROP COLUMN `Unnamed: 18`, DROP COLUMN `Unnamed: 19`
, DROP COLUMN `Unnamed: 20`, DROP COLUMN `Unnamed: 21`, DROP COLUMN `Unnamed: 22`, DROP COLUMN `Unnamed: 23`, DROP COLUMN `Unnamed: 24`, DROP COLUMN `Unnamed: 25`;

#Cambiamos el tipo de variable de cast de la tabla HULU para que esté igual que el resto
ALTER TABLE hulu_titles 
MODIFY COLUMN cast TEXT;

#Cambiamos la tipología de la variable release_year de bigint a int en todas las tablas
ALTER TABLE amazon_titles MODIFY release_year INT;
ALTER TABLE disney_titles MODIFY release_year INT;
ALTER TABLE hulu_titles MODIFY release_year INT;
ALTER TABLE netflix_titles MODIFY release_year INT;
-- Fin limpieza de datos

-- CREAMOS UNA TABLA UNIFICADA CON TODAS LAS PLATAFORMAS STREAMING
CREATE TABLE streaming_catalog AS
SELECT
    title,
    type,
    release_year,
    rating,
    duration,
    listed_in AS genre,
    country,
    date_added,
    'Netflix' AS platform
FROM netflix_titles
UNION ALL
SELECT
    title,
    type,
    release_year,
    rating,
    duration,
    listed_in AS genre,
    country,
	date_added,
    'Amazon Prime' AS platform
FROM amazon_titles
UNION ALL
SELECT
    title,
    type,
    release_year,
    rating,
    duration,
    listed_in AS genre,
    country,
	date_added,
    'Disney+' AS platform
FROM disney_titles
UNION ALL
SELECT
    title,
    type,
    release_year,
    rating,
    duration,
    listed_in AS genre,
    country,
    date_added,
    'Hulu' AS platform
FROM hulu_titles;

SELECT *
FROM streaming_catalog;

-- LIMPIEZA DE DATOS

-- COLUMNA DURATION CON MINUTOS Y TEMPORADAS:
#Creamos nuevas columnas para minutos y temporadas
ALTER TABLE streaming_catalog
ADD COLUMN duration_minutes INT,
ADD COLUMN seasons INT;


#Rellenamos minutos solo de películas
SET SQL_SAFE_UPDATES = 0; -- Abrimos seguridad
UPDATE streaming_catalog
SET duration_minutes = CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)
WHERE type = 'Movie'
AND duration LIKE '%min%';

#Rellenamos temporadas solo de series
UPDATE streaming_catalog
SET seasons = CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)
WHERE type = 'TV Show'
AND duration LIKE '%Season%';

SET SQL_SAFE_UPDATES = 1; #Cerramos seguridad

#Verificamos que se hayan rellenado de forma correcta
SELECT
    type,
    COUNT(*) AS total,
    COUNT(duration_minutes) AS con_minutos,
    COUNT(seasons) AS con_temporadas
FROM streaming_catalog
GROUP BY type;

-- Ordenamos columnas
ALTER TABLE streaming_catalog MODIFY COLUMN duration_minutes INT AFTER duration;
ALTER TABLE streaming_catalog MODIFY COLUMN seasons INT AFTER duration_minutes;

-- NORMALIZAR LOS GÉNEROS
#Creamos un id en la tabla
ALTER TABLE streaming_catalog
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE streaming_catalog MODIFY COLUMN id INT FIRST;

#Creamos tabla generos
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) UNIQUE
);

#Creamos tabla puente de titulo - genero
CREATE TABLE title_genres (
    title_id INT,
    genre_id INT,
    PRIMARY KEY (title_id, genre_id)
);

SELECT * FROM genres;

#Nos encontramos con 121 generos distintos. Para poder analizar mejor, creamos nueva columna en tabla genres y agrupamos los generos
SELECT
    g.genre_name,
    COUNT(*) AS total_titles
FROM title_genres tg
JOIN genres g ON tg.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_titles DESC;

ALTER TABLE genres
ADD COLUMN genre_group VARCHAR(100);

SET SQL_SAFE_UPDATES = 0;
-- 1. Action & Adventure
UPDATE genres SET genre_group = 'Action & Adventure'
WHERE genre_name IN ('Action & Adventure', 'Action-Adventure', 'TV Action & Adventure', 'Action', 'Superhero', 'Spy/Espionage', 'Disaster', 'Adventure');

-- 2. Western
UPDATE genres SET genre_group = 'Western'
WHERE genre_name IN ('Western');

-- 3. History & War
UPDATE genres SET genre_group = 'History & War'
WHERE genre_name IN ('History', 'Historical', 'Military and War');

-- 4. Animation & Anime (Mantenemos la unión que sugeriste al final)
UPDATE genres SET genre_group = 'Animation'
WHERE genre_name IN ('Animation', 'Adult Animation', 'Cartoons');

-- 5. Anime
UPDATE genres SET genre_group = 'Anime'
WHERE genre_name IN ('Anime', 'Anime Features', 'Anime Series');

-- 6. Comedy
UPDATE genres SET genre_group = 'Comedy'
WHERE genre_name IN ('Comedy', 'Comedies', 'TV Comedies', 'Romantic Comedy', 'Sitcom', 'Parody', 'Buddy', 'Stand Up', 'Stand-Up Comedy', 'Stand-Up Comedy & Talk Shows', 'Sketch Comedy');

-- 7. Drama & Romance
UPDATE genres SET genre_group = 'Drama & Romance'
WHERE genre_name IN ('Drama', 'Dramas', 'TV Dramas', 'Soap Opera / Melodrama', 'Coming of Age', 'Romance', 'Romantic Movies', 'Romantic TV Shows', 'LGBTQ', 'LGBTQ Movies', 'LGBTQ+');

-- 8. Independent & Arthouse
UPDATE genres SET genre_group = 'Independent & Arthouse'
WHERE genre_name IN ('Independent Movies', 'Arthouse');

-- 9. Kids & Family
UPDATE genres SET genre_group = 'Kids & Family'
WHERE genre_name IN ('Kids', "Kids' TV", 'Children & Family Movies', 'Family', 'Young Adult Audience', 'Teen', 'Teen TV Shows');

-- 10. Horror
UPDATE genres SET genre_group = 'Horror'
WHERE genre_name IN ('Horror', 'Horror Movies', 'TV Horror');

-- 11. Thriller & Mystery
UPDATE genres SET genre_group = 'Thriller & Mystery'
WHERE genre_name IN ('Thriller', 'Thrillers', 'TV Thrillers', 'Suspense', 'Mystery', 'TV Mysteries', 'Police/Cop','Black Stories');

-- 12. Sci-Fi & Fantasy
UPDATE genres SET genre_group = 'Sci-Fi & Fantasy'
WHERE genre_name IN ('Sci-fi', 'Science Fiction', 'Sci-Fi & Fantasy', 'TV Sci-Fi & Fantasy', 'Fantasy', 'Science & Technology');

-- 13. Documentary & News
UPDATE genres SET genre_group = 'Documentary & News'
WHERE genre_name IN ('Documentary', 'Documentaries', 'Docuseries', 'Science & Nature TV', 'Animals & Nature', 'Biographical', 'News', 'News and Information');

-- 14. Reality & Lifestyle
UPDATE genres SET genre_group = 'Reality & Lifestyle'
WHERE genre_name IN ('Reality', 'Reality TV', 'Unscripted', 'Game Shows', 'Game Show / Competition', 'Survival', 'Lifestyle', 'Lifestyle & Culture', 'Health & Wellness', 'Fitness', 'Cooking & Food', 'Travel', 'Talk Show', 'Talk Show and Variety', 'Variety', 'Late Night', 'TV Shows');

-- 15. Music & Arts
UPDATE genres SET genre_group = 'Music & Arts'
WHERE genre_name IN ('Music', 'Music & Musicals', 'Musical', 'Concert Film', 'Music Videos and Concerts', 'Dance', 'Arts', 'and Culture');

-- 16. Classics & International
UPDATE genres SET genre_group = 'Classics & International'
WHERE genre_name IN ('Classics', 'Classic Movies', 'Classic & Cult TV', 'Cult Movies', 'International', 'International Movies', 'International TV Shows', 'British TV Shows', 'Spanish-Language TV Shows', 'Korean TV Shows', 'Latino');

-- 17. Sports
UPDATE genres SET genre_group = 'Classics & International'
WHERE genre_name IN ('Sports Movies', 'Sports');

-- 18. Others (El cajón de sastre final)
UPDATE genres SET genre_group = 'Others'
WHERE genre_name IN ('Faith & Spirituality', 'Faith and Spirituality', 'Special Interest', 'Movies', 'Entertainment', 'Anthology', 'Medical', 'Series');

-- 17. Sports
UPDATE genres SET genre_group = 'Sports'
WHERE genre_group IS NULL OR genre_name IN ('Sports Movies', 'Sports');

-- 18. Others (El cajón de sastre final)
UPDATE genres SET genre_group = 'Others'
WHERE genre_group IS NULL OR genre_name IN ('Faith & Spirituality', 'Faith and Spirituality', 'Special Interest', 'Movies', 'Entertainment', 'Anthology', 'Medical', 'Series');

SET SQL_SAFE_UPDATES = 1;

-- Vemos si hay generos sin nueva agrupación asignada
SELECT 
    genre_id,
    genre_name
FROM genres
WHERE genre_group IS NULL
   OR genre_group = ''
ORDER BY genre_name;

SELECT genre_name, genre_group
FROM genres;

SELECT 
    genre_group,
    COUNT(*) AS n_genres
FROM genres
GROUP BY genre_group
ORDER BY n_genres DESC;

-- Todos los géneros han sido correctamente mapeados a un grupo final--
-- END TABLA GENRES--

-- AGRUPACIÓN RATING EDADES--
-- Hacemos un grupo de clasificación de edades
ALTER TABLE streaming_catalog
ADD COLUMN audience_group VARCHAR(20);

SET SQL_SAFE_UPDATES = 0;
UPDATE streaming_catalog
SET audience_group = 
CASE 
    -- 1. UNIVERSAL (0+ años: Contenido educativo o preescolar)
    WHEN audience IN ('ALL', 'ALL_AGES', 'G', 'TV-G', 'TV-Y') THEN 'Universal'
    
    -- 2. YOUNG KIDS (6-7+ años: Fantasía, aventura suave, supervisión recomendada)
    WHEN audience IN ('7+', 'TV-Y7', 'TV-Y7-FV', 'PG') THEN 'Young Kids'
    
    -- 3. TEENS (13-15 años: Temas juveniles, acción, drama)
    WHEN audience IN ('13+', 'PG-13', 'TV-PG', 'TV-14') THEN 'Teens'
    
    -- 4. ADULTS (16-18+ años: Contenido maduro o restringido)
    WHEN audience IN ('16+', '18+', 'R', 'TV-MA', 'NC-17') THEN 'Adults'
    
    -- 5. UNRATED (Sin clasificación o nulos)
    WHEN audience IN ('NR', 'UR', 'UNRATED', 'NOT_RATE') 
         OR audience IS NULL 
         OR audience = '' THEN 'Unrated'
    
    ELSE 'Unrated'
END;
SET SQL_SAFE_UPDATES = 1;

-- Modificamos orden en la tabla
ALTER TABLE streaming_catalog MODIFY COLUMN audience_group VARCHAR(20) AFTER rating;
ALTER TABLE streaming_catalog RENAME COLUMN rating TO audience;

-- Muchos títulos en Unrated. Búsqueda coincidiencias de titulo con audiencia unrated en cada plataforma y reclasificación---

#Cambio audiencia Unrated de Hulu
SELECT 
    a.title AS titulo_unrated_hulu,
    a.platform AS plataforma_origen,
    b.platform AS plataforma_comparada,
    b.audience_group AS audiencia_en_otra_plataforma
FROM streaming_catalog a
INNER JOIN streaming_catalog b ON a.title = b.title
WHERE a.platform = 'Hulu' 
  AND a.audience_group = 'Unrated'
  AND b.platform <> 'Hulu';
  
SET SQL_SAFE_UPDATES = 0;
UPDATE streaming_catalog AS hulu_table
INNER JOIN streaming_catalog AS other_platforms 
ON hulu_table.title = other_platforms.title
SET hulu_table.audience_group = other_platforms.audience_group
WHERE hulu_table.platform = 'Hulu' 
AND hulu_table.audience_group = 'Unrated'
AND other_platforms.platform <> 'Hulu'
AND other_platforms.audience_group <> 'Unrated';

-- Cambio audiencia Unrated Amazon Prime
SELECT 
    a.title AS titulo_unrated_amazon,
    a.platform AS plataforma_origen,
    b.platform AS plataforma_comparada,
    b.audience_group AS audiencia_en_otra_plataforma
FROM streaming_catalog a
INNER JOIN streaming_catalog b ON a.title = b.title
WHERE a.platform = 'Amazon Prime' 
  AND a.audience_group = 'Unrated'
  AND b.platform <> 'Amazon Prime';
  

UPDATE streaming_catalog AS amazon_table
INNER JOIN streaming_catalog AS other_platforms 
ON amazon_table.title = other_platforms.title
SET amazon_table.audience_group = other_platforms.audience_group
WHERE amazon_table.platform = 'Amazon Prime' 
AND amazon_table.audience_group = 'Unrated'
AND other_platforms.platform <> 'Amazon Prime'
AND other_platforms.audience_group <> 'Unrated';

-- Unrated de Netflix
SELECT 
    a.title AS titulo_unrated_netflix,
    a.platform AS plataforma_origen,
    b.platform AS plataforma_comparada,
    b.audience_group AS audiencia_en_otra_plataforma
FROM streaming_catalog a
INNER JOIN streaming_catalog b ON a.title = b.title
WHERE a.platform = 'Netflix' 
  AND a.audience_group = 'Unrated'
  AND b.platform <> 'Netflix';
  
  UPDATE streaming_catalog AS netflix_table
INNER JOIN streaming_catalog AS other_platforms 
ON netflix_table.title = other_platforms.title
SET netflix_table.audience_group = other_platforms.audience_group
WHERE netflix_table.platform = 'Netflix' 
AND netflix_table.audience_group = 'Unrated'
AND other_platforms.platform <> 'Netflix'
AND other_platforms.audience_group <> 'Unrated';

-- Unrated Disney
SELECT 
    a.title AS titulo_unrated_disney,
    a.platform AS plataforma_origen,
    b.platform AS plataforma_comparada,
    b.audience_group AS audiencia_en_otra_plataforma
FROM streaming_catalog a
INNER JOIN streaming_catalog b ON a.title = b.title
WHERE a.platform = 'Disney' 
  AND a.audience_group = 'Unrated'
  AND b.platform <> 'Disney';
-- Disney no tiene ningún titulo Unrated coincidente con otro catálogo
SET SQL_SAFE_UPDATES = 1;

-- END CLASIFICACIÓN EDAD

-- AÑADIMOS LA PRIMARY Y LA FOREIGN KEY AL MODELO
ALTER TABLE title_genres
ADD CONSTRAINT fk_title
FOREIGN KEY (title_id) REFERENCES streaming_catalog(id),
ADD CONSTRAINT fk_genre
FOREIGN KEY (genre_id) REFERENCES genres(genre_id);

-- RENOMBRAMOS LAS TABLAS RAW PARA MAYOR CLARIDAD
RENAME TABLE netflix_titles TO raw_netflix;
RENAME TABLE amazon_titles TO raw_amazon;
RENAME TABLE disney_titles TO raw_disney;
RENAME TABLE hulu_titles TO raw_hulu;


-- BASE DE DATOS DE IMDB--
#Verificamos si la base de datos de IMDb se ha subido correctamente desde Python:
SELECT COUNT(*) FROM imdb_titles;
SELECT * FROM imdb_titles LIMIT 10;

#Creamos la PK
ALTER TABLE imdb_titles 
MODIFY COLUMN tconst VARCHAR(20) NOT NULL;

ALTER TABLE imdb_titles
ADD PRIMARY KEY (tconst);

#HACEMOS MATCH entre catálogo y IMDb
#Normlización de título
ALTER TABLE streaming_catalog
ADD COLUMN title_clean VARCHAR(255);

SET SQL_SAFE_UPDATES = 0;
UPDATE streaming_catalog
SET title_clean = LOWER(
    REGEXP_REPLACE(
        CONVERT(title USING ascii),
        '[^a-z0-9 ]',
        ''
    )
);
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM  catalog_imdb_match;

#Después de hacer match desde Python, creamos relaciones entre tablas:
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE streaming_catalog 
MODIFY COLUMN id INT NOT NULL;

ALTER TABLE catalog_imdb_match 
MODIFY COLUMN id INT NOT NULL,
MODIFY COLUMN tconst VARCHAR(20) NOT NULL;

-- Definir la clave primaria compuesta
ALTER TABLE catalog_imdb_match
ADD PRIMARY KEY (id, tconst);

-- - Crear relación con el catálogo de streaming
ALTER TABLE catalog_imdb_match
ADD CONSTRAINT fk_streaming
FOREIGN KEY (id) REFERENCES streaming_catalog(id);

-- Crear relación con los títulos de IMDb
ALTER TABLE catalog_imdb_match
ADD CONSTRAINT fk_imdb
FOREIGN KEY (tconst) REFERENCES imdb_titles(tconst);

SET SQL_SAFE_UPDATES = 1;

-- END TABLAS IMDB--


-- CREACIÓN DE VISTAS
#Vista catálogo + generos + ratings
CREATE VIEW vw_streaming_with_genres_and_ratings AS
SELECT
    s.id,
    s.title,
    s.type,
    s.platform,
    s.release_year,
    s.duration_minutes,
    s.seasons,
    s.audience_group,
    g.genre_group,
    i.averageRating,
    i.numVotes,
    m.match_type,
    s.date_added
FROM streaming_catalog s
LEFT JOIN title_genres tg ON s.id = tg.title_id
LEFT JOIN genres g ON tg.genre_id = g.genre_id
LEFT JOIN catalog_imdb_match m ON s.id = m.id
LEFT JOIN imdb_titles i ON m.tconst = i.tconst;

-- Vistas para gráfico solapamiento
CREATE VIEW vw_titles_platforms AS
SELECT 
    LOWER(TRIM(title)) AS title_clean,
    release_year,
    platform
FROM streaming_catalog;

CREATE VIEW vw_platform_overlap AS
SELECT
    a.platform AS platform_1,
    b.platform AS platform_2,
    COUNT(DISTINCT a.title_clean) AS shared_titles
FROM vw_titles_platforms a
JOIN vw_titles_platforms b
    ON a.title_clean = b.title_clean
   AND a.release_year = b.release_year
   AND a.platform <> b.platform
GROUP BY a.platform, b.platform;

-- Vista gráfico de flourish top 6 generos - conteo un único genre_group
CREATE VIEW vw_platform_genre_titles_flourish AS
SELECT 
    s.platform,
    g.genre_group,
    COUNT(DISTINCT s.id) AS total_titles
FROM streaming_catalog s
JOIN title_genres tg ON s.id = tg.title_id
JOIN genres g ON tg.genre_id = g.genre_id
GROUP BY s.platform, g.genre_group;

SELECT *
FROM vw_streaming_with_genres_and_ratings;

-- Vista gráfico top 3 generos
CREATE VIEW vw_platform_top_genres AS
SELECT *
FROM (
    SELECT
        platform,
        genre_group,
        COUNT(*) AS total_titles,
        ROW_NUMBER() OVER (
            PARTITION BY platform
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM streaming_catalog s
    JOIN title_genres tg ON s.id = tg.title_id
    JOIN genres g ON tg.genre_id = g.genre_id
    GROUP BY platform, genre_group
) t
WHERE rn <= 3;






