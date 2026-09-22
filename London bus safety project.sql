--How many total incidents occurred each year?
SELECT EXTRACT(YEAR FROM date) AS year,
COUNT(*) num_incidents 
FROM fact_incidents
GROUP BY year 
ORDER BY year;

--Which 10 routes had the most incidents overall?
SELECT route, COUNT(incidents_id) num_incidents
FROM fact_incidents fi
LEFT JOIN dim_route dr ON 
fi.route_id = dr.route_id
GROUP BY route 
ORDER BY num_incidents DESC 
LIMIT 10;

--What's the breakdown of incidents by injury result severity (count and % of total)?

WITH ti AS(SELECT injury_result_description, COUNT(*) num_incidents
           FROM fact_incidents
           GROUP BY injury_result_description)

SELECT injury_result_description, num_incidents,
       ROUND(num_incidents::numeric/(SELECT COUNT(*) FROM fact_incidents)*100,2) AS pct
FROM ti;

--Which borough had the highest number of incidents, and which had the fewest?

WITH ni AS(SELECT borough, COUNT(*) num_incidents
           FROM fact_incidents fi
           LEFT JOIN dim_borough bo ON 
           fi.borough_id = bo.borough_id
           GROUP BY borough
           ORDER BY num_incidents),
   li AS(SELECT borough, num_incidents,
           ROW_NUMBER() OVER( ORDER BY num_incidents DESC) highest_rank,
		   ROW_NUMBER() OVER (ORDER BY num_incidents) lowest_rank
           FROM ni)
SELECT borough, num_incidenTs 
FROM li 
WHERE highest_rank = 1 
OR lowest_rank = 1;

--How do incidents split between weekdays and weekends?
SELECT CASE WHEN EXTRACT(ISODOW FROM date) >= 6 THEN 'weekend'
ELSE 'weekday' END AS day_type,
COUNT(*) num_incidents
FROM fact_incidents
GROUP BY day_type;

--Which operator group had the most incidents, and how does that compare to their number of operators/routes?

WITH gn AS(SELECT group_name, COUNT(*) num_incidents,COUNT(DISTINCT fi.operator_id) num_operator, 
           COUNT(DISTINCT fi.route_id) num_route
           FROM fact_incidents fi
           LEFT JOIN dim_operator op ON
           fi.operator_id = op.operator_id
           GROUP BY group_name
           ORDER BY num_incidents DESC
           LIMIT 1)
SELECT group_name, num_incidents, num_operator, num_route,
       ROUND(num_incidents::numeric/num_operator,2) incidents_per_operator,
	   ROUND(num_incidents::numeric/num_route,2)  incidents_per_route
FROM gn;

--For each borough, what's the most common incident_event_type? 

SELECT * FROM(SELECT borough,incident_event_type, COUNT(*) num_incidents,
              RANK() OVER(PARTITION BY borough ORDER BY COUNT(*) DESC) incident_type_rank
              FROM fact_incidenTs fi
              LEFT JOIN  dim_borough bo ON 
              fi.borough_id = bo.borough_id
              GROUP BY borough,incident_event_type) h
WHERE incident_type_rank = 1 ;

--What's the month-over-month incident count for each year, plus the change from the previous month?

WITH ym AS(SELECT EXTRACT(YEAR FROM date) AS year,EXTRACT(MONTH FROM date) AS month,
           COUNT(*) num_incidents
           FROM fact_incidents
           GROUP BY year, month)

SELECT year, month, num_incidents,
LAG(num_incidents)OVER(ORDER BY year,month) prior_mnth_incident, 
num_incidents - LAG(num_incidents)OVER(ORDER BY year, month)  mom_cj
FROM ym;


--Rank routes within each borough by incident count, and pull just the top 3 per borough.

WITH brn AS(SELECT borough,route, COUNT(*) num_incidents,
RANK() OVER (PARTITION BY borough ORDER BY COUNT(*) DESC) incidents_rank
            FROM fact_incidents fi
            INNER JOIN dim_borough bo ON 
            fi.borough_id = bo.borough_id
            INNER JOIN dim_route dr ON
            fi.route_id = dr.route_id
            GROUP BY borough, route)
SELECT *
FROM brn
WHERE incidents_rank <=3;

--What's the running (cumulative) total of incidents over time, month by month? 

WITH ymn AS(SELECT EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month,
            COUNT(*) num_incidents
            FROM fact_incidents
            GROUP BY year, month)
SELECT year, month, num_incidents,
SUM(num_incidents) OVER(order by year,month) cumulative_total
FROM ymn;

DELETE FROM dim_date
WHERE date > (SELECT MAX(date) FROM fact_incidents);






 






