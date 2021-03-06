--1--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info WHERE (source_station_name LIKE '%KURLA%' AND train_no = 97131)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4)
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;


--2--

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

--3--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,day_of_arrival,1 AS depth FROM train_info WHERE (source_station_name LIKE '%DADAR%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,train_info.day_of_arrival,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 AND train_info.day_of_arrival = train_info.day_of_departure
		AND train_info.day_of_arrival = connected2K.day_of_arrival)
) 
SELECT destination_station_name,distance,day_of_arrival as day
FROM connected2K
WHERE (destination_station_name NOT LIKE '%DADAR%')
ORDER BY destination_station_name,distance,day;


--4--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,arrival_time,day_of_arrival,1 AS depth FROM train_info WHERE (source_station_name LIKE '%DADAR%')
	UNION 
	SELECT train_info.source_station_name,train_info.destination_station_name,train_info.arrival_time,train_info.day_of_arrival,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<4 
		AND ((train_info.day_of_departure = connected2K.day_of_arrival AND connected2K.arrival_time<train_info.departure_time) 
			OR (train_info.day_of_departure != connected2K.day_of_arrival AND
			   ((connected2K.day_of_arrival LIKE '%Monday%')
			OR (connected2K.day_of_arrival LIKE '%Tuesday%' AND train_info.day_of_departure NOT LIKE '%Monday%')
			OR (connected2K.day_of_arrival LIKE '%Wednesday%' AND train_info.day_of_departure NOT LIKE '%Monday|Tuesday%')
			OR (connected2K.day_of_arrival LIKE '%Thursday%' AND train_info.day_of_departure NOT LIKE '%Monday|Tuesday|Wednesday%')
			OR (connected2K.day_of_arrival LIKE '%Friday%' AND train_info.day_of_departure LIKE '%Saturday|Sunday%')
			OR (connected2K.day_of_arrival LIKE '%Saturday%' AND train_info.day_of_departure LIKE '%Sunday%')))))
) 
SELECT distinct destination_station_name
FROM connected2K
WHERE (destination_station_name NOT LIKE '%DADAR%')
ORDER BY destination_station_name;


--5--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth,ARRAY[source_station_name] as path0 FROM train_info WHERE (source_station_name LIKE '%CST-MUMBAI%')
	UNION ALL
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth, path0 || train_info.source_station_name
	FROM train_info INNER JOIN connected2K on 
	(train_info.source_station_name = connected2K.destination_station_name 
		AND connected2K.depth + 1<4 AND train_info.destination_station_name <> ALL(connected2K.path0)
		AND train_info.source_station_name NOT LIKE '%VASHI%')
) 
SELECT COUNT(*) as count
FROM connected2K
WHERE (destination_station_name LIKE '%VASHI%');


--6--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,distance,1 AS depth FROM train_info
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,train_info.distance + connected2K.distance,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<7)
) 
SELECT source_station_name,destination_station_name,MIN(distance) as distance
FROM connected2K
GROUP BY source_station_name,destination_station_name
ORDER BY destination_station_name,source_station_name,distance;

--7--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info WHERE (source_station_name!=destination_station_name)
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<5 AND
			connected2K.source_station_name!=train_info.destination_station_name)
) 
SELECT distinct source_station_name,destination_station_name
FROM connected2K
ORDER BY source_station_name,destination_station_name;

--8--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,day_of_arrival FROM train_info WHERE (source_station_name LIKE '%SHIVAJINAGAR%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,train_info.day_of_arrival
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name 
		AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = connected2K.day_of_arrival AND
		train_info.destination_station_name NOT LIKE '%SHIVAJINAGAR%')
) 
SELECT distinct destination_station_name
FROM connected2K
ORDER BY destination_station_name;

--9--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,day_of_arrival,ARRAY[source_station_name] as path0,1 as pathlen FROM train_info
	WHERE (source_station_name LIKE '%LONAVLA%' AND train_info.day_of_arrival = train_info.day_of_departure)
	UNION
	SELECT connected2K.source_station_name,train_info.destination_station_name,train_info.day_of_arrival,path0 || train_info.source_station_name,pathlen + 1
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND
		train_info.destination_station_name <> ALL(connected2K.path0) AND train_info.day_of_arrival = connected2K.day_of_arrival
		AND train_info.day_of_arrival = train_info.day_of_departure)
),
TEMP1 AS (
	SELECT destination_station_name,MIN(pathlen) as pathlen
	FROM connected2K
	GROUP BY destination_station_name
)

