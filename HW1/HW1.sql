SELECT * 
FROM olympics.event;

SELECT * 
FROM olympics.person_region;

SELECT * 
FROM olympics.noc_region;

#1) Which are the most popular cities in which the Olympics have taken place? 
SELECT city_name, COUNT(*) AS total_games_hosted
FROM olympics.games a, olympics.games_city b, olympics.city c
WHERE a.id = b.games_id AND b.city_id = c.id
GROUP BY city_name
ORDER BY total_games_hosted DESC;

#Confirm London and Athina
SELECT *
FROM olympics.games a, olympics.games_city b, olympics.city c
WHERE a.id = b.games_id AND b.city_id = c.id AND city_name IN ('London','Athina');

#2) Which are the 3 most medal winner countries, in the 5 sports with the most participants,
# from the Olympics that took place from 1960 (exclusive) and before 2016 (exclusive)

# All competitors that won a medal and their respective sport
SELECT *
FROM olympics.competitor_event AS a, olympics.event AS b, olympics.sport AS c
WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4;

#All games after 1960 and before 2016
SELECT *
FROM olympics.games_competitor AS a, olympics.games AS b
WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016;

SELECT region_name AS participant_country, COUNT(*) AS total_participants
FROM olympics.person
LEFT JOIN olympics.person_region 
ON person.id = person_region.person_id
LEFT JOIN olympics.noc_region
ON person_region.region_id = noc_region.id
GROUP BY region_name
ORDER BY total_participants DESC;

#Base Query #1
SELECT *
FROM olympics.games_competitor
LEFT JOIN olympics.person
ON games_competitor.person_id = person.id
LEFT JOIN olympics.person_region 
ON person.id = person_region.person_id
LEFT JOIN olympics.noc_region
ON person_region.region_id = noc_region.id 
WHERE games_id IN (SELECT b.id
					FROM olympics.games_competitor AS a, olympics.games AS b
					WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016);

#Base Query #2
SELECT competitor_id, sport_name
FROM olympics.competitor_event AS a, olympics.event AS b, olympics.sport AS c
WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4 AND sport_id IN (
SELECT turum.sport_id
FROM (SELECT sport_id, COUNT(*) AS total_competitors 
		FROM olympics.competitor_event AS a, olympics.event AS b    
		WHERE a.event_id = b.id
		GROUP BY sport_id
		ORDER BY total_competitors DESC
		LIMIT 5) AS turum);

#Final Query
SELECT region_name, COUNT(*) medal_winners
FROM 	(SELECT games_competitor.id, region_name
		FROM olympics.games_competitor
		LEFT JOIN olympics.person
		ON games_competitor.person_id = person.id
		LEFT JOIN olympics.person_region 
		ON person.id = person_region.person_id
		LEFT JOIN olympics.noc_region
		ON person_region.region_id = noc_region.id 
		WHERE games_id IN 	(SELECT b.id
							FROM olympics.games_competitor AS a, olympics.games AS b
							WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016)) AS principal
INNER JOIN (SELECT competitor_id, sport_name
			FROM olympics.competitor_event AS a, olympics.event AS b, olympics.sport AS c
			WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4 AND sport_id IN (
				SELECT turum.sport_id
				FROM 	(SELECT sport_id, COUNT(*) AS total_competitors 
						FROM olympics.competitor_event AS a, olympics.event AS b    
						WHERE a.event_id = b.id
						GROUP BY sport_id
						ORDER BY total_competitors DESC
						LIMIT 5) AS turum)) AS secondary
ON principal.id = secondary.competitor_id
GROUP BY region_name
ORDER BY medal_winners DESC;



#-----------------------
# 1
SELECT *
FROM olympics.games_competitor AS a, olympics.games AS b
WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016 AND a.id = 145147;
# 2
SELECT games_competitor.id, region_name
FROM olympics.games_competitor
LEFT JOIN olympics.person
ON games_competitor.person_id = person.id
LEFT JOIN olympics.person_region 
ON person.id = person_region.person_id
LEFT JOIN olympics.noc_region
ON person_region.region_id = noc_region.id 
WHERE games_id = 1;

#Tests to check correctness of query
         
         
SELECT id, COUNT(*) AS pumpum
FROM 	(SELECT games_competitor.id, region_name
		FROM olympics.games_competitor
		LEFT JOIN olympics.person
		ON games_competitor.person_id = person.id
		LEFT JOIN olympics.person_region 
		ON person.id = person_region.person_id
		LEFT JOIN olympics.noc_region
		ON person_region.region_id = noc_region.id 
		WHERE games_id IN 	(SELECT b.id
							FROM olympics.games_competitor AS a, olympics.games AS b
							WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016)) AS principal
INNER JOIN (SELECT competitor_id, sport_name
			FROM olympics.competitor_event AS a, olympics.event AS b, olympics.sport AS c
			WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4 AND sport_id IN (
				SELECT turum.sport_id
				FROM 	(SELECT sport_id, COUNT(*) AS total_competitors 
						FROM olympics.competitor_event AS a, olympics.event AS b    
						WHERE a.event_id = b.id
						GROUP BY sport_id
						ORDER BY total_competitors DESC
						LIMIT 5) AS turum)) AS secondary
ON principal.id = secondary.competitor_id
GROUP BY id
ORDER BY pumpum DESC;

SELECT *
FROM 	(SELECT games_competitor.id, region_name
		FROM olympics.games_competitor
		LEFT JOIN olympics.person
		ON games_competitor.person_id = person.id
		LEFT JOIN olympics.person_region 
		ON person.id = person_region.person_id
		LEFT JOIN olympics.noc_region
		ON person_region.region_id = noc_region.id 
		WHERE games_id IN 	(SELECT b.id
							FROM olympics.games_competitor AS a, olympics.games AS b
							WHERE a.games_id = b.id AND games_year > 1960 AND games_year < 2016)) AS principal
INNER JOIN (SELECT competitor_id, sport_name
			FROM olympics.competitor_event AS a, olympics.event AS b, olympics.sport AS c
			WHERE a.event_id = b.id AND b.sport_id = c.id AND medal_id <> 4 AND sport_id IN (
				SELECT turum.sport_id
				FROM 	(SELECT sport_id, COUNT(*) AS total_competitors 
						FROM olympics.competitor_event AS a, olympics.event AS b    
						WHERE a.event_id = b.id
						GROUP BY sport_id
						ORDER BY total_competitors DESC
						LIMIT 5) AS turum)) AS secondary
ON principal.id = secondary.competitor_id;




#Query # 3
#Which are the countries that have NEVER hosted the Olympics but have won the biggest number of medals?

#Composing the final Query
#Competitors that have won medals - COMPONENT # 1
SELECT competitor_id
FROM olympics.competitor_event
WHERE medal_id <> 4;

#Filter games_competitor tables so that it only has competitors that have won medals - COMPONENT #2
SELECT id, games_id, person_id
FROM olympics.games_competitor AS a
INNER JOIN(
	SELECT competitor_id
	FROM olympics.competitor_event
	WHERE medal_id <> 4) AS b
ON a.id = b.competitor_id;

#Identifying

SELECT *
FROM olympics.city;
    


