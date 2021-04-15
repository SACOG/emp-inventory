/*
Various tests to try joining 2016 to 2020 employment data

Top-line stats:
	* 130,285 rows in 2016 file
	* 417,105 rows in raw 2020 file

*/

USE EMP2020
GO

--=======Test 1: Left join 2020 to 2016 on LOCNUM<>INFOID_16================
SELECT
	t20.LOCNUM,
	t20.LOCEMP AS EMP20,
	t16.F_EMP16 AS EMP16
INTO #jn_emp20_to_emp16
FROM SACOG_Jan_2020 t20
	LEFT JOIN REGION_EMP16_FINAL_060217 t16
		ON t20.LOCNUM = t16.INFOID_16

--7 unique 2020 LOCNUMS that match to 1 or more INFOID_16 values
WITH t AS (
	SELECT
		LOCNUM,
		COUNT(LOCNUM) AS cnt
	FROM #jn_emp20_to_emp16
	GROUP BY LOCNUM
	)

SELECT LOCNUM INTO #maybedupe FROM t WHERE cnt > 1

SELECT * FROM #jn_emp20_to_emp16
WHERE LOCNUM IN (SELECT LOCNUM FROM #maybedupe)

/*
There are several INFOID_16 values that are duplicated in the 2016 emp table. E.g., INFOID_16 = 104723093,
but in all cases, each duplicate ID still refers to a different biz (e.g. for ID 104723093,
one of them is for architects institute, while the other is for consulting engineers).
*/
SELECT
	NAME,
	ADDRESS,
	ZIP,
	F_EMP16,
	INFOID_16,
	match_,
	NAICS_CODE,
	verified
FROM REGION_EMP16_FINAL_060217
WHERE INFOID_16 IN (SELECT LOCNUM FROM #maybedupe)
ORDER BY INFOID_16

/*
See if there are INFOID_16 values that are not in the list of LOCNUMs in the 2020 table
Answer: there are 8,346 unique INFOID_16 values (containing 190,368 jobs) that are not in the 2020 table.
	These records  will not be included by left joining 2020 to 2016 based on LOCNUM-INFOID_16

NOTE - THERE ARE 106,049 JOBS in the 2016 table with INFOID_16 = 0
	>>The 2020 table does NOT have this issue, i.e., there are no records with LOCNUM = 0
*/
SELECT 
	INFOID_16,
	SUM(F_EMP16) AS tot_emp
FROM REGION_EMP16_FINAL_060217
WHERE INFOID_16 NOT IN (SELECT LOCNUM FROM #jn_emp20_to_emp16)
GROUP BY INFOID_16

--============Test 2: Left join 2016 to 2020 on LOCNUM<>INFOID_16=============

SELECT
	t16.INFOID_16,
	t16.F_EMP16 AS EMP16,
	t20.LOCEMP AS EMP20
INTO #jn_emp16_to_emp20
FROM REGION_EMP16_FINAL_060217 t16 
	LEFT JOIN SACOG_Jan_2020 t20
		ON t20.LOCNUM = t16.INFOID_16