SELECT connected2K.destination_station_name, TEMP1.pathlen as distance,connected2K.day_of_arrival as day
FROM connected2K,TEMP1
WHERE (connected2K.destination_station_name = TEMP1.destination_station_name AND connected2K.pathlen = TEMP1.pathlen)
ORDER BY distance,destination_station_name,connected2K.day_of_arrival;

--10--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,ARRAY[]::text[] as path0,1 as pathlen FROM train_info
	WHERE (source_station_name!=destination_station_name)
	UNION
	SELECT connected2K.source_station_name,train_info.destination_station_name,path0 || train_info.source_station_name,pathlen + 1
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND
		train_info.destination_station_name <> ALL(connected2K.path0) AND connected2K.source_station_name!=train_info.source_station_name)
)
SELECT distinct source_station_name,pathlen as distance
FROM connected2K
WHERE (connected2K.source_station_name = connected2K.destination_station_name AND 
	(connected2K.pathlen = (SELECT MAX(pathlen) FROM connected2K WHERE (connected2K.source_station_name = connected2K.destination_station_name))))
ORDER BY source_station_name;

--11--

WITH RECURSIVE connected2K AS(
	SELECT source_station_name,destination_station_name,1 AS depth FROM train_info
	UNION 
	SELECT connected2K.source_station_name,train_info.destination_station_name,connected2K.depth + 1 as depth
	FROM train_info INNER JOIN connected2K on (train_info.source_station_name = connected2K.destination_station_name AND connected2K.depth + 1<3)
),
TEMP1 AS (SELECT distinct source_station_name FROM train_info 
		 UNION SELECT distinct destination_station_name FROM train_info),
TEMP2 AS (
SELECT connected2K.source_station_name,COUNT(distinct connected2K.destination_station_name) as count
FROM connected2K
GROUP BY connected2K.source_station_name
)

SELECT TEMP2.source_station_name
FROM TEMP2,TEMP1
WHERE (TEMP2.count = (SELECT COUNT(*) FROM TEMP1))
ORDER BY source_station_name;

--12--

SELECT distinct teams2.name as teamnames
FROM games as games1,games as games2,teams as teams1, teams as teams2
WHERE (teams1.teamid = games1.hometeamid AND teams2.teamid = games2.hometeamid
		AND games1.awayteamid = games2.awayteamid AND teams1.name LIKE '%Arsenal%' AND teams2.name NOT LIKE '%Arsenal%')
ORDER BY teamnames;

--13--

WITH TEMP1 AS (
	SELECT hometeamid, SUM(homegoals) as goals
	FROM games
	GROUP BY hometeamid),

TEMP2 AS (SELECT awayteamid, SUM(awaygoals) as goals
		  FROM games
		  GROUP BY awayteamid),

TEMP3 AS 
(SELECT games2.hometeamid,TEMP1.goals + TEMP2.goals as goals ,games2.year
FROM games as games1, games as games2,teams,TEMP1,TEMP2,teams as teams2
WHERE (teams.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid
		AND teams.name LIKE '%Arsenal%' AND TEMP1.hometeamid = games2.hometeamid
		AND TEMP2.awayteamid = games2.hometeamid AND teams2.name NOT LIKE '%Arsenal%' AND teams2.teamid = games2.hometeamid)),

TEMP4 AS (SELECT TEMP3.hometeamid,goals,year
FROM TEMP3
WHERE (TEMP3.goals = (SELECT MAX(goals) FROM TEMP3)))

SELECT distinct teams.name as teamnames,goals,year
FROM TEMP4,teams
WHERE (teams.teamid = TEMP4.hometeamid AND TEMP4.year = (SELECT MIN(year) FROM TEMP4))
ORDER BY goals DESC,year,teamnames;

--14--

WITH TEMP1 AS(
	SELECT distinct games2.hometeamid
	FROM games as games1,games as games2,teams as teams1, teams as teams2
	WHERE (teams1.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid 
		AND teams1.name LIKE '%Leicester%' AND games2.hometeamid = teams2.teamid 
		AND teams2.name NOT LIKE '%Leicester%')
)
SELECT distinct teams.name as teamnames,games.homegoals - games.awaygoals as goaldiff
FROM games,teams,TEMP1
WHERE (games.hometeamid = teams.teamid AND TEMP1.hometeamid = games.hometeamid AND games.year = 2015
		AND games.homegoals - games.awaygoals > 3)
