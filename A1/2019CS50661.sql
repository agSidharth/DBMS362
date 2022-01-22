--1--
WITH TEMP AS (SELECT lapTimes.driverId,milliseconds as time
		 			  FROM lapTimes
					  WHERE lapTimes.raceId = (SELECT races.raceId
						    				FROM races,circuits
											WHERE (circuits.country LIKE '%Monaco%' AND races.year = 2017 AND races.circuitId = circuits.circuitId)))

SELECT drivers.driverId,forename,surname,nationality,TEMP.time
FROM drivers,TEMP
WHERE (drivers.driverId = TEMP.driverId AND time = (SELECT MAX(time) FROM TEMP))
ORDER BY forename,surname,nationality;

--2--
WITH TEMP AS (SELECT constructorResults.constructorId,SUM(points) as points
					  FROM constructorResults,races
					  WHERE (races.year = 2012 AND races.raceId = constructorResults.raceId)
					  GROUP BY constructorResults.constructorId)

SELECT constructors.name,constructors.constructorId,constructors.nationality,TEMP.points
FROM constructors,TEMP
WHERE (constructors.constructorId = TEMP.constructorId)
ORDER BY points DESC, constructors.name, nationality, constructorId
LIMIT 5;


--3--

WITH TEMP AS (SELECT results.driverId,SUM(results.points) as points
					  FROM results,races
					  WHERE (races.year>=2001 AND races.year<=2020 AND races.raceId=results.raceId)
					  GROUP BY results.driverId)

SELECT drivers.driverId,forename,surname,TEMP.points
FROM TEMP,drivers
WHERE (drivers.driverId = TEMP.driverId AND (TEMP.points = (SELECT MAX(points) FROM TEMP)))
ORDER BY forename,surname,driverId;


--4--
WITH TEMP AS (SELECT constructorResults.constructorId,SUM(constructorResults.points) as points
					  FROM constructorResults,races
					  WHERE (races.year>=2010 AND races.year<=2020 AND races.raceId=constructorResults.raceId)
					  GROUP BY constructorResults.constructorId)

SELECT constructors.constructorId,constructors.name,constructors.nationality,TEMP.points
FROM TEMP,constructors
WHERE (constructors.constructorId = TEMP.constructorId AND (TEMP.points = (SELECT MAX(points) FROM TEMP)))
ORDER BY name,nationality,constructorId;


--5--
WITH TEMP1 AS (SELECT results.raceId,MAX(results.points) as points
					  FROM results
					  GROUP BY results.raceId),

TEMP2 AS (SELECT results.driverId,TEMP1.points
					   FROM results,TEMP1
					   WHERE (results.raceId = TEMP1.raceId AND results.points = TEMP1.points)),

TEMP3 AS (SELECT TEMP2.driverId,COUNT(TEMP2.driverId) as race_wins
					   FROM TEMP2
					   GROUP BY TEMP2.driverId)


SELECT drivers.driverId,drivers.forename,drivers.surname,race_wins
FROM TEMP3,drivers
WHERE (drivers.driverId = TEMP3.driverId AND TEMP3.race_wins = (SELECT MAX(race_wins) FROM TEMP3))
ORDER BY forename,surname,driverId;


--6--
WITH TEMP1 AS (SELECT constructorResults.raceId,MAX(constructorResults.points) as points
					  FROM constructorResults
					  GROUP BY constructorResults.raceId),

TEMP2 AS (SELECT constructorResults.constructorId,TEMP1.points
					   FROM constructorResults,TEMP1
					   WHERE (constructorResults.raceId = TEMP1.raceId AND constructorResults.points = TEMP1.points)),

TEMP3 AS (SELECT TEMP2.constructorId,COUNT(TEMP2.constructorId) as num_wins
					   FROM TEMP2
					   GROUP BY TEMP2.constructorId)


SELECT constructors.constructorId,constructors.name,num_wins
FROM TEMP3,constructors
WHERE (constructors.constructorId = TEMP3.constructorId AND TEMP3.num_wins = (SELECT MAX(num_wins) FROM TEMP3))
ORDER BY name,constructorId;


--7--

WITH TEMP1 AS (SELECT results.driverId,races.year,SUM(results.points) as points
			  FROM results,races
			  WHERE (results.raceId = races.raceId)
			  GROUP BY results.driverId,races.year),

TEMP2 AS (SELECT TEMP1.year,MAX(points) as points
		  FROM TEMP1
		  GROUP BY TEMP1.year),

TEMP3 AS (SELECT TEMP1.driverId,COUNT(*) as counts
		  FROM TEMP1,TEMP2
		  WHERE (TEMP1.year = TEMP2.year AND TEMP1.points = TEMP2.points)
		  GROUP BY TEMP1.driverId)


SELECT TEMP1.driverId,forename,surname,SUM(TEMP1.points) as points
FROM TEMP1,drivers
WHERE (drivers.driverId = TEMP1.driverId AND (NOT EXISTS (SELECT * FROM TEMP3 WHERE (TEMP3.driverId = TEMP1.driverId))))
GROUP BY TEMP1.driverId,forename,surname
ORDER BY points DESC,forename,surname,TEMP1.driverId
LIMIT 3;

