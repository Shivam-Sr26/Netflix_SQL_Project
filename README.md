# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
CREATE DATABASE netflix_project;
USE netflix_project;

DROP TABLE IF EXISTS netflix;
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
```

## Analyzing
```sql
SELECT * FROM netflix;

SELECT 
COUNT(*) as total_content 
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

```
## Business Problems and Solutions

### Q1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type;
```

### Q2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### Q3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
    AND
	release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### Q4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	TRIM(SUBSTRING_INDEX(country, ',', 1)) AS new_country,
    COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### Q5. Identify the Longest Movie

```sql
SELECT *
FROM netflix
	WHERE 
	type = 'Movie'
    AND
	duration = (SELECT MAX(duration) FROM netflix);
```

**Objective:** Find the movie with the longest duration.

### Q6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### Q7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE FIND_IN_SET('Rajiv Chilaka', REPLACE(director, ', ', ',')) > 0;
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### Q8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND 
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### Q9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### Q10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### Q11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### Q12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;

```

**Objective:** List content that does not have a director.

### Q13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### Q14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### Q15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Shivam Srivastava

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles.

- **LinkedIn**: (https://www.linkedin.com/in/shivam-srivastava-463259370/)
- **Email**: shivammjj@gmail.com

Thank you for your support, and I look forward to connecting with you!
