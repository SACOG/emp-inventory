--Get records marked as duplicates but have a unique address-company name combination

--======NOTES=======
	--all "DNN" (null naics code) also has a "DMN"
SELECT 
	coname, 
	staddr, 
	zip, 
	dupe_flag,
	COUNT(*) as counts
FROM TEST_AddSiteDupeFlag_1
WHERE dupe_flag LIKE '%DNN%'
	AND dupe_flag NOT LIKE '%DMN%'
GROUP BY coname, 
	staddr, 
	zip,
	dupe_flag
HAVING COUNT(*) = 1


--query to drill down to specific cases in which a company name may have been wrongly labeled as a duplicate
SELECT
	CONAME,
	STADDR,
	ZIP,
	LOCEMP,
	latitude,
	longitude,
	geo_level,
	dupe_flag
FROM TEST_AddSiteDupeFlag_1
WHERE STADDR = '801 J ST'
	AND ZIP = '95814'
