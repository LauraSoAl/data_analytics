-- Rating medio IMDb
SELECT platform, AVG(averageRating) AS avg_imdb_rating
FROM vw_streaming_with_genres_and_ratings
GROUP BY platform;

-- Lista general Top 6 genres
SELECT genre_group, COUNT(DISTINCT id) AS total
FROM streaming_catalog s
JOIN title_genres tg ON s.id = tg.title_id
JOIN genres g ON tg.genre_id = g.genre_id
GROUP BY genre_group
ORDER BY total DESC
LIMIT 6;

-- TOP 3: Porcentaje de títulos únicos que están cubiertos por el Top 3
WITH top_genres AS (
  SELECT platform, genre_group
  FROM (
    SELECT 
      s.platform, 
      g.genre_group,
      COUNT(DISTINCT s.id) as num_titles,
      RANK() OVER (PARTITION BY s.platform ORDER BY COUNT(DISTINCT s.id) DESC) as rk
    FROM streaming_catalog s
    JOIN title_genres tg ON s.id = tg.title_id
    JOIN genres g ON tg.genre_id = g.genre_id
    GROUP BY s.platform, g.genre_group
  ) t
  WHERE rk <= 3
),
titles_in_top3 AS (
  SELECT s.platform, COUNT(DISTINCT s.id) as count_top3
  FROM streaming_catalog s
  JOIN title_genres tg ON s.id = tg.title_id
  JOIN genres g ON tg.genre_id = g.genre_id
  -- Filtramos: solo títulos cuyo género esté en el Top 3 de su plataforma
  WHERE EXISTS (
    SELECT 1 FROM top_genres tg_top 
    WHERE tg_top.platform = s.platform 
    AND tg_top.genre_group = g.genre_group
  )
  GROUP BY s.platform
),
total_titles AS (
  SELECT platform, COUNT(DISTINCT id) as total
  FROM streaming_catalog
  GROUP BY platform
)
SELECT 
  t.platform,
  ROUND((c.count_top3 * 100.0) / t.total, 1) AS pct_top3
FROM total_titles t
JOIN titles_in_top3 c USING (platform);
-- End total títulos top3 --






