--Netflix Project
drop table if exists netflix;
CREATE TABLE netflix
(
show_id	VARCHAR(6),
type VARCHAR(10),	
title VARCHAR(150),	
director VARCHAR(208),	
castS	VARCHAR(1000),
country	VARCHAR(150),
date_added	VARCHAR(50),
release_year	INT,
rating	VARCHAR(10),
duration	VARCHAR(15),
listed_in	VARCHAR(150),
description VARCHAR(250)

);

select * from netflix;


select
    count(*) as total_content
from netflix;

select 
     distinct type
from netflix;

-- 1. count the number of movies vs tv shows

select type,
    count (*) as total_content
from netflix
group by type;

-- 2. Find the most common rating for movies & tv shows

select type,
     rating from (
select type,
     rating,count(*),
     rank() over (partition by type order by count(*)desc) as ranking
from netflix
group by 1,2
) as t1
where ranking = 1

-- 3.list all the movies released in a specific year (e.g - 2020)
  
  --Filter 2020
   --movies
   Select * from netflix
   where 
         type = 'Movie'
		 and
		 release_year = 2020
	
-- 4.Find the top 5 countries with thye most content on netflix 

Select 
      unnest (string_to_array(country,',')) as new_country,
	  count(show_id) as total_content
from netflix
group by 1

-- 5.Identify the longest movie 

Select * from netflix 
where 
      type = 'Movie'
	  and
	  duration = (select max(duration) from netflix)
	  
-- 6.Find the content added in the last 5 years

Select * from netflix
where 
      to_date(date_added,'Month DD,YYYY') >= current_date - interval'5 years'
	  
-- 7.find all the movies/Tv shows by director "Rajiv Chilaka"

select * from netflix
where director ILike '%Rajiv Chilaka%'

-- 8.List all tv shows with the more than 5 seasons

Select * from netflix
where 
     type ='TV Show'
	 and
	 split_part(duration,' ',1)::numeric >5
	 
-- 9.count the number of content item in each genre

Select 
       unnest (string_to_array(listed_in,',')) as genre,
	   count(show_id) as total_content
from netflix
group by 1

-- 10.Find each year & avg number of content release in india on netflix . return top 5 year with highest avg content release

Select 
       extract (year from to_date(date_added,'Month DD,YYYY')) as year,
	   count(*) as yearly_content,
	   round(count(*)::numeric/(select 
	                                  count(*) from netflix
									  where country ='India')::numeric * 100,2)
									  as avg_content_per_year
from netflix
where country ='India'
group by 1

-- 11.List all the movies that are documentaries

Select * from netflix
where 
      listed_in ILIKE '%Documentaries%'
	  
-- 12.Find all the content without a director 

select * from netflix
where director is null

-- 13.Find how many movies actor "Salman Khan" appeared in last 10 years 

Select * from netflix
where 
      casts ILike '%Salman Khan%'
	  and
	  release_year > extract(year from current_date)-10
	  
-- 14.Find the top 10 actors who have appeared in the highest number of movies produced in india 

Select
      unnest (string_to_array(casts,',')) as actors,
	  count(*) as total_content
from netflix
where country ilike '%India'
group by 1
order by 2 Desc
Limit 10

-- 15.categories the content based on the presence of the keyword 'kill' & 'violience' in the description field 
label content containing these keywods as 'bad' & all othet content as 'good' .
count how many items fall in to each categories.

With new_table
as(
    select *,
	         case
			 when
			      description ilike '%Kill%' or
				  description ilike '%Violence%' then 'Bad Content'
				  Else 'Good Content'
			 end category 
	from netflix		 
  ) select category,
                    count(*) as total_content
	from new_table
	group by 1
