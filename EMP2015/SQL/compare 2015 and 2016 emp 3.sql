
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
--select *
--from PLACER2015_FINAL
--where match is null and infousaid=0   --741
--where  infousaid=0   --788
--47 out of 788 records matched in 2016;741


--merge 2016 two data files
drop table  placer2016_merged0

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
--several dozens of records have the same name and address but different infousaid and naics code in placer2016_rawdata1 and 
--placer2016_rawdata2

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

--select *
--from placer2015_final
--WHERE infousaid=0 and match is null

UPDATE placer2016_merged0
set verified=0
where verified is null
--0=those records from SACOG15 and other sources
--++++++++++++++++++++++++++++++++++++++++++
--identify duplicates
select name,address,count(*) as counts
from placer2016_merged0
--where name='ELECTRICK MOTORSPORTS' and address= '3730 PLACER CORPORATE DR'
group by name,address
order by count(*) desc
--184 records have duplicates

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

select *
from placer2015_unused_v2
where address like 'PO BOX%'

delete from placer2016_merged0
where unused=1
--2846 records; they may or may not be duplicates

drop table placer2016_merged0_dup0

select name,address, count(*) as counts 
into placer2016_merged0_dup0
from placer2016_merged0
--where name='ELECTRICK MOTORSPORTS' and address= '3730 PLACER CORPORATE DR'
group by name,address
order by count(*) desc
--73 records have 78 duplicates

drop table placer2016_merged0_dup0a

SELECT *
INTO placer2016_merged0_dup0a
FROM placer2016_merged0_dup0
WHERE COUNTS>1

alter table placer2016_merged0
add dup int
go

update placer2016_merged0
set dup=b.counts
from placer2016_merged0 a
left outer join placer2016_merged0_dup0a b on
     a.name=b.name and a.address=b.address

drop table placer2016_merged0_dup1

select *
into placer2016_merged0_dup1
from placer2016_merged0
where dup>=2
order by name,address

drop table placer2016_merged2

--identify the unique records
select infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified,dup
into placer2016_emp0
from placer2016_merged0
where dup is null
--27285 records

select *
from placer2016_merged0
where name like 'CREEKSIDE FACIL%'

select *
from placer2016_emp0
where name like 'HEIDI CREEDON'

select infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified,dup
into placer2016_emp0a
from placer2016_merged0
where dup >=2 


=====================================
--create a blank table with all the variables 
create table placer2016_emp0b
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
	  ,[VERIFIED] int
	  ,dup int)


--run cursor to remove duplicates
DECLARE @name varchar(50),
        @address varchar(50),
        @counts int

TRUNCATE TABLE placer2016_emp0b

DECLARE loop1 SCROLL CURSOR FOR SELECT name,address,counts FROM placer2016_merged0_dup0a FOR READ ONLY
OPEN loop1
FETCH loop1 INTO @name,@address,@counts
WHILE @@FETCH_STATUS = 0
 	BEGIN
 		IF @counts > 1
 			INSERT INTO placer2016_emp0b SELECT top 1 * FROM placer2016_emp0a WHERE name = @name AND address = @address ORDER BY match,verified,emp16 DESC
 		ELSE
 			INSERT INTO placer2016_emp0b SELECT * FROM placer2016_emp0a WHERE name = @name AND address = @address
	  FETCH loop1 INTO @name,@address,@counts
    END
CLOSE loop1
DEALLOCATE loop1


INSERT INTO placer2016_emp0 (infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified)
SELECT infousaid,name,address,city,zip5,emp16,emp15,naics8,naics_desc,source,notes,match,verified
FROM placer2016_emp0b


--count 
select sum(emp16) as emp16,count(*) 
FROM placer2016_emp0
where address like 'PO BOX%'
--588 employers; 1389 jobs

--new records in 2015
select sum(emp16) as emp16New, count(*)
FROM placer2016_emp0
where match is null
--9163 records, 37076 jobs

--2016 total jobs without adjustment
select sum(emp16) as emp16New, count(*)
FROM placer2016_emp0
--27358 (vs 21645 in 2015) records; 171228 (vs 150137 in 2015) jobs

select source,count(*)
from placer2016_emp0
group by source
order by source

--add source in 2015 final into 2016
alter table placer2016_emp0
add source15 varchar(15)

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.infousaid=b.infousaid and a.name=b.name and a.address=b.address
--17923

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.name=b.name and a.address=b.address and source15 is null
--81

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.name=b.name and a.infousaid=b.infousaid and source15 is null and a.match in (2,3,4,5,6,7,8,12,13,14,15,16,17,18)
--439

alter table placer2016_emp0
add address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5)
go

update placer2016_emp0
set address0=b.address0,name0=b.name0,address1=b.address1,name1=b.name1,address2=b.address2,name2=b.name2,address3=b.address3,name3=b.name3
from placer2016_emp0 a,placer2016_merged0 b
where a.infousaid=b.infousaid and a.address=b.address and a.name=b.name


update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.name0=b.name0 and a.infousaid=b.infousaid and source15 is null and a.match in (2,3,4,5,6,7,8,12,13,14,15,16,17,18)
--107

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.name1=b.name1 and a.infousaid=b.infousaid and source15 is null and a.match in (2,3,4,5,6,7,8,12,13,14,15,16,17,18)
--70

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.name2=b.name2 and a.infousaid=b.infousaid and source15 is null and a.match in (2,3,4,5,6,7,8,12,13,14,15,16,17,18)
--55

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where a.name3=b.name3 and a.infousaid=b.infousaid and source15 is null and a.match in (2,3,4,5,6,7,8,12,13,14,15,16,17,18)
--14

update placer2016_emp0
set source15=b.source
from placer2016_emp0 a, placer2015_final b
where (a.address=b.address AND a.name=b.name and a.match is not null and a.source15 is null) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match is not null and a.source15 is null ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match is not null and a.source15 is null) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match is not null and a.source15 is null)
--247


SELECT *
FROM placer2016_emp0
WHERE  MATCH IS  NULL


--END OF CLEANING
--finished on 08/12/2016


select match,count(*)
from placer2016_merged0
where unused=1 and address like 'PO BOX%'
group by match
order by match

select *
from placer2016_merged0
where  address like 'PO BOX%'
group by match
order by match






select *
from placer2016_rawdata1
where name like 'CREEKSIDE FACILITY SVC INC'
order by name

select *
from placer2016_rawdata2
where name like 'CREEKSIDE FACIL%'
order by name

select *
from placer2016_emp0
where  address like '311 VERNON%'
order by name

select *
from placer2015_unused_v2
where address like '311 VERNON%'


select *
from placer2015_final
where name like 'CREEKSIDE FACILITY SVC INC' 
order by name



select name1,address1, count(*) as counts 
--into placer2016_merged0_dup0
from placer2016_merged0
where match  in (3,13)
group by name1,address1
order by count(*) desc
--73 records have 78 duplicates




SELECT a.name,b.name,a.address,b.address,a.emp16,b.emp15,a.match
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where ((a.address=b.address AND a.name=b.name ) or 
      (a.address0=b.address0 AND a.name0=b.name0  ) or
	  (a.address1=b.address1 AND a.name1=b.name1 ) or 
	  (a.address2=b.address2 AND a.name2=b.name2 )) and a.match>11
order by a.name,a.address


SELECT a.name as name16,b.name as name15,a.address as address16,b.address as address15,a.emp16,b.emp15,a.match
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.name like 'CREEKSIDE FACILITY SVC INC'
order by a.name,a.address



select distinct *
from placer2015_unused_v2

























