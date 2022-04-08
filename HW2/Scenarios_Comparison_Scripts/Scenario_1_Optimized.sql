
#*************************************************************************#
#Query #1
#Which are the most popular cities in which the Olympics have taken place?
#*************************************************************************#

SELECT city_name, COUNT(*) AS total_games_hosted
FROM olympics_changed.games a, olympics_changed.games_city b, olympics_changed.city c
WHERE a.id = b.games_id AND b.city_id = c.id
GROUP BY city_name
ORDER BY total_games_hosted DESC;

#*************************************************************************#
#Query #2
#Which are the 3 most medal winner countries, in the 5 sports with most participants, from the Olympics that took place from 1960(exclusive) until 2016(exclusive)?
#*************************************************************************#

SELECT region_name, COUNT(*) medal_winners
FROM 	(SELECT games_competitor.id, region_name
		FROM olympics_changed.games_competitor
		LEFT JOIN olympics_changed.person
		ON games_competitor.person_id = person.id
		LEFT JOIN olympics_changed.person_region 
		ON person.id = person_region.person_id
		LEFT JOIN olympics_changed.noc_region
		ON person_region.region_id = noc_region.id 
		WHERE games_id IN 	(SELECT b.id
							FROM olympics_changed.games_competitor AS a, olympics_changed.games AS b
							WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016)) AS principal
INNER JOIN (SELECT competitor_id, sport_name
			FROM olympics_changed.competitor_event AS a, olympics_changed.event AS b, olympics_changed.sport AS c
			WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4 AND sport_id IN (
				SELECT turum.sport_id
				FROM 	(SELECT sport_id, COUNT(*) AS total_competitors 
						FROM olympics_changed.competitor_event AS a, olympics_changed.event AS b    
						WHERE a.event_id = b.id
						GROUP BY sport_id
						ORDER BY total_competitors DESC
						LIMIT 5) AS turum)) AS secondary
ON principal.id = secondary.competitor_id
GROUP BY region_name
ORDER BY medal_winners DESC;

#*************************************************************************#
#Query #3
#Which are the countries that have NEVER hosted the Olympics but have won the most number of medals? 
#*************************************************************************#

SELECT region_name AS country, COUNT(*) AS number_medal_winners
FROM(SELECT id, games_id, person_id
	FROM olympics_changed.games_competitor AS a
	INNER JOIN(
		SELECT competitor_id
		FROM olympics_changed.competitor_event
		WHERE medal_id <> 4) AS b
	ON a.id = b.competitor_id) AS fir
LEFT JOIN(	SELECT e.id, e.full_name,g.region_name
			FROM olympics_changed.person AS e, olympics_changed.person_region AS f, olympics_changed.noc_region AS g
			WHERE e.id = f.person_id AND f.region_id = g.id AND g.id NOT IN(SELECT DISTINCT(country_id)
																			FROM olympics_changed.city)) AS sec
ON fir.person_id = sec.id
WHERE region_name IS NOT NULL
GROUP BY region_name
ORDER BY number_medal_winners DESC;

#*************************************************************************#
#Query #4
#Who won a medal in her/his FIRST appearance in the Olympic games? Not only identify them but give some characteristics about them
#*************************************************************************#

WITH order_values AS(
	SELECT person_id, competitor_id, first_appearance, dense_rank()
	OVER (partition by person_id ORDER BY first_appearance) AS 'dense_rank_1' 
	FROM(
		SELECT person_id, a.id AS competitor_id , MIN(games_year) AS first_appearance
		FROM olympics_changed.games_competitor a
		LEFT JOIN olympics_changed.games b
		ON a.games_id = b.id
		GROUP BY person_id, a.id
		ORDER BY person_id,first_appearance) AS tulum
)
SELECT person_id, order_values.competitor_id, first_appearance, thi.full_name, thi.gender, thi.height, thi.weight
FROM order_values
INNER JOIN(	SELECT DISTINCT(competitor_id)
			FROM olympics_changed.competitor_event
			WHERE medal_id = 1) AS sec
ON order_values.competitor_id = sec.competitor_id
INNER JOIN olympics_changed.person AS thi
ON order_values.person_id = thi.id
WHERE dense_rank_1 = 1;

#*************************************************************************#
#Query #5 - The most perseverant ones!
#Who are the people  that have competed, without ever winning a medal,
#on the SAME DISCIPLINE (not sport, but discipline), for the greatest number of olympic games (at least twice)
#*************************************************************************#

