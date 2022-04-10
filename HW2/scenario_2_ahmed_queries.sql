# DB Pre-Processing:
# 1. Combine noc_region & city into person_region into person_region
##################################################################
# Q6
# What countries won medals in the Swimming games, 
# and what is the medal counts per each country?.
# Execution time: 3 ~ 6 Seconds.
SELECT pr.region_name, 
	   m.medal_name, COUNT(*) as number_medals
FROM olympics_scen_2.sport s, 
	 olympics_scen_2.event e,
     olympics_scen_2.medal m,
	 olympics_scen_2.competitor_event ce,
     olympics_scen_2.games_competitor gc,
     olympics_scen_2.person p,
     olympics_scen_2.person_region pr
     
WHERE s.id = e.sport_id 
AND event_name LIKE '%swim%'
AND e.id = ce.event_id
AND m.id = ce.medal_id
AND m.medal_name != 'NA'
AND gc.id = ce.competitor_id
AND p.id = gc.person_id
AND pr.person_id = p.id

GROUP BY  m.medal_name, pr.region_name
ORDER BY pr.region_name, number_medals DESC
;
##################################################################
# Q7
# What's the age of the oldest persons who won a Golden medal
# for each country and what is their sport?
# Execution time: ~ 1 Seconds.
WITH
	all_ AS (
		SELECT gc.age,
			   pr.region_name,
               p.full_name, 
               s.sport_name
		FROM olympics_scen_2.medal m,
			 olympics_scen_2.competitor_event ce,
			 olympics_scen_2.event e,
			 olympics_scen_2.sport s,
			 olympics_scen_2.games_competitor gc,
			 olympics_scen_2.person p,
			 olympics_scen_2.person_region pr
			 
		WHERE m.id = ce.medal_id
		AND ce.event_id = e.id
		AND e.sport_id  = s.id
		AND ce.competitor_id = gc.id
		AND m.medal_name = 'Gold'
		AND p.id = gc.person_id
		AND pr.person_id = p.id),
	
    oldest_p AS (
		SELECT region_name, 
			   MAX(age) AS oldest_winner_age
		FROM all_
        GROUP BY region_name)

SELECT oldest_p.region_name, oldest_winner_age, full_name, sport_name
FROM oldest_p
JOIN all_
ON all_.region_name = oldest_p.region_name
AND all_.age = oldest_p.oldest_winner_age
ORDER BY oldest_winner_age DESC
;
##################################################################
# Q8
# List the sports played by tallest people ever. 
# And list their nationalities, age and genders?
# Execution time: ~ 5 Seconds.
WITH 
	all_ AS (
		SELECT s.sport_name, 
			   p.height, 
			   p.gender,
			   pr.region_name,
               gc.age
		FROM olympics_scen_2.competitor_event ce,
			 olympics_scen_2.event e,
			 olympics_scen_2.sport s,
			 olympics_scen_2.games_competitor gc,
			 olympics_scen_2.person p,
			 olympics_scen_2.person_region pr
			 
		WHERE ce.event_id = e.id
		AND e.sport_id  = s.id
		AND gc.id = ce.competitor_id
		AND p.id = gc.person_id
		AND pr.person_id = p.id),
        
	tallest AS (
		SELECT sport_name, 
			   MAX(height) as max_height
		FROM all_
		GROUP BY sport_name
        )
SELECT all_.sport_name, 
	   max_height,
       region_name,
       gender,
       age
FROM all_
JOIN tallest
ON all_.height = tallest.max_height
AND all_.sport_name = tallest.sport_name
ORDER BY max_height DESC
;
##################################################################
# Q9
# List the total number of won medals for each country. 
# And for which sport each country won the highest number of these medals?
# Execution time: ~ 10 Seconds.

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
		SELECT pr.region_name, 
			   COUNT(m.medal_name) AS tot_num_medals
		FROM olympics_scen_2.medal m,
			 olympics_scen_2.competitor_event ce,
			 olympics_scen_2.event e,
			 olympics_scen_2.sport s,
			 olympics_scen_2.games_competitor gc,
			 olympics_scen_2.person p,
			 olympics_scen_2.person_region pr

		WHERE m.id = ce.medal_id
		AND ce.event_id = e.id
		AND e.sport_id  = s.id
		AND ce.competitor_id = gc.id
		AND p.id = gc.person_id
		AND pr.person_id = p.id
		AND m.medal_name != 'NA'
		
		GROUP BY pr.region_name
		ORDER BY tot_num_medals DESC),
	
    # 2. A temporary table to display the dominant sport for each 
	# country and the number of won medals for this sport.
    dominant AS (
		WITH 
			# region_name, sport_name, tot_num_medals
            all_ AS (
				SELECT pr.region_name, 
					   s.sport_name AS dominant_sport, 
					   COUNT(m.medal_name) AS tot_num_medals
				FROM olympics_scen_2.medal m,
					 olympics_scen_2.competitor_event ce,
					 olympics_scen_2.event e,
					 olympics_scen_2.sport s,
					 olympics_scen_2.games_competitor gc,
					 olympics_scen_2.person p,
					 olympics_scen_2.person_region pr

				WHERE m.id = ce.medal_id
				AND ce.event_id = e.id
				AND e.sport_id  = s.id
				AND ce.competitor_id = gc.id
				AND p.id = gc.person_id
				AND pr.person_id = p.id
				AND m.medal_name != 'NA'
				
				GROUP BY pr.region_name, s.sport_name),
			
            # region_name, MAX(tot_num_medals) AS dominant_num_medals
            tempo AS (
				SELECT region_name, 
					   MAX(tot_num_medals) AS dominant_num_medals
				FROM all_

				GROUP BY region_name)
    
    
		SELECT all_.region_name, 
			   dominant_sport,
               dominant_num_medals
		FROM all_ JOIN tempo
        ON all_.tot_num_medals = tempo.dominant_num_medals
        AND all_.region_name = tempo.region_name)

