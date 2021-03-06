
--approach to update placer2016_rawdata1 and rawdata2
--+++++++++++++++++++++++++++++++++++++++++++++++++++
--count total records in 2015 final and 2016 raw data
select count(*) as records
from [PLACER2015_FINAL]
--21645

select count(*) as records
from [PLACER2016_rawdata1]
--14358

select count(*) as records
from [PLACER2016_rawdata2]
--15181

--+++++++++++++++++++++++++++++++++++++++++++++++++
--copy to Excel; see map
select city,count(*) as points
from [PLACER2015_FINAL] 
group by city
order by city
-- several dozens of miscoded records (outside of Placer County Boundary);
--the same error in Placer2016_rawdata; cities and counties has mismatch in geography

select city,count(*) as points
from [PLACER2016_rawdata1] 
group by city
order by city

select city,count(*) as points
from [PLACER2016_rawdata2] 
group by city
order by city


select *
from placer2016_rawdata10
======================================================================
--objectID is added when it is exported from ARCmap
select [INFOUSAID],[NAME],[ADDRESS],[CITY],[ZIP5],[LATITUDE],[LONGITUDE]
      ,[NAICS8],[NAICS_DESC],[EMP16],[SOURCE],[NOTES],year16,address0,name0,address1,name1
into placer2016_rawdata1
from placer2016_rawdata10

select [INFOUSAID],[NAME],[ADDRESS],[CITY],[ZIP5],[LATITUDE],[LONGITUDE]
      ,[NAICS8],[NAICS_DESC],[EMP16],[SOURCE],[NOTES],year16,address0,name0,address1,name1
into placer2016_rawdata2
from placer2016_rawdata20

alter table placer2016_rawdata2
drop column match, naddress,emp15

alter table placer2016_rawdata2
add match int, naddress varchar(100),emp15 int
go


alter table placer2016_rawdata2
add match int, naddress varchar(100),emp15 int
go

alter table placer2015_final
add address2 varchar(5),name2 varchar(5)
go

alter table placer2016_rawdata1
add address2 varchar(5),name2 varchar(5)
go

alter table placer2016_rawdata2
add address2 varchar(5),name2 varchar(5)
go

update placer2015_final
set address2=left(address,5),name2=left(name,5)

update placer2016_rawdata1
set address2=left(address,5),name2=left(name,5)

update placer2016_rawdata2
set address2=left(address,5),name2=left(name,5)

--
alter table placer2015_final
add address3 varchar(5),name3 varchar(5)
go

alter table placer2016_rawdata1
add address3 varchar(5),name3 varchar(5)
go

alter table placer2016_rawdata2
add address3 varchar(5),name3 varchar(5)
go

update placer2015_final
set address3=left(address,3),name3=left(name,3)

update placer2016_rawdata1
set address3=left(address,3),name3=left(name,3)

update placer2016_rawdata2
set address3=left(address,3),name3=left(name,3)


--replace PO BOX with secondary address
--placer2016_rawdata1 and placer2016_rawdata1a are the same dataset with differt variables
update placer2016_rawdata1
set address=b.saddress
from placer2016_rawdata1 a
join placer2016_rawdata1a b on
    a.infousaid=b.infousaid and a.name=b.name and a.city=b.city and a.zip5=b.zip5 and a.address like 'PO BOX%'

update placer2016_rawdata2
set address=b.saddress
from placer2016_rawdata2 a
join placer2016_rawdata2a b on
    a.infousaid=b.infousaid and a.name=b.name and a.city=b.city and a.zip5=b.zip5 and a.address like 'PO BOX%'

--
--match address and name in placer2016_rawdata1
update placer2016_rawdata1
set match=1,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address=b.address AND a.name=b.name
-- 9446 out of 14358

--match address0 and name0 in placer2016_rawdata1
update placer2016_rawdata1
set match=2,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--171 records; eyeballed check and correct

--match address1 and name1 in placer2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update placer2016_rawdata1
set match=3,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--62 records; eyeballed check and correct

