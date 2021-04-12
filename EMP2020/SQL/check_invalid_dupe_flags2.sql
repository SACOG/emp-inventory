/*
drop table #dmn
drop table #temp
drop table #bizxaddr
*/

select 
coname,staddr, naics4, zip, count(*) as counts
into #dmn
from TestDupeFlag20210412_1355
where dupe_flag='DMN'
group by coname,staddr, naics4, zip
HAVING count(*) = 1



select
	staddr,
	zip,
	count(*) as biz_cnt
INTO #bizxaddr
FROM #dmn
GROUP BY staddr, zip

SELECT
	d.*,
	ba.biz_cnt
INTO #temp
FROM #dmn d
	JOIN #bizxaddr ba
		ON d.STADDR = ba.STADDR
			AND d.ZIP = ba.ZIP

select
	biz_cnt,
	count(*) as addresses_w_question
FROM #temp
GROUP BY biz_cnt
ORDER BY biz_cnt

/*
Exploring wrong dupes at addresses where there was only one business at the address but still was labeled as a dupe
*/
SELECT * FROM #temp
WHERE biz_cnt = 1

SELECT * FROM TestDupeFlag20210412_1355
WHERE CONAME LIKE '%WATERWAYS%'


--Compare counts of each dupe flag value between different table versions.
DROP TABLE #uniqflag

WITH uniqflag1 AS (
	SELECT DISTINCT
		dupe_flag
	FROM TEST_AddSiteDupeFlag_1
	UNION ALL
	SELECT DISTINCT
		dupe_flag
	FROM TestDupeFlag20210412_1355
	)

select DISTINCT * into #uniqflag from uniqflag1
SELECT * FROM #uniqflag

SELECT
	df.dupe_flag,
	count(t1.dupe_flag) AS t1_cnt
	--count(t2.dupe_flag) AS t2_cnt
FROM #uniqflag df
	LEFT JOIN TEST_AddSiteDupeFlag_1 t1
		ON df.dupe_flag = t1.dupe_flag
	--LEFT JOIN TestDupeFlag20210412_1355 t2
	--	ON df.dupe_flag = t2.dupe_flag
GROUP BY df.dupe_flag

SELECT
	df.dupe_flag,
	count(t1.dupe_flag) AS t2_cnt
	--count(t2.dupe_flag) AS t2_cnt
FROM #uniqflag df
	LEFT JOIN TestDupeFlag20210412_1355 t1
		ON df.dupe_flag = t1.dupe_flag
	--LEFT JOIN TestDupeFlag20210412_1355 t2
	--	ON df.dupe_flag = t2.dupe_flag
GROUP BY df.dupe_flag

