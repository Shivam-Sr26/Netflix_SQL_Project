-- Netflix Project
CREATE DATABASE netflix_project;
USE netflix_project;

DROP TABLE if EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix;

SELECT 
COUNT(*) as total_content 
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

-- Business Problems and Solutions
-- Q1. Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- Q2. Find the Most Common Rating for Movies and TV Shows

SELECT
	type,
    rating
FROM
(
	SELECT
		type,
        rating,
        COUNT(*),
		RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
    GROUP BY 1, 2
) as t1
WHERE
	ranking = 1;
    
-- Q3. List All Movies Released in a Specific Year (e.g., 2020)
    
SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
    AND
	release_year = 2020;
    
-- Q4. Find the Top 5 Countries with the Most Content on Netflix

SELECT
	TRIM(SUBSTRING_INDEX(country, ',', 1)) AS new_country,
    COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q5. Identify the Longest Movie

SELECT *
FROM netflix
	WHERE 
	type = 'Movie'
    AND
	duration = (SELECT MAX(duration) FROM netflix);

-- Q6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- Q7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE FIND_IN_SET('Rajiv Chilaka', REPLACE(director, ', ', ',')) > 0;

-- Q8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND 
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- Q9. Count the Number of Content Items in Each Genre

SELECT 
    TRIM(JSON_UNQUOTE(jt.genre)) AS genre,
    COUNT(*) AS total_content
FROM netflix n
JOIN JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(TRIM(n.listed_in), ', ', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (genre VARCHAR(255) PATH '$')
) AS jt
WHERE genre <> ''
GROUP BY genre
ORDER BY total_content DESC;

-- Q10.Find each year and the average numbers of content release in India on netflix
	-- return top 5 year with highest avg content release

SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) * 100.0 /
        (SELECT COUNT(show_id) 
         FROM netflix 
         WHERE FIND_IN_SET('India', REPLACE(country, ', ', ',')) > 0), 2
    ) AS avg_release_percentage
FROM netflix
WHERE FIND_IN_SET('India', REPLACE(country, ', ', ',')) > 0
GROUP BY release_year
ORDER BY avg_release_percentage DESC
LIMIT 5;

-- Q11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- Q12. Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

-- Q13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- Q14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    TRIM(JSON_UNQUOTE(jt.actor)) AS actor,
    COUNT(*) AS total_movies
FROM netflix n
JOIN JSON_TABLE(
    CONCAT(
        '["',
        REPLACE(TRIM(n.casts), ', ', '","'),
        '"]'
    ),
    '$[*]' COLUMNS (actor VARCHAR(255) PATH '$')
) AS jt
WHERE jt.actor <> ''
  AND n.type = 'Movie'
  AND FIND_IN_SET('India', REPLACE(n.country, ', ', ',')) > 0
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;

-- Q15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' 
              OR LOWER(description) LIKE '%violence%' 
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

















