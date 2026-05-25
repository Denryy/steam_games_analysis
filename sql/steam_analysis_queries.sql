-- 1. Проверка количества строк в таблице
SELECT COUNT(*) AS total_rows
FROM steam_games;

-- 2. Общая сводка по датасету
SELECT
    COUNT(*) AS total_games,
    COUNT(DISTINCT developers) AS unique_developers,
    COUNT(DISTINCT publishers) AS unique_publishers,
    ROUND(AVG(final_price)::numeric, 2) AS avg_final_price,
    ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations,
    MIN(release_year) AS min_release_year,
    MAX(release_year) AS max_release_year
FROM steam_games;

-- 3. Количество игр по годам
SELECT release_year, COUNT(*) AS game_count
FROM steam_games
WHERE release_year IS NOT NULL
GROUP BY release_year
ORDER BY release_year;

-- 4. Сравнение бесплатных и платных игр
SELECT is_free, COUNT(*) AS game_count, ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations, ROUND(AVG(final_price)::numeric, 2) AS avg_price
FROM steam_games
GROUP BY is_free
ORDER BY game_count DESC;

-- 5. Топ 15 игр по количеству рекомендаций
SELECT name, developers, publishers, final_price, recommendations, release_year
FROM steam_games
WHERE recommendations IS NOT NULL
ORDER BY recommendations DESC
LIMIT 15;

-- 6. Топ 15 разработчиков по количеству игр
SELECT developers, COUNT(*) AS game_count, ROUND(AVG(final_price)::numeric, 2) AS avg_price, ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations
FROM steam_games
WHERE developers IS NOT NULL
GROUP BY developers
ORDER BY game_count DESC
LIMIT 15;

-- 7. Топ 15 издателей по количеству игр
SELECT publishers, COUNT(*) AS game_count, ROUND(AVG(final_price)::numeric, 2) AS avg_price, ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations
FROM steam_games
WHERE publishers IS NOT NULL
GROUP BY publishers
ORDER BY game_count DESC
LIMIT 15;

-- 8. Анализ по ценовым категориям
SELECT price_category, COUNT(*) AS game_count, ROUND(AVG(final_price)::numeric, 2) AS avg_price, ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations, ROUND(MIN(final_price)::numeric, 2) AS min_price, ROUND(MAX(final_price)::numeric, 2) AS max_price
FROM steam_games
WHERE price_category IS NOT NULL
GROUP BY price_category
ORDER BY avg_price;

-- 9. Количество игр по поддерживаемым платформам
SELECT 'Windows' AS platform, COUNT(*) AS game_count
FROM steam_games
WHERE platform_windows = true
UNION ALL
SELECT 'Mac' AS platform, COUNT(*) AS game_count
FROM steam_games
WHERE platform_mac = true
UNION ALL
SELECT 'Linux' AS platform, COUNT(*) AS game_count
FROM steam_games
WHERE platform_linux = true
ORDER BY game_count DESC;

-- 10. Анализ игр со скидками
SELECT COUNT(*) AS discounted_games, ROUND(AVG(discount_percent)::numeric, 2) AS avg_discount, ROUND(AVG(final_price)::numeric, 2) AS avg_final_price, ROUND(AVG(initial_price)::numeric, 2) AS avg_initial_price
FROM steam_games
WHERE discount_percent > 0;

-- 11. Топ 15 игр по оценке Metacritic
SELECT name, developers, publishers, metacritic_score, recommendations, final_price, release_year
FROM steam_games
WHERE metacritic_score > 0
ORDER BY metacritic_score DESC, recommendations DESC
LIMIT 15;

-- 12. Топ 15 жанров по количеству игр
SELECT TRIM(genre) AS genre, COUNT(*) AS game_count
FROM steam_games, unnest(string_to_array(genres, ',')) AS genre
WHERE genres IS NOT NULL
GROUP BY TRIM(genre)
ORDER BY game_count DESC
LIMIT 15;

