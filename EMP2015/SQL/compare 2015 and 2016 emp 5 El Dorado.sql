
--08/31/2016
--standard procedures
--replace "sacramento" with a county name
======================================================================
drop table eldorado2016_rawdata1
drop table eldorado2016_rawdata2
drop table eldorado2015_final

--exclude primary key from original files
select infousaid,name,address,city,state,zip,county,latitude,longitude,saddress,scity,sstate,szip,naics8,naics_desc,
       emp16,year_established,work_at_home,sfootage_code,sfootage_desc
into eldorado2016_rawdata1
from eldorado2016_rawdata10

select infousaid,name,address,city,state,zip,county,latitude,longitude,saddress,scity,sstate,szip,naics8,naics_desc,
       emp16,year_established,work_at_home,sfootage_code,sfootage_desc
into eldorado2016_rawdata2
from eldorado2016_rawdata20

select *
into eldorado2015_final
from eldorado2015_final0

alter table eldorado2015_final
add infousaid int
go

update eldorado2015_final
set infousaid=infousa_id

--
alter table eldorado2016_rawdata1
add naddress varchar(100), source16 varchar(15),naics4 varchar(4),naics2 varchar(2),address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5),match int, verified int,
	infousaid15 int,name15 varchar(50),address15 varchar(50),naddress15 varchar(100),source15 varchar(15),emp15 int,naics815 int
go

alter table eldorado2016_rawdata2
add naddress varchar(100), source16 varchar(15),naics4 varchar(4),naics2 varchar(2),address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5),match int, verified int,
	infousaid15 int,name15 varchar(50),address15 varchar(50),naddress15 varchar(100),source15 varchar(15),emp15 int,naics815 int
go

alter table eldorado2015_final
add match int, naddress varchar(100), emp16 int, address0 varchar(15),name0 varchar(15),address1 varchar(10),name1 varchar(10),
    address2 varchar(5),name2 varchar(5),address3 varchar(5),name3 varchar(5)
go

--
update eldorado2016_rawdata1
set address=saddress
where address like 'PO BOX%'
--

update eldorado2016_rawdata2
set address=saddress
where address like 'PO BOX%'
--

update eldorado2016_rawdata1
set verified=1, naics4=left(naics8,4),naics2=left(naics8,2)

update eldorado2016_rawdata2
set verified=2, naics4=left(naics8,4),naics2=left(naics8,2)



--++++++++++++++++++++++++++++++++++++++++
--save the deleted records
drop table eldorado2016_rawdata1_pobox

select *
into eldorado2016_rawdata1_pobox
from eldorado2016_rawdata1
where address like 'PO BOX%'
--

drop table eldorado2016_rawdata2_pobox

select *
into eldorado2016_rawdata2_pobox
from eldorado2016_rawdata2
where address like 'PO BOX%'
--

--delete records address like 'PO BOX%'
delete from eldorado2016_rawdata1
where address like 'PO BOX%'
--

delete from eldorado2016_rawdata2
where address like 'PO BOX%'
--
--++++++++++++++++++++++++++++++++++++++++++++
update eldorado2016_rawdata1
set naddress=address + ' ' + city + ' ' + state + ' ' + cast (zip as varchar(5))

update eldorado2016_rawdata1
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3),
	naics4=left(naics8,4),
	naics2=left(naics8,2),
	source16='INFOUSA'
--

update eldorado2016_rawdata2
set naddress=address + ' ' + city + ' ' + state + ' ' + cast (zip as varchar(5))

update eldorado2016_rawdata2
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3),
	naics4=left(naics8,4),
	naics2=left(naics8,2),
	source16='INFOUSA'
--

update eldorado2015_final
set naddress=address + ' ' + city + ' ' + 'CA' + ' ' + cast (zip as varchar(5))

update eldorado2015_final
set address0=left(naddress,15),name0=left(name,15),
    address1=left(naddress,10),name1=left(name,10),
	address2=left(naddress, 5),name2=left(name, 5),
    address3=left(naddress, 3),name3=left(name, 3)
--

--match address and name in eldorado2016_rawdata1
update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=1
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name
--  out of 13871

--match address0 and name0 in eldorado2016_rawdata1
update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=2
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
-- records; eyeball checked and correct

--match address1 and name1 in eldorado2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=3
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
-- records; eyeball checked and correct

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=4
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
-- records; eyeball checked and correct

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=5
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
-- records; eyeball checked and correct

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=6
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null)
--

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=7
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--  

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
-- 

update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=8
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
-- 


--flag the business with relocation
update eldorado2016_rawdata1
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=9
from eldorado2016_rawdata1 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--

--match address and name in eldorado2016_rawdata2
update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=11
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name
-- 

--match address0 and name0 in eldorado2016_rawdata2
update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=12
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--

--match address1 and name1 in eldorado2016_rawdata2
--some records have short company name and address and are excluded by address1 and name1
update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=13
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
-- 

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=14
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=15
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=16
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where (a.address=b.address AND a.name=b.name and a.match is null)
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=17
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--

