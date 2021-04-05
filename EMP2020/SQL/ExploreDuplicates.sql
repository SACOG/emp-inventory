use emp2020

select distinct staddr
from SACOG_Jan_2020
order by staddr

SELECT
	NAICS,
	NAICSD,
	COUNT(*) AS rec_cnt
FROM SACOG_Jan_2020
GROUP BY NAICS, NAICSD
ORDER BY NAICS

SELECT
	NAICS,
	LOCEMP,
	CONAME
FROM SACOG_Jan_2020
WHERE NAICS > 99999000 AND LOCEMP > 0


--============MULTIPLE ADDRS PER COORDINATE AND VICE-VERSA========
WITH temp AS (
	SELECT DISTINCT
		STADDR,
		STCITY,
		latitude,
		longitude,
		geo_level
	FROM SACOG_Jan_2020
	WHERE geo_level IN ('0', 'P', '4', 'Z')
	)

--There are lat-long pairs that tag to more than 1 address, but only for records whose
--lat-longs are at ZIP code level. For parcels and entry point lat-longs, each lat-long pair
--tags to exactly 1 address record.
SELECT
	latitude,
	longitude,
	STADDR,
	geo_level
FROM temp
--WHERE STADDR LIKE '%[V]'
GROUP BY latitude, longitude, STADDR, geo_level
HAVING COUNT(STADDR) > 1
ORDER BY latitude, longitude
	
SELECT
	CONAME,
	STADDR,
	LOCEMP,
	NAICS,
	NAICSD
	latitude,
	longitude
FROM SACOG_Jan_2020
WHERE latitude = 38.6408 AND longitude = -121.4908

/*
--zero records have >1 lat-long record for 1 address ASSUMING that the geo_level parcel or entry point.
SELECT
	STADDR,
	STCITY,
	COUNT(*)
FROM temp
GROUP BY STADDR, STCITY
HAVING COUNT(*) > 1
*/

--=====================================================