--match the records with the same infousaid, name, and address by PO BOX in placer2016_rawdata1
--update placer2016_rawdata1
--set match=4,emp15=b.emp15
--from placer2016_rawdata1 a, [PLACER2015_FINAL] b
--where a.infousaid=b.infousaid and a.name0=b.name0 and a.city=b.city and a.match is null  and a.address like 'PO BOX%'
--0; this problem is fixed by updating PO BOX with secondary address as in placer2015_final

update placer2016_rawdata1
set match=5,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--54 records; eyeballed check and correct

update placer2016_rawdata1
set match=6,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--12 records; eyeballed check and correct

update placer2016_rawdata1
set match=7,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match is null) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
-- 626 records; eyeballed check and correct
--the same business with different infousaid

--flag the business with relocation
update placer2016_rawdata1
set match=8,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--187



--
--match address and name in placer2016_rawdata1
update placer2016_rawdata2
set match=11,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address=b.address AND a.name=b.name
-- 7238 out of 14358

--match address0 and name0 in placer2016_rawdata1
update placer2016_rawdata2
set match=12,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--124 records; eyeballed check and correct

--match address1 and name1 in placer2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update placer2016_rawdata2
set match=13,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--7 records; eyeballed check and correct

--match the records with the same infousaid, name, and address by PO BOX in placer2016_rawdata1
--update placer2016_rawdata2
--set match=14,emp15=b.emp15
--from placer2016_rawdata2 a, [PLACER2015_FINAL] b
--where a.infousaid=b.infousaid and a.name0=b.name0 and a.city=b.city and a.match is null  and a.address like 'PO BOX%'
--76

update placer2016_rawdata2
set match=15,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--1 records; eyeballed check and correct

update placer2016_rawdata2
set match=16,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--5 records; eyeballed check and correct

update placer2016_rawdata2
set match=17,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match is null) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
-- 274 records; eyeballed check and correct
--the same business with different infousaid

--flag the business with relocation
update placer2016_rawdata2
set match=18,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--57

--update match in placer2015_final to identify those records from non-infousa source and no matches in 2016
--see compare 2015 and 2016 emp.sql

--add Tina's special cases to 2016 
select *
from PLACER2015_FINAL
where match is null and infousaid=0   --741
--where  infousaid=0   --788
--47 out of 788 records matched in 2016;741


--merge 2016 two data files
select infousaid, [NAME],[ADDRESS],[CITY],cast([ZIP5] as int) as ZIP5,[LATITUDE],[LONGITUDE]
      ,[NAICS8],[NAICS_DESC],cast([EMP16] as int) AS EMP16,cast(source as varchar(15)) as source, cast(notes as varchar(100)) as notes, year16,name0,name1,name2,name3,address0,address1,address2,address3,
	  match,naddress,emp15
into placer2016_merged0
from placer2016_rawdata1

alter table placer2016_merged0
add verified int
GO

update placer2016_merged0
set verified=1

insert into placer2016_merged0 (infousaid, [NAME],[ADDRESS],[CITY],[ZIP5],[LATITUDE],[LONGITUDE]
      ,[NAICS8],[NAICS_DESC],[EMP16],source, notes, year16,name0,name1,name2,name3,address0,address1,address2,address3,
	  match,naddress,emp15)
select infousaid, [NAME],[ADDRESS],[CITY],[ZIP5],[LATITUDE],[LONGITUDE]
      ,[NAICS8],[NAICS_DESC],[EMP16],source, notes, year16,name0,name1,name2,name3,address0,address1,address2,address3,
	  match,naddress,emp15
from placer2016_rawdata2

update placer2016_merged0
set verified=2
where verified is null


--insert 2015 unique records 
insert into placer2016_merged0 (infousaid, [NAME],[ADDRESS],[CITY],[ZIP5],[LATITUDE],[LONGITUDE],
       [NAICS8],[NAICS_DESC],[EMP16],source, notes, year16,name0,name1,name2,name3,address0,address1,address2,address3,match)