ORDER BY goaldiff, teamnames;


--15--

WITH TEMP1 AS(
	SELECT distinct games2.hometeamid,games2.gameid
	FROM games as games1,games as games2,teams as teams1, teams as teams2
	WHERE (teams1.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid 
		AND teams1.name LIKE '%Valencia%' AND games2.hometeamid = teams2.teamid 
		AND teams2.name NOT LIKE '%Valencia%')
),
TEMP2 AS (
	SELECT appearances.playerid,SUM(appearances.goals) as score
	FROM appearances,TEMP1,games
	WHERE (TEMP1.hometeamid = games.hometeamid AND games.gameid = appearances.gameid AND games.gameid = TEMP1.gameid)
	GROUP BY appearances.playerid
)

SELECT players.name as playernames,TEMP2.score
FROM players,TEMP2
WHERE (players.playerid = TEMP2.playerid AND TEMP2.score = (SELECT MAX(score) FROM TEMP2))
ORDER BY playernames,score;


--16--

WITH TEMP1 AS(
	SELECT distinct games2.hometeamid,games2.gameid
	FROM games as games1,games as games2,teams as teams1, teams as teams2
	WHERE (teams1.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid 
		AND teams1.name LIKE '%Everton%' AND games2.hometeamid = teams2.teamid 
		AND teams2.name NOT LIKE '%Everton%')
),
TEMP2 AS (
	SELECT appearances.playerid,SUM(appearances.assists) as assistscount
	FROM appearances,TEMP1,games
	WHERE (TEMP1.hometeamid = games.hometeamid AND games.gameid = appearances.gameid AND games.gameid = TEMP1.gameid)
	GROUP BY appearances.playerid
)

SELECT players.name as playernames,TEMP2.assistscount
FROM players,TEMP2
WHERE (players.playerid = TEMP2.playerid AND TEMP2.assistscount = (SELECT MAX(assistscount) FROM TEMP2))
ORDER BY assistscount desc,playernames;

--17--

WITH TEMP1 AS(
	SELECT distinct games2.awayteamid,games2.gameid
	FROM games as games1,games as games2,teams as teams1, teams as teams2
	WHERE (teams1.teamid = games1.awayteamid AND games1.hometeamid = games2.hometeamid 
		AND teams1.name LIKE '%AC Milan%' AND games2.awayteamid = teams2.teamid 
		AND teams2.name NOT LIKE '%AC Milan%')
),
TEMP2 AS (
	SELECT appearances.playerid,SUM(appearances.shots) as shotscount
	FROM appearances,TEMP1,games
	WHERE (TEMP1.awayteamid = games.awayteamid AND games.gameid = appearances.gameid AND games.year = 2016 AND games.gameid = TEMP1.gameid)
	GROUP BY appearances.playerid
)

SELECT players.name as playernames,TEMP2.shotscount
FROM players,TEMP2
WHERE (players.playerid = TEMP2.playerid AND TEMP2.shotscount = (SELECT MAX(shotscount) FROM TEMP2))
ORDER BY shotscount desc,playernames;


--18--

WITH TEMP1 AS(
	SELECT distinct games2.hometeamid,games2.gameid
	FROM games as games1,games as games2,teams as teams1, teams as teams2
	WHERE (teams1.teamid = games1.hometeamid AND games1.awayteamid = games2.awayteamid 
		AND teams1.name LIKE '%AC Milan%' AND games2.hometeamid = teams2.teamid 
		AND teams2.name NOT LIKE '%AC Milan%')
),

TEMP2 AS (
SELECT teams.name as teamnames,games.year,SUM(games.awaygoals) as goals
FROM teams,games,TEMP1
WHERE (teams.teamid = games.awayteamid AND games.hometeamid = TEMP1.hometeamid AND games.year = 2020 AND games.gameid = TEMP1.gameid)
GROUP BY teams.name,year)

SELECT distinct teamnames,year
FROM TEMP2
WHERE (TEMP2.goals = 0)
ORDER BY teamnames,year
LIMIT 5;

