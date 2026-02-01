-- CREATE FINANCE PARAMETERS TABLE
DROP TABLE IF EXISTS finance_parameters;

CREATE TABLE finance_parameters (
	parameter_name VARCHAR(50) PRIMARY KEY,
	parameter_value FLOAT
);
GO

TRUNCATE TABLE finance_parameters;
GO

INSERT INTO finance_parameters (
	parameter_name,
	parameter_value
)
VALUES
-- Revenue parameters
('passenger_revenue_per_mile',0.04),
('freight_revenue_per_mile',0.03),
('mail_revenue_per_mile',0.02),

-- Distance driven cost parameters
('fuel_cost_per_mile',4.50),
('maintenance_cost_per_mile',2.80),
('navigation_cost_per_mile',1.20),

-- Flight driven cost parameters
('crew_cost_per_flight',2.80),
('airport_cost_per_flight',2.80),
('ground_handling_cost_per_flight',2.80),

-- Passenger driven cost parameters
('cost_per_passenger',75.00),
('passenger_service_cost', 22.00),

-- Overhead
('overhead_pct_of_revenue', 0.12)
;
GO



-- CREATE PROFITABILITY ANATYTIC VIEW

SELECT TOP 10 *
FROM fact_airline_operations;


CREATE OR ALTER VIEW vw_airline_profitability AS

WITH route_passanger_baseline AS (
	SELECT 
		route_key,
		SUM(passengers) * 1.0 / COUNT(DISTINCT date_key) AS avg_monthly_passengers
	FROM fact_airline_operations
	GROUP BY route_key
)

SELECT -- keys
		f.date_key,
		f.carrier_key,
		f.route_key,
		
		-- volumes
		f.passengers,
		f.freight,
		f.mail,
		r.distance,
		
		-- activity factor 
		af.activity_factor,

		-- flight_classification
		CASE WHEN r.distance = 0 THEN 1 ELSE 0
			END AS is_cancelled_flight,
		
		CASE WHEN distance > 0
			AND f.passengers = 0
			AND f.freight = 0
			AND f.mail = 0
			THEN 1 ELSE 0
			END AS is_empty_flight,
		
		-- revenue
		CASE WHEN distance = 0 THEN 0 
		ELSE f.passengers * r.distance * prm_passenger.parameter_value END AS passenger_revenue,
		
		CASE WHEN distance = 0 THEN 0
		ELSE f.freight * r.distance * prm_freight.parameter_value END AS freight_revenue,
		
		CASE WHEN distance = 0 THEN 0
		ELSE f.mail * r.distance * prm_mail.parameter_value END AS mail_revenue,

		-- Distance driven cost
		CASE WHEN distance = 0 THEN 0
		ELSE r.distance * prm_fuel.parameter_value * activity_factor END AS fuel_cost,
		
		CASE WHEN distance = 0 THEN 0
		ELSE r.distance * prm_maintenance.parameter_value * activity_factor END AS maintenance_cost,

		CASE WHEN distance = 0 THEN 0
		ELSE r.distance * prm_navigation.parameter_value * activity_factor END AS navigation_cost,
		
		-- Flight driven cost
		CASE WHEN distance = 0 THEN 0
		ELSE prm_crew.parameter_value * activity_factor END AS crew_cost,

		CASE WHEN distance = 0 THEN 0
		ELSE prm_airport.parameter_value * activity_factor END AS airport_cost,

		CASE WHEN distance = 0 THEN 0
		ELSE prm_ground_handling.parameter_value * activity_factor END AS ground_handling_cost,
		
		-- Passenger driven cost
		CASE WHEN distance = 0 THEN 0
		ELSE f.passengers * prm_cost_pax.parameter_value END AS cost_per_passenger,
		
		CASE WHEN distance = 0 THEN 0
		ELSE f.passengers * prm_pax_service.parameter_value END AS passenger_service_cost,

		-- overhead cost
		CASE WHEN distance = 0 THEN 0
		ELSE ((f.passengers * r.distance * prm_passenger.parameter_value + f.freight * r.distance * prm_freight.parameter_value +
		f.mail * r.distance * prm_mail.parameter_value)	* prm_overhead.parameter_value) END AS overhead_cost,

		-- total revenue
		CASE WHEN distance = 0 THEN 0
		ELSE (f.passengers * r.distance * prm_passenger.parameter_value +
		f.freight * r.distance * prm_freight.parameter_value +
		f.mail * r.distance * prm_mail.parameter_value)
		END AS total_revenue,

		-- total_cost
		CASE WHEN distance = 0 THEN 0
		ELSE (r.distance * prm_fuel.parameter_value * activity_factor) +
		(r.distance * prm_maintenance.parameter_value * activity_factor) +
		(r.distance * prm_navigation.parameter_value * activity_factor) +
		(prm_crew.parameter_value * activity_factor) +
		(prm_airport.parameter_value * activity_factor) +
		(prm_ground_handling.parameter_value * activity_factor) +
		(f.passengers * prm_cost_pax.parameter_value) +
		(f.passengers * prm_pax_service.parameter_value) +
		((f.passengers * r.distance * prm_passenger.parameter_value + f.freight * r.distance * prm_freight.parameter_value +
		f.mail * r.distance * prm_mail.parameter_value)	* prm_overhead.parameter_value)
		END AS total_cost,
		
		-- operating profit
		((f.passengers * r.distance * prm_passenger.parameter_value +
		f.freight * r.distance * prm_freight.parameter_value +
		f.mail * r.distance * prm_mail.parameter_value)) - 
		
		((r.distance * prm_fuel.parameter_value * activity_factor) +
		(r.distance * prm_maintenance.parameter_value * activity_factor) +
		(r.distance * prm_navigation.parameter_value * activity_factor) +
		(prm_crew.parameter_value * activity_factor) +
		(prm_airport.parameter_value * activity_factor) +
		(prm_ground_handling.parameter_value * activity_factor) +
		(f.passengers * prm_cost_pax.parameter_value) +
		(f.passengers * prm_pax_service.parameter_value) +
		((f.passengers * r.distance * prm_passenger.parameter_value + f.freight * r.distance * prm_freight.parameter_value +
		f.mail * r.distance * prm_mail.parameter_value)	* prm_overhead.parameter_value))
		AS operating_profit
		