WITH perseverants AS (
SELECT a.person_id AS person, b.event_id AS discipline, COUNT(*) AS total_participations
FROM olympics_changed.games_competitor AS a 
LEFT JOIN olympics_changed.competitor_event AS b
ON a.id = b.competitor_id
WHERE person_id NOT IN(	SELECT DISTINCT(person_id)
						FROM olympics_changed.games_competitor a 
						LEFT JOIN olympics_changed.competitor_event b
						ON a.id = b.competitor_id
						WHERE medal_id <> 4)
GROUP BY a.person_id, b.event_id
HAVING total_participations > 1
ORDER BY total_participations DESC)
SELECT person, full_name, gender, height, weight, region_name, discipline, event_name, total_participations 
FROM perseverants
LEFT JOIN olympics_changed.event AS event_table
ON perseverants.discipline = event_table.id
LEFT JOIN (	SELECT eins.id, eins.full_name, eins.gender, eins.height, eins.weight, drei.region_name
			FROM olympics_changed.person AS eins, olympics_changed.person_region AS zwei, olympics_changed.noc_region AS drei
			WHERE eins.id = zwei.person_id AND zwei.region_id = drei.id) AS detail_table
ON person = detail_table.id;

##################################################################
# Q6
# What countries won medals in the Swimming games, 
# and what is the medal counts per each country?.
# Execution time: 3 ~ 6 Seconds.
##################################################################
SELECT nr.region_name, 
	   m.medal_name, COUNT(*) as number_medals
FROM olympics_changed.sport s, 
	 olympics_changed.event e,
     olympics_changed.medal m,
	 olympics_changed.competitor_event ce,
     olympics_changed.games_competitor gc,
     olympics_changed.person p,
     olympics_changed.person_region pr,
     olympics_changed.noc_region nr
     
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
ORDER BY nr.region_name, number_medals DESC;

##################################################################
# Q7
# What's the age of the oldest persons who won a Golden medal
# for each country and what is their sport?
# Execution time: ~ 1 Seconds.
##################################################################

SELECT nr.region_name, 
	   p.full_name, 
	   MAX(age) as oldest_winner_age, 
       s.sport_name
FROM olympics_changed.medal m,
	 olympics_changed.competitor_event ce,
     olympics_changed.event e,
     olympics_changed.sport s,
     olympics_changed.games_competitor gc,
	 olympics_changed.person p,
     olympics_changed.person_region pr,
     olympics_changed.noc_region nr
     
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
##################################################################

SELECT s.sport_name, 
	   MAX(p.height) as max_height, 
       p.gender,
       nr.region_name
FROM olympics_changed.competitor_event ce,
	 olympics_changed.event e,
     olympics_changed.sport s,
     olympics_changed.games_competitor gc,
     olympics_changed.person p,
     olympics_changed.person_region pr,
     olympics_changed.noc_region nr
     
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
		FROM olympics_changed.medal m,
			 olympics_changed.competitor_event ce,
			 olympics_changed.event e,
			 olympics_changed.sport s,
			 olympics_changed.games_competitor gc,
			 olympics_changed.person p,
			 olympics_changed.person_region pr,
			 olympics_changed.noc_region nr 

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
		FROM olympics_changed.medal m,
			 olympics_changed.competitor_event ce,
			 olympics_changed.event e,
			 olympics_changed.sport s,
			 olympics_changed.games_competitor gc,
			 olympics_changed.person p,
			 olympics_changed.person_region pr,
			 olympics_changed.noc_region nr 

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
			FROM olympics_changed.medal m,
				 olympics_changed.competitor_event ce,
				 olympics_changed.event e,
				 olympics_changed.sport s,
				 olympics_changed.games_competitor gc,
				 olympics_changed.games g,
				 olympics_changed.person p,
				 olympics_changed.person_region pr,
				 olympics_changed.noc_region nr 

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
			FROM olympics_changed.medal m,
				 olympics_changed.competitor_event ce,
				 olympics_changed.event e,
				 olympics_changed.sport s,
				 olympics_changed.games_competitor gc,
				 olympics_changed.games g,
				 olympics_changed.person p,
				 olympics_changed.person_region pr,
				 olympics_changed.noc_region nr 

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