--8--
WITH TEMP1 AS (SELECT results.raceId,MAX(results.points) as points
					  FROM results
					  GROUP BY results.raceId),

TEMP2 AS (SELECT results.driverId,results.raceId
					   FROM results,TEMP1
					   WHERE (results.raceId = TEMP1.raceId AND results.points = TEMP1.points)),

TEMP3 AS (SELECT TEMP2.driverId,COUNT(DISTINCT circuits.country) as num_countries
					   FROM TEMP2,races,circuits
					   WHERE (TEMP2.raceId=races.raceId AND races.circuitId = circuits.circuitId)
					   GROUP BY driverId)

SELECT TEMP3.driverId,drivers.forename,drivers.surname,TEMP3.num_countries
FROM drivers,TEMP3
WHERE (drivers.driverId = TEMP3.driverId AND TEMP3.num_countries = (SELECT MAX(num_countries) FROM TEMP3))
ORDER BY forename,surname,driverId;

--9--
SELECT results.driverId,drivers.forename,drivers.surname,COUNT(DISTINCT results.raceId) as num_wins
FROM results,drivers
WHERE (results.grid = 1 AND results.positionOrder = 1 AND drivers.driverId = results.driverId)
GROUP BY results.driverId,drivers.forename,drivers.surname
ORDER BY num_wins DESC,forename,surname,driverId
LIMIT 3;

--10--
WITH TEMP AS (SELECT results.raceId,MAX(pitStops.stop) as num_stops,results.driverId
			  FROM results,pitStops
			  WHERE (results.positionOrder = 1 AND results.raceId = pitStops.raceId AND results.driverId = pitStops.driverId)
			  GROUP BY results.raceId,results.driverId)

SELECT TEMP.raceId,TEMP.num_stops,TEMP.driverId,forename,surname,circuits.circuitId,circuits.name
FROM TEMP,drivers,circuits,races
WHERE (TEMP.num_stops = (SELECT MAX(num_stops) FROM TEMP) AND TEMP.driverId = drivers.driverId AND TEMP.raceId = races.raceId AND races.circuitId = circuits.circuitId)
ORDER BY forename,surname,name,circuits.circuitId,TEMP.driverId;

--11--
WITH TEMP AS (SELECT results.raceId, COUNT(*) as num_collisions
			  FROM results,status
			  WHERE (results.statusId = status.statusId AND status.status LIKE '%Collision%')
			  GROUP BY results.raceId)

SELECT TEMP.raceId,circuits.name,circuits.location,TEMP.num_collisions
FROM TEMP,circuits,races
WHERE (TEMP.raceId = races.raceId AND races.circuitId = circuits.circuitId AND TEMP.num_collisions = (SELECT MAX(num_collisions) FROM TEMP))
ORDER BY name,location,raceId;

--12--
WITH TEMP1 AS (SELECT lapTimes.raceId,MIN(milliseconds) as time
			   FROM lapTimes
			   GROUP BY lapTimes.raceId),

TEMP2 AS (SELECT results.driverId,forename,surname,COUNT(*) as count
		  FROM results,drivers,lapTimes,TEMP1
		  WHERE (results.driverId = drivers.driverId AND results.raceId = lapTimes.raceId AND results.driverId = lapTimes.driverId AND
		  		  results.fastestLap = lapTimes.lap AND TEMP1.raceId = results.raceId AND lapTimes.milliseconds = TEMP1.time)
		  GROUP BY results.driverId,forename,surname)

SELECT * 
FROM TEMP2
WHERE (count = (SELECT MAX(count) FROM TEMP2))
ORDER BY forename,surname,TEMP2.driverId;


--13--

WITH TEMP1 AS (SELECT constructorResults.constructorId,races.year,SUM(constructorResults.points) as points
			  FROM constructorResults,races
			  WHERE (constructorResults.raceId = races.raceId)
			  GROUP BY constructorResults.constructorId,races.year),

TEMP2 AS (SELECT TEMP1.year,MAX(points) as points
		  FROM TEMP1
		  GROUP BY TEMP1.year),

TEMP3 AS (SELECT TEMP1.year, MAX(TEMP1.points) as points
		  FROM TEMP1,TEMP2
		  WHERE (TEMP1.year=TEMP2.year AND TEMP1.points<TEMP2.points)
		  GROUP BY TEMP1.year),

TEMP4 AS (SELECT TEMP1.constructorId,TEMP1.points,TEMP1.year,constructors.name
		  FROM TEMP1,TEMP2,constructors
		  WHERE (TEMP1.year = TEMP2.year AND TEMP1.points = TEMP2.points AND TEMP1.constructorId = constructors.constructorId)),

TEMP5 AS (SELECT TEMP1.constructorId,TEMP1.points,TEMP1.year,constructors.name
		  FROM TEMP1,TEMP3,constructors
		  WHERE (TEMP1.year = TEMP3.year AND TEMP1.points = TEMP3.points AND TEMP1.constructorId = constructors.constructorId)),