select infousaid, CAST([NAME] AS VARCHAR(50)) AS NAME,CAST([ADDRESS] AS VARCHAR(50)) AS ADDRESS,CAST([CITY] AS VARCHAR(20)) AS CITY,[ZIP5],CAST([LATITUDE] AS NUMERIC(15,6)) AS LATITUDE,CAST([LONGITUDE] AS NUMERIC(16,6)) AS LONGITUDE,
       [NAICS8],CAST([NAICS_DESC] AS VARCHAR(50)) AS NAICS_DESC,[EMP15],CAST(source AS VARCHAR(15)) AS source, CAST(notes AS VARCHAR(100)) AS notes, year15,name0,name1,name2,name3,address0,address1,address2,address3,match
from placer2015_final
WHERE infousaid=0 and match is null

select *
from placer2015_final
WHERE infousaid=0 and match is null

UPDATE placer2016_merged0
set verified=0
where verified is null
--0=those records from SACOG15 and other sources
--++++++++++++++++++++++++++++++++++++++++++
--identify duplicates
select name,address,match,count(*) as counts
from placer2016_merged0
group by name,address,match
order by count(*) desc
--128 duplicate counts

--remove duplicates by using unused records in 2015
alter table placer2016_merged0
add unused int
go

update placer2016_merged0
set unused=1
from placer2016_merged0 a, placer2015_unused_v2 b
where a.infousaid=b.infousaid and
      a.name=b.name and
	  a.address=b.address and
	  a.city=b.city and 
	  a.zip5=b.zip5

delete from placer2016_merged0
where unused=1

select name,address, count(*) as counts 
--into placer2016_merged0_dup0
from placer2016_merged0
group by name,address,match
order by count(*) desc

SELECT *
INTO placer2016_merged0_dup0a
FROM placer2016_merged0_dup0
WHERE COUNTS>1

drop table placer2016_merged0_dup0
	  
alter table placer2016_merged0
add dup int
go

update placer2016_merged0
set dup=b.counts
from placer2016_merged0 a
join placer2016_merged0_dup1 b on
     a.name=b.name and a.address=b.address

select *
--into placer2016_merged0_dup1
from placer2016_merged0
where dup>=2
order by name,address


select infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified
into placer2016_merged1
from placer2016_merged0
where dup is null

select infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified
into placer2016_merged2
from placer2016_merged0
where dup >=2 


=====================================
--create a blank table with all the variables 
create table pla_emp_16_0
      ([INFOUSAID] int
	  ,[NAME] varchar(50)
      ,[ADDRESS] varchar(50)
      ,[CITY] varchar(20)
      ,[ZIP5] int
      ,[EMP16] int
      ,[EMP15] int
      ,[NAICS8] int
	  ,[NAICS_DESC] varchar(50)
	  ,[SOURCE] varchar(15)
	  ,[NOTES] varchar(100)
	  ,[MATCH] int
	  ,[VERIFIED] int)

DROP TABLE pla_emp_16_0

--run cursor to remove duplicates
DECLARE @name varchar(50),
        @address varchar(50),
        @counts int

TRUNCATE TABLE pla_emp_16_0

DECLARE loop1 SCROLL CURSOR FOR SELECT name,address,counts FROM placer2016_merged0_dup0a FOR READ ONLY
OPEN loop1
FETCH loop1 INTO @name,@address,@counts
WHILE @@FETCH_STATUS = 0
 	BEGIN
 		IF @counts > 1
 			INSERT INTO pla_emp_16_0 SELECT top 1 * FROM placer2016_merged2 WHERE name = @name AND address = @address ORDER BY match,verified,emp16 DESC
 		ELSE
 			INSERT INTO pla_emp_16_0 SELECT * FROM placer2016_merged2 WHERE name = @name AND address = @address
	  FETCH loop1 INTO @name,@address,@counts
    END
CLOSE loop1
DEALLOCATE loop1


INSERT INTO pla_emp_16_0 (infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified)
SELECT infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified
FROM placer2016_merged1

--count 
select sum(emp16) as emp16,count(*) 
FROM pla_emp_16_0
where address like 'PO BOX%'
--588 employers; 1389 jobs


