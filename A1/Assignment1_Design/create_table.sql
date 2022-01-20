
CREATE table IF NOT EXISTS drivers(
    driverId bigint NOT NULL,
    driverRef text,
    forename text,
    surname  text,
    nationality text,
    CONSTRAINT driver_key PRIMARY KEY (driverId)
);

CREATE TABLE  IF NOT EXISTS circuits (
    circuitId bigint NOT NULL,
    circuitRef text,
    name text,
    location  text,
    country text,
    CONSTRAINT circuit_key PRIMARY KEY (circuitId)
);

CREATE TABLE  IF NOT EXISTS constructors (
    constructorId bigint NOT NULL,
    constructorRef text,
    name text,
    nationality text,
    CONSTRAINT constructor_key PRIMARY KEY (constructorId)
);

CREATE TABLE  IF NOT EXISTS status (
    statusId bigint NOT NULL,
    status text,
    CONSTRAINT status_key PRIMARY KEY (statusId)
);

CREATE TABLE  IF NOT EXISTS races (
    raceId bigint NOT NULL,
    year bigint,
    round bigint,
    circuitId bigint,
    name text,
    CONSTRAINT race_key PRIMARY KEY (raceId),
    CONSTRAINT circuit_ref FOREIGN KEY (circuitId) references circuits(circuitId)
);

CREATE TABLE  IF NOT EXISTS pitStops (
    raceId bigint NOT NULL,
    driverId bigint NOT NULL,
    stop bigint,
    lap bigint,
    milliseconds bigint,
    CONSTRAINT race_ref FOREIGN KEY (raceId) references races(raceId),
    CONSTRAINT driver_ref FOREIGN KEY (driverId) references drivers(driverId)
);



CREATE TABLE  IF NOT EXISTS lapTimes (
    raceId bigint NOT NULL,
    driverId bigint NOT NULL,
    lap bigint,
    position bigint,
    milliseconds bigint,
    CONSTRAINT race_ref FOREIGN KEY (raceId) references races(raceId),
    CONSTRAINT driver_ref FOREIGN KEY (driverId) references drivers(driverId)
);

CREATE TABLE  IF NOT EXISTS qualifying (
    qualifyId bigint NOT NULL,
    raceId bigint,
    driverId bigint,
    constructorId bigint,
    position bigint,
    CONSTRAINT qualify_key PRIMARY KEY (qualifyId),
    CONSTRAINT race_ref FOREIGN KEY (raceId) references races(raceId),
    CONSTRAINT driver_ref FOREIGN KEY (driverId) references drivers(driverId),
    CONSTRAINT constructor_ref FOREIGN KEY (constructorId) references constructors(constructorId)
);

CREATE TABLE  IF NOT EXISTS results (
    resultId bigint NOT NULL,
    raceId bigint,
    driverId bigint,
    constructorId bigint,
    grid bigint,
    positionOrder bigint,
    points bigint,
    laps bigint,
    milliseconds bigint,
    fastestLap bigint,
    rank bigint,
    statusId bigint,
    CONSTRAINT result_key PRIMARY KEY (resultId),
    CONSTRAINT race_ref FOREIGN KEY (raceId) references races(raceId),
    CONSTRAINT driver_ref FOREIGN KEY (driverId) references drivers(driverId),
    CONSTRAINT constructor_ref FOREIGN KEY (constructorId) references constructors(constructorId),
    CONSTRAINT status_ref FOREIGN KEY (statusId) references status(statusId)
);


CREATE TABLE  IF NOT EXISTS constructorResults (
    constructorResultsId bigint NOT NULL,
    raceId bigint,
    constructorId bigint,
    points bigint,
    CONSTRAINT constructorResults_key PRIMARY KEY (constructorResultsId),
    CONSTRAINT race_ref FOREIGN KEY (raceId) references races(raceId),
    CONSTRAINT constructor_ref FOREIGN KEY (constructorId) references constructors(constructorId)
);


