

--Total jobs for all bizs in raw table with site-level geo accuracy
SELECT SUM(LOCEMP) FROM SACOG_Jan_2020 WHERE geo_level IN ('P', '0')
SELECT SUM(LOCEMP) FROM TEST_AddSiteDupeFlag_1 WHERE geo_level IN ('P', '0')


--For only bizs with site-level geo accuracy, how many jobs are in potential duplicates
DECLARE @emptotall FLOAT = (SELECT SUM(LOCEMP) FROM TEST_AddSiteDupeFlag_1)

SELECT
	dupe_flag,
	SUM(LOCEMP) AS emp_tot,
	SUM(LOCEMP) / @emptotall AS emp_tot_pct
FROM TEST_AddSiteDupeFlag_1
GROUP BY dupe_flag

