#########################################################################
# Our GitHub Repo: https://github.com/brauliovillalobos/DM
#########################################################################
/*
This file includes the following:
1. Creating the schema of our database (without including the inserted values as required) for the un-optimized scenario.
2. Creating the schema of our database (without including the inserted values as required) alongside with the used primary keys, secondary keys, and constraints for the optimized scenario.
3. Data pre-processing. 
4. Our ten queries.
5. Re-design the implementation of queries 9 and 10.
#########################################################################
How did we optimize our queries? 

We went through two roads
	1. Using the mentioned keys and constraints.
	2. Re-designing the implementation of the queries. We did it only for two queries (Query9 and Query10).

So for the optimization instead of using the schema of number 1, we used the schema of number 2 to efficiently execute our queries. 

Moreover, we re-designed the implementation of queries 9 and 10 to boost the performance even more!
*/
#########################################################################
#########################################################################
# 1. Creating the schema of our database (without including the inserted values as required), the un-optimized schema.
#########################################################################
#########################################################################
CREATE DATABASE  IF NOT EXISTS `olympics_scen_3`;
USE `olympics_scen_3`;

--
-- Table structure for table `city`
--
DROP TABLE IF EXISTS `city`;
CREATE TABLE `city` (
  `id` int(11) NOT NULL,
  `city_name` varchar(200) DEFAULT NULL,
  `country_name` varchar(200) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `city`
--
#LOCK TABLES `city` WRITE;
#INSERT INTO `city` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `competitor_event`
--
DROP TABLE IF EXISTS `competitor_event`;
CREATE TABLE `competitor_event` (
  `event_id` int(11) DEFAULT NULL,
  `competitor_id` int(11) DEFAULT NULL,
  `medal_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `competitor_event`
--
#LOCK TABLES `competitor_event` WRITE;
#INSERT INTO `competitor_event` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `medal`
--
DROP TABLE IF EXISTS `medal`;
CREATE TABLE `medal` (
  `id` int(11) NOT NULL,
  `medal_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `medal`
--
#LOCK TABLES `medal` WRITE;
#INSERT INTO `medal` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `noc_region`
--
DROP TABLE IF EXISTS `noc_region`;
CREATE TABLE `noc_region` (
  `id` int(11) NOT NULL,
  `noc` varchar(5) DEFAULT NULL,
  `region_name` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `noc_region`
--
#LOCK TABLES `noc_region` WRITE;
#INSERT INTO `noc_region` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `person`
--
DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `id` int(11) NOT NULL,
  `full_name` varchar(500) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `person`
--
#LOCK TABLES `person` WRITE;
#INSERT INTO `person` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `person_region`
--
DROP TABLE IF EXISTS `person_region`;
CREATE TABLE `person_region` (
  `person_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `person_region`
--
#LOCK TABLES `person_region` WRITE;
#INSERT INTO `person_region` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `sport`
--
DROP TABLE IF EXISTS `sport`;
CREATE TABLE `sport` (
  `id` int(11) NOT NULL,
  `sport_name` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sport`
--
#LOCK TABLES `sport` WRITE;
#INSERT INTO `sport` VALUES;
#UNLOCK TABLES;
#########################################################################
#########################################################################
# 2. Creating the schema of our database (without including the inserted values as required) alongside with the used primary keys, secondary keys, and constraints for the optimized scenario.
#########################################################################
#########################################################################
CREATE DATABASE  IF NOT EXISTS `olympics_scen_1`;
USE `olympics_scen_1`;


--
-- Table structure for table `city`
--
DROP TABLE IF EXISTS `city`;
CREATE TABLE `city` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city_name` varchar(200) DEFAULT NULL,
  `country_name` varchar(200) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  KEY (`id`),
  KEY (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `city`
--
#LOCK TABLES `city` WRITE;
#INSERT INTO `city` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `competitor_event`
--
DROP TABLE IF EXISTS `competitor_event`;
CREATE TABLE `competitor_event` (
  `event_id` int(11) DEFAULT NULL,
  `competitor_id` int(11) DEFAULT NULL,
  `medal_id` int(11) DEFAULT NULL,
  KEY `fk_ce_ev` (`event_id`),
  KEY `fk_ce_com` (`competitor_id`),
  KEY `fk_ce_med` (`medal_id`),
  CONSTRAINT `fk_ce_com` FOREIGN KEY (`competitor_id`) REFERENCES `games_competitor` (`id`),
  CONSTRAINT `fk_ce_ev` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `fk_ce_med` FOREIGN KEY (`medal_id`) REFERENCES `medal` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `competitor_event`
--
#LOCK TABLES `competitor_event` WRITE;
#INSERT INTO `competitor_event` VALUES;
#UNLOCK TABLES;

--

-- Table structure for table `event`
--
DROP TABLE IF EXISTS `event`;
CREATE TABLE `event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sport_id` int(11) DEFAULT NULL,
  `event_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ev_sp` (`sport_id`),
  CONSTRAINT `fk_ev_sp` FOREIGN KEY (`sport_id`) REFERENCES `sport` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1024 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `event`
--
#LOCK TABLES `event` WRITE;
#INSERT INTO `event` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `games`
--
DROP TABLE IF EXISTS `games`;
CREATE TABLE `games` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `games_year` int(11) DEFAULT NULL,
  `games_name` varchar(100) DEFAULT NULL,
  `season` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `games`
--
#LOCK TABLES `games` WRITE;
#INSERT INTO `games` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `games_city`
--
DROP TABLE IF EXISTS `games_city`;
CREATE TABLE `games_city` (
  `games_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  KEY `fk_gci_city` (`city_id`),
  KEY `fk_gci_gam` (`games_id`),
  CONSTRAINT `fk_gci_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`id`),
  CONSTRAINT `fk_gci_gam` FOREIGN KEY (`games_id`) REFERENCES `games` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `games_city`
--
#LOCK TABLES `games_city` WRITE;
#INSERT INTO `games_city` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `games_competitor`
--
DROP TABLE IF EXISTS `games_competitor`;
CREATE TABLE `games_competitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `games_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_gc_gam` (`games_id`),
  KEY `fk_gc_per` (`person_id`),
  CONSTRAINT `fk_gc_gam` FOREIGN KEY (`games_id`) REFERENCES `games` (`id`),
  CONSTRAINT `fk_gc_per` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=196606 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `games_competitor`
--
#LOCK TABLES `games_competitor` WRITE;
#INSERT INTO `games_competitor` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `medal`
--
DROP TABLE IF EXISTS `medal`;
CREATE TABLE `medal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `medal_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `medal`
--
#LOCK TABLES `medal` WRITE;
#INSERT INTO `medal` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `noc_region`
--
DROP TABLE IF EXISTS `noc_region`;
CREATE TABLE `noc_region` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `noc` varchar(5) DEFAULT NULL,
  `region_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `noc_region`
--
#LOCK TABLES `noc_region` WRITE;
#INSERT INTO `noc_region` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `person`
--
DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(500) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=135572 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `person`
--
#LOCK TABLES `person` WRITE;
#INSERT INTO `person` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `person_region`
--
DROP TABLE IF EXISTS `person_region`;
CREATE TABLE `person_region` (
  `person_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  KEY `fk_per_per` (`person_id`),
  KEY `fk_per_reg` (`region_id`),
  CONSTRAINT `fk_per_per` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `fk_per_reg` FOREIGN KEY (`region_id`) REFERENCES `noc_region` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `person_region`
--
#LOCK TABLES `person_region` WRITE;
#INSERT INTO `person_region` VALUES;
#UNLOCK TABLES;


--
-- Table structure for table `sport`
--
DROP TABLE IF EXISTS `sport`;
CREATE TABLE `sport` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sport_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sport`
--

#LOCK TABLES `sport` WRITE;
#INSERT INTO `sport` VALUES ;
#UNLOCK TABLES;
#########################################################################
#########################################################################
#3. Data pre-processing.
#########################################################################
#########################################################################
# 1. Combining noc_region table and person_region table into a new table called person_region.

# 1.1 Exporting the combined tables alongside with the headers
SELECT 'person_id', 'region_id', 'noc', 'region_name'
UNION ALL
SELECT pr.*,
	   nr.noc,
       nr.region_name
FROM olympics_scen_1.person_region pr,
	 olympics_scen_1.noc_region nr
WHERE pr.region_id = nr.id
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/person_region.csv' 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


# 1.2 Drop the original tables
DROP TABLE IF EXISTS olympics_scen_1.person_region;
DROP TABLE IF EXISTS olympics_scen_1.noc_region;

# 1.3 Creating the structure for the new table
CREATE TABLE olympics_scen_1.person_region (
  `person_id` int(11) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `noc` varchar(5) DEFAULT NULL,
  `region_name` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# 1.4 Loading the new table into the schema
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/person_region.csv" IGNORE
INTO TABLE olympics_scen_1.person_region
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;
#########################################################################
#########################################################################
# 4. Our ten queries.
#########################################################################
#########################################################################
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

WITH perseverants AS (
SELECT a.person_id AS person, b.event_id AS discipline, COUNT(*) AS total_participations
FROM olympics_scen_1.games_competitor AS a 
LEFT JOIN olympics_scen_1.competitor_event AS b
ON a.id = b.competitor_id
WHERE person_id NOT IN( SELECT DISTINCT(person_id)
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
LEFT JOIN ( SELECT eins.id, eins.full_name, eins.gender, eins.height, eins.weight, zwei.region_name
      FROM olympics_scen_1.person AS eins, olympics_scen_1.person_region AS zwei
      WHERE eins.id = zwei.person_id) AS detail_table
ON person = detail_table.id;

##################################################################
# Q6
# What countries won medals in the Swimming games, 
# and what is the medal counts per each country?.
#################################
# Execution time: 2 ~ 4 Seconds.
#################################
# Aggregaation, Joining 7 tables, LIKE statement
# Number of used tables: 7
#################################
# Execution Plan:
################################
# 1. Gather all medals per countries.
# 2. Filter by the swimming games
# 3. Count the number of medals per each medal type and each country.
################################
# Output Example:
################################
/*
region_name 	medal_name 		number_medals
USA 			Gold 			639
USA				Silver 			252
USA				Bronze 			176
*/
#################################
SELECT pr.region_name, 
	   m.medal_name, COUNT(*) as number_medals
FROM olympics_scen_1.sport s, 
	 olympics_scen_1.event e,
     olympics_scen_1.medal m,
	 olympics_scen_1.competitor_event ce,
     olympics_scen_1.games_competitor gc,
     olympics_scen_1.person p,
     olympics_scen_1.person_region pr
     
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
#################################
# Execution time: ~ 1 Seconds.
#################################
# WITH class for creating 2 temp. tables.
# Number of used tables: 7
#################################
# Execution Plan:
################################
# 1. Create a temporary table that hold the required columns of persons who won a golden medal.
# 2. Creating another temporary table to extract the oldest person who won a golden medal in each country from the previos table.
# 3. Joining both tables to display the required columns for each person.
################################
# Output Example:
################################
/*
region_name 	oldest_winner_age 	full_name 				sport_name
USA				64					Charles Jacobus			Roque
Sweden			64					Oscar Gomer Swahn		Shooting
Netherlands		63					Isaac Lazarus Israls	Art Competitions
UK				60					Joshua Kearney Millner	Shooting
*/
#################################
WITH
	all_ AS (
		SELECT gc.age,
			   pr.region_name,
               p.full_name, 
               s.sport_name
		FROM olympics_scen_1.medal m,
			 olympics_scen_1.competitor_event ce,
			 olympics_scen_1.event e,
			 olympics_scen_1.sport s,
			 olympics_scen_1.games_competitor gc,
			 olympics_scen_1.person p,
			 olympics_scen_1.person_region pr
			 
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
#################################
# Execution time: ~ 5 Seconds.
#################################
# WITH class for creating 2 temp. tables.
# Number of used tables: 6
#################################
# Execution Plan:
################################
# 1. Create a temporary table that hold the required columns.
# 2. Create another temporary table to extract the tallest person who played each sport from the previos table.
# 3. Joining both tables to display the required columns for each person.
################################
# Output Example:
################################
/*
sport_name 	max_height 	region_name gender age
Basketball		226		China		M		20
Basketball		226		China		M		23
Basketball		226		China		M		27
Volleyball		219		Russia		M		23
Handball		214		Germany		M		33
*/
#################################
WITH 
	all_ AS (
		SELECT s.sport_name, 
			   p.height, 
			   p.gender,
			   pr.region_name,
               gc.age
		FROM olympics_scen_1.competitor_event ce,
			 olympics_scen_1.event e,
			 olympics_scen_1.sport s,
			 olympics_scen_1.games_competitor gc,
			 olympics_scen_1.person p,
			 olympics_scen_1.person_region pr
			 
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
#################################
# Execution time: ~ 9 Seconds.
#################################
# 2 WITH clauses, 4 temp. tables
# Number of used tables: 7
#################################
# Execution Plan:
################################
# 1. Create a Temporary table (total) to display the total number of won medals for each country.
	# Output Example:
	/*
    region_name 	tot_num_medals
	USA				5414
	Soviet Union	2658
	Germany			2395
	UK				1971
    */
# 2. Create another temporary table (dominant) to display the dominant sport for each 
# 	country and the number of won medals for this sport by creating another WITH clause:
	# a) Another temporary table (all_) to count the number of won medals per each sport for each country.
		/* Output Example:
		region_name 	dominant_sport 	tot_num_medals
		USA				Swimming		1038
		USA				Athletics		1035
		USA				Rowing			348
		USA				Basketball		331
		*/
	# b) Another temporary table (tempo) to display the dominant sport for each country from all_.
		/* Output Example:
		region_name 	dominant_num_medals
		USA				1038
		Australia		402
		Italy			358
		Canada			347
		*/
# 3. Join 1 and 2 to display the total number of medals per each country, 
 # the dominant sport for which each country won the highest number of medals,
 # and how many medals they won for this sport.
################################
# Output Example:
################################
/*
region_name 	tot_num_medals 	dominant_sport 		dominant_num_medals
USA				5414			Swimming			1038
Soviet Union	2658			Gymnastics			290
Germany			2395			Rowing				258
UK				1971			Athletics			337
France			1686			Fencing				307
*/
#################################
#################################
WITH 
	# 1. A Temporary table to display the total number of won medals 
    # for each country.
	total AS (
		SELECT pr.region_name, 
			   COUNT(m.medal_name) AS tot_num_medals
		FROM olympics_scen_3.medal m,
			 olympics_scen_3.competitor_event ce,
			 olympics_scen_3.event e,
			 olympics_scen_3.sport s,
			 olympics_scen_3.games_competitor gc,
			 olympics_scen_3.person p,
			 olympics_scen_3.person_region pr

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
				FROM olympics_scen_3.medal m,
					 olympics_scen_3.competitor_event ce,
					 olympics_scen_3.event e,
					 olympics_scen_3.sport s,
					 olympics_scen_3.games_competitor gc,
					 olympics_scen_3.person p,
					 olympics_scen_3.person_region pr

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
# Q10
# What is the percentage of number of won medals 
# for each country over the last ten years compared to 
# the whole period (20 years, 1896 to 2016)?
#################################
# Execution Time: ~ 12 seconds.
#################################
# 2 temp. tables, 1 subquery, FULL OUTER JOIN, TRUNCATE
# Number of used tables: 8
#################################
# Execution Plan:
################################
# 1. Create a temporary table (tot20years) to list the total number of medals from 1896 to 2006.
# 2. Create another temporary table (last10years) to list the same over last 10 years (from 2006 until 2016).
# 3. Full outer join tot20years and last10years to compute the number of medals between '1896-2006' 
	# and calculate the percentage of won medals during the last 10 years '2006-2016'.
################################
# Output Example:
################################
/*
region_name 	tot20years_num_medals 	'1896-2005' 	'2006-2016' 	last_10years_pct
USA				5414					4379			1035			19.11
Soviet Union	2658					2654			4				0.15
Germany			2395					1899			496				20.70
UK				1971					1607			364				18.46
France			1686					1384			302				17.91
*/
################################
SELECT region_name, 
       tot20years_num_medals,
       (tot20years_num_medals - last10years_num_medals) AS '1896-2005',
       last10years_num_medals AS '2006-2016',
       TRUNCATE(((last10years_num_medals / tot20years_num_medals) * 100), 2) AS last_10years_pct

FROM (
	WITH 
		# 1. List the total number of medals from 1896 to 2006.
		tot20years AS (
			SELECT pr.region_name, 
				   COUNT(m.medal_name) as tot20years_num_medals
			FROM olympics_scen_3.medal m,
				 olympics_scen_3.competitor_event ce,
				 olympics_scen_3.event e,
				 olympics_scen_3.sport s,
				 olympics_scen_3.games_competitor gc,
				 olympics_scen_3.games g,
				 olympics_scen_3.person p,
				 olympics_scen_3.person_region pr

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
			FROM olympics_scen_3.medal m,
				 olympics_scen_3.competitor_event ce,
				 olympics_scen_3.event e,
				 olympics_scen_3.sport s,
				 olympics_scen_3.games_competitor gc,
				 olympics_scen_3.games g,
				 olympics_scen_3.person p,
				 olympics_scen_3.person_region pr

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
#########################################################################
#########################################################################
# 5. Re-design the implementation of queries 9 and 10.
#########################################################################
#########################################################################
# Q9 - Re-design
# List the total number of won medals for each country. 
# And for which sport each country won the highest number of these medals?
#################################
# Execution time: ~ 3 Seconds.
#################################
# 1 WITH clause, 3 temporary tables.
# Number of used tables: 7
#################################
# Execution Plan:
################################
# 1. Create a temporary table (all_) to display the number of won medals per each sport for each country.
	# Output Example:
	/*
    region_name 	sport_name 		num_medals
	USA				Rowing			348
	USA				Softball		60
	USA				Swimming		1038
    ...
	*/
# 2. Crteate another temporary table (tot) to count the total number of medals per each country from all_.
	# Output Example:
	/*
    region_name 		tot_num_medals
	Russia				1321
	South Korea			642
	Canada				1324
	USA					5414
	*/
# 3. Create another temporary table (dominant) to display the dominant sport for each country from all_. 
	# In other words, to get the sport that has the highest number of medals for each country. 
	# For example: USA, Rowing 348, Softball 60, Swimming 1038. Then this table will return USA 1038.
 	# Output Example:
	/*   
    region_name 		dominant_num_medals
	USA					1038
	Australia			402
	Italy				358
	Canada				347
	*/
# 4. Join all three tables together to display the total number of medals per each country, 
 # the dominant sport for which each country won the highest number of medals,
 # and how many medals they won for this sport.
################################
# Output Example:
################################
/*
region_name 	tot_num_medals 	dominant_sport 		dominant_num_medals
USA				5414			Swimming			1038
Soviet Union	2658			Gymnastics			290
Germany			2395			Rowing				258
UK				1971			Athletics			337
France			1686			Fencing				307
*/
#################################
WITH 
	all_ AS (
		SELECT pr.region_name, 
			   s.sport_name, 
			   COUNT(m.medal_name) AS num_medals
		FROM olympics_scen_1.medal m,
			 olympics_scen_1.competitor_event ce,
			 olympics_scen_1.event e,
			 olympics_scen_1.sport s,
			 olympics_scen_1.games_competitor gc,
			 olympics_scen_1.person p,
			 olympics_scen_1.person_region pr

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
# Q10 - Re-design
# What is the percentage of number of won medals 
# for each country over the last ten years compared to 
# the whole period (20 years, 1896 to 2016)?
#################################
# Execution Time: ~ 7 seconds.
#################################
# 3 temp. tables, FULL OUTER JOIN, TRUNCATE
# Number of used tables: 8
#################################
# Execution Plan:
################################
# 1. Create a temporary table (medals_per_country) that hold the required columns.
# 2. Create another temporary table (tot20years) to count the number of medals per each country between '1896-2016' from medals_per_country.
# 3. Create another temporary table (last10years) to count the number of medals per each country between '2006-2016' from medals_per_country.
# 4. Full outer join tot20years and last10years to compute the number of medals between '1896-2006' 
	# and calculate the percentage of won medals during the last 10 years '2006-2016'.
################################
# Output Example:
################################
/*
region_name 	tot20years_num_medals 	'1896-2005' 	'2006-2016' 	last_10years_pct
USA				5414					4379			1035			19.11
Soviet Union	2658					2654			4				0.15
Germany			2395					1899			496				20.70
UK				1971					1607			364				18.46
France			1686					1384			302				17.91
*/
#################################
SELECT region_name, 
       tot20years_num_medals,
       (tot20years_num_medals - last10years_num_medals) AS '1896-2005',
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
			FROM olympics_scen_1.medal m,
				 olympics_scen_1.competitor_event ce,
				 olympics_scen_1.event e,
				 olympics_scen_1.sport s,
				 olympics_scen_1.games_competitor gc,
				 olympics_scen_1.games g,
				 olympics_scen_1.person p,
				 olympics_scen_1.person_region pr

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
#########################################################################
#########################################################################
/*
Comparison between the two implementations of Query 9 and Query 10.

# Query 9
In the first implementation (unoptimized), we joined 7 tables together twice,
once for total temporary table to get the total number of medals per each
country, and once for all_ temporary table to count the total number of medals
per each sport in each country.
# While in the second implementation (optimized), we joined the 7 tables once.

# Query 10
Exactly the same idea. Instead of joining 8 tables twice in the first implementation (unoptimized), 
we did it once in the second implementation (optimized).
*/

