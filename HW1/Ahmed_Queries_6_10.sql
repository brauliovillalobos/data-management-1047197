# DB Pre-Processing:
# 1. Combine games_city & city into games_city
# 2. Combine noc_region & city into person_region into person_region
##################################################################
# Q6
# What countries won medals in the Swimming games, 
# and what is the medal counts per each country?.
# Execution time: 3 ~ 6 Seconds.
SELECT nr.region_name, 
	   m.medal_name, COUNT(*) as number_medals
FROM olympics.sport s, 
	 olympics.event e,
     olympics.medal m,
	 olympics.competitor_event ce,
     olympics.games_competitor gc,
     olympics.person p,
     olympics.person_region pr,
     olympics.noc_region nr
     
WHERE s.id = e.sport_id 
AND event_name LIKE '%swim%'
AND e.id = ce.event_id
AND m.id = ce.medal_id
AND m.medal_name != 'NA'
AND gc.id = ce.competitor_id
AND p.id = gc.person_id
AND pr.person_id = p.id
AND pr.region_id = nr.id

GROUP BY  m.medal_name, nr.region_name
ORDER BY nr.region_name, number_medals DESC
;
##################################################################
# Q7
# What's the age of the oldest persons who won a Golden medal
# for each country and what is their sport?
# Execution time: ~ 1 Seconds.
SELECT nr.region_name, 
	   p.full_name, 
	   MAX(age) as oldest_winner_age, 
       s.sport_name
FROM olympics.medal m,
	 olympics.competitor_event ce,
     olympics.event e,
     olympics.sport s,
     olympics.games_competitor gc,
	 olympics.person p,
     olympics.person_region pr,
     olympics.noc_region nr
     
WHERE m.id = ce.medal_id
AND ce.event_id = e.id
AND e.sport_id  = s.id
AND ce.competitor_id = gc.id
AND m.medal_name = 'Gold'
AND p.id = gc.person_id
AND pr.person_id = p.id
AND pr.region_id = nr.id

GROUP BY nr.region_name
ORDER BY oldest_winner_age DESC
;
##################################################################
# Q8
# List the sports played by tallest people ever. 
# And list their nationalities, age and genders?
# Execution time: ~ 80 Seconds.
SELECT s.sport_name, 
	   MAX(p.height) as max_height, 
       p.gender,
       nr.region_name
FROM olympics.competitor_event ce,
	 olympics.event e,
     olympics.sport s,
     olympics.games_competitor gc,
     olympics.person p,
     olympics.person_region pr,
     olympics.noc_region nr
     
WHERE ce.event_id = e.id
AND e.sport_id  = s.id
AND gc.id = ce.competitor_id
AND p.id = gc.person_id
AND pr.person_id = p.id
AND pr.region_id = nr.id

GROUP BY s.sport_name
ORDER BY max_height DESC
;
##################################################################
# Q9
# List the total number of won medals for each country. 
# And for which sport each country won the highest number of these medals?
# Execution time: 43 ~ 45 Seconds.

# Execution Plan
# 1. Create a Temporary table to display the total number of won medals 
# 	for each country.
# 2. Create a temporary table to display the dominant sport for each 
# 	country and the number of won medals for this sport.
# 3. Join them together.
################################
WITH 
	# 1. A Temporary table to display the total number of won medals 
    # for each country.
	total AS (
		SELECT nr.region_name, 
			   COUNT(m.medal_name) as tot_num_medals
		FROM olympics.medal m,
			 olympics.competitor_event ce,
			 olympics.event e,
			 olympics.sport s,
			 olympics.games_competitor gc,
			 olympics.person p,
			 olympics.person_region pr,
			 olympics.noc_region nr 

		WHERE m.id = ce.medal_id
		AND ce.event_id = e.id
		AND e.sport_id  = s.id
		AND ce.competitor_id = gc.id
		AND p.id = gc.person_id
		AND pr.person_id = p.id
		AND pr.region_id = nr.id
		AND m.medal_name != 'NA'
		
		GROUP BY nr.region_name
		ORDER BY tot_num_medals DESC),
	
    # 2. A temporary table to display the dominant sport for each 
	# country and the number of won medals for this sport.
    dominant AS (
		SELECT region_name, 
			   sport_name as dominant_sport, 
			   MAX(tot_num_medals) as dominant_num_medals
		FROM (
		SELECT nr.region_name, 
			   s.sport_name, 
               COUNT(m.medal_name) as tot_num_medals
		FROM olympics.medal m,
			 olympics.competitor_event ce,
			 olympics.event e,
			 olympics.sport s,
			 olympics.games_competitor gc,
			 olympics.person p,
			 olympics.person_region pr,
			 olympics.noc_region nr 

		WHERE m.id = ce.medal_id
		AND ce.event_id = e.id
		AND e.sport_id  = s.id
		AND ce.competitor_id = gc.id
		AND p.id = gc.person_id
		AND pr.person_id = p.id
		AND pr.region_id = nr.id
		AND m.medal_name != 'NA'
		
		GROUP BY nr.region_name, s.sport_name
		ORDER BY tot_num_medals DESC) subquery

		GROUP BY region_name)

