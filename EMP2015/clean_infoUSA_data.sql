--this script is developed to streamline employment inventory update
--03/23/2016
--Shengyi Gao

--sacxab_15_AllRecVar is merged from sacxa001 (verified) and sacxb001(unverified) in SPSS
--it includes all records and variables in the raw data
--note:the variable is cut to 10 digit in dbf; it is better to rename it in SPSS
--verified: V=verified, U=unverified
--total records:227602

USE EMP_INVENTORY
GO

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SELECT DISTINCT INFOUSAID
FROM sacxab_15_unique_records_0
--unique infousaid:162429

select distinct company_na
from sacxab_15_unique_records_0
--unique company names:139171

select distinct company_na,infousaid
from sacxab_15_unique_records_0
--unique records by company name and infousaid:162511

select infousaid,count(company_na) as namecount
from sacxab_15_unique_records_0
group by infousaid
order by namecount desc
--110 records do not have an infousaid
--some records have only one infousaid but many company names
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--identify duplicates: step 1
--unique records in terms of all variables:227558
select distinct *
into sacxab_15_unique_records_0
from sacxab_15_AllRecVar

--identify duplicates: step 2
--records:162524
--credit_S_A causes the duplicate
select company_na as CName,
       primary_AD as PAddress,
	   primary_ci as City,
	   primary_st as state,
	   primary_zi as zipcode,
	   county_nam as county,
	   longitude,
	   latitude,
	   primary_si as SIC,
	   NAICS_CODE as NAICS8,
	   NAICS_DESC,
	   ACTUAL_LOC as EMP,
	   modeled_em as ModeledEMP,
	   infousaID,
	   infousasub,
	   infousapar,
	   site_numbe as SiteNumber,
	   HQ_branch as HQB_code,
	   HQ_branc_a as HQB_desc,
	   individual as indi_code,
	   individu_a as indi_desc,
	   year_SIC_a as year_SIC,
	   credit_sco as CScoreCode,
	   actual_cre as CScore,
	   office_siz as off_size,
	   office_S_A as off_desc,
	   population as pop_size,
	   populati_a as pop_desc,
	   work_at_ho as workhome,
	   own_lease as Own_rent,
	   square_foo as sq_ft_code,
	   square_f_a as sq_ft_desc,
	   verified,
	   count(*) as counts
into sacxab_15_unique_records_1
from sacxab_15_unique_records_0
group by company_na,
       primary_AD,
	   primary_ci,
	   primary_st,
	   primary_zi,
	   county_nam,
	   longitude,
	   latitude,
	   primary_si,
	   NAICS_CODE,
	   NAICS_DESC,
	   ACTUAL_LOC,
	   modeled_em,
	   infousaID,
	   infousasub,
	   infousapar,
	   site_numbe,
	   HQ_branch,
	   HQ_branc_a,
	   individual,
	   individu_a,
	   year_SIC_a,
	   credit_sco,
	   actual_cre,
	   office_siz,
	   office_S_A,
	   population,
	   populati_a,
	   work_at_ho,
	   own_lease,
	   square_foo,
	   square_f_a,
	   verified


--identify duplicates: step 3
--unique records in terms of name,address,longitude,latitude,jobs,and naics (8 digit)
--records:162517
-credit_S_A causes the duplicate
select distinct CName,PAddress, City,state,zipcode,county,
	   longitude,latitude,SIC,NAICS8,NAICS_DESC, EMP,ModeledEMP,
	   infousaID,infousasub,infousapar,SiteNumber, HQB_code,HQB_desc,workhome,verified
into sacxab_15_unique_records_3
from sacxab_15_unique_records_1

--identify duplicates: step 4
--records: 134866
select CName,PAddress, longitude,latitude,NAICS8, EMP,
	   infousaID,verified
into sacxab_15_unique_records_4     --used as the base to build 2015 base
from sacxab_15_unique_records_3
where emp is not null --and cname like '%ATM%'
group by  CName,PAddress, 
	   longitude,latitude,NAICS8, EMP,
	   infousaID
--"emp is null" is meaningless to this inventory
--Bank ATM machines were excluded.


--identify duplicates: step 5
--records:133592
--duplicates caused by different NAICS8, EMP,infousaID
--some records have the same cname,longitude, and latitude but have a paddress and a null paddress
select CName,longitude,latitude,
	   count(*) as counts
--into sacxab_15_unique_records_5
from sacxab_15_unique_records_4
group by CName, longitude,latitude
order by counts desc,cname

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--create a blank table with all the variables in sacxab_15_unique_records_4
create table sac_emp_15_0
      ([CName] varchar(30)
      ,[PAddress] varchar(30)
      ,[longitude] float
      ,[latitude] float
      ,[NAICS8] varchar(8)
      ,[EMP] float
      ,[infousaID] float)

--run the cursor to insert unique records in sacxab_15_unique_records_4 into sac_emp_15_0
DECLARE @cname varchar(30),
        @paddress varchar(30),
        @longitude float,
        @latitude float,
        @counts int

TRUNCATE TABLE sac_emp_15_0

