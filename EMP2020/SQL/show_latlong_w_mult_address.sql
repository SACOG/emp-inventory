USE EMP2020
GO

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