TEMP6 AS (SELECT TEMP4.year,(TEMP4.points - TEMP5.points) as point_diff,TEMP4.constructorId as constructor1_id,
		  TEMP4.name as constructor1_name, TEMP5.constructorId as constructor2_id, TEMP5.name as constructor2_name
		  FROM TEMP4,TEMP5
		  WHERE (TEMP4.year = TEMP5.year))

SELECT *
FROM TEMP6
WHERE (TEMP6.point_diff = (SELECT MAX(point_diff) FROM TEMP6))
ORDER BY constructor1_name,constructor2_name,constructor1_id,constructor2_id;


--14--

SELECT results.driverId,forename, surname, circuits.circuitId,circuits.country,results.grid as pos
FROM results,races,drivers,circuits
WHERE (results.positionOrder = 1 AND results.raceId = races.raceId AND races.year = 2018
		AND results.grid = (SELECT MAX(grid) FROM results,races WHERE (results.positionOrder = 1 AND results.raceId = races.raceId AND races.year = 2018))
		AND results.driverId = drivers.driverId AND races.circuitId = circuits.circuitId)
ORDER BY forename DESC, surname,country,drivers.driverId,circuits.circuitId;

--15--

WITH TEMP AS (SELECT results.constructorId,constructors.name,COUNT(*) as num
			  FROM results,constructors,races
			  WHERE (results.statusId = 5 AND results.raceId = races.raceId AND races.year>=2000 AND races.year<=2021 AND results.constructorId = constructors.constructorId)
			  GROUP BY results.constructorId,constructors.name)

SELECT *
FROM TEMP
WHERE (num = (SELECT MAX(num) FROM TEMP))
ORDER BY name,constructorId;

--16--

WITH TEMP AS (SELECT drivers.driverId,forename,surname,COUNT(*) as num
			   FROM drivers,results,races,circuits
			   WHERE (results.positionOrder = 1 AND results.driverId = drivers.driverId AND races.raceId = results.raceId
			   		  AND races.circuitId = circuits.circuitId AND circuits.country LIKE '%USA%')
			   GROUP BY drivers.driverId)

SELECT TEMP.driverId,TEMP.forename,TEMP.surname
FROM TEMP
ORDER BY forename,surname,TEMP.driverId
LIMIT 5;

--17--

WITH TEMP1 AS (SELECT results.constructorId,results.raceId
			   FROM results,races
			   WHERE (results.positionOrder = 1 AND results.raceId = races.raceId AND races.year>=2014)),

TEMP2 AS (SELECT results.constructorId,results.raceId
		  FROM results,races
		  WHERE (results.positionOrder = 2 AND results.raceId = races.raceId AND races.year>=2014)),

TEMP3 AS (SELECT TEMP1.constructorId,constructors.name,COUNT(*) as count
		  FROM TEMP1,TEMP2,constructors
		  WHERE (TEMP1.constructorId = TEMP2.constructorId AND TEMP1.raceId = TEMP2.raceId AND constructors.constructorId = TEMP1.constructorId)
		  GROUP BY TEMP1.constructorId,constructors.name)

SELECT *
FROM TEMP3
WHERE (TEMP3.count = (SELECT MAX(count) FROM TEMP3))
ORDER BY TEMP3.name,TEMP3.constructorId;

--18--

WITH TEMP AS (SELECT drivers.driverId,drivers.forename,drivers.surname,COUNT(*) as num_laps
			  FROM lapTimes,drivers
			  WHERE (lapTimes.position = 1 AND drivers.driverId = lapTimes.driverId)
			  GROUP BY drivers.driverId,drivers.forename,drivers.surname)

SELECT *
FROM TEMP
WHERE (TEMP.num_laps = (SELECT MAX(num_laps) FROM TEMP))
ORDER BY forename,surname,TEMP.driverId;

--19--

WITH TEMP AS (SELECT drivers.driverId,drivers.forename,drivers.surname,COUNT(*) as count
			  FROM results,drivers
			  WHERE (results.positionOrder >= 1 AND results.positionOrder <= 3 AND results.driverId = drivers.driverId)
			  GROUP BY drivers.driverId,drivers.forename,drivers.surname)

SELECT *
FROM TEMP
WHERE (TEMP.count = (SELECT MAX(count) FROM TEMP))
ORDER BY forename,surname DESC,TEMP.driverId;

--20--

WITH TEMP1 AS (SELECT results.driverId,races.year,SUM(results.points) as points
			  FROM results,races
			  WHERE (results.raceId = races.raceId)
			  GROUP BY results.driverId,races.year),

TEMP2 AS (SELECT TEMP1.year,MAX(points) as points
		  FROM TEMP1
		  GROUP BY TEMP1.year)

SELECT TEMP1.driverId,forename,surname,COUNT(*) as num_champs
FROM TEMP1,TEMP2,drivers
WHERE (TEMP1.year = TEMP2.year AND TEMP1.points = TEMP2.points AND drivers.driverId = TEMP1.driverId)
GROUP BY TEMP1.driverId,drivers.forename,drivers.surname
ORDER BY num_champs DESC,forename,surname DESC,TEMP1.driverId
LIMIT 5;