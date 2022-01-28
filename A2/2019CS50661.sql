/*
--Q1--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info WHERE (source_station_name LIKE '%KURLA%' AND train_no = 97131)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;


--Q2--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth,day_of_arrival FROM train_info WHERE (source_station_name LIKE '%KURLA%' AND train_no = 97131 AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth,train_info.day_of_arrival
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.day_of_arrival = train_info.day_of_departure
		AND train_info.day_of_arrival = connected2K.day_of_arrival)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;

--Q3--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,day_of_arrival,1 AS depth FROM train_info WHERE (source_station_name LIKE '%DADAR%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,train_info.day_of_arrival,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.day_of_arrival = train_info.day_of_departure
		AND train_info.day_of_arrival = connected2K.day_of_arrival)
) 
SELECT destination_station_name,distance,day_of_arrival as day
FROM connected2K
ORDER BY destination_station_name,distance,day;

--Q4--
/* ADD WEEK DAY CONDITIONS */

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,arrival_time,day_of_arrival,1 AS depth FROM train_info WHERE (source_station_name LIKE '%DADAR%')
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.arrival_time,train_info.day_of_arrival,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 
		AND ((train_info.day_of_departure = connected2K.day_of_arrival AND connected2K.arrival_time<train_info.departure_time) 
			OR (connected2K.day_of_arrival LIKE '%Monday%')
			OR (connected2K.day_of_arrival LIKE '%Tuesday%' AND train_info.day_of_departure NOT LIKE '%Monday%')
			OR (connected2K.day_of_arrival LIKE '%Wednesday%' AND train_info.day_of_departure NOT LIKE '%Monday|Tuesday%')
			OR (connected2K.day_of_arrival LIKE '%Thursday%' AND train_info.day_of_departure NOT LIKE '%Monday|Tuesday|Wednesday%')
			OR (connected2K.day_of_arrival LIKE '%Friday%' AND train_info.day_of_departure LIKE '%Saturday|Sunday%')
			OR (connected2K.day_of_arrival LIKE '%Saturday%' AND train_info.day_of_departure LIKE '%Sunday%')))
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;

--Q5--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth,'' AS path0 FROM train_info WHERE (source_station_name LIKE '%CST-MUMBAI%')
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth, path0 || ',' || train_info.destination_station_name
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.source_station_name NOT LIKE '%VASHI%')
) 
SELECT COUNT(*) as count
FROM connected2K
WHERE (destination_station_name LIKE '%VASHI%');

--Q6--

/* Taking too much time */

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,1 AS depth FROM train_info
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<2)
) 
SELECT source_station_name,destination_station_name,distance
FROM connected2K
WHERE (connected2K.distance = (SELECT MIN(connected2K.distance) FROM connected2K))
ORDER BY destination_station_name,source_station_name,distance;


--Q7--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<5)
) 
SELECT source_station_name,destination_station_name
FROM connected2K
ORDER BY source_station_name,destination_station_name;


--Q8--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,day_of_arrival FROM train_info WHERE (source_station_name LIKE '%SHIVAJINAGAR%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,train_info.day_of_arrival
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name 
		AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = connected2K.day_of_arrival)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;

--Q9--
/*Wrong..*/

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,day_of_arrival FROM train_info WHERE (source_station_name LIKE '%LONAVLA%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,train_info.day_of_arrival
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name 
		AND train_info.day_of_arrival = train_info.day_of_departure  AND 
		(NOT EXISTS (SELECT * FROM connected2K WHERE (connected2K.source_station_name = train_info.source_station_name))))
)
SELECT MIN(distance),destination_station_name,day_of_arrival
FROM connected2K
GROUP BY destination_station_name,day_of_arrival
ORDER BY


--Q10--


*/
--Q11--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<3)
),
TEMP1 AS (SELECT COUNT(distinct destination_station_name) as count FROM train_info),
TEMP2 AS (
SELECT connected2K.source_station_name,COUNT(distinct connected2K.destination_station_name) as count
FROM connected2K
GROUP BY connected2K.source_station_name
)

SELECT TEMP2.source_station_name
FROM TEMP2,TEMP1
WHERE (TEMP2.count = TEMP1.count)
ORDER BY source_station_name

/*
--Q12--

SELECT distinct teams2.name as teamnames
FROM games as games1,games as games2,teams as teams1, teams as teams2
WHERE (teams1.teamid = games1.hometeamid AND teams2.teamid = games2.hometeamid
		AND games1.awayteamid = games2.awayteamid AND teams1.name LIKE '%Arsenal%')
ORDER BY teamnames

--Q13--

WITH TEMP1 AS (
	SELECT hometeamid, SUM(homegoals) as goals
	FROM games
	GROUP BY hometeamid),

TEMP2 AS (SELECT awayteamid, SUM(awaygoals) as goals
		  FROM games
		  GROUP BY awayteamid),

TEMP3 AS games2.hometeamid,TEMP1.goals + TEMP2.goals as goals ,games2.year
FROM games as games1, games as games2,teams,TEMP1,TEMP2
WHERE (teams.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid
		AND teams.name LIKE '%Arsenal%' AND TEMP1.hometeamid = games2.hometeamid
		AND TEMP2.awayteamid = games2.hometeamid),

TEMP4 AS TEMP3.hometeamid,goals,year
FROM TEMP3
WHERE (TEMP3.goals = (SELECT MAX(goals) FROM TEMP3))

SELECT teams.name as teamnames,goals,year
FROM TEMP4,teams
WHERE (teams.teamid = TEMP4.hometeamid AND TEMP4.year = (SELECT MIN(year) FROM TEMP4))
ORDER BY teamnames,goals,year


--Q14--

SELECT teams2.name, games2.homegoals - games2.awaygoals as goals
FROM games as games1,games as games2,teams as teams1,teams as teams2
WHERE(teams1.teamid = games1.hometeamid AND teams2.teamid = games2.hometeamid
	  AND games1.awayteamid = games2.awayteamid AND teams1.name LIKE '%Leicester%'
	  games2.year = 2015 AND (games2.homegoals - games2.awaygoals > 3))
ORDER BY goals,teams2.name

--Q15--

--Q16--

--Q17--

--Q18--

--Q19--

--Q20--

--Q21--

--Q22--

*/