--new records in 2015
select sum(emp16) as emp16New, count(*)
FROM pla_emp_16_0
where match is null
--9163 records, 37076 jobs

--2016 total jobs without adjustment
select sum(emp16) as emp16New, count(*)
FROM pla_emp_16_0
--27410 (vs 21645 in 2015) records; 171580 (vs 150137 in 2015) jobs

select sum(emp15) as emp15, count(*)
FROM placer2015_final

END OF CLEANING

SELECT *
FROM placer2016_merged0
WHERE NAME='US BANK' AND ADDRESS='1400 ROCKY RIDGE DR # 100'

SELECT *
FROM pla_emp_16_0
WHERE NAME='US BANK' AND ADDRESS='1400 ROCKY RIDGE DR # 100'











drop table placer2016_merged1
--+++++++++++++++++++++++++++++++++++++++++++
--create a blank table with all the variables in sacxab_15_unique_records_4
create table pla_emp_16_0
      ([INFOUSAID] int
	  ,[NAME] varchar(50)
      ,[ADDRESS] varchar(50)
      ,[CITY] varchar(20)
      ,[ZIP5] int
      ,[EMP16] int
      ,[EMP15] int
      ,[NAICS8] int
	  ,[NAICS_DESC] varchar(50)
	  ,[SOURCE] varchar(15)
	  ,[NOTES] varchar(100))

drop table pla_emp_16_0

--run cursor to remove duplicates
DECLARE @name varchar(50),
        @address varchar(50),
        @counts int

TRUNCATE TABLE pla_emp_16_0

DECLARE loop1 SCROLL CURSOR FOR SELECT name,address,counts FROM placer2016_merged0_dup0 FOR READ ONLY
OPEN loop1
FETCH loop1 INTO @name,@address,@counts
WHILE @@FETCH_STATUS = 0
 	BEGIN
 		IF @counts > 1
 			INSERT INTO pla_emp_16_0 SELECT top 1 * FROM placer2016_merged1 WHERE name = @name AND address = @address ORDER BY emp16 DESC
 		ELSE
 			INSERT INTO pla_emp_16_0 SELECT * FROM placer2016_merged1 WHERE name = @name AND address = @address
	  FETCH loop1 INTO @name,@address,@counts
    END
CLOSE loop1
DEALLOCATE loop1

--+++++++++++++++++++++++++++++++++++++++++++++++++


select name,address, count(*) as counts 
from pla_emp_16_0
group by name,address
order by count(*) desc



select *
from placer2016_merged1
where name='BOBST BOOK & BRIEL CPAS INC' and address='13620 LINCOLN WAY # 250'


select *
from pla_emp_16_0
where name='BOBST BOOK & BRIEL CPAS INC' and address='13620 LINCOLN WAY # 250'

select *
from placer2016_merged0_dup0
order by counts desc

select name,address, count(*) as counts 
--into placer2016_merged0_dup0
from placer2016_merged1
group by name,address
order by count(*) desc






update placer2016_merged0
set match=0
where match=7


update placer2016_merged0
set match=7,emp15=b.emp15
from placer2016_merged0 a, [PLACER2015_FINAL] b
--where (a.address=b.address AND a.name=b.name and a.match=0)
--where (a.address0=b.address0 AND a.name0=b.name0 and a.match=0)
--where (a.address1=b.address1 AND a.name1=b.name1 and a.match=0)
where (a.address2=b.address2 AND a.name2=b.name2 and a.match=0)
where (a.address3=b.address3 AND a.name3=b.name3 and a.match=0)

-- 626 records; eyeballed check and correct
--the same business with different infousaid







select year16,count(*)
from placer2016_merged0
group by year16

SELECT *
FROM placer2016_merged0
order by year16





SELECT a.infousaid as infousaid16, b.infousaid as infousaid15,
       a.address as address16, b.address as address15,
	   a.name as name15, b.name as name16,
	   a.emp16,b.emp15,
	   a.source as source16,b.source as source15
from placer2016_rawdata1 a  
join placer2015_final b 
  on    a.infousaid=b.infousaid and a.match=8 is null
