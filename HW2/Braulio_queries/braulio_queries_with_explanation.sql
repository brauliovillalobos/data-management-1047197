#*************************************************************************#
#Query #1
#Which are the most popular cities in which the Olympics have taken place?
# Number of tables used: 3

# Logic of the query: We joined the tables that contain information about the Olympic Games
# by using the keys between tables. We group by the names of the city and count how many
# different games where hosted in each city. This Count is carried out in this form because of the
# organization of the DB schema. Finally we order the resulting table in a descendent way according
# to the number of games hosted.
#*************************************************************************#

SELECT city_name, COUNT(*) AS total_games_hosted
FROM olympics_scen_1.games a, olympics_scen_1.games_city b, olympics_scen_1.city c
WHERE a.id = b.games_id AND b.city_id = c.id
GROUP BY city_name
ORDER BY total_games_hosted DESC;

#*************************************************************************#
#Query #2
#Which are the most medal winner countries, in the 5 sports with most participants, 
#from the Olympics that took place from 1960(exclusive) until 2016(exclusive)?

# Number of tables used: 5

# Logic of the query: We basically have to address some separated challenges.
# First, we need to isolate information that comes only from the Olympic Games that were carried out between
# the desired dates. This is carried out in the first FROM clause by means of the IN clause that produces the
# 'principal' table. 
# Second, we need to identify the 5 sports with the most participants ever. We do this in the secondary table
# in the inner most query, we group by all the sports and count how many competitors each sport has had, we
# order the table by number of total competitors and take the first 5 by using the LIMIT clause.alter
# Then we take all competitors that have won a medal and that belong to those 5 sports
# Finally, we join these two pieces of information, group by region_name and retrieve the desired answer.
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

# Number of tables used: 5

# Basically we extract two pieces of information and then join them to answer the question. 
# First, we select competitors along with their corresponding games that have won a medal. This in the fir table
# Second, we identify the countries that have never hosted the olympics and select persons that
# don't belong to those countries (by means of the NOT in clause). 
# Finally, we join this information, we group by the name of the region (country) and count how many medal winners
# each country has. 
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
#Who won a golden medal in her/his FIRST appearance in the Olympic games? Not only identify them but give some characteristics about them

# Number of tables used: 5

# Because of the DB schema, this is a simple question that needs more complex tools to be answered. Here we need to know, for each person_id,
# which is the min games_year. Once I know that, we need three pieces of information: the competitor_id, the person_id to be able to identify the person
# and the games_year to know when those games took place. Now, the problems: 1st: we group by the person_id, then we can't obtain the competitor_id. Since
# 1 person can have multiple competitor_id's, we can't simply filter the games_competitor table based on the person_id, in order to obtain the competitor_id. 
# 2nd: if the group by is dony by the competitor_id, then we would have the same person, with different competitor_id, winning medals not in their first appearance
# but in other appearances. 

# For these reasons, we make use of the dense rank. In the order_values table, we identify the persons along with their competitor_id's and the minimum year
# of appearance. We group by person_id and the competitor_id and order the table by the person and year of first appearance. We then use the dense rank
# to put a 1 for each different person_id, along with its competitor_id for the first olympic games they participated in. 
# Then we just just join this information with some characteristics for each person and we make sure to just select those rows in which the dense_rank is equal to 1.
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

# Number of tables used: 5

# Here in the perseverants table we retrieve the persons, discipline and the total number of participations of those
# who never won a medal. For this, we exploited the NOT IN clause as it is very difficult to know who has never won a medal with a single query
# since we have to group by person_id and then select only those people that have a 4 in the medal column in ALL rows. This is hard to check. 
# It is perfectly possible that one person has just 1 medal (1,2,3) and a lot of non medals (4) so we would have to check each row for each person
# Therefore, we go opposite... we identify all people that HAS won at least one medal and then return all people that ARE NOT in that list (NOT IN clause)

# Then we filter the groups by means of the HAVING clause so that we only have person with more than 1 participation. And we join this information
# with the characteristics of the competitors.
#*************************************************************************#