update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=18
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--

--flag the business with relocation
update eldorado2016_rawdata2
set infousaid15=b.infousaid,name15=b.name,address15=b.address,naics815=b.naics_code,naddress15=b.naddress,
    source15=b.source,emp15=b.emp15,match=19
from eldorado2016_rawdata2 a, [eldorado2015_FINAL] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--

alter table eldorado2015_FINAL
drop column match

alter table eldorado2015_FINAL
add match int
go

--match address and name in [eldorado2015_FINAL]
--update match in eldorado2015_final to identify those records from non-infousa source and no matches in 2016
update [eldorado2015_FINAL]
set match=1
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name and a.match is null
--

update [eldorado2015_FINAL]
set match=2
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--

update [eldorado2015_FINAL]
set match=3
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--

update [eldorado2015_FINAL]
set match=4
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--

update [eldorado2015_FINAL]
set match=5
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--

update [eldorado2015_FINAL]
set match=6
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.address=b.address AND a.name=b.name and a.match is null
--

update [eldorado2015_FINAL]
set match=7
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update [eldorado2015_FINAL]
set match=8
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update [eldorado2015_FINAL]
set match=8
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--

update [eldorado2015_FINAL]
set match=8
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--

update [eldorado2015_FINAL]
set match=8
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--

update [eldorado2015_FINAL]
set match=9
from [eldorado2015_FINAL] a, eldorado2016_rawdata1 b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--

update [eldorado2015_FINAL]
set match=11
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.infousaid=b.infousaid and a.naddress=b.naddress AND a.name=b.name and a.match is null
--

update [eldorado2015_FINAL]
set match=12
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--

update [eldorado2015_FINAL]
set match=13
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--

update [eldorado2015_FINAL]
set match=14
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--

update [eldorado2015_FINAL]
set match=15
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--

update [eldorado2015_FINAL]
set match=16
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.address=b.address AND a.name=b.name and a.match is null
--

update [eldorado2015_FINAL]
set match=17
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) 
--

update [eldorado2015_FINAL]
set match=18
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where (a.address1=b.address1 AND a.name1=b.name1 and a.match is null)
--

update [eldorado2015_FINAL]
set match=18
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
--

update [eldorado2015_FINAL]
set match=18
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where (a.address0=b.address0 AND a.name3=b.name3 and a.match is null)
--

update [eldorado2015_FINAL]
set match=18
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where (a.address1=b.address1 AND a.name3=b.name3 and a.match is null)
--

update [eldorado2015_FINAL]
set match=19
from [eldorado2015_FINAL] a, eldorado2016_rawdata2 b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--



--merge 2016 two data files
drop table eldorado2016_merged0

select *
into eldorado2016_merged0
from eldorado2016_rawdata1


insert into eldorado2016_merged0 (infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815)
select infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815
from eldorado2016_rawdata2
--several dozens of records have the same name and address but different infousaid and naics code in eldorado2016_rawdata1 and 
--eldorado2016_rawdata2


--add Tina's special cases (737) to 2016 
--select *
--from eldorado2015_FINAL
--where match is null and infousaid=0   --737
--where  infousaid=0   --789


--insert 2015 unique records 
insert into eldorado2016_merged0 (infousaid, NAME,ADDRESS,CITY,ZIP,
            naics8,naics_desc,emp15,address0,name0,address1,name1,address2,name2,address3,name3,
			naddress15,source15)
select infousaid, CAST([NAME] AS VARCHAR(50)) AS NAME,CAST([ADDRESS] AS VARCHAR(50)) AS ADDRESS,CAST([CITY] AS VARCHAR(20)) AS CITY,[ZIP],
       [NAICS_code],CAST([NAICS_DESC] AS VARCHAR(50)) AS NAICS_DESC,[EMP15],address0,name0,address1,name1,address2,name2,address3,name3,
	   naddress,CAST(source AS VARCHAR(15)) AS source15
from eldorado2015_final
WHERE infousaid=0 and match is null


UPDATE eldorado2016_merged0
set verified=0
where verified is null
--0=those records from SACOG15 and other sources

--++++++++++++++++++++++++++++++++++++++++++

--identify duplicates
--select name,address,count(*) as counts
--from eldorado2016_merged0
--where name='sacramento MEDICAL FOUNDATION' and address= '10470 OLD PLACERVILLE RD # 1'
--group by name,address
--order by count(*) desc
-- records have multiple counts


--remove duplicates by using unused records in 2015
--alter table eldorado2016_merged0
--drop column unused
--go

alter table eldorado2016_merged0
add unused int
go

update eldorado2016_merged0
set unused=1,infousaid15=b.infousaid,name15=b.name,address15=b.address
from eldorado2016_merged0 a, eldorado2015_FINAL_UNUSED b
where a.infousaid=b.infousaid and
      a.name=b.name and
	  a.address=b.address and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null
--163

