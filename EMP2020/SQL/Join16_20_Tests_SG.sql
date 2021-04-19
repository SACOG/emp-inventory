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
--INTO #jn_emp20_to_emp16
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

--+++++++++++++++++++++++++++++++++++++++++++++++++++++
--include coname, staddr,emp from emp2016

select top 5 *
from REGION_EMP16_FINAL_060217

--combine notes and notes_1
update REGION_EMP16_FINAL_060217
set NOTES=NOTES_1
WHERE NOTES IS NULL

alter table TestDupeFlag20210412_1754
add coname16 varchar(100), staddr16 varchar(100), emp16 int, notes16 varchar(100), infoid16 bigint

update TestDupeFlag20210412_1754
set coname16=emp16.name, staddr16=emp16.address,emp16=emp16.f_emp16, notes16=emp16.notes, infoid16=emp16.infoid_16
from TestDupeFlag20210412_1754 a, REGION_EMP16_FINAL_060217 emp16
where a.locnum=emp16.infoid_16

select count(*) as counts
from TestDupeFlag20210412_1754
where coname16 is not null
--116,349 matched by locnum

select dupe_flag,NAICS,staddr,staddr16,coname,coname16,locnum,infoid16,locemp,emp16,notes16
from TestDupeFlag20210412_1754
--where locnum=712665423
--where dupe_flag<>'0'
order by staddr,coname,dupe_flag
--the coname and coname16 are not necessarily the same where locnum=infoid16. so is the staddr.Majorit of them
--are the same company at the same location. Exceptions are observed (locnum= 712665423). That said, after the preliminary
--match by locnum, a fuzzy match in coname and staddre is neccessary for further confirmation. This process has nothing 
--to do with DMN because the records may not be flagged as DMN.

update TestDupeFlag20210412_1754
set coname16=emp16.name, staddr16=emp16.address,emp16=emp16.f_emp16, notes16=emp16.notes, infoid16=emp16.infoid_16
from TestDupeFlag20210412_1754 a, REGION_EMP16_FINAL_060217 emp16
where a.coname=emp16.name and a.staddr=emp16.address and coname16 is null
--3619; if two business have the same name and address in emp 2020 and 2016, they are assumed to be the same business.
--a fuzzy match is needed for the records with different coding of name and address but actually the same business.

--spot check
select dupe_flag,NAICS,staddr,staddr16,coname,coname16,locnum,infoid16,locemp,emp16,notes16
from TestDupeFlag20210412_1754
where staddr ='1 CAPITOL MALL STE 800' and coname like'CALIFORNIA SOCIETY%'
--it returns 2 records with DMN. By checking emp2016, they are not duplicates.

select name,address,f_emp16
from REGION_EMP16_FINAL_060217
where address ='1 CAPITOL MALL # 800' and name like'CALIFORNIA SOCIETY%'

select name,address,f_emp16
from REGION_EMP16_FINAL_060217
where name like'CALIFORNIA SOCIETY%'
--
select dupe_flag,NAICS,staddr,staddr16,coname,coname16,locnum,infoid16,locemp,emp16,notes16
from TestDupeFlag20210412_1754
where staddr ='1 MEDICAL PLAZA DR' 
--it returns 85 records with DMN. The record with the highest locemp is the correct one and all others are duplicates
--or coding error (SUNRISE HEALTHCARE CTR does not locate at 1 MEDICAL PLAZA DR)

select name,address,f_emp16
from REGION_EMP16_FINAL_060217
where address ='1 MEDICAL PLAZA DR'

select *
from TestDupeFlag20210412_1754



select a.dupe_flag,a.staddr,b.address as staddr16,a.coname,b.name as coname16,a.locnum,b.infoid_16 as infoid16,a.locemp,b.f_emp16 as emp16,b.notes as notes16
from TestDupeFlag20210412_1754 a,REGION_EMP16_FINAL_060217 b
where a.coname=b.name and a.staddr=b.address and coname16 is null