--on   a.infousaid=b.infousaid and a.address=b.address AND a.name=b.name and a.match=11
--on   a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match=12
--on   a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match=13
--on   a.infousaid=b.infousaid and a.name0=b.name0 and a.city=b.city and a.match=14  and a.address like 'PO BOX%'
--on   a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match=15
--on   a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match=16
--on (a.address=b.address AND a.name=b.name and a.match=17) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match=17 ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match=17) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match=17)


select *
from placer2015_final
WHERE NAME='%ROCKY RIDGE DR %'

SELECT *
FROM PLACER2016_RAWDATA2
WHERE NAME='CITY OF AUBURN'

SELECT *
FROM PLACER2016_RAWDATA2
WHERE NAME='CITY OF AUBURN'


SELECT *
from placer2016_rawdata1
WHERE NAME2 = 'COLFA' and address2 = '120 W'


SELECT *
from placer2015_final
where NAME2 = 'COLFA' and address2 ='120 W ' 
where infousaid='715107171'
order by address



select match,sum(emp15) as emp15,sum(emp16) as emp16
from placer2016_rawdata1
group by match
order by match

SELECT a.infousaid as infousaid16, b.infousaid as infousaid15,
       a.address as address16, b.address as address15,
	   a.name as name15, b.name as name16,
	   a.emp16,b.emp15,
	   a.source as source16,b.source as source15
from placer2016_rawdata1 a  
join placer2015_final b 
on  (a.address=b.address AND a.name=b.name and a.match=7) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match=7 ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match=7) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match=7)











































































--match infousaid and address
update placer2016_rawdata1
set match=5,emp15=b.emp15
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address=b.address and a.match is null
--135



select a.infousaid,b.infousaid,a.name,b.name,a.address,b.address
from placer2016_rawdata1 a
join placer2015_final b on 
   a.infousaid=b.infousaid and a.address=b.address and a.match is null










--++++++++++++++++
update placer2016_rawdata2
set match=1,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.address=b.address AND a.name=b.name
-- 7190 out of 15181

--match address0 and name0 in placer2016_rawdata1
update placer2016_rawdata2
set match=2,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--172 records; eyeballed check and correct

--match address1 and name1 in placer2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update placer2016_rawdata2
set match=3,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--60 records; eyeballed check and correct

--match the records with the same infousaid, name, and address by PO BOX in placer2016_rawdata1
update placer2016_rawdata2
set match=4,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.name0=b.name0 and a.city=b.city and a.match is null  and a.address like 'PO BOX%'
--76

--match infousaid and address
update placer2016_rawdata2
set match=5,emp15=b.emp15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address=b.address and a.match is null
--7
--++++++++++++++++++++++++

select [INFOUSAID]      ,[NAME]
      ,[ADDRESS]      ,[CITY]      ,[ZIP5]      ,[LATITUDE]      ,[LONGITUDE]
      ,[NAICS8]      ,[NAICS_DESC]      ,[EMP16]      ,[SOURCE]
      ,[NOTES]      ,[YEAR16]      ,[address0]      ,[name0]      ,[address1]
      ,[name1]      ,[match]      ,[naddress]      ,[emp15]
into placer2016_merged0
from placer2016_rawdata1

ALTER TABLE placer2016_merged0
ADD verified int

update placer2016_merged0
set verified=1

ALTER TABLE placer2016_rawdata2
ADD verified int

update placer2016_merged0
set verified=2


insert into placer2016_merged0 ([INFOUSAID]      ,[NAME]
      ,[ADDRESS]      ,[CITY]      ,[ZIP5]      ,[LATITUDE]      ,[LONGITUDE]
      ,[NAICS8]      ,[NAICS_DESC]      ,[EMP16]      ,[SOURCE]
      ,[NOTES]      ,[YEAR16]      ,[address0]      ,[name0]      ,[address1]
      ,[name1]      ,[match]      ,[naddress]      ,[emp15],verified)
