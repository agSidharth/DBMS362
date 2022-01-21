/*\i Assignment1_Design/create_table.sql*/
\copy drivers from 'Assignment1_Design/drivers.csv' DELIMITER ',' CSV HEADER;
\copy circuits from 'Assignment1_Design/circuits.csv' DELIMITER ',' CSV HEADER;
\copy constructors from 'Assignment1_Design/constructors.csv' DELIMITER ',' CSV HEADER;
\copy status from 'Assignment1_Design/status.csv' DELIMITER ',' CSV HEADER;
\copy races from 'Assignment1_Design/races.csv' DELIMITER ',' CSV HEADER;
\copy pitStops from 'Assignment1_Design/pit_stops.csv' DELIMITER ',' CSV HEADER;
\copy lapTimes from 'Assignment1_Design/lap_times.csv' DELIMITER ',' CSV HEADER;
\copy qualifying from 'Assignment1_Design/qualifying.csv' DELIMITER ',' CSV HEADER;
\copy results from 'Assignment1_Design/results.csv' DELIMITER ',' CSV HEADER;
\copy constructorResults from 'Assignment1_Design/constructor_results.csv' DELIMITER ',' CSV HEADER;