--19--
WITH TEMP1 AS(
	SELECT games.hometeamid,games.leagueid,SUM(games.homegoals) as teamtopscore
	FROM games
	WHERE (games.year = 2019)
	GROUP BY games.hometeamid,games.leagueid
),
TEMP2 AS(
SELECT teams.name as teamname,leagues.name as leaguename,teamtopscore
FROM TEMP1,leagues,teams
WHERE (TEMP1.teamtopscore = (SELECT MAX(teamtopscore) FROM TEMP1 as TEMPN WHERE(TEMPN.leagueid = TEMP1.leagueid))
		AND leagues.leagueid = TEMP1.leagueid AND teams.teamid = TEMP1.hometeamid)
),
TEMP3 AS(
	SELECT TEMP2.leaguename,players.name as playernames,SUM(appearances.goals) as playertopscore,TEMP2.teamname,TEMP2.teamtopscore
	FROM games as games1,TEMP2,games as games2,teams,appearances,players
	WHERE (teams.teamid = games1.hometeamid AND teams.name = TEMP2.teamname AND games1.awayteamid = games2.awayteamid AND
		appearances.gameid = games2.gameid AND appearances.playerid = players.playerid AND games2.year = 2019)
	GROUP BY TEMP2.leaguename,players.name,TEMP2.teamname,TEMP2.teamtopscore
)

SELECT *
FROM TEMP3
WHERE (TEMP3.playertopscore = (SELECT MAX(playertopscore) FROM TEMP3 as TEMP4 WHERE (TEMP3.leaguename = TEMP4.leaguename AND TEMP3.teamname = TEMP4.teamname AND TEMP3.teamtopscore = TEMP4.teamtopscore)))
ORDER BY playertopscore desc, teamtopscore desc, playernames asc;


--20--

WITH RECURSIVE TEMP AS(
	SELECT games.hometeamid,games.awayteamid,ARRAY[games.hometeamid] as path0,1 as pathlen FROM games,teams 
	WHERE(games.hometeamid = teams.teamid AND teams.name LIKE '%Manchester United%')
	UNION
	SELECT TEMP.hometeamid,games.awayteamid,path0 || games.hometeamid as path0,pathlen + 1 as pathlen
	FROM games INNER JOIN TEMP on 
	(TEMP.awayteamid = games.hometeamid AND games.awayteamid <> ALL(TEMP.path0)
	 AND games.hometeamid != (SELECT teamid FROM teams WHERE(teams.name LIKE '%Manchester City%')))
)
SELECT MAX(pathlen) as count
FROM TEMP,teams
WHERE (TEMP.awayteamid = teams.teamid AND teams.name LIKE '%Manchester City%');


--21--


WITH RECURSIVE TEMP AS(
	SELECT games.hometeamid,games.awayteamid,ARRAY[games.hometeamid] as path0 FROM games,teams WHERE(games.hometeamid = teams.teamid AND teams.name LIKE '%Manchester United%')
	UNION
	SELECT TEMP.hometeamid,games.awayteamid,path0 || games.hometeamid as path0
	FROM games INNER JOIN TEMP on 
	(TEMP.awayteamid = games.hometeamid AND games.awayteamid <> ALL(TEMP.path0)
	 AND games.hometeamid != (SELECT teamid FROM teams WHERE(teams.name LIKE '%Manchester City%')))
)
SELECT COUNT(*) as count
FROM TEMP,teams
WHERE (TEMP.awayteamid = teams.teamid AND teams.name LIKE '%Manchester City%');

--22--

WITH RECURSIVE TEMP AS(
	SELECT games.hometeamid,games.awayteamid,games.leagueid,ARRAY[games.hometeamid] as path0,1 as pathlen FROM games,teams
	UNION
	SELECT TEMP.hometeamid,games.awayteamid,games.leagueid,path0 || games.hometeamid as path0,pathlen + 1 as pathlen
	FROM games INNER JOIN TEMP on 
	(TEMP.awayteamid = games.hometeamid AND games.awayteamid <> ALL(TEMP.path0)
	 AND games.leagueid = TEMP.leagueid)
),
TEMP2 AS (
SELECT	leagueid,MAX(pathlen) as pathlen
FROM TEMP
GROUP BY leagueid)


SELECT distinct leagues.name as leaguename,teams1.name as teamAname,teams2.name as teamBname,TEMP2.pathlen as count
FROM teams as teams1,teams as teams2,leagues,TEMP,TEMP2
WHERE (TEMP.leagueid = TEMP2.leagueid AND TEMP.pathlen = TEMP2.pathlen AND TEMP.leagueid = leagues.leagueid
AND teams1.teamid = TEMP.hometeamid AND teams2.teamid = TEMP.awayteamid)
ORDER BY count desc, teamAname, teamBname;

