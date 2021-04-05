/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
	CONAME,
	LOCNUM,
	SITE,
	STADDR,
	STCITY,
	ZIP,
	ZIP4,
	CNTYCD,
	CCNTY,
	ADDTYP,
	NAICS,
	NAICSD,
	LOCEMP,
	YREY2K,
	LMDATE,
	LNGNAM,
	Latitude,
	Longitude,
	geo_level
  FROM [EMP2020].[dbo].[SACOG_Jan_2020]
WHERE LOCEMP > 0
AND CONAME LIKE '%U C Davis Med%'
ORDER BY STADDR, ZIP

SELECT * FROM [EMP2020].[dbo].[SACOG_Jan_2020]
WHERE LEN(YREY2K) > 0


--187,696 distinct addresses with jobs on them, ~7,000 do not start with a number and thus have no address
--180,730 distinct addresses that start with a number and have employment on them
--only 4 addresses that do NOT start with a number are still coded to a parcel or entry point level of detail.
SELECT DISTINCT 
	STADDR,
	geo_level
FROM [EMP2020].[dbo].[SACOG_Jan_2020] 
WHERE LOCEMP > 0 
	AND STADDR NOT LIKE '[0-9]%' 
	AND geo_level IN ('0', 'P')
ORDER BY STADDR