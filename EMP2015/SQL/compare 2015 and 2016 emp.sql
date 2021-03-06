
select *
into [PLACER2015_FINAL0]
from [PLACER2015_FINAL]
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


--+++++++++++++++++++++++++++++++++++++++++++++++
alter table [PLACER2015_FINAL]
drop column match,emp16

alter table [PLACER2015_FINAL]
add match int,emp16 int

alter table [PLACER2015_FINAL]
add address0 varchar (15),name0 varchar(15),address1 varchar (10),name1 varchar(10),match int, EMP16 int

alter table [PLACER2016_rawdata1]
add address0 varchar (15),name0 varchar(15),address1 varchar (10),name1 varchar(10)

alter table [PLACER2016_rawdata2]
add address0 varchar (15),name0 varchar(15),address1 varchar (10),name1 varchar(10)

--this is adopted to deal with issues such as suite 100 or #100 in name and address 
--longer names and address improve accuracy but may exclude shorter names
update [PLACER2015_FINAL]
set address0=LEFT(address,15),name0=left(name,15)

--short names and address
update [PLACER2015_FINAL]
set address1=LEFT(address,10),name1=left(name,10)

update [PLACER2016_rawdata1]
set address0=LEFT(address,15),name0=left(name,15)

--short names and address
update [PLACER2016_rawdata2]
set address1=LEFT(address,10),name1=left(name,10)

update [PLACER2016_rawdata2]
set address0=LEFT(address,15),name0=left(name,15)

--short names and address 
update [PLACER2016_rawdata1]
set address1=LEFT(address,10),name1=left(name,10)



--++++++++++++++++++++++++++++++++++++++++++++++++++++
--match address and name in placer2016_rawdata1
update PLACER2015_FINAL
set match=1,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where a.infousaid=b.infousaid and a.address=b.address AND a.name=b.name
-- 9946 out of 14358

--match address0 and name0 in placer2016_rawdata1
update PLACER2015_FINAL
set match=2,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--171 records; eyeballed check and correct

--match address1 and name1 in placer2016_rawdata1
--some records have short company name and address and are excluded by address1 and name1
update PLACER2015_FINAL
set match=3,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--62 records; eyeballed check and correct

--match the records with the same infousaid, name, and address by PO BOX in placer2016_rawdata1
--update PLACER2015_FINAL
--set match=4,emp15=b.emp15
--from PLACER2015_FINAL a, [placer2016_rawdata1] b
--where a.infousaid=b.infousaid and a.name0=b.name0 and a.city=b.city and a.match is null  and b.address like 'PO BOX%'
--0, PO BOX was fixed

update PLACER2015_FINAL
set match=5,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--54 records; eyeballed check and correct

update PLACER2015_FINAL
set match=6,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--12 records; eyeballed check and correct

update PLACER2015_FINAL
set match=7,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where (a.address=b.address AND a.name=b.name and a.match is null) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match is null) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
-- 275 records; eyeballed check and correct

update PLACER2015_FINAL
set match=8,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata1] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--191
--
--match address and name in placer2016_rawdata2
update PLACER2015_FINAL
set match=11,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and a.address=b.address AND a.name=b.name
-- 7238 out of 14358

--match address0 and name0 in placer2016_rawdata2
update PLACER2015_FINAL
set match=12,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and a.address0=b.address0 AND a.name0=b.name0 and a.match is null
--120 records; eyeballed check and correct

--match address1 and name1 in placer2016_rawdata2
--some records have short company name and address and are excluded by address1 and name1
update PLACER2015_FINAL
set match=13,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and a.address1=b.address1 AND a.name1=b.name1 and a.match is null
--5 records; eyeballed check and correct

--match the records with the same infousaid, name, and address by PO BOX in placer2016_rawdata2
update PLACER2015_FINAL
set match=14,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and a.name0=b.name0 and a.city=b.city and a.match is null  and b.address like 'PO BOX%'
--0

update PLACER2015_FINAL
set match=15,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and a.address2=b.address2 AND a.name2=b.name2 and a.match is null
--1 records; eyeballed check and correct

update PLACER2015_FINAL
set match=16,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and a.address3=b.address3 AND a.name3=b.name3 and a.match is null
--5 records; eyeballed check and correct

update PLACER2015_FINAL
set match=17,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where (a.address=b.address AND a.name=b.name and a.match is null) or 
      (a.address0=b.address0 AND a.name0=b.name0 and a.match is null ) or
	  (a.address1=b.address1 AND a.name1=b.name1 and a.match is null) or 
	  (a.address2=b.address2 AND a.name2=b.name2 and a.match is null)
-- 52 records; eyeballed check and correct

update PLACER2015_FINAL
set match=18,emp15=b.emp15
from PLACER2015_FINAL a, [placer2016_rawdata2] b
where a.infousaid=b.infousaid and (a.name=b.name or a.name0=b.name0 or a.name1=b.name1 or
      a.name2=b.name2 or a.name3=b.name3) and a.match is null
--58


select *
from PLACER2015_FINAL
--where match is null and infousaid=0
where  infousaid=0
