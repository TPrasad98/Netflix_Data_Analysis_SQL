create database netflix_data_analysis;


-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;


SELECT count(*) FROM netflix;


-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems


-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) AS total_count
FROM netflix
GROUP BY 1;


-- 2. Find the most common rating for movies and TV shows

-- USING SUB_QUERIES
SELECT
	type,
	rating,
	rating_count
FROM
	(SELECT 
	      type,
	      rating,
	      COUNT(*) AS rating_count,
	      RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
	FROM netflix
	GROUP BY 1,2) X1
WHERE
	X1.rank = 1
;

-- USING CTE

WITH rating_count
AS
	(
	SELECT 
	      type,
	      rating,
	      COUNT(*) AS rating_count,
	      RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
	FROM netflix
	GROUP BY 1,2
	)
SELECT
	type,
	rating,
	rating_count
FROM rating_count
WHERE rank = 1
;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT
	title
FROM netflix
WHERE 
	type = 'Movie'
	and release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix


SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as country,
COUNT(*) as total_content
FROM netflix
GROUP BY 1
ORDER BY total_content desc
limit 5;



-- 5. Identify the longest movie

SELECT title, duration
FROM netflix
WHERE type = 'Movie' 
AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;


-- 6. Find content added in the last 5 years

SELECT
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD,YYYY') >= current_date - interval '5 years' ;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
	title,
	type,
	director_name
FROM (
	SELECT *,
	UNNEST(STRING_TO_ARRAY(director,',')) as director_name
	FROM netflix 
)
WHERE director_name = 'Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons

SELECT * 
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration,' ',1)::INT >5 ;

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !



SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY 1, 2
ORDER BY avg_release DESC 
LIMIT 5;


-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'
AND type = 'Movie'


-- 12. Find all content without a director
	
SELECT * FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	unnest(STRING_TO_ARRAY(casts,',')) AS actors,
	COUNT(*) AS movie_count
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 desc
LIMIT 10


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


-- USING SUBQUERIES
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2



-- USING CTE

WITH categorized_content
AS(
	SELECT
		*,
		CASE
			WHEN description ILIKE '%KILL%' OR description ILIKE '%VIOLENCE%' THEN 'Bad'
			ELSE 'Good'
			END AS category
		FROM netflix
)
SELECT 
	category,
	type,
	COUNT(*) AS content_count
FROM categorized_content
GROUP BY 1,2
ORDER BY 2 