
--This script combines 2008 and 2012 employment inventory by matching company name and address
--Inventory2008:2008 employment inventory; imported from 
--Inventory2012:2012 employment inventory; imported from 
--database name: RegionEMP1

--2 duplicates are found
SELECT infousa_id,address,count(*) as num
FROM Inventory2008_eld
GROUP BY infousa_id,address
ORDER BY NUM desc

SELECT *
FROM Inventory2008_eld
WHERE infousa_id='104644109                                         ' 

DELETE FROM Inventory2008_ELD
WHERE TARGET_FID='5289'

SELECT *
FROM Inventory2008_eld
WHERE ADDRESS='7900 Shingle Springs Rd                                                                                                                                                                                                                                       '

DELETE FROM Inventory2008_ELD
WHERE TARGET_FID='5302'

--flag company12 at the same ST_NUM and INFOUSAID as 2008 but different ST_NAME and ADDRESS due to two different 
--methods to code the ST_NAME (with # in 2012)
--==

SELECT     Inventory2012_eld.Target_FID12,Inventory2012_eld.INFOUSAID12, Inventory2012_eld.COMPANY12, Inventory2012_eld.EMP12, Inventory2012_eld.ADDRESS12, Inventory2012_eld.NAICS12, 
                      Inventory2012_eld.NAICS_D12, Inventory2012_eld.ST_NUM12, Inventory2012_eld.ST_NAME12, Inventory2012_eld.SOURCE12, Inventory2012_eld.PIDSTR08, 
                      Inventory2012_eld.PID_2005, Inventory2008_eld.Target_FID08,Inventory2008_eld.INFOUSAID08, Inventory2008_eld.COMPANY08, Inventory2008_eld.EMP08, Inventory2008_eld.ADDRESS08, 
                      Inventory2008_eld.NAICS08, Inventory2008_eld.NAICS_D08, Inventory2008_eld.ST_NUM08, Inventory2008_eld.ST_NAME08, Inventory2008_eld.CITY08, 
                      Inventory2008_eld.ZIP08
INTO Inventory2012And2008a_eld
FROM         Inventory2008_eld RIGHT OUTER JOIN
                      Inventory2012_eld ON Inventory2008_eld.INFOUSAID08 = Inventory2012_eld.INFOUSAID12 AND Inventory2008_eld.ST_NUM08 = Inventory2012_eld.ST_NUM12


ALTER TABLE Inventory2012And2008a_eld
ADD Note12 nvarchar(20)

UPDATE Inventory2012And2008a_eld
SET Note12='2008 and 2012'
WHERE INFOUSAID08 IS NOT NULL
--Inventory2012And2008a includes all 2012 records and those companies (19214) with the same name and address
--checked and no mismatches and duplicates were found.

--==
--flag address12 with company08;company12<>company08 at the same address
SELECT *
INTO Inventory2012And2008a1_eld
FROM Inventory2012And2008a_eld
WHERE Note12 is null

--exclude Note12='2008 and 2012' from Inventory2008
SELECT INFOUSAID08, Note12
INTO Flag2008_eld
FROM  Inventory2012And2008a_eld
WHERE Note12='2008 and 2012'

SELECT     Inventory2008_eld.*, Flag2008_eld.Note12
INTO Inventory2008Flag2008_eld
FROM         Flag2008_eld RIGHT OUTER JOIN
                      Inventory2008_eld ON Flag2008_eld.INFOUSAID08 = Inventory2008_eld.INFOUSAID08

--remove '2008 and 2012' records from Inventory2008
SELECT    Target_FID08,INFOUSAID08,COMPANY08,EMP08,ADDRESS08,NAICS08,NAICS_D08,ST_NUM08, ST_NAME08, CITY08, ZIP08                     
INTO Inventory2008Flag2008a_eld
FROM         Inventory2008Flag2008_eld
WHERE Note12 is null

--due to many-to-one and one-to-many crosswalk between 2008 and 2012, duplicates of objectid12 and objectid08 were created.
--total duplicates=11265
SELECT     Inventory2012And2008a1_eld.*,Inventory2008Flag2008a_eld.Target_FID08 AS Expr1,Inventory2008Flag2008a_eld.INFOUSAID08 AS Expr2, Inventory2008Flag2008a_eld.COMPANY08 AS Expr3, 
                      Inventory2008Flag2008a_eld.EMP08 AS Expr4, Inventory2008Flag2008a_eld.ADDRESS08 AS Expr5, Inventory2008Flag2008a_eld.NAICS08 AS Expr6, 
                      Inventory2008Flag2008a_eld.NAICS_D08 AS Expr7, Inventory2008Flag2008a_eld.ST_NUM08 AS Expr8, Inventory2008Flag2008a_eld.ST_NAME08 AS Expr9, 
                      Inventory2008Flag2008a_eld.CITY08 AS Expr10, Inventory2008Flag2008a_eld.ZIP08 AS Expr11
INTO Inventory2012And2008a2_eld
FROM         Inventory2008Flag2008a_eld RIGHT OUTER JOIN
                      Inventory2012And2008a1_eld ON Inventory2008Flag2008a_eld.ADDRESS08 = Inventory2012And2008a1_eld.ADDRESS12

UPDATE Inventory2012And2008a2_eld
SET [Target_FID08]=Expr1,[INFOUSAID08]=Expr2,[COMPANY08]=Expr3,[EMP08]=Expr4,[ADDRESS08]=Expr5,[NAICS08]=Expr6,[NAICS_D08]=Expr7,
    [ST_NUM08]=Expr8,[ST_NAME08]=Expr9,[CITY08]=Expr10,[ZIP08]=Expr11


ALTER TABLE Inventory2012And2008a2_eld
DROP COLUMN Expr1,Expr2,Expr3,Expr4,Expr5,Expr6,Expr7,Expr8,Expr9,Expr10,Expr11

--2012A=2012 address; all 2012 records are labelled and some 2008 records are labelled.
UPDATE Inventory2012And2008a2_eld
SET Note12='2012A'

--select Note12='2008 and 2012'
SELECT *
INTO Inventory2012And2008b_eld
FROM Inventory2012And2008a_eld
WHERE Note12='2008 and 2012'

--combine Note12='2008 and 2012' and '2012A'
--this table includes all 2012 recrods but only 31425 2008 records
INSERT INTO Inventory2012And2008b_eld ([Target_FID12],[INFOUSAID12],[COMPANY12],[EMP12],[ADDRESS12],[NAICS12],[NAICS_D12],[ST_NUM12],[ST_NAME12]
,[SOURCE12],[PIDSTR08],[PID_2005],[Target_FID08],[INFOUSAID08],[COMPANY08],[EMP08],[ADDRESS08],[NAICS08]
,[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08],[ZIP08],[Note12])
SELECT [Target_FID12],[INFOUSAID12],[COMPANY12],[EMP12],[ADDRESS12],[NAICS12],[NAICS_D12],[ST_NUM12],[ST_NAME12]
,[SOURCE12],[PIDSTR08],[PID_2005],[Target_FID08],[INFOUSAID08],[COMPANY08],[EMP08],[ADDRESS08],[NAICS08]
,[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08],[ZIP08],[Note12]
FROM Inventory2012And2008a2_eld

SELECT Target_FID08,IN2012=1
INTO Target_FID08IN2012_eld
FROM Inventory2012And2008b_eld
GROUP BY Target_FID08

SELECT     Inventory2008_eld.*, Target_FID08IN2012_eld.IN2012
INTO Inventory2008a_eld
FROM         Inventory2008_eld LEFT OUTER JOIN
                      Target_FID08IN2012_eld ON Inventory2008_eld.Target_FID08 = Target_FID08IN2012_eld.Target_FID08

--select those records exist only in 2008;
SELECT *,Note12=''
INTO Inventory2008b_eld
FROM Inventory2008a_eld
WHERE IN2012 IS NULL

--append Inventory2008b to Inventory2012And2008b to create a table including all 2008 and 2012 recrods
SELECT *
INTO Inventory2012And2008c_eld
FROM Inventory2012And2008b_eld

INSERT INTO Inventory2012And2008c_eld ([Target_FID08],[INFOUSAID08]
,[COMPANY08],[EMP08],[ADDRESS08],[NAICS08],[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08]
,[ZIP08],[Note12])
SELECT [Target_FID08],[INFOUSAID08]
,[COMPANY08],[EMP08],[ADDRESS08],[NAICS08],[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08]
,[ZIP08],[Note12]
FROM Inventory2008b_eld


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--to validate the script of this database
--make 2012 records only table
SELECT DISTINCT [Target_FID12],[INFOUSAID12],[COMPANY12],[EMP12],[ADDRESS12],[NAICS12],[NAICS_D12]
,[ST_NUM12],[ST_NAME12],[SOURCE12],[PIDSTR08],[PID_2005]
INTO Inventory2012only_eld
FROM Inventory2012And2008c_eld
WHERE Note12='2012A' or Note12='2008 and 2012'

--make 2008 records only table
SELECT DISTINCT [Target_FID08],[INFOUSAID08],[COMPANY08],[EMP08],[ADDRESS08],[NAICS08],[NAICS_D08],
[ST_NUM08],[ST_NAME08],[CITY08],[ZIP08]
INTO Inventory2008only_eld
FROM Inventory2012And2008c_eld

SELECT sum(emp08)
FROM Inventory2008only_eld

SELECT sum(emp08)
FROM Inventory2008_eld

SELECT sum(emp12)
FROM Inventory2012only_eld

SELECT sum(emp12)
FROM Inventory2012_eld
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

