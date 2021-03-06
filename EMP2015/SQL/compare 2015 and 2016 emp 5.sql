
--08/31/2016
--standard procedures
--replace "sutter" with a county name
======================================================================
drop table sutter2016_rawdata1
drop table sutter2016_rawdata2
drop table sutter2015_final

--exclude primary key from original files
select infousaid,name,address,city,state,zip,county,latitude,longitude,saddress,scity,sstate,szip,naics8,naics_desc,
       emp16,year_established,work_at_home,sfootage_code,sfootage_desc
into sutter2016_rawdata1
from sutter2016_rawdata10

select infousaid,name,address,city,state,zip,county,latitude,longitude,saddress,scity,sstate,szip,naics8,naics_desc,
       emp16,year_established,work_at_home,sfootage_code,sfootage_desc
into sutter2016_rawdata2
from sutter2016_rawdata20

select *
into sutter2015_final
from sutter2015_final0

alter table sutter2015_final
add infousaid int
go

update sutter2015_final
set infousaid=infousa_id

--
alter table sutter2016_rawdata1
add naddress varchar(100), source16 varchar(15),naics4 varchar(4),naics2 varchar(2),address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5),match int, verified int,
	infousaid15 int,name15 varchar(50),address15 varchar(50),naddress15 varchar(100),source15 varchar(15),emp15 int,naics815 int
go

alter table sutter2016_rawdata2
add naddress varchar(100), source16 varchar(15),naics4 varchar(4),naics2 varchar(2),address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5),match int, verified int,
	infousaid15 int,name15 varchar(50),address15 varchar(50),naddress15 varchar(100),source15 varchar(15),emp15 int,naics815 int
go

alter table sutter2015_final
add match int, naddress varchar(100), emp16 int, address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5)
go

--
update sutter2016_rawdata1
set address=saddress
where address like 'PO BOX%'
--

update sutter2016_rawdata2
set address=saddress
where address like 'PO BOX%'
--

update sutter2016_rawdata1
set verified=1, naics4=left(naics8,4),naics2=left(naics8,2)

update sutter2016_rawdata2
set verified=2, naics4=left(naics8,4),naics2=left(naics8,2)



--++++++++++++++++++++++++++++++++++++++++
--save the deleted records
select *
into sutter2016_rawdata1_pobox
from sutter2016_rawdata1
where address like 'PO BOX%'
--

select *
into sutter2016_rawdata2_pobox
from sutter2016_rawdata2
where address like 'PO BOX%'
--

--delete records address like 'PO BOX%'
delete from sutter2016_rawdata1
where address like 'PO BOX%'
--

delete from sutter2016_rawdata2
where address like 'PO BOX%'
--
--++++++++++++++++++++++++++++++++++++++++++++
update sutter2016_rawdata1
set naddress=address + ' ' + city + ' ' + state + ' ' + cast (zip as varchar(5))

update sutter2016_rawdata1
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3),
	naics4=left(naics8,4),
	naics2=left(naics8,2),
	source16='INFOUSA'
--

update sutter2016_rawdata2
set naddress=address + ' ' + city + ' ' + state + ' ' + cast (zip as varchar(5))

update sutter2016_rawdata2
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3),
	naics4=left(naics8,4),
	naics2=left(naics8,2),
	source16='INFOUSA'
--

update sutter2015_final
set naddress=address + ' ' + city + ' ' + 'CA' + ' ' + cast (zip as varchar(5))

update sutter2015_final
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3)
--

--match address and name in sutter2016_rawdata1
update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=1
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name
--  out of 13871

--match address0 and name0 in sutter2016_rawdata1
update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=2
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
-- records; eyeball checked and correct

--match address1 and name1 in sutter2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=3
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
-- records; eyeball checked and correct

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=4
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
-- records; eyeball checked and correct

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=5
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
-- records; eyeball checked and correct

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=6
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null)
--

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=7
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--  

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
-- 

update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
-- 


--flag the business with relocation
update sutter2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=9
from sutter2016_rawdata1 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--

--match address and name in sutter2016_rawdata2
update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=11
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name
-- 

--match address0 and name0 in sutter2016_rawdata2
update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=12
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--

--match address1 and name1 in sutter2016_rawdata2
--some records have short company name and address and are excluded by address1 and name1
update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=13
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
-- 

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=14
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=15
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=16
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null)
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=17
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--

update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--

