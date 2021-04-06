USE EMP2020
GO

WITH temp AS (
	SELECT DISTINCT
		STADDR,
		STCITY,
		latitude as lat,
		longitude as lon,
		geo_level
	FROM SACOG_Jan_2020
	WHERE geo_level IN ('0', 'P')
	)

SELECT * FROM temp
ORDER BY 

--There are lat-long pairs that tag to more than 1 address, but only for records whose
--lat-longs are at ZIP code level. For parcels and entry point lat-longs, each lat-long pair
--tags to exactly 1 address record.
SELECT
	lat,
	lon,
	STADDR,
	geo_level
FROM temp
--WHERE STADDR LIKE '%[V]'
GROUP BY lat, lon, STADDR, geo_level
HAVING COUNT(STADDR) > 1
--ORDER BY latitude, longitude
ORDER BY staddr


DECLARE @lat1 FLOAT = (SELECT TOP 1 latitude FROM SACOG_Jan_2020 WHERE STADDR = '1000 Sacramento Ave')
DECLARE @lon1 FLOAT = (SELECT TOP 1 longitude FROM SACOG_Jan_2020 WHERE STADDR = '1000 Sacramento Ave')

SELECT 
	staddr, 
	ZIP,
	latitude, 
	longitude, 
	geo_level
FROM SACOG_Jan_2020
WHERE latitude = @lat1
	AND longitude = @lon1