alter table eldorado2015_FINAL_UNUSED
add address0 varchar(15), name0 varchar(15),address1 varchar(10),name1 varchar(10), flag16 int
go

update eldorado2015_FINAL_UNUSED
set address0=left(address,15),name0=left(name,15),address1=left(address,10),name1=left(name,10)
--986

update eldorado2016_merged0
set unused=2,infousaid15=b.infousaid,name15=b.name,address15=b.address
from eldorado2016_merged0 a, eldorado2015_FINAL_UNUSED b
where a.infousaid=b.infousaid and
      a.name0=b.name0 and
	  a.address0=b.address0 and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null and a.unused is null
--3

update eldorado2016_merged0
set unused=3,infousaid15=b.infousaid,name15=b.name,address15=b.address
from eldorado2016_merged0 a, eldorado2015_FINAL_UNUSED b
where a.infousaid=b.infousaid and
      a.name1=b.name1 and
	  a.address1=b.address1 and
	  a.city=b.city and 
	  a.zip=b.zip and a.match is null and unused is null
--2

--select *
--from eldorado2015_FINAL_UNUSED
--where address like 'PO BOX%'
--

drop table eldorado2016_merged0_unused

select *
into eldorado2016_merged0_unused
from eldorado2016_merged0
where unused is not null 
--168


delete from eldorado2016_merged0
where unused is not null
--168 records;


drop table eldorado2016_merged0_dup0

select name,address, count(*) as counts 
into eldorado2016_merged0_dup0
from eldorado2016_merged0
group by name,address
order by count(*) desc
--

drop table eldorado2016_merged0_dup0a

SELECT *
INTO eldorado2016_merged0_dup0a
FROM eldorado2016_merged0_dup0
WHERE COUNTS>1

alter table eldorado2016_merged0
add dup int
go

update eldorado2016_merged0
set dup=b.counts
from eldorado2016_merged0 a
left outer join eldorado2016_merged0_dup0a b on
     a.name=b.name and a.address=b.address

drop table eldorado2016_merged0_dup1

select *
into eldorado2016_merged0_dup1
from eldorado2016_merged0
where dup>=2
order by name,address
--105

drop table eldorado2016_emp0

--identify the unique records
select *
into eldorado2016_emp0
from eldorado2016_merged0
where dup is null
--5152 records

drop table eldorado2016_emp0a

select *
into eldorado2016_emp0a
from eldorado2016_merged0
where dup >=2 
--105

--=====================================
--create a blank table with all the variables 
drop table eldorado2016_emp0b

create table eldorado2016_emp0b
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

TRUNCATE TABLE eldorado2016_emp0b

DECLARE loop1 SCROLL CURSOR FOR SELECT name,address,counts FROM eldorado2016_merged0_dup0a FOR READ ONLY
OPEN loop1
FETCH loop1 INTO @name,@address,@counts
WHILE @@FETCH_STATUS = 0
 	BEGIN
 		IF @counts > 1
 			INSERT INTO eldorado2016_emp0b SELECT top 1 * FROM eldorado2016_emp0a WHERE name = @name AND address = @address ORDER BY match,verified,emp16 DESC
 		ELSE
 			INSERT INTO eldorado2016_emp0b SELECT * FROM eldorado2016_emp0a WHERE name = @name AND address = @address
	  FETCH loop1 INTO @name,@address,@counts
    END
CLOSE loop1
DEALLOCATE loop1


INSERT INTO eldorado2016_emp0 (infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815)
SELECT infousaid, NAME,ADDRESS,CITY,state,ZIP,county,LATITUDE,LONGITUDE
      ,saddress,scity,sstate,szip,NAICS8,NAICS_DESC,EMP16,year_established,work_at_home,sfootage_code,sfootage_desc,
	  naddress,source16, naics4,naics2,address0,name0,address1,name1,address2,name2,address3,name3,match,verified,
	  infousaid15,name15,address15,naddress15,source15,emp15,naics815
FROM eldorado2016_emp0b
--49

--flag the records in 2016 that are filtered out by 2015 unused

update eldorado2015_FINAL_UNUSED
set flag16=1
from eldorado2015_FINAL_UNUSED a, eldorado2016_merged0_unused b
where a.name=b.name and a.address=b.address and b.unused>=1
--164

drop table flag_eldorado2015_name_address

--flag dupllicate name15 and address15
select name15, address15,count(*) as dupname15
into flag_eldorado2015_name_address
from eldorado2016_emp0
where name15 is not null 
group by name15,address15
order by count(*) desc,name15,address15

alter table eldorado2016_emp0
add dupname15 int
go

update eldorado2016_emp0
set dupname15=b.dupname15
from eldorado2016_emp0 a,flag_eldorado2015_name_address b
where a.name15=b.name15 and a.address15=b.address15 and b.dupname15>1
--275

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


select *
from eldorado2016_emp0

select *
from ELDORADO2015_FINAL_UNUSED

select *
from eldorado2016_emp0
where dupname15 is not null
order by name15,name,address

--END OF CLEANING
--finished on 08/12/2016





