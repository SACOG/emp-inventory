
--08/24/2016
--placer2015_final is updated as v2 on 08/24/2016
--placer2015_final_unused_v2 is updated on 08/24/2016

======================================================================
drop table placer2016_rawdata1
drop table placer2016_rawdata2
drop table placer2015_final

--exclude primary key from original files
select infousaid,name,address,city,state,zip,county,latitude,longitude,saddress,scity,sstate,szip,naics8,naics_desc,
       emp16,year_established,work_at_home,sfootage_code,sfootage_desc
into placer2016_rawdata1
from placer2016_rawdata10

select infousaid,name,address,city,state,zip,county,latitude,longitude,saddress,scity,sstate,szip,naics8,naics_desc,
       emp16,year_established,work_at_home,sfootage_code,sfootage_desc
into placer2016_rawdata2
from placer2016_rawdata20

select *
into placer2015_final
from placer2015_final0

alter table placer2015_final
add infousaid int
go

update placer2015_final
set infousaid=infousa_id

--
alter table placer2016_rawdata1
add naddress varchar(100), source16 varchar(15),naics4 varchar(4),naics2 varchar(2),address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5),match int, verified int,
	infousaid15 int,name15 varchar(50),address15 varchar(50),naddress15 varchar(100),source15 varchar(15),emp15 int,naics815 int
go

alter table placer2016_rawdata2
add naddress varchar(100), source16 varchar(15),naics4 varchar(4),naics2 varchar(2),address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5),match int, verified int,
	infousaid15 int,name15 varchar(50),address15 varchar(50),naddress15 varchar(100),source15 varchar(15),emp15 int,naics815 int
go

alter table placer2015_final
add match int, naddress varchar(100), emp16 int, address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5)
go

--
update placer2016_rawdata1
set address=saddress
where address like 'PO BOX%'
--1798

update placer2016_rawdata2
set address=saddress
where address like 'PO BOX%'
--1284

update placer2016_rawdata1
set verified=1, naics4=left(naics8,4),naics2=left(naics8,2)

update placer2016_rawdata2
set verified=2, naics4=left(naics8,4),naics2=left(naics8,2)



--++++++++++++++++++++++++++++++++++++++++
--save the deleted records
select *
into placer2016_rawdata1_pobox
from placer2016_rawdata1
where address like 'PO BOX%'
--487

select *
into placer2016_rawdata2_pobox
from placer2016_rawdata2
where address like 'PO BOX%'
--1153

--delete records address like 'PO BOX%'
delete from placer2016_rawdata1
where address like 'PO BOX%'
--487

delete from placer2016_rawdata2
where address like 'PO BOX%'
--1153
--++++++++++++++++++++++++++++++++++++++++++++
update placer2016_rawdata1
set naddress=address + ' ' + city + ' ' + state + ' ' + cast (zip as varchar(5))

update placer2016_rawdata1
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3),
	naics4=left(naics8,4),
	naics2=left(naics8,2),
	source16='INFOUSA'
--13781

update placer2016_rawdata2
set naddress=address + ' ' + city + ' ' + state + ' ' + cast (zip as varchar(5))

update placer2016_rawdata2
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3),
	naics4=left(naics8,4),
	naics2=left(naics8,2),
	source16='INFOUSA'
--14028

update placer2015_final
set naddress=address + ' ' + city + ' ' + 'CA' + ' ' + cast (zip as varchar(5))

update placer2015_final
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3)
--

--match address and name in placer2016_rawdata1
update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=1
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name
-- 9851 out of 13871

--match address0 and name0 in placer2016_rawdata1
update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=2
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--219 records; eyeball checked and correct

--match address1 and name1 in placer2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=3
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--73 records; eyeball checked and correct

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=4
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--57 records; eyeball checked and correct

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=5
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--14 records; eyeball checked and correct

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=6
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null)
--210

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=7
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--121

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--139

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
-- 224 

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
-- 64

update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
-- 1


--flag the business with relocation
update placer2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=9
from placer2016_rawdata1 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--160; eyeball checked and correct

--match address and name in placer2016_rawdata2
update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=11
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name
-- 7301 out of 13871

--match address0 and name0 in placer2016_rawdata2
update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=12
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--59

--match address1 and name1 in placer2016_rawdata2
--some records have short company name and address and are excluded by address1 and name1
update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=13
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--8 

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=14
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--2

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=15
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--5 records

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=16
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null)
--37

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=17
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--48

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--54

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--137 

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--74

update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--1