SELECT total.*, 
	   dominant.dominant_sport, 
       dominant.dominant_num_medals
FROM total
JOIN dominant
ON total.region_name = dominant.region_name
ORDER BY tot_num_medals DESC
;
##################################################################
# Same question, simpler logic for HW2
# Execution time: ~ 5 Seconds.
################################
WITH 
	all_ AS (
		SELECT pr.region_name, 
			   s.sport_name, 
			   COUNT(m.medal_name) AS num_medals
		FROM olympics_scen_2.medal m,
			 olympics_scen_2.competitor_event ce,
			 olympics_scen_2.event e,
			 olympics_scen_2.sport s,
			 olympics_scen_2.games_competitor gc,
			 olympics_scen_2.person p,
			 olympics_scen_2.person_region pr

		WHERE m.id = ce.medal_id
		AND ce.event_id = e.id
		AND e.sport_id  = s.id
		AND ce.competitor_id = gc.id
		AND p.id = gc.person_id
		AND pr.person_id = p.id
		AND m.medal_name != 'NA'
		
		GROUP BY pr.region_name, s.sport_name),
	
    tot AS (
		SELECT region_name, 
			   SUM(num_medals) AS tot_num_medals
		FROM all_
        GROUP BY region_name),
	dominant AS (
		SELECT region_name, 
			   MAX(num_medals) AS dominant_num_medals
        FROM all_
        GROUP BY region_name
    )

SELECT all_.region_name,
	   tot.tot_num_medals,
       all_.sport_name AS dominant_sport,
       dominant.dominant_num_medals

FROM all_ JOIN tot
ON all_.region_name = tot.region_name
JOIN dominant
ON all_.region_name = dominant.region_name
AND all_.num_medals = dominant.dominant_num_medals        
ORDER BY tot_num_medals DESC
;
##################################################################
# Q10
# What is the percentage of number of won medals 
# for each country over the last ten years compared to 
# the whole period (20 years, 1896 to 2016)?
# Execution Time: ~ 9 seconds.

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
			SELECT pr.region_name, 
				   COUNT(m.medal_name) as tot20years_num_medals
			FROM olympics_scen_2.medal m,
				 olympics_scen_2.competitor_event ce,
				 olympics_scen_2.event e,
				 olympics_scen_2.sport s,
				 olympics_scen_2.games_competitor gc,
				 olympics_scen_2.games g,
				 olympics_scen_2.person p,
				 olympics_scen_2.person_region pr

			WHERE m.id = ce.medal_id
			AND ce.event_id = e.id
			AND e.sport_id  = s.id
			AND ce.competitor_id = gc.id
			AND g.id = gc.games_id
			AND p.id = gc.person_id
			AND pr.person_id = p.id
			AND m.medal_name != 'NA'

			GROUP BY pr.region_name
			ORDER BY tot20years_num_medals DESC),

		# 2. Then List the same over last 10 years (from 2006 until 2016).
        last10years AS (
			# 2. Then List the same from 1896 until 2016 (End of the DB)
			SELECT pr.region_name, 
				   COUNT(m.medal_name) as last10years_num_medals
			FROM olympics_scen_2.medal m,
				 olympics_scen_2.competitor_event ce,
				 olympics_scen_2.event e,
				 olympics_scen_2.sport s,
				 olympics_scen_2.games_competitor gc,
				 olympics_scen_2.games g,
				 olympics_scen_2.person p,
				 olympics_scen_2.person_region pr

			WHERE m.id = ce.medal_id
			AND ce.event_id = e.id
			AND e.sport_id  = s.id
			AND ce.competitor_id = gc.id
			AND g.id = gc.games_id
			AND p.id = gc.person_id
			AND pr.person_id = p.id
			AND m.medal_name != 'NA'
			AND g.games_year BETWEEN 2005 AND 2016

			GROUP BY pr.region_name
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
##################################################################
# Q10, simpler logic for HW2
# Execution time: ~ ? Seconds.
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
		medals_per_country AS (
			SELECT pr.region_name, 
				   m.medal_name,
				   g.games_year
			FROM olympics_scen_2.medal m,
				 olympics_scen_2.competitor_event ce,
				 olympics_scen_2.event e,
				 olympics_scen_2.sport s,
				 olympics_scen_2.games_competitor gc,
				 olympics_scen_2.games g,
				 olympics_scen_2.person p,
				 olympics_scen_2.person_region pr

			WHERE m.id = ce.medal_id
			AND ce.event_id = e.id
			AND e.sport_id  = s.id
			AND ce.competitor_id = gc.id
			AND g.id = gc.games_id
			AND p.id = gc.person_id
			AND pr.person_id = p.id
			AND m.medal_name != 'NA'),
			
		tot20years AS (
			SELECT region_name,
				   COUNT(medal_name) as tot20years_num_medals
			FROM medals_per_country
			GROUP BY region_name
			ORDER BY tot20years_num_medals DESC),
			
		last10years AS (
			SELECT region_name,
				   COUNT(medal_name) as last10years_num_medals
			FROM medals_per_country
			WHERE games_year BETWEEN 2005 AND 2016
			GROUP BY region_name
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