--flag the business with relocation
update sutter2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=19
from sutter2016_rawdata2 a, [sutter2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--

alter table sutter2015_FINAL
drop column match

alter table sutter2015_FINAL
add match int

--match address and name in [sutter2015_FINAL]
--update match in sutter2015_final to identify those records from non-infousa source and no matches in 2016
update [sutter2015_FINAL]
set match=1
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name and a.match is null
--

update [sutter2015_FINAL]
set match=2
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--

update [sutter2015_FINAL]
set match=3
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--

update [sutter2015_FINAL]
set match=4
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--

update [sutter2015_FINAL]
set match=5
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--

update [sutter2015_FINAL]
set match=6
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.address=b.address AND a.name=b.name and a.match is null
--

update [sutter2015_FINAL]
set match=7
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update [sutter2015_FINAL]
set match=8
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update [sutter2015_FINAL]
set match=8
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--

update [sutter2015_FINAL]
set match=8
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--

update [sutter2015_FINAL]
set match=8
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--

update [sutter2015_FINAL]
set match=9
from [sutter2015_FINAL] a, sutter2016_rawdata1 b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--

update [sutter2015_FINAL]
set match=11
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name and a.match is null
--

update [sutter2015_FINAL]
set match=12
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--

update [sutter2015_FINAL]
set match=13
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--

update [sutter2015_FINAL]
set match=14
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--

update [sutter2015_FINAL]
set match=15
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--

update [sutter2015_FINAL]
set match=16
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.address=b.address AND a.name=b.name and a.match is null
--

update [sutter2015_FINAL]
set match=17
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update [sutter2015_FINAL]
set match=18
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update [sutter2015_FINAL]
set match=18
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--

update [sutter2015_FINAL]
set match=18
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--

update [sutter2015_FINAL]
set match=18
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--

update [sutter2015_FINAL]
set match=19
from [sutter2015_FINAL] a, sutter2016_rawdata2 b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--



--merge 2016 two data files
drop table sutter2016_merged0

select *
into sutter2016_merged0
from sutter2016_rawdata1


insert into sutter2016_merged0 (infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815)
select infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815
from sutter2016_rawdata2
--several dozens of records have the same name and address but different infousaid and naics code in sutter2016_rawdata1 and 
--sutter2016_rawdata2


--add Tina's special cases (737) to 2016 
--select *
--from sutter2015_FINAL
--where match is null and infousaid=0   --737
--where  infousaid=0   --789


--insert 2015 unique records 
insert into sutter2016_merged0 (infousaid, NAME,ADDRESS,CITY,ZIP,LATITUDE,LONGITUDE,
            naics8,naics_desc,emp15,address0,name0,address1,name1,address2,name2,address3,name3,
			naddress15,source15)
select infousaid, CAST([NAME] AS VARCHAR(50)) AS NAME,CAST([ADDRESS] AS VARCHAR(50)) AS ADDRESS,CAST([CITY] AS VARCHAR(20)) AS CITY,[ZIP],CAST([LATITUDE] AS NUMERIC(15,6)) AS LATITUDE,CAST([LONGITUDE] AS NUMERIC(16,6)) AS LONGITUDE,
       [NAICS_code],CAST([NAICS_DESC] AS VARCHAR(50)) AS NAICS_DESC,[EMP15],address0,name0,address1,name1,address2,name2,address3,name3,
	   naddress,CAST(source AS VARCHAR(15)) AS source15
from sutter2015_final
WHERE infousaid=0 and match is null


UPDATE sutter2016_merged0
set verified=0
where verified is null
--0=those records from SACOG15 and other sources

--++++++++++++++++++++++++++++++++++++++++++

--identify duplicates
select name,address,count(*) as counts
from sutter2016_merged0
--where name='ELECTRICK MOTORSPORTS' and address= '3730 sutter CORPORATE DR'
group by name,address
order by count(*) desc
--183 records have multiple counts

--remove duplicates by using unused records in 2015
--alter table sutter2016_merged0
--drop column unused
--go

alter table sutter2016_merged0
add unused int
go

update sutter2016_merged0
set unused=1,infousaid15=b.infousaid,name15=b.name,address15=b.address
from sutter2016_merged0 a, sutter2015_FINAL_UNUSED_V2 b
where a.infousaid=b.infousaid and
      a.name=b.name and
	  a.address=b.address and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null
--1243

alter table sutter2015_FINAL_UNUSED_V2
add address0 varchar(15), name0 varchar(15),address1 varchar(10),name1 varchar(10), flag16 int
go

update sutter2015_FINAL_UNUSED_V2
set address0=left(address,15),name0=left(name,15),address1=left(address,10),name1=left(name,10)
--8028

update sutter2016_merged0
set unused=2,infousaid15=b.infousaid,name15=b.name,address15=b.address
from sutter2016_merged0 a, sutter2015_FINAL_UNUSED_V2 b
where a.infousaid=b.infousaid and
      a.name0=b.name0 and
	  a.address0=b.address0 and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null and unused is null
--19

update sutter2016_merged0
set unused=3,infousaid15=b.infousaid,name15=b.name,address15=b.address
from sutter2016_merged0 a, sutter2015_FINAL_UNUSED_V2 b
where a.infousaid=b.infousaid and
      a.name1=b.name1 and
	  a.address1=b.address1 and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null and unused is null
--12

--select *
--from sutter2015_FINAL_UNUSED_V2
--where address like 'PO BOX%'
--2153

drop table sutter2016_merged0_unused

select *
into sutter2016_merged0_unused
from sutter2016_merged0
where unused is not null 
--1274


delete from sutter2016_merged0
where unused is not null
--1274 records; they may or may not be duplicates


drop table sutter2016_merged0_dup0

select name,address, count(*) as counts 
into sutter2016_merged0_dup0
from sutter2016_merged0
group by name,address
order by count(*) desc
--167 records have 204 duplicates

drop table sutter2016_merged0_dup0a


SELECT *
INTO sutter2016_merged0_dup0a
FROM sutter2016_merged0_dup0
WHERE COUNTS>1

alter table sutter2016_merged0
add dup int
go

update sutter2016_merged0
set dup=b.counts
from sutter2016_merged0 a
left outer join sutter2016_merged0_dup0a b on
     a.name=b.name and a.address=b.address

drop table sutter2016_merged0_dup1

select *
into sutter2016_merged0_dup1
from sutter2016_merged0
where dup>=2
order by name,address
--362

drop table sutter2016_emp0

--identify the unique records
select *
into sutter2016_emp0
from sutter2016_merged0
where dup is null
--26996 records

drop table sutter2016_emp0a

select *
into sutter2016_emp0a
from sutter2016_merged0
where dup >=2 
--362

--=====================================
--create a blank table with all the variables 
create table sutter2016_emp0b
      ([INFOUSAID] int
	  ,[NAME] varchar(50)
      ,[ADDRESS] varchar(50)
      ,[CITY] varchar(20)
	  ,[STATE] varchar(2)
      ,[ZIP] int
	  ,county varchar(20)
	  ,LATITUDE numeric(11,6)
	  ,LONGITUDE numeric(11,6)
      ,saddress varchar(50)
	  ,scity varchar(20)
	  ,sstate varchar(2)
	  ,szip int
      ,[NAICS8] int
	  ,[NAICS_DESC] varchar(50)
	  ,[EMP16] int
      ,year_established varchar(4)
	  ,work_at_home varchar(4)
	  ,sfootage_code int
	  ,sfootage_desc varchar(30)
	  ,naddress varchar(100)
	  ,source16 varchar(15)
	  ,naics4 varchar(4)
	  ,naics2 varchar(2)
	  ,address0 varchar(15)
	  ,name0 varchar(15)
	  ,address1  varchar(10)
	  ,name1  varchar(10)
	  ,address2  varchar(5)
	  ,name2  varchar(5)
	  ,address3  varchar(5)
	  ,name3  varchar(5)
	  ,match int
	  ,verified int
	  ,infousaid15 int
	  ,name15 varchar(50)
	  ,address15  varchar(50)
	  ,naddress15  varchar(100)
	  ,source15  varchar(15)
	  ,emp15 int
	  ,naics815  int
	  ,unused int
	  ,dup int)

      

--run cursor to remove duplicates
DECLARE @name varchar(50),
        @address varchar(50),
        @counts int

TRUNCATE TABLE sutter2016_emp0b

DECLARE loop1 SCROLL CURSOR FOR SELECT name,address,counts FROM sutter2016_merged0_dup0a FOR READ ONLY
OPEN loop1
FETCH loop1 INTO @name,@address,@counts
WHILE @@FETCH_STATUS = 0
 	BEGIN
 		IF @counts > 1
 			INSERT INTO sutter2016_emp0b SELECT top 1 * FROM sutter2016_emp0a WHERE name = @name AND address = @address ORDER BY match,verified,emp16 DESC
 		ELSE
 			INSERT INTO sutter2016_emp0b SELECT * FROM sutter2016_emp0a WHERE name = @name AND address = @address
	  FETCH loop1 INTO @name,@address,@counts
    END
CLOSE loop1
DEALLOCATE loop1


INSERT INTO sutter2016_emp0 (infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815)
SELECT infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815
FROM sutter2016_emp0b
--169

--flag the records in 2016 that are filtered out by 2015 unused

update sutter2015_final_unused_v2
set flag16=1
from sutter2015_final_unused_v2 a, sutter2016_merged0_unused b
where a.name=b.name and a.address=b.address and b.unused>=1
--1250

select *
from sutter2015_final_unused_v2

select *
from sutter2016_emp0

--END OF CLEANING
--finished on 08/12/2016


select *
from sutter2016_emp0
where name like '%school%'

select *
from sutter2015_final
where name='STAR SCHOOL'