--flag the business with relocation
update placer2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=19
from placer2016_rawdata2 a, [PLACER2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--56

alter table PLACER2015_FINAL
drop column match

alter table PLACER2015_FINAL
add match int

--match address and name in [PLACER2015_FINAL]
--update match in placer2015_final to identify those records from non-infousa source and no matches in 2016
update [PLACER2015_FINAL]
set match=1
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name and a.match is null
--9851

update [PLACER2015_FINAL]
set match=2
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--219

update [PLACER2015_FINAL]
set match=3
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--73

update [PLACER2015_FINAL]
set match=4
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--57

update [PLACER2015_FINAL]
set match=5
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--14

update [PLACER2015_FINAL]
set match=6
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.address=b.address AND a.name=b.name and a.match is null
--91

update [PLACER2015_FINAL]
set match=7
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--56

update [PLACER2015_FINAL]
set match=8
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--41

update [PLACER2015_FINAL]
set match=8
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--94

update [PLACER2015_FINAL]
set match=8
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--70

update [PLACER2015_FINAL]
set match=8
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--3

update [PLACER2015_FINAL]
set match=9
from [PLACER2015_FINAL] a, placer2016_rawdata1 b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--169

update [PLACER2015_FINAL]
set match=11
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name and a.match is null
--7238

update [PLACER2015_FINAL]
set match=12
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--56

update [PLACER2015_FINAL]
set match=13
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--6

update [PLACER2015_FINAL]
set match=14
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--2

update [PLACER2015_FINAL]
set match=15
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--5

update [PLACER2015_FINAL]
set match=16
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.address=b.address AND a.name=b.name and a.match is null
--6

update [PLACER2015_FINAL]
set match=17
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--12

update [PLACER2015_FINAL]
set match=18
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--10

update [PLACER2015_FINAL]
set match=18
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--24

update [PLACER2015_FINAL]
set match=18
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--15

update [PLACER2015_FINAL]
set match=18
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--0

update [PLACER2015_FINAL]
set match=19
from [PLACER2015_FINAL] a, placer2016_rawdata2 b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--52



--merge 2016 two data files
drop table placer2016_merged0

select *
into placer2016_merged0
from placer2016_rawdata1


insert into placer2016_merged0 (infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815)
select infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815
from placer2016_rawdata2
--several dozens of records have the same name and address but different infousaid and naics code in placer2016_rawdata1 and 
--placer2016_rawdata2


--add Tina's special cases (737) to 2016 
--select *
--from PLACER2015_FINAL
--where match is null and infousaid=0   --737
--where  infousaid=0   --789


--insert 2015 unique records 
insert into placer2016_merged0 (infousaid, NAME,ADDRESS,CITY,ZIP,LATITUDE,LONGITUDE,
            naics8,naics_desc,emp15,address0,name0,address1,name1,address2,name2,address3,name3,
			naddress15,source15)
select infousaid, CAST([NAME] AS VARCHAR(50)) AS NAME,CAST([ADDRESS] AS VARCHAR(50)) AS ADDRESS,CAST([CITY] AS VARCHAR(20)) AS CITY,[ZIP],CAST([LATITUDE] AS NUMERIC(15,6)) AS LATITUDE,CAST([LONGITUDE] AS NUMERIC(16,6)) AS LONGITUDE,
       [NAICS_code],CAST([NAICS_DESC] AS VARCHAR(50)) AS NAICS_DESC,[EMP15],address0,name0,address1,name1,address2,name2,address3,name3,
	   naddress,CAST(source AS VARCHAR(15)) AS source15
from placer2015_final
WHERE infousaid=0 and match is null


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
--183 records have multiple counts

--remove duplicates by using unused records in 2015
--alter table placer2016_merged0
--drop column unused
--go

alter table placer2016_merged0
add unused int
go

update placer2016_merged0
set unused=1,infousaid15=b.infousaid,name15=b.name,address15=b.address
from placer2016_merged0 a, PLACER2015_FINAL_UNUSED_V2 b
where a.infousaid=b.infousaid and
      a.name=b.name and
	  a.address=b.address and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null
--1243

alter table PLACER2015_FINAL_UNUSED_V2
add address0 varchar(15), name0 varchar(15),address1 varchar(10),name1 varchar(10), flag16 int
go

update PLACER2015_FINAL_UNUSED_V2
set address0=left(address,15),name0=left(name,15),address1=left(address,10),name1=left(name,10)
--8028

update placer2016_merged0
set unused=2,infousaid15=b.infousaid,name15=b.name,address15=b.address
from placer2016_merged0 a, PLACER2015_FINAL_UNUSED_V2 b
where a.infousaid=b.infousaid and
      a.name0=b.name0 and
	  a.address0=b.address0 and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null and unused is null
--19

update placer2016_merged0
set unused=3,infousaid15=b.infousaid,name15=b.name,address15=b.address
from placer2016_merged0 a, PLACER2015_FINAL_UNUSED_V2 b
where a.infousaid=b.infousaid and
      a.name1=b.name1 and
	  a.address1=b.address1 and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null and unused is null
--12

--select *
--from PLACER2015_FINAL_UNUSED_V2
--where address like 'PO BOX%'
--2153

drop table placer2016_merged0_unused

select *
into placer2016_merged0_unused
from placer2016_merged0
where unused is not null 
--1274


delete from placer2016_merged0
where unused is not null
--1274 records; they may or may not be duplicates


drop table placer2016_merged0_dup0

select name,address, count(*) as counts 
into placer2016_merged0_dup0
from placer2016_merged0
group by name,address
order by count(*) desc
--167 records have 204 duplicates

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
--362

drop table placer2016_emp0

--identify the unique records
select *
into placer2016_emp0
from placer2016_merged0
where dup is null
--26996 records

drop table placer2016_emp0a

select *
into placer2016_emp0a
from placer2016_merged0
where dup >=2 
--362

--=====================================
--create a blank table with all the variables 
create table placer2016_emp0b
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


INSERT INTO placer2016_emp0 (infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815)
SELECT infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815
FROM placer2016_emp0b
--169

--flag the records in 2016 that are filtered out by 2015 unused

update placer2015_final_unused_v2
set flag16=1
from placer2015_final_unused_v2 a, placer2016_merged0_unused b
where a.name=b.name and a.address=b.address and b.unused>=1
--1250

select *
from placer2015_final_unused_v2

select *
from placer2016_emp0

--END OF CLEANING
--finished on 08/12/2016


select *
from placer2016_emp0
where name like '%school%'

select *
from placer2015_final
where name='STAR SCHOOL'