SELECT total.*, 
	   dominant.dominant_sport, 
       dominant.dominant_num_medals
FROM total
JOIN dominant
ON total.region_name = dominant.region_name
;
##################################################################
# Q10
# What is the percentage of number of won medals 
# for each country over the last ten years compared to 
# the whole period (20 years, 1896 to 2016)?
# Execution Time: ~ 30 seconds.

# Execution Plan:
# 1. List the total number of medals from 1896 to 2006.
# 2. Then List the same over last 10 years (from 2006 until 2016).
# 3. Divide 2 by 1, then multiply by 100 to get the percentage 
# 	 of last 10 years medals.
################################
SELECT region_name, 
       tot20years_num_medals,
       (tot20years_num_medals - last10years_num_medals) AS '1896-2015',
       last10years_num_medals AS '2006-2016',
       # 3. Divide 2 by 1, then multiply by 100 to get the percentage of last 10 years medals.
       TRUNCATE(((last10years_num_medals / tot20years_num_medals) * 100), 2) AS last_10years_pct

FROM (
	WITH 
		# 1. List the total number of medals from 1896 to 2006.
		tot20years AS (
			SELECT nr.region_name, 
				   COUNT(m.medal_name) as tot20years_num_medals
			FROM olympics.medal m,
				 olympics.competitor_event ce,
				 olympics.event e,
				 olympics.sport s,
				 olympics.games_competitor gc,
				 olympics.games g,
				 olympics.person p,
				 olympics.person_region pr,
				 olympics.noc_region nr 

			WHERE m.id = ce.medal_id
			AND ce.event_id = e.id
			AND e.sport_id  = s.id
			AND ce.competitor_id = gc.id
			AND g.id = gc.games_id
			AND p.id = gc.person_id
			AND pr.person_id = p.id
			AND pr.region_id = nr.id
			AND m.medal_name != 'NA'

			GROUP BY nr.region_name
			ORDER BY tot20years_num_medals DESC),

		# 2. Then List the same over last 10 years (from 2006 until 2016).
        last10years AS (
			# 2. Then List the same from 1896 until 2016 (End of the DB)
			SELECT nr.region_name, 
				   COUNT(m.medal_name) as last10years_num_medals
			FROM olympics.medal m,
				 olympics.competitor_event ce,
				 olympics.event e,
				 olympics.sport s,
				 olympics.games_competitor gc,
				 olympics.games g,
				 olympics.person p,
				 olympics.person_region pr,
				 olympics.noc_region nr 

			WHERE m.id = ce.medal_id
			AND ce.event_id = e.id
			AND e.sport_id  = s.id
			AND ce.competitor_id = gc.id
			AND g.id = gc.games_id
			AND p.id = gc.person_id
			AND pr.person_id = p.id
			AND pr.region_id = nr.id
			AND m.medal_name != 'NA'
			AND g.games_year BETWEEN 2005 AND 2016

			GROUP BY nr.region_name
			ORDER BY last10years_num_medals DESC)


	# FULL OUTER JOIN the previous two tables.
	(SELECT tot20years.*, IFNULL(last10years.last10years_num_medals, 0) AS last10years_num_medals
	FROM tot20years
	LEFT JOIN last10years
	ON tot20years.region_name = last10years.region_name)
	UNION ALL
	(SELECT tot20years.*, IFNULL(last10years.last10years_num_medals, 0) AS last10years_num_medals
	FROM tot20years
	RIGHT JOIN last10years
	ON tot20years.region_name = last10years.region_name
	WHERE tot20years.region_name IS NULL)) subquery
;