DECLARE loop1 SCROLL CURSOR FOR SELECT cname,longitude,latitude,counts FROM sacxab_15_unique_records_5 FOR READ ONLY
OPEN loop1
FETCH loop1 INTO @cname,@longitude,@latitude,@counts
WHILE @@FETCH_STATUS = 0
 	BEGIN
 		IF @counts > 1
 			INSERT INTO sac_emp_15_0 SELECT top 1 * FROM sacxab_15_unique_records_4 WHERE cname = @cname AND longitude = @longitude AND latitude = @latitude ORDER BY emp DESC
 		ELSE
 			INSERT INTO sac_emp_15_0 SELECT * FROM sacxab_15_unique_records_4 WHERE cname = @cname AND longitude = @longitude AND latitude = @latitude
	  FETCH loop1 INTO @cname,@longitude,@latitude,@counts
 	END
CLOSE loop1
DEALLOCATE loop1
--records:133592


alter table sac_emp_15_0
add SACOGID bigint

declare @SACOGID bigint=0
update sac_emp_15_0
set @SACOGID=SACOGID=@SACOGID+1

alter table sac_emp_15_0
add County varchar(10),city varchar(16),zipcode float
go

update sac_emp_15_0
set county=b.county,city=b.city,zipcode=b.zipcode
from sac_emp_15_0 a,sacxab_15_unique_records_3 b
where a.cname=b.cname and a.longitude=b.longitude and a.latitude=b.latitude
--42403 records do not have a city name
--1 record does not have zipcode
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
select *
--into sac_emp_15_0_yuba
from sac_emp_15_0
where county='Yuba'
order by cname

select sum(emp)as emp
from sac_emp_15_0_yuba

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--repeat the steps above to get unique records for 2016
--compare 2015 and 2016 through a cursor






select *
from sacxab_15_unique_records_3
where cname='PACIFIC GAS & ELECTRIC CO'


select *
from sacxab_15_unique_records_1
where cname='WHACKY QUACKY MOTION DECOYS'


select *
from sac_emp_15_0_yuba
where cname='WHACKY QUACKY MOTION DECOYS'






select *
from sac_emp_15_0
where city is null
order by paddress



select *
from sac_emp_15_0
where cname='PACIFIC GAS & ELECTRIC CO'

select *
from sacxab_15_unique_records_0
where infousaid=426898184




select *
from sacxab_15_unique_records_0
where company_na='ATM'

--identify duplicates: step 6
--duplicate records:843
select *
into sacxab_15_unique_records_6
from sacxab_15_unique_records_5
where counts >1
order by cname


--flag duplicates
alter table sacxab_15_unique_records_5
add duplicate int
Go

update sacxab_15_unique_records_5
set duplicate=0   --0=unique record, 1=at least 1 duplicate

--887 records were updated
--including paddress lead to more flag records; eyeball check shows it is correct
update sacxab_15_unique_records_5
set duplicate=1
from sacxab_15_unique_records_5 a,
     sacxab_15_unique_records_6 b
where a.cname=b.cname and
--      a.paddress=b.paddress and
	  a.longitude=b.longitude and 
	  a.latitude=b.latitude

--flag duplicates in sacxab_15_unique_records_3
alter table sacxab_15_unique_records_3
--drop column counts,duplicate
add counts int,duplicate int
go

update sacxab_15_unique_records_3
set duplicate=b.duplicate,counts=b.counts
from sacxab_15_unique_records_3 a,
     sacxab_15_unique_records_5 b
where a.cname=b.cname and
     -- a.paddress=b.paddress and
	  a.longitude=b.longitude and 
	  a.latitude=b.latitude and b.duplicate=1 
--unique records 160658 (not really unique, cname has duplidate records or meaningless records
--for example, Union Bank ATM; duplicate records 1859
--a lot of company have unique company names and infousaid and do not have addresses. these companies
--are given the same longitude and latitude


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
select paddress,longitude,latitude,count(cname) as cname
from sacxab_15_unique_records_3
where duplicate is null
group by paddress,longitude,latitude
order by cname desc


select *
from sacxab_15_unique_records_0
where  company_na ='TERRA LITE INC'
order by company_na




--56 records
select cname,paddress,longitude,latitude,duplicate,counts
--into sacxab_15_unique_records_7
from sacxab_15_unique_records_3
where duplicate=1 and counts=1
order by cname


drop table temp8
select *
into temp8
from sacxab_15_unique_records_3
where duplicate is null 
order by cname

select  cname,paddress,longitude,latitude,count(*) as counts
from temp8
group by cname,paddress,longitude,latitude
order by counts desc

select *
from sacxab_15_unique_records_3
order by counts desc
where cname='AKSEEZ DESIGN'

select *
from temp7
where cname='AKSEEZ DESIGN'

select cname,longitude,latitude,count(counts) as counts
--into sacxab_15_unique_records_7
from sacxab_15_unique_records_7
group by cname,longitude,latitude
order by cname,longitude,latitude

select *
from sacxab_15_unique_records_5
where duplicate=1
order by cname
where duplicate=1

 and counts=1
--where cname='A BRIGHTER CHILD HOMESCHOOL'

select distinct cname,paddress,longitude,latitude,duplicate,counts
from sacxab_15_unique_records_3
where duplicate=1 and counts=1
order by cname
where cname='DIAGNOSTIC PATHOLOGY MED GROUP'



select *
from sacxab_15_unique_records_3
where cname = 'ANOTHER CHOICE ANOTHER CHANCE'

select company_na as CName,primary_AD as PAddress,NAICS_CODE as NAICS8,ACTUAL_LOC as EMP,
from sacxab_15_AllRecVar

