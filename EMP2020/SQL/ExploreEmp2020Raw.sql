/*
PURPOSE: Explore and get sense of the 2020 raw employment data from Data Axle
    CONAME 
    LOCNUM 
    SITE 
    STADDR 
    STCITY 
    STATE 
    ZIP 
    NAICS 
    NAICSD
    HOME 
    EMPSIZ 
    LOCEMP 
	latitude
	longitude

*/

USE EMP2020
GO

--==========CONFIRM ONE LAT-LONG SET PER SITE ID============
/*
SELECT
	SITE,
	CONCAT(latitude, longitude) AS latlong
INTO #latlong
FROM SACOG_Jan_2020

SELECT
	SITE,
	latlong,
	COUNT(latlong) AS pts_for_site
FROM #latlong
GROUP BY SITE, latlong
HAVING COUNT(*) > 1

SELECT
	LOCNUM,
	CONAME,
	SITE,
	STADDR,
	latitude,
	longitude,
	CONCAT(latitude, longitude) AS latlong2
FROM 
	SACOG_Jan_2020
	WHERE SITE = 532393071
	*/

--================CAN S==================

