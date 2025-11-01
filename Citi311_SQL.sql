/*
250925 SQL & EXCEL project - Khadija Abdulla Al-Hay

DB: City 311
SCOPE: LA (2016-2017) excluding neighborhood_council_ids (0,44,24)
*/

/*
Q1
 Combine 2016 & 2017 data in one table as a CTE (total No. rows = 2,360,672 row)
 
 - Excluded rows from both years that are missing lots of data such as 
 address, area planning committee, council district .. etc
 
 - Excluded open/cancelled tickets cause they are not needed for the first question (Q1)
 
 - Excluded neighborhood_council_ids (0,44,24) because the ids are not unique.

 Total rows after joinning and filtering were 2,138,407 rows and the excluded is less than %10 of the data (222,265 rows ex.) 
*/
WITH la_311_2016_2017 AS
(
	SELECT
		request_id
		, created_date
		, closed_date
		, status
		, statusnotes
		, requesttype
		, responsibleagency
		, source
		, mobile_source
		, address
		, area_planning_committee
		, council_district_member
		, neighborhood_council_name
		, police_precinct
	FROM 
		la_311_2016
		JOIN 
		la_311_area_planning_committees as apc USING(area_planning_committee_id)
		JOIN
		la_311_council_districts as cd USING(council_district_id)
		JOIN
		la_311_area_neighborhood_councils as anc USING(neighborhood_council_id)
		JOIN
		la_311_area_police_precincts as app USING(police_precinct_id)
	WHERE
	area_planning_committee_id IS NOT NULL
	AND
	council_district_id IS NOT NULL
	AND
	neighborhood_council_id IS NOT NULL
	AND 
	police_precinct_id IS NOT NULL
	AND
	neighborhood_council_id NOT IN (0,44,24)
	AND
	status NOT ILIKE 'cancelled'
	AND 
	status NOT ILIKE 'open'
	AND
	status NOT ILIKE 'pending'
		
	UNION ALL

	SELECT
		request_id
		, created_date
		, closed_date
		, status
		, statusnotes
		, requesttype
		, responsibleagency
		, source
		, mobile_source
		, address
		, area_planning_committee
		, council_district_member
		, neighborhood_council_name
		, police_precinct
	FROM
		la_311_2017
		JOIN 
		la_311_area_planning_committees as apc USING(area_planning_committee_id)
		JOIN
		la_311_council_districts as cd USING(council_district_id)
		JOIN
		la_311_area_neighborhood_councils as anc USING(neighborhood_council_id)
		JOIN
		la_311_area_police_precincts as app USING(police_precinct_id)
	WHERE
	area_planning_committee_id IS NOT NULL
	AND
	council_district_id IS NOT NULL
	AND
	neighborhood_council_id IS NOT NULL
	AND 
	police_precinct_id IS NOT NULL
	AND
	neighborhood_council_id NOT IN (0,44,24)
	AND
	status NOT ILIKE 'cancelled'
	AND 
	status NOT ILIKE 'open'
	AND
	status NOT ILIKE 'pending'
)
/*
After filtering the data during the creation of the CTE, The following query returns the data needed to analyze for
problem statement 1: 

Q1 - Is there a delay in resolving issues raised as tickets in LA 2016-2017 excluding (44,42,0) neighborhood councils.
Metric used: MTTR (Mean Time to resolve) per Responsible Agency in each year

>>This can assess the performance of the team.. can they solve the issues any faster? or are they consistent
*/

SELECT
	 EXTRACT(YEAR FROM created_date) AS year 
	-- ,EXTRACT (MONTH FROM created_date) AS month
	 , responsibleagency
	 , COUNT(DISTINCT request_id) No_cases_per_year
	, CASE
		WHEN AVG(closed_date - created_date) < '1 day' THEN '0' -- if the MTTR is less than a day then return 0
	ELSE
		AVG(closed_date - created_date) -- otherwise return the MTTR duration in days
	END AS MTTR
FROM
	la_311_2016_2017
WHERE 
	(status ILIKE 'closed' --only for closed tickets
	OR
	status ILIKE 'forward'
	OR 
	status ILIKE 'Reffered out')
	AND
	(EXTRACT(YEAR FROM created_date) = '2016'
	OR
	EXTRACT(YEAR FROM created_date) = '2017')
GROUP BY
	1, 2;

-------------------------------------------------------------------------------------------------------------------
/* Q2
Same CTE as before

Combined LA data from 2016 - 2017

- Excluding tickets from both years that are missing lots of data such as 
address, area planning committee, council district .. etc

- Excluded cancelled tickets cause they are not needed for the second question (Q2)

- Excluded neighborhood_council_ids (0,44,24) because the ids are not unique.

*/

WITH la_311_2016_2017 AS
(
	SELECT
		request_id
		, created_date
		, closed_date
		, status
		, statusnotes
		, requesttype
		, responsibleagency
		, source
		, mobile_source
		, address
		, area_planning_committee
		, council_district_member
		, neighborhood_council_name
		, police_precinct
	FROM 
		la_311_2016
		JOIN 
		la_311_area_planning_committees as apc USING(area_planning_committee_id)
		JOIN
		la_311_council_districts as cd USING(council_district_id)
		JOIN
		la_311_area_neighborhood_councils as anc USING(neighborhood_council_id)
		JOIN
		la_311_area_police_precincts as app USING(police_precinct_id)
	WHERE
	area_planning_committee_id IS NOT NULL
	AND
	council_district_id IS NOT NULL
	AND
	neighborhood_council_id IS NOT NULL
	AND 
	police_precinct_id IS NOT NULL
	AND
	neighborhood_council_id NOT IN (0,44,24)
	AND
	status NOT ILIKE 'cancelled'
	
	UNION ALL

	SELECT
		request_id
		, created_date
		, closed_date
		, status
		, statusnotes
		, requesttype
		, responsibleagency
		, source
		, mobile_source
		, address
		, area_planning_committee
		, council_district_member
		, neighborhood_council_name
		, police_precinct
	FROM
		la_311_2017
		JOIN 
		la_311_area_planning_committees as apc USING(area_planning_committee_id)
		JOIN
		la_311_council_districts as cd USING(council_district_id)
		JOIN
		la_311_area_neighborhood_councils as anc USING(neighborhood_council_id)
		JOIN
		la_311_area_police_precincts as app USING(police_precinct_id)
	WHERE
	area_planning_committee_id IS NOT NULL
	AND
	council_district_id IS NOT NULL
	AND
	neighborhood_council_id IS NOT NULL
	AND 
	police_precinct_id IS NOT NULL
	AND
	neighborhood_council_id NOT IN (0,44,24)
	AND
	status NOT ILIKE 'cancelled'
)

