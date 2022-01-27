--Q1--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info WHERE (source_station_name LIKE '%KURLA%' AND train_no = 97131)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;

--Q2--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth WHERE (source_station_name LIKE '%KURLA%' AND train_no = 97131 AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.day_of_arrival = train_info.day_of_departure)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;

--Q3--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,day_of_arrival,1 AS depth FROM train_info WHERE (source_station_name LIKE '%DADAR%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,train_info.day_of_arrival,connected2K.depth + 1 as depth
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.day_of_arrival = train_info.day_of_departure)
) 
SELECT destination_station_name,distance,day_of_arrival as day
FROM connected2K
ORDER BY destination_station_name,distance,day;

--Q4--

/* Remember to recheck this..*/

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,arrival_time,1 AS depth FROM train_info WHERE (source_station_name LIKE '%DADAR%')
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.arrival_time,connected2K.depth + 1 as depth
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.departure_time>=connected2K.arrival_time)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;


--Q5--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,'' AS path0,1 AS depth FROM train_info WHERE (source_station_name LIKE '%CST-MUMBAI%')
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth, path0 || ',' || train_info.destination_station_name
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.source_station_name NOT LIKE '%VASHI%')
) 
SELECT COUNT(*) as count
FROM connected2K
WHERE (destination_station_name LIKE '%VASHI%');

--Q6--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,1 AS depth FROM train_info
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,connected2K.depth + 1 as depth
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<7)
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
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<5)
) 
SELECT source_station_name,destination_station_name
FROM connected2K
ORDER BY source_station_name,destination_station_name;


--Q8--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name FROM train_info WHERE (source_station_name LIKE '%SHIVAJINAGAR%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name 
		AND train_info.day_of_arrival = train_info.day_of_departure  AND 
		(NOT EXISTS (SELECT * FROM connected2K WHERE (connected2K.source_station_name = train_info.source_station_name))))
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
	FROM train_info INNER_JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name 
		AND train_info.day_of_arrival = train_info.day_of_departure  AND 
		(NOT EXISTS (SELECT * FROM connected2K WHERE (connected2K.source_station_name = train_info.source_station_name))))
)
SELECT MIN(distance),destination_station_name,day_of_arrival
FROM connected2K
GROUP BY destination_station_name,day_of_arrival
ORDER BY


--Q10--

--Q11--

WITH TEMP1 AS (SELECT COUNT(DISTINCT source_station_name))



--Q12--

SELECT distinct teams2.name as teamnames
FROM games as games1,games as games2,teams as teams1, teams as teams2
WHERE (teams1.teamid = games1.hometeamid AND teams2.teamid = games2.hometeamid
		AND games1.awayteamid = games2.awayteamid AND teams1.name LIKE '%Arsenal%')
ORDER BY teamnames

--Q13--

/* Remember to recheck this..*/

WITH TEMP1 AS (
	SELECT hometeamid, SUM(homegoals)
	FROM games
	GROUP BY hometeamid),

TEMP2 AS (SELECT awayteamid, SUM(awaygoals)
		  FROM games
		  GROUP BY awayteamid),

TEMP3 AS distinct games2.hometeamid
FROM games as games1, games as games2,teams
WHERE (teams.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid
		AND teams.name LIKE '%Arsenal%')


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

