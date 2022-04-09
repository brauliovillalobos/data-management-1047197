#*************************************************************************#
#Query #1
#Which are the most popular cities in which the Olympics have taken place?
#*************************************************************************#

SELECT city_name, COUNT(*) AS total_games_hosted
FROM olympics_scen_1.games a, olympics_scen_1.games_city b, olympics_scen_1.city c
WHERE a.id = b.games_id AND b.city_id = c.id
GROUP BY city_name
ORDER BY total_games_hosted DESC;

#*************************************************************************#
#Query #2
#Which are the 3 most medal winner countries, in the 5 sports with most participants, from the Olympics that took place from 1960(exclusive) until 2016(exclusive)?
#*************************************************************************#

SELECT region_name, COUNT(*) medal_winners
FROM 	(SELECT games_competitor.id, region_name
		FROM olympics_scen_1.games_competitor
		LEFT JOIN olympics_scen_1.person
		ON games_competitor.person_id = person.id
		LEFT JOIN olympics_scen_1.person_region 
		ON person.id = person_region.person_id
		WHERE games_id IN 	(SELECT b.id
							FROM olympics_scen_1.games_competitor AS a, olympics_scen_1.games AS b
							WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016)) AS principal
INNER JOIN (SELECT competitor_id, sport_name
			FROM olympics_scen_1.competitor_event AS a, olympics_scen_1.event AS b, olympics_scen_1.sport AS c
			WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4 AND sport_id IN (
				SELECT turum.sport_id
				FROM 	(SELECT sport_id, COUNT(*) AS total_competitors 
						FROM olympics_scen_1.competitor_event AS a, olympics_scen_1.event AS b    
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
	FROM olympics_scen_1.games_competitor AS a
	INNER JOIN(
		SELECT competitor_id
		FROM olympics_scen_1.competitor_event
		WHERE medal_id <> 4) AS b
	ON a.id = b.competitor_id) AS fir
LEFT JOIN(	SELECT e.id, e.full_name,f.region_name
			FROM olympics_scen_1.person AS e, olympics_scen_1.person_region AS f
			WHERE e.id = f.person_id AND f.region_id NOT IN(SELECT DISTINCT(country_id)
																			FROM olympics_scen_1.city)) AS sec
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
		FROM olympics_scen_1.games_competitor a
		LEFT JOIN olympics_scen_1.games b
		ON a.games_id = b.id
		GROUP BY person_id, a.id
		ORDER BY person_id,first_appearance) AS tulum
)
SELECT person_id, order_values.competitor_id, first_appearance, thi.full_name, thi.gender, thi.height, thi.weight
FROM order_values
INNER JOIN(	SELECT DISTINCT(competitor_id)
			FROM olympics_scen_1.competitor_event
			WHERE medal_id = 1) AS sec
ON order_values.competitor_id = sec.competitor_id
INNER JOIN olympics_scen_1.person AS thi
ON order_values.person_id = thi.id
WHERE dense_rank_1 = 1;

#*************************************************************************#
#Query #5 - The most perseverant ones!
#Who are the people  that have competed, without ever winning a medal,
#on the SAME DISCIPLINE (not sport, but discipline), for the greatest number of olympic games (at least twice)
#*************************************************************************#

WITH perseverants AS (
SELECT a.person_id AS person, b.event_id AS discipline, COUNT(*) AS total_participations
FROM olympics_scen_1.games_competitor AS a 
LEFT JOIN olympics_scen_1.competitor_event AS b
ON a.id = b.competitor_id
WHERE person_id NOT IN(	SELECT DISTINCT(person_id)
						FROM olympics_scen_1.games_competitor a 
						LEFT JOIN olympics_scen_1.competitor_event b
						ON a.id = b.competitor_id
						WHERE medal_id <> 4)
GROUP BY a.person_id, b.event_id
HAVING total_participations > 1
ORDER BY total_participations DESC)
SELECT person, full_name, gender, height, weight, region_name, discipline, event_name, total_participations 
FROM perseverants
LEFT JOIN olympics_scen_1.event AS event_table
ON perseverants.discipline = event_table.id
LEFT JOIN (	SELECT eins.id, eins.full_name, eins.gender, eins.height, eins.weight, zwei.region_name
			FROM olympics_scen_1.person AS eins, olympics_scen_1.person_region AS zwei
			WHERE eins.id = zwei.person_id) AS detail_table
ON person = detail_table.id;