/*
Q2:
- for reccuring issues(requests) each year that is more than 7,427 requests(Average overall), 
is it possible to recommend ways to reduce the number of requests received in LA* based on 2016-2017 data.

Metric used: average number of cases handled per year for each request type, excluding cancelled requests. 

>>to locate reccuring issues/requests and implemening ways to lower the number of request received 
from the same type by either preventing the problem by making changes or increasing resources for 
the residents other than the Non-emergency hotline. 

*/

SELECT
	EXTRACT(YEAR FROM created_date) AS year 
	,EXTRACT (MONTH FROM created_date) AS month
	, requesttype
	, COUNT(request_id) number_of_requests
FROM 
	la_311_2016_2017
WHERE 
	EXTRACT(YEAR FROM created_date) = '2016'
	OR
	EXTRACT(YEAR FROM created_date) = '2017'
GROUP BY
	1,2,3

---------------------------------------------------------------------------------------------------------------------
/* Q3
Same CTE as before

Combined LA data from 2016 - 2017

- Excluding tickets from both years that are missing lots of data such as 
address, area planning committee, council district .. etc

- Excluded cancelled/open/pending tickets cause they are not needed for the second question (Q2)

- Excluded neighborhood_council_ids (0,44,24) because the ids are not unique.
*/

WITH la_311_2016_2017 AS
(
	SELECT
		request_id
		, created_date
		, closed_date
		, status
		, statusnotes
		, requesttype
		, responsibleagency
		, source
		, mobile_source
		, address
		, area_planning_committee
		, council_district_member
		, neighborhood_council_name
		, police_precinct
	FROM 
		la_311_2016
		JOIN 
		la_311_area_planning_committees as apc USING(area_planning_committee_id)
		JOIN
		la_311_council_districts as cd USING(council_district_id)
		JOIN
		la_311_area_neighborhood_councils as anc USING(neighborhood_council_id)
		JOIN
		la_311_area_police_precincts as app USING(police_precinct_id)
	WHERE
	area_planning_committee_id IS NOT NULL
	AND
	council_district_id IS NOT NULL
	AND
	neighborhood_council_id IS NOT NULL
	AND 
	police_precinct_id IS NOT NULL
	AND
	neighborhood_council_id NOT IN (0,44,24)
	AND
	status NOT ILIKE 'cancelled'
	AND 
	status NOT ILIKE 'open'
	AND
	status NOT ILIKE 'pending'
		
	UNION ALL

	SELECT
		request_id
		, created_date
		, closed_date
		, status
		, statusnotes
		, requesttype
		, responsibleagency
		, source
		, mobile_source
		, address
		, area_planning_committee
		, council_district_member
		, neighborhood_council_name
		, police_precinct
	FROM
		la_311_2017
		JOIN 
		la_311_area_planning_committees as apc USING(area_planning_committee_id)
		JOIN
		la_311_council_districts as cd USING(council_district_id)
		JOIN
		la_311_area_neighborhood_councils as anc USING(neighborhood_council_id)
		JOIN
		la_311_area_police_precincts as app USING(police_precinct_id)
	WHERE
	area_planning_committee_id IS NOT NULL
	AND
	council_district_id IS NOT NULL
	AND
	neighborhood_council_id IS NOT NULL
	AND 
	police_precinct_id IS NOT NULL
	AND
	neighborhood_council_id NOT IN (0,44,24)
	AND
	status NOT ILIKE 'cancelled'
	AND 
	status NOT ILIKE 'open'
	AND
	status NOT ILIKE 'pending'
)
/*
After filtering the data during the creation of the CTE, The following query returns the data needed to analyze for
Q3: 

P1 - how long does it take for each request type to be resolved on average in LA during 2016-2017*, 
where the Mean Time To Resolve was Higher than 4 days(Overall average)? 

Metric used: MTTR (Mean Time to resolve) per request type in each year**

>> This can assess the average time it takes to resolve specific request types. This can help the agencies in 
determining whether they need to add a priority system, where each request type will have a priority (High/Medium/Low) 
by default and it can be modified manually by the agent handelling the case as needed.  
*/

SELECT
	EXTRACT(YEAR FROM created_date) AS year 
	,requesttype
	 ,CASE
		WHEN AVG(closed_date - created_date) < '1 day' THEN '0' -- if the MTTR is less than a day then return 0
	ELSE
		AVG(closed_date - created_date) -- otherwise return the MTTR duration in days
	END AS MTTR
FROM
	la_311_2016_2017
WHERE 
	(status ILIKE 'closed' --only for closed tickets
	OR
	status ILIKE 'forward'
	OR 
	status ILIKE 'Reffered out')
	AND
	(EXTRACT(YEAR FROM created_date) = '2016'
	OR
	EXTRACT(YEAR FROM created_date) = '2017')
GROUP BY
	1,2;