FROM fact_airline_operations f
JOIN dim_route r
	ON f.route_key = r.route_key
JOIN route_passanger_baseline rpb
	ON f.route_key = rpb.route_key

CROSS APPLY (
	SELECT
		f.passengers/NULLIF(rpb.avg_monthly_passengers,0) 
) af(activity_factor)

-- parameters

CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'passenger_revenue_per_mile') prm_passenger
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'freight_revenue_per_mile') prm_freight
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'mail_revenue_per_mile') prm_mail

CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'fuel_cost_per_mile') prm_fuel
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'maintenance_cost_per_mile') prm_maintenance
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'navigation_cost_per_mile') prm_navigation

CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'crew_cost_per_flight') prm_crew
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'airport_cost_per_flight') prm_airport
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'ground_handling_cost_per_flight') prm_ground_handling

CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'cost_per_passenger') prm_cost_pax
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'passenger_service_cost') prm_pax_service
CROSS JOIN (SELECT parameter_value FROM finance_parameters WHERE parameter_name = 'overhead_pct_of_revenue') prm_overhead
;



-- SANITY CHECK

SELECT COUNT(*) AS cancelled_flights,
		SUM(total_cost) AS total_cost
FROM vw_airline_profitability
WHERE is_cancelled_flight = 1;


SELECT COUNT(*) AS empty_flight,
		AVG(operating_profit) AS avg_profit
FROM vw_airline_profitability
WHERE is_empty_flight = 1;

SELECT MAX(operating_profit),
		MIN(operating_profit)
FROM vw_airline_profitability
WHERE is_empty_flight = 0
	AND is_cancelled_flight = 0;
