
--This script combines 2008 and 2012 employment inventory by matching company name and address
--Inventory2008:2008 employment inventory; imported from 
--Inventory2012:2012 employment inventory; imported from 
--database name: RegionEMP1

--No duplicates are found
SELECT infousaid08,address08,company08,count(*) as num
FROM Inventory2008_yub
GROUP BY infousaid08,address08,company08
ORDER BY NUM desc

--No duplicates were found
SELECT infousaid12,address12,company12,count(*) as num
FROM Inventory2012_yub
GROUP BY infousaid12,address12,company12
ORDER BY NUM desc

--flag company12 at the same ST_NUM and INFOUSAID as 2008 but different ST_NAME and ADDRESS due to two different 
--methods to code the ST_NAME (with # in 2012)
--==

SELECT     Inventory2012_yub.Target_FID12,Inventory2012_yub.INFOUSAID12, Inventory2012_yub.COMPANY12, Inventory2012_yub.EMP12, Inventory2012_yub.ADDRESS12, Inventory2012_yub.NAICS12, 
                      Inventory2012_yub.NAICS_D12, Inventory2012_yub.ST_NUM12, Inventory2012_yub.ST_NAME12,  Inventory2012_yub.PIDSTR08, 
                      Inventory2012_yub.PID_2005, Inventory2008_yub.Target_FID08,Inventory2008_yub.INFOUSAID08, Inventory2008_yub.COMPANY08, Inventory2008_yub.EMP08, Inventory2008_yub.ADDRESS08, 
                      Inventory2008_yub.NAICS08, Inventory2008_yub.NAICS_D08, Inventory2008_yub.ST_NUM08, Inventory2008_yub.ST_NAME08, Inventory2008_yub.CITY08, 
                      Inventory2008_yub.ZIP08
INTO Inventory2012And2008a_yub
FROM         Inventory2008_yub RIGHT OUTER JOIN
                      Inventory2012_yub ON Inventory2008_yub.INFOUSAID08 = Inventory2012_yub.INFOUSAID12 AND Inventory2008_yub.ST_NUM08 = Inventory2012_yub.ST_NUM12


ALTER TABLE Inventory2012And2008a_yub
ADD Note12 nvarchar(20)

UPDATE Inventory2012And2008a_yub
SET Note12='2008 and 2012'
WHERE INFOUSAID08 IS NOT NULL
--Inventory2012And2008a includes all 2012 records and those companies (19214) with the same name and address
--checked and no mismatches and duplicates were found.

--==
--flag address12 with company08;company12<>company08 at the same address
SELECT *
INTO Inventory2012And2008a1_yub
FROM Inventory2012And2008a_yub
WHERE Note12 is null

--exclude Note12='2008 and 2012' from Inventory2008
SELECT INFOUSAID08, Note12
INTO Flag2008_yub
FROM  Inventory2012And2008a_yub
WHERE Note12='2008 and 2012'

SELECT     Inventory2008_yub.*, Flag2008_yub.Note12
INTO Inventory2008Flag2008_yub
FROM         Flag2008_yub RIGHT OUTER JOIN
                      Inventory2008_yub ON Flag2008_yub.INFOUSAID08 = Inventory2008_yub.INFOUSAID08

--remove '2008 and 2012' records from Inventory2008
SELECT    Target_FID08,INFOUSAID08,COMPANY08,EMP08,ADDRESS08,NAICS08,NAICS_D08,ST_NUM08, ST_NAME08, CITY08, ZIP08                     
INTO Inventory2008Flag2008a_yub
FROM         Inventory2008Flag2008_yub
WHERE Note12 is null

--due to many-to-one and one-to-many crosswalk between 2008 and 2012, duplicates of objectid12 and objectid08 were created.
--total duplicates=11265
SELECT     Inventory2012And2008a1_yub.*,Inventory2008Flag2008a_yub.Target_FID08 AS Expr1,Inventory2008Flag2008a_yub.INFOUSAID08 AS Expr2, Inventory2008Flag2008a_yub.COMPANY08 AS Expr3, 
                      Inventory2008Flag2008a_yub.EMP08 AS Expr4, Inventory2008Flag2008a_yub.ADDRESS08 AS Expr5, Inventory2008Flag2008a_yub.NAICS08 AS Expr6, 
                      Inventory2008Flag2008a_yub.NAICS_D08 AS Expr7, Inventory2008Flag2008a_yub.ST_NUM08 AS Expr8, Inventory2008Flag2008a_yub.ST_NAME08 AS Expr9, 
                      Inventory2008Flag2008a_yub.CITY08 AS Expr10, Inventory2008Flag2008a_yub.ZIP08 AS Expr11
INTO Inventory2012And2008a2_yub
FROM         Inventory2008Flag2008a_yub RIGHT OUTER JOIN
                      Inventory2012And2008a1_yub ON Inventory2008Flag2008a_yub.ADDRESS08 = Inventory2012And2008a1_yub.ADDRESS12

UPDATE Inventory2012And2008a2_yub
SET [Target_FID08]=Expr1,[INFOUSAID08]=Expr2,[COMPANY08]=Expr3,[EMP08]=Expr4,[ADDRESS08]=Expr5,[NAICS08]=Expr6,[NAICS_D08]=Expr7,
    [ST_NUM08]=Expr8,[ST_NAME08]=Expr9,[CITY08]=Expr10,[ZIP08]=Expr11


ALTER TABLE Inventory2012And2008a2_yub
DROP COLUMN Expr1,Expr2,Expr3,Expr4,Expr5,Expr6,Expr7,Expr8,Expr9,Expr10,Expr11

--2012A=2012 address; all 2012 records are labelled and some 2008 records are labelled.
UPDATE Inventory2012And2008a2_yub
SET Note12='2012A'

--select Note12='2008 and 2012'
SELECT *
INTO Inventory2012And2008b_yub
FROM Inventory2012And2008a_yub
WHERE Note12='2008 and 2012'

--combine Note12='2008 and 2012' and '2012A'
--this table includes all 2012 recrods but only 31425 2008 records
INSERT INTO Inventory2012And2008b_yub ([Target_FID12],[INFOUSAID12],[COMPANY12],[EMP12],[ADDRESS12],[NAICS12],[NAICS_D12],[ST_NUM12],[ST_NAME12]
,[PIDSTR08],[PID_2005],[Target_FID08],[INFOUSAID08],[COMPANY08],[EMP08],[ADDRESS08],[NAICS08]
,[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08],[ZIP08],[Note12])
SELECT [Target_FID12],[INFOUSAID12],[COMPANY12],[EMP12],[ADDRESS12],[NAICS12],[NAICS_D12],[ST_NUM12],[ST_NAME12]
,[PIDSTR08],[PID_2005],[Target_FID08],[INFOUSAID08],[COMPANY08],[EMP08],[ADDRESS08],[NAICS08]
,[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08],[ZIP08],[Note12]
FROM Inventory2012And2008a2_yub

SELECT Target_FID08,IN2012=1
INTO Target_FID08IN2012_yub
FROM Inventory2012And2008b_yub
GROUP BY Target_FID08

SELECT     Inventory2008_yub.*, Target_FID08IN2012_yub.IN2012
INTO Inventory2008a_yub
FROM         Inventory2008_yub LEFT OUTER JOIN
                      Target_FID08IN2012_yub ON Inventory2008_yub.Target_FID08 = Target_FID08IN2012_yub.Target_FID08

--select those records exist only in 2008;
SELECT *,Note12=''
INTO Inventory2008b_yub
FROM Inventory2008a_yub
WHERE IN2012 IS NULL

--append Inventory2008b to Inventory2012And2008b to create a table including all 2008 and 2012 recrods
SELECT *
INTO Inventory2012And2008c_yub
FROM Inventory2012And2008b_yub

INSERT INTO Inventory2012And2008c_yub ([Target_FID08],[INFOUSAID08]
,[COMPANY08],[EMP08],[ADDRESS08],[NAICS08],[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08]
,[ZIP08],[Note12])
SELECT [Target_FID08],[INFOUSAID08]
,[COMPANY08],[EMP08],[ADDRESS08],[NAICS08],[NAICS_D08],[ST_NUM08],[ST_NAME08],[CITY08]
,[ZIP08],[Note12]
FROM Inventory2008b_yub


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--to validate the script of this database
--make 2012 records only table
SELECT DISTINCT [Target_FID12],[INFOUSAID12],[COMPANY12],[EMP12],[ADDRESS12],[NAICS12],[NAICS_D12]
,[ST_NUM12],[ST_NAME12],[PIDSTR08],[PID_2005]
INTO Inventory2012only_yub
FROM Inventory2012And2008c_yub
WHERE Note12='2012A' or Note12='2008 and 2012'

--make 2008 records only table
SELECT DISTINCT [Target_FID08],[INFOUSAID08],[COMPANY08],[EMP08],[ADDRESS08],[NAICS08],[NAICS_D08],
[ST_NUM08],[ST_NAME08],[CITY08],[ZIP08]
INTO Inventory2008only_yub
FROM Inventory2012And2008c_yub

SELECT sum(emp08)
FROM Inventory2008only_yub

SELECT sum(emp08)
FROM Inventory2008_yub

SELECT sum(emp12)
FROM Inventory2012only_yub

SELECT sum(emp12)
FROM Inventory2012_yub
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

