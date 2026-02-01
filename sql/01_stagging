-- CREATE DATABASE

CREATE DATABASE AirlineFinanceAnalytics;
GO

USE AirlineFinanceAnalytics;
GO

-- CHECKING DATA AFTER IMPORTING FILES VIA IMPORT WIZARD

SELECT '2018' AS YR, COUNT(*) AS total_rows FROM stg_airline_raw_2018
UNION ALL
SELECT '2019', COUNT(*) FROM stg_airline_raw_2019
UNION ALL
SELECT '2020', COUNT(*) FROM stg_airline_raw_2020
UNION ALL
SELECT '2021', COUNT(*) FROM stg_airline_raw_2021
UNION ALL
SELECT '2022', COUNT(*) FROM stg_airline_raw_2022
;	


-- CREATE UNIFIED RAW VIEW TO COMBINE 5 YEARS DATA

CREATE OR ALTER VIEW stg_airline_raw_view AS (
	SELECT *, 2018 AS source_year FROM stg_airline_raw_2018
	UNION ALL
	SELECT *, 2019 AS source_year FROM stg_airline_raw_2019
	UNION ALL
	SELECT *, 2020 AS source_year FROM stg_airline_raw_2020
	UNION ALL
	SELECT *, 2021 AS source_year FROM stg_airline_raw_2021
	UNION ALL
	SELECT *, 2022 AS source_year FROM stg_airline_raw_2022
)

SELECT source_year, COUNT(*) AS total_rows
FROM stg_airline_raw_view
GROUP BY source_year
;


-- CREATE CLEAN STAGGING TABLE

DROP TABLE IF EXISTS stg_airline_operations;

CREATE TABLE stg_airline_operations (
	
	-- measures
	passengers FLOAT,
	freight FLOAT,
	mail FLOAT,
	distance FLOAT,

	-- carrier details
	unique_carrier VARCHAR(10),
	airline_id INT,
	unique_carrier_name VARCHAR(200),
	unique_carrier_entity VARCHAR(50),
	region VARCHAR(50),
	carrier VARCHAR(10),
	carrier_name VARCHAR(200),
	carrier_group INT,
	carrier_group_new INT,

	-- origin
	origin_airport_id INT,
	origin_airport_seq_id BIGINT,
	origin_city_market_id INT,
	origin CHAR(3),
	origin_city_name VARCHAR(200),
	origin_state_abr CHAR(3),
	origin_state_fips INT,
	origin_state_nm VARCHAR(50),
	origin_wac INT,

	-- destination
	dest_airport_id INT, 
	dest_airport_seq_id BIGINT,
	dest_city_market_id INT,
	dest CHAR(3),
	dest_city_name VARCHAR(200),
	dest_state_abr CHAR(3),
	dest_state_fips INT,
	dest_state_nm VARCHAR(50),
	dest_wac VARCHAR(10),

	-- time
	year INT,
	quarter INT,
	month INT,
	distance_group INT,
	class CHAR(1),


	-- control
	report_month_date DATE,
	source_year INT
)
;


SELECT TOP 10 *
FROM stg_airline_raw_view;


-- INSERT DATA INTO CLEAN STAGGING TABLE FROM THE VIEW

TRUNCATE TABLE stg_airline_operations;

INSERT INTO stg_airline_operations 
(	passengers,
	freight,
	mail,
	distance,

	unique_carrier,
	airline_id,
	unique_carrier_name,
	unique_carrier_entity,
	region,
	carrier,
	carrier_name,
	carrier_group,
	carrier_group_new,
	
	origin_airport_id,
	origin_airport_seq_id,
	origin_city_market_id,
	origin,
	origin_city_name,
	origin_state_abr,
	origin_state_fips,
	origin_state_nm,
	origin_wac,

	dest_airport_id, 
	dest_airport_seq_id,
	dest_city_market_id,
	dest,
	dest_city_name,
	dest_state_abr,
	dest_state_fips,
	dest_state_nm,
	dest_wac,
	
	year,
	quarter,
	month,
	distance_group,
	class,
	
	report_month_date,
	source_year
	)
SELECT 
	TRY_CAST(PASSENGERS AS FLOAT),
	TRY_CAST(FREIGHT AS FLOAT),
	TRY_CAST(MAIL AS FLOAT),
	TRY_CAST(DISTANCE AS FLOAT),

	UNIQUE_CARRIER,
	TRY_CAST(AIRLINE_ID AS INT),
	UNIQUE_CARRIER_NAME,
	UNIQUE_CARRIER_ENTITY,
	REGION,
	CARRIER,
	CARRIER_NAME,
	TRY_CAST(CARRIER_GROUP AS INT),
	TRY_CAST(CARRIER_GROUP_NEW AS INT),

	TRY_CAST(ORIGIN_AIRPORT_ID AS INT),
	TRY_CAST(ORIGIN_AIRPORT_SEQ_ID AS BIGINT),
	TRY_CAST(ORIGIN_CITY_MARKET_ID AS INT),
	ORIGIN,
	ORIGIN_CITY_NAME,
	ORIGIN_STATE_ABR,
	TRY_CAST(ORIGIN_STATE_FIPS AS INT),
	ORIGIN_STATE_NM,
	TRY_CAST(ORIGIN_WAC AS INT),

	TRY_CAST(DEST_AIRPORT_ID AS INT),
	TRY_CAST(DEST_AIRPORT_SEQ_ID AS BIGINT),
	TRY_CAST(DEST_CITY_MARKET_ID AS INT),
	DEST,
	DEST_CITY_NAME,
	DEST_STATE_ABR,
	TRY_CAST(DEST_STATE_FIPS AS INT),
	DEST_STATE_NM,
	TRY_CAST(DEST_WAC AS INT),

	TRY_CAST(YEAR AS INT),
	TRY_CAST(QUARTER AS INT),
	TRY_CAST(MONTH AS INT),
	TRY_CAST(DISTANCE_GROUP AS INT),
	CLASS,

	DATEFROMPARTS(
		TRY_CAST(YEAR AS INT), TRY_CAST(MONTH AS INT),1),
	source_year

FROM stg_airline_raw_view
;

-- SANITY CHECKS

-- ROWS COUNT PER YEAR 

SELECT year, COUNT(*) AS total_rows
FROM stg_airline_operations
GROUP BY year;

-- DATE COVERAGE

SELECT MAX(report_month_date) AS max_month,
		MIN(report_month_date) AS min_month
FROM stg_airline_operations;

-- DATA QUALITY CHECKS

SELECT COUNT(*) AS total_rows,
		COUNT(passengers) AS passengers_rows,
		COUNT(distance) AS distance_rows
FROM stg_airline_operations
;
