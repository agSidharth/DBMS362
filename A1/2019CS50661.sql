--1--
CREATE TABLE TEMP AS (SELECT lapTimes.driverId,milliseconds as time
		 			  FROM lapTimes
					  WHERE lapTimes.raceId = (SELECT races.raceId
						    				FROM races,circuits
											WHERE (circuits.country LIKE '%Monaco%' AND races.year = 2017 AND races.circuitId = circuits.circuitId)));

SELECT drivers.driverId,forename,surname,nationality,TEMP.time
FROM drivers,TEMP
WHERE (drivers.driverId = TEMP.driverId AND time = (SELECT MAX(time) FROM TEMP))
ORDER BY forename,surname,nationality;

DROP TABLE TEMP;

--2--
CREATE TABLE TEMP AS (SELECT constructorResults.constructorId,SUM(points) as points
					  FROM constructorResults,races
					  WHERE (races.year = 2012 AND races.raceId = constructorResults.raceId)
					  GROUP BY constructorResults.constructorId);

SELECT constructors.name,constructors.constructorId,constructors.nationality,TEMP.points
FROM constructors,TEMP
WHERE (constructors.constructorId = TEMP.constructorId)
ORDER BY points DESC, constructors.name, nationality, constructorId
LIMIT 5;

DROP TABLE TEMP;

--3--

CREATE TABLE TEMP AS (SELECT results.driverId,SUM(results.points) as points
					  FROM results,races
					  WHERE (races.year>=2001 AND races.year<=2020 AND races.raceId=results.raceId)
					  GROUP BY results.driverId);

SELECT drivers.driverId,forename,surname,TEMP.points
FROM TEMP,drivers
WHERE (drivers.driverId = TEMP.driverId AND (TEMP.points = (SELECT MAX(points) FROM TEMP)))
ORDER BY forename,surname,driverId;

DROP TABLE TEMP;

--4--
CREATE TABLE TEMP AS (SELECT constructorResults.constructorId,SUM(constructorResults.points) as points
					  FROM constructorResults,races
					  WHERE (races.year>=2010 AND races.year<=2020 AND races.raceId=constructorResults.raceId)
					  GROUP BY constructorResults.constructorId);

SELECT constructors.constructorId,constructors.name,constructors.nationality,TEMP.points
FROM TEMP,constructors
WHERE (constructors.constructorId = TEMP.constructorId AND (TEMP.points = (SELECT MAX(points) FROM TEMP)))
ORDER BY name,nationality,constructorId;

DROP TABLE TEMP;

--5--
CREATE TABLE TEMP1 AS (SELECT results.raceId,MAX(results.points) as points
					  FROM results
					  GROUP BY results.raceId);

CREATE TABLE TEMP2 AS (SELECT results.driverId,TEMP1.points
					   FROM results,TEMP1
					   WHERE (results.raceId = TEMP1.raceId AND results.points = TEMP1.points));

CREATE TABLE TEMP3 AS (SELECT TEMP2.driverId,COUNT(TEMP2.driverId) as race_wins
					   FROM TEMP2
					   GROUP BY TEMP2.driverId);


SELECT drivers.driverId,drivers.forename,drivers.surname,race_wins
FROM TEMP3,drivers
WHERE (drivers.driverId = TEMP3.driverId AND TEMP3.race_wins = (SELECT MAX(race_wins) FROM TEMP3))
ORDER BY forename,surname,driverId;

DROP TABLE TEMP1,TEMP2,TEMP3;

--6--
CREATE TABLE TEMP1 AS (SELECT constructorResults.raceId,MAX(constructorResults.points) as points
					  FROM constructorResults
					  GROUP BY constructorResults.raceId);

CREATE TABLE TEMP2 AS (SELECT constructorResults.constructorId,TEMP1.points
					   FROM constructorResults,TEMP1
					   WHERE (constructorResults.raceId = TEMP1.raceId AND constructorResults.points = TEMP1.points));

CREATE TABLE TEMP3 AS (SELECT TEMP2.constructorId,COUNT(TEMP2.constructorId) as num_wins
					   FROM TEMP2
					   GROUP BY TEMP2.constructorId);


SELECT constructors.constructorId,constructors.name,num_wins
FROM TEMP3,constructors
WHERE (constructors.constructorId = TEMP3.constructorId AND TEMP3.num_wins = (SELECT MAX(num_wins) FROM TEMP3))
ORDER BY name,constructorId;

DROP TABLE TEMP1,TEMP2,TEMP3;

--7--