select [INFOUSAID]      ,[NAME]
      ,[ADDRESS]      ,[CITY]      ,[ZIP5]      ,[LATITUDE]      ,[LONGITUDE]
      ,[NAICS8]      ,[NAICS_DESC]      ,[EMP16]      ,[SOURCE]
      ,[NOTES]      ,[YEAR16]      ,[address0]      ,[name0]      ,[address1]
      ,[name1]      ,[match]      ,[naddress]      ,[emp15], verified
from placer2016_rawdata2



SELECT  [NAME]
      ,[ADDRESS]      ,[CITY]      ,[ZIP5]      ,[LATITUDE]      ,[LONGITUDE]
      ,[NAICS8]      ,[NAICS_DESC]      ,[EMP16]      ,[SOURCE]
      ,[NOTES]      ,[YEAR16]      ,[address0]      ,[name0]      ,[address1]
      ,[name1]      ,[match]      ,[naddress]  ,count(*)
FROM placer2016_merged0
group by [NAME]
      ,[ADDRESS]      ,[CITY]      ,[ZIP5]      ,[LATITUDE]      ,[LONGITUDE]
      ,[NAICS8]      ,[NAICS_DESC]      ,[EMP16]      ,[SOURCE]
      ,[NOTES]      ,[YEAR16]      ,[address0]      ,[name0]      ,[address1]
      ,[name1]      ,[match]      ,[naddress]
order by count(*) desc
--some cases have all the same varaibles except infousaid. Keep the records that's verified in 2015.


select *
from placer2016_rawdata1
where name='PARKWAY DENTAL GROUP'

select *
from PLACER2015_FINAL
where name='PARKWAY DENTAL GROUP'

--summary
select match,sum(emp15) as emp15, count(*) as counts
from PLACER2015_FINAL
group by match
order by match



















select *
from placer2016_rawdata1
where infousaid=517203055

select sum(emp15),sum(emp16)
from PLACER2015_FINAL
where match is null


select a.infousaid as infousaid15,b.infousaid as inforusaid16,a.name as name15,b.name as name16,a.address as address15,b.address as address16,a.emp15,b.emp16,
       a.naics8 as naics8_15,b.naics8 as naics8_16,a.match
from PLACER2015_FINAL a
join PLACER2016_RAWDATA1 b on

 a.address=b.address  and match is null       and a.name0=b.name0 and a.city=b.city and match=11  and b.address like 'PO BOX%'

--a.address=b.address AND a.name=b.name and a.match=11

 --a.address0=b.address0 AND a.name0=b.name0 and a.match=12

a.address1=b.address1 and a.name1=b.name1 and match=13
--  a.infousaid=b.infousaid and a.city=b.city and match is null  


 select MATCH,COUNT(*)
 from PLACER2015_FINAL
 GROUP BY MATCH
 ORDER BY MATCH

 where match is null
  --match name only
  update PLACER2015_FINAL
  set emp16=b.emp16
  from [PLACER2015_FINAL] a,placer2016_rawdata b
  where a.name=b.name and match is null
  --1473 records

  select sum(emp16) as emp16
  FROM placer2016_rawdata
  
===================================================
  select address,name,naics8,emp15,emp16
  from [PLACER2015_FINAL] 
  where address='1100 MELODY LN'

  select *
  from [PLACER2015_FINAL] 
  where match is null and emp16>0
  order by emp15 desc
   
select *
from placer2016_rawdata2
where infousaid='532257235'

select *
from [PLACER2015_FINAL]
--where match=2
where infousaid='674203138'

 a,placer2016_rawdata b
  where a.name=b.name and match is null

select *
from [PLACER2015_FINAL] a,placer2016_rawdata b
where a.name=b.name  and match is null


SELECT TOP 1000 [OBJECTID]
      ,[INFOUSAID]
      ,[NAME]
      ,[ADDRESS]
      ,[CITY]
      ,[ZIP5]
      ,[LATITUDE]
      ,[LONGITUDE]
      ,[NAICS8]
      ,[NAICS_DESC]
      ,[EMP15]
      ,[SOURCE]
      ,[NOTES]
      ,[YEAR15]
  FROM [EMP_INVENTORY].[dbo].[PLACER2015_FINAL]