-- 13. Рейтинг игр внутри каждой ценовой категории по рекомендациям
SELECT name, price_category, final_price, recommendations, release_year,
       RANK() OVER (PARTITION BY price_category ORDER BY recommendations DESC) AS rank_in_category
FROM steam_games
WHERE recommendations IS NOT NULL AND price_category IS NOT NULL
ORDER BY price_category, rank_in_category
LIMIT 50;

-- 14. Среднее количество рекомендаций по жанрам
SELECT TRIM(genre) AS genre, COUNT(*) AS game_count, ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations
FROM steam_games, unnest(string_to_array(genres, ',')) AS genre
WHERE genres IS NOT NULL
GROUP BY TRIM(genre)
HAVING COUNT(*) >= 20
ORDER BY avg_recommendations DESC
LIMIT 15;

-- 15. Средняя цена по жанрам
SELECT TRIM(genre) AS genre, COUNT(*) AS game_count, ROUND(AVG(final_price)::numeric, 2) AS avg_price, ROUND(MIN(final_price)::numeric, 2) AS min_price, ROUND(MAX(final_price)::numeric, 2) AS max_price
FROM steam_games, unnest(string_to_array(genres, ',')) AS genre
WHERE genres IS NOT NULL
GROUP BY TRIM(genre)
HAVING COUNT(*) >= 20
ORDER BY avg_price DESC
LIMIT 15;

-- 16. Самая популярная игра каждого года по рекомендациям
WITH ranked_games AS (
    SELECT name, release_year, recommendations, final_price,
           ROW_NUMBER() OVER (PARTITION BY release_year ORDER BY recommendations DESC) AS rn
    FROM steam_games
    WHERE release_year IS NOT NULL AND recommendations IS NOT NULL
)
SELECT name, release_year, recommendations, final_price
FROM ranked_games
WHERE rn = 1
ORDER BY release_year;

-- 17. Сравнение цены игры со средней ценой своей категории
SELECT name, price_category, final_price,
       ROUND(AVG(final_price) OVER (PARTITION BY price_category)::numeric, 2) AS avg_category_price,
       ROUND((final_price - AVG(final_price) OVER (PARTITION BY price_category))::numeric, 2) AS price_difference
FROM steam_games
WHERE price_category IS NOT NULL
ORDER BY ABS(final_price - AVG(final_price) OVER (PARTITION BY price_category)) DESC
LIMIT 30;

-- 18. Сравнение игры со средней популярностью её жанра
WITH game_genres AS (
    SELECT appid, name, TRIM(genre) AS genre, recommendations
    FROM steam_games, unnest(string_to_array(genres, ',')) AS genre
    WHERE genres IS NOT NULL
),
genre_stats AS (
    SELECT genre, ROUND(AVG(recommendations)::numeric, 2) AS avg_genre_recommendations
    FROM game_genres
    GROUP BY genre
)
SELECT g.name, g.genre, g.recommendations, s.avg_genre_recommendations,
       ROUND((g.recommendations - s.avg_genre_recommendations)::numeric, 2) AS difference_from_genre_avg
FROM game_genres g
JOIN genre_stats s ON g.genre = s.genre
ORDER BY difference_from_genre_avg DESC
LIMIT 30;

-- 19. Накопительное количество игр по годам
WITH yearly_games AS (
    SELECT release_year, COUNT(*) AS game_count
    FROM steam_games
    WHERE release_year IS NOT NULL
    GROUP BY release_year
)
SELECT release_year, game_count,
       SUM(game_count) OVER (ORDER BY release_year) AS cumulative_games
FROM yearly_games
ORDER BY release_year;

-- 20. Топ 15 издателей по общему количеству рекомендаций
SELECT publishers, COUNT(*) AS game_count, SUM(recommendations) AS total_recommendations, ROUND(AVG(recommendations)::numeric, 2) AS avg_recommendations
FROM steam_games
WHERE publishers IS NOT NULL
GROUP BY publishers
HAVING COUNT(*) >= 3
ORDER BY total_recommendations DESC
LIMIT 15;