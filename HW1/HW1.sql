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






#*******************************************************************************************************
#2) Which are the 3 most medal winner countries, in the 5 sports with the most participants,
# from the Olympics that took place from 1960 (exclusive) and before 2016 (exclusive)
#*******************************************************************************************************


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



#*******************************************************************************************************
#Query # 3
#Which are the countries that have NEVER hosted the Olympics but have won the biggest number of medals?
#*******************************************************************************************************

#Composing the final Query
#Competitors that have won medals - COMPONENT # 1
SELECT competitor_id
FROM olympics_changed.competitor_event
WHERE medal_id <> 4;

#Filter games_competitor tables so that it only has competitors that have won medals - COMPONENT #2
SELECT id, games_id, person_id
FROM olympics_changed.games_competitor AS a
INNER JOIN(
	SELECT competitor_id
	FROM olympics_changed.competitor_event
	WHERE medal_id <> 4) AS b
ON a.id = b.competitor_id;

#Identifying which countries have NEVER hosted olympic games - COMPONENT #3

SELECT *
FROM olympics_changed.noc_region
WHERE id NOT IN(SELECT DISTINCT(country_id)
				FROM olympics_changed.city);

# - COMPONENT #4

SELECT a.id, a.full_name,c.region_name
FROM olympics_changed.person AS a, olympics_changed.person_region AS b, olympics_changed.noc_region AS c
WHERE a.id = b.person_id AND b.region_id = c.id AND c.id NOT IN(SELECT DISTINCT(country_id)
																FROM olympics_changed.city);
                                                                
# FINAL QUERY WITHOUT AGGREGATION!!!
SELECT *
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
WHERE region_name IS NOT NULL;

# FINAL QUERY WITH AGGREGATION!!!
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




#*******************************************************************************************************
#Query # 4
#Who won a gold medal in his/her first appearance in the Olympic Games? Give some personal details about this person.
#*******************************************************************************************************

#First let us see which were the first Olympic games in which each person participated. 

#I need to identify for each person which was his/her first Olympic Games. 
SELECT person_id, MIN(games_year) AS first_appearance
FROM olympics_changed.games_competitor AS a, olympics_changed.games AS b
WHERE a.games_id = b.id
GROUP BY person_id;
#Then I need to identify if that person, on those Olympic Games, won a gold medal or not. 
#For this I need the competitor event table and to query it I need the COMPETITOR ID

#Which participants have won a gold medal? 
SELECT event_id, competitor_id
FROM olympics_changed.competitor_event
WHERE medal_id = 1;



SELECT * 
FROM olympics_changed.games_competitor
WHERE id IN (SELECT competitor_id
			FROM olympics_changed.competitor_event
			WHERE medal_id = 1);


#En este query yo necesito por cada PERSON ID saber cuál es el mínimo de games_year
# Y traerme 3 cosas: el id del competidor de la primera tabla games_competitor, el person_id para poder identificar a la persona 
#el games_year para saber cuándo fue esa primera Olimpiada. 

#Which are the problems that I'm currently having?
#If the group by is done based on person_id, then I don't obtain the competitor id. Consider that 1 person can have multiple competitor ids
#Therefore, we can't just simply filter the games_competitor table based on the person_id, in order to obtain the competitor id.

#If the group is done by the competitor id, then we will have the same person, with different competitor id, winning medals not in their
#first appearance in Olympic games but in other appearances. This is not desired. 

#We also can't group by person id and competitor id... Or is this the solution??
SELECT * 
FROM olympics_changed.games_competitor a
LEFT JOIN olympics_changed.games b
ON a.games_id = b.id;

SELECT * 
FROM olympics_changed.games_competitor a
LEFT JOIN olympics_changed.games b
ON a.games_id = b.id;

SELECT person_id, a.id AS competitor_id , MIN(games_year) AS first_appearance
FROM olympics_changed.games_competitor a
LEFT JOIN olympics_changed.games b
ON a.games_id = b.id
GROUP BY person_id, a.id
ORDER BY person_id,first_appearance;

WITH order_values_2 AS(
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
SELECT person_id, order_values.competitor_id, first_appearance
FROM order_values
WHERE dense_rank_1 = 1
)
SELECT person_id, order_values_2.competitor_id,first_appearance
FROM order_values_2
INNER JOIN(	SELECT DISTINCT(competitor_id)
			FROM olympics_changed.competitor_event
			WHERE medal_id = 1) AS sec
ON order_values_2.competitor_id = sec.competitor_id;





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

#*******************************************************************************************************
#Query # 5 - The most perseverant ones!
#Who are the people that belong to a country that has never hosted the olympics, that have competed, 
#without ever winning a medal, on the SAME SPORT, for the greatest number of olympic games (at least twice).
#*******************************************************************************************************

#Who has competed at least twice in the same discipline? 
SELECT * FROM olympics_changed.event;

#Who has never won a medal? 
SELECT person_id, 
FROM olympics_changed.games_competitor a 
LEFT JOIN olympics_changed.competitor_event b
ON a.id = b.competitor_id
GROUP person_id
HAVING medal_id = 4;

#Going the opposite... It's very difficult to know who has never won a medal with one single query since we have to group by person_id
#and then select only those people that have a 4 in the medal column in all the rows. That's hard to check...It's perfectly possible
#that 1 person has just 1 medal (1,2,3) and a lot of non medals (4) so we would have to check each row for each person
#But we can go opposite and know who HAS won at least one medal and then return all people that ARE NOT in that list

#Who has won at least a medal?
SELECT DISTINCT(person_id)
FROM olympics_changed.games_competitor a 
LEFT JOIN olympics_changed.competitor_event b
ON a.id = b.competitor_id
WHERE medal_id <> 4;

#Then... who has NEVER won at least a medal? 
SELECT * 
FROM olympics_changed.games_competitor
WHERE person_id NOT IN(	SELECT DISTINCT(person_id)
						FROM olympics_changed.games_competitor a 
						LEFT JOIN olympics_changed.competitor_event b
						ON a.id = b.competitor_id
						WHERE medal_id <> 4);
                        
                        
#Now... we need to know in which events these people, that never won a medal, participated
SELECT * 
FROM olympics_changed.games_competitor AS fir
LEFT JOIN olympics_changed.competitor_event AS sec
ON fir.id = sec.competitor_id
WHERE person_id NOT IN(	SELECT DISTINCT(person_id)
						FROM olympics_changed.games_competitor a 
						LEFT JOIN olympics_changed.competitor_event b
						ON a.id = b.competitor_id
						WHERE medal_id <> 4);


