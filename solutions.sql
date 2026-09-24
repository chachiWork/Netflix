--Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
	show_id	VARCHAR(10),
	type VARCHAR(10),	
	title VARCHAR(150),	
	director VARCHAR(208),	
	casts VARCHAR(1000) ,	
	country VARCHAR(150),	
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);
SELECT * FROM netflix;
SELECT COUNT (*) as total_count 
FROM netflix;


--Business Problems
-- Q.1.Count the number of Movies  vs TV Shows
SELECT type,
      COUNT(*) as Num_counts
FROM netflix
GROUP BY 1;

--Q.2 Find the most common rating for movies and TV shows 
SELECT type,
       rating
FROM
(
SELECT type,
       rating,
      COUNT(*),
	  RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as rank 
FROM netflix
GROUP BY 1,2

) as t1
WHERE rank = 1

-- Q.3 List all movies released in a specific year(e.g., 2020)

 SELECT title ,
        release_year
 FROM netflix 
 WHERE 
	 release_year = 2020
	 AND 
	 type = 'Movie'
	 
-- Q.4. Find the top 5 countries with the most content on Netflix
 SELECT 
	 TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country ,
	 COUNT(*) as cnt
 FROM netflix
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 5

 -- Q.5 Identify the longest movie?
SELECT title,
       CAST(REPLACE(duration, ' min', '') AS INTEGER) as movie_min
FROM netflix
WHERE type = 'Movie'
GROUP BY 1, duration
ORDER BY movie_min DESC

--Q.6 Find content added in the last years 
SELECT title,
       TO_DATE(date_added, 'Month DD, YYYY')
FROM netflix
WHERE
  TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--Q.7 Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title,
       director
FROM netflix
WHERE director ILIKE'%Rajiv Chilaka%'

-- Q.8 List all TV shows with more than 5 seasons

SELECT *
  		
FROM netflix
WHERE 
	type = 'TV Show'
	 AND
	SPLIT_PART(duration, ' ',1)::numeric > 5
	
--Q.9 Count the number of content items in each genre
SELECT 
       UNNEST(STRING_TO_ARRAY(listed_in ,',')),
	   COUNT(*) as cnt
FROM netflix
GROUP BY 1

-- Q.10 Find each year and the average numbers of content release by India on netflix
-- return top 5 year with highest avg content release !
SELECT 
	EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD, YYYY') ) as year_content ,
	COUNT(*),
	ROUND(
	COUNT (*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 
	,2) AS avg_
FROM netflix 
WHERE country = 'India'
GROUP BY 1

--Q.11 List all movies tht are documentaries 
SELECT *
FROM netflix 
 WHERE 
 listed_in ILIKE '%documentaries%'
 AND
 type = 'Movie' ;
 


-- Q.12 Find all content without a director
SELECT * 
FROM netflix
WHERE director IS NULL

-- Q.13 Find how many movie actor 'Salman Khan ' appeared in last 10 years

SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND 
    release_year > EXTRACT(YEAR FROM CURRENT_DATE ) - 10;


SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND 
    EXTRACT(YEAR FROM TO_DATE(date_added , 'Month DD, YYYY') ) > EXTRACT(YEAR FROM CURRENT_DATE ) - 10

-- Q.14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST(STRING_TO_ARRAY (casts,',')) as actor_movie,
       COUNT (show_id) as num_movies 
	
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--Q.15 Categorize the content based on the presence of the keywords 'kill ' and 'violence ' in 
-- the description field. Label content containing these keywords as 'Bad' and all other
-- content as 'Good'. Count how many items fall into each category.
SELECT category,
     COUNT(show_id) as cnt
FROM
(SELECT show_id,
  CASE 
    WHEN description ILIKE '%kill%' OR description ILIKE '%violence%'
	     THEN 'BAD'
	ELSE 'Good'
  END AS category 
	
FROM netflix

) AS t1 
GROUP BY category;
