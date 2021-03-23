
--This script combines 2008 and 2012 employment inventory by matching company name and address
--Inventory2008:2008 employment inventory; imported from P:\Employment Inventory\Employment 2012\2012\files for review\FinalReview\sacramento.xlsx
--Inventory2012:2012 employment inventory; imported from P:\Employment Inventory\Employment 2012\2012\files for review\FinalReview\sacramento.xlsx
--database name: SacEMP1

--clean duplicates
--4 duplicate records found: two objectid12 but one infousaid12 and one infouseid08
DELETE FROM Inventory2012
WHERE OBJECTID12='85760' OR OBJECTID12='85758' OR OBJECTID12='85759' OR OBJECTID12='85756'

DELETE FROM Inventory2008
WHERE objectid08='17747' or objectid08='42925' or objectid08='33915' or objectid08='37149' or
      objectid08='14675' or objectid08='25091' or objectid08='4675' or objectid08='25286' or
      objectid08='44436' or objectid08='20041' or objectid08='44428' or objectid08='17008' or
      objectid08='39577' or objectid08='44426' 


--flag company12 at the same ST_NUM and INFOUSAID as 2008 but different ST_NAME and ADDRESS due to two different 
--methods to code the ST_NAME (with # in 2012)
--==
SELECT     Inventory2012.*, Inventory2008.OBJECTID08, Inventory2008.INFOUSAID08, Inventory2008.COMMENT08, Inventory2008.ST_NUM08, Inventory2008.ST_NAME08,Inventory2008.ADDRESS08, 
                      Inventory2008.CITY08, Inventory2008.ZIP_COD08, Inventory2008.COMPANY08, Inventory2008.EMP08, Inventory2008.SOURCE08, Inventory2008.NAICS08,Inventory2008.NAICS_D08
INTO Inventory2012And2008a
FROM         Inventory2008 RIGHT OUTER JOIN
                      Inventory2012 ON Inventory2008.INFOUSAID08 = Inventory2012.INFOUSAID12 AND Inventory2008.ST_NUM08 = Inventory2012.ST_NUM12 AND 
                      Inventory2008.COMPANY08 = Inventory2012.COMPANY12

ALTER TABLE Inventory2012And2008a
ADD Note12 nvarchar(20)

UPDATE Inventory2012And2008a
SET Note12='2008 and 2012'
WHERE OBJECTID08 IS NOT NULL
--Inventory2012And2008a includes all 2012 records and those companies (19214) with the same name and address
--checked and no mismatches and duplicates were found.

--==
--flag address12 with company08;company12<>company08 at the same address
SELECT *
INTO Inventory2012And2008a1
FROM Inventory2012And2008a
WHERE Note12 is null

--exclude Note12='2008 and 2012' from Inventory2008
SELECT OBJECTID08, Note12
INTO Flag2008
FROM  Inventory2012And2008a
WHERE Note12='2008 and 2012'

SELECT     Inventory2008.*, Flag2008.Note12
INTO Inventory2008Flag2008
FROM         Flag2008 RIGHT OUTER JOIN
                      Inventory2008 ON Flag2008.OBJECTID08 = Inventory2008.OBJECTID08

--remove '2008 and 2012' records from Inventory2008
SELECT     OBJECTID08, INFOUSAID08, COMMENT08, ST_NUM08, ST_NAME08, ADDRESS08, CITY08, ZIP_COD08, COMPANY08, EMP08, SOURCE08, NAICS08, 
                      NAICS_D08
INTO Inventory2008Flag2008a
FROM         Inventory2008Flag2008
WHERE Note12 is null

--due to many-to-one and one-to-many crosswalk between 2008 and 2012, duplicates of objectid12 and objectid08 were created.
--total duplicates=11265
SELECT     Inventory2012And2008a1.*, Inventory2008Flag2008a.OBJECTID08 AS Expr1, Inventory2008Flag2008a.INFOUSAID08 AS Expr2, 
                      Inventory2008Flag2008a.COMMENT08 AS Expr3, Inventory2008Flag2008a.ST_NUM08 AS Expr4, Inventory2008Flag2008a.ST_NAME08 AS Expr5, 
                      Inventory2008Flag2008a.ADDRESS08 AS Expr6, Inventory2008Flag2008a.CITY08 AS Expr7, Inventory2008Flag2008a.ZIP_COD08 AS Expr8, 
                      Inventory2008Flag2008a.COMPANY08 AS Expr9, Inventory2008Flag2008a.EMP08 AS Expr10, Inventory2008Flag2008a.SOURCE08 AS Expr11, 
                      Inventory2008Flag2008a.NAICS08 AS Expr12, Inventory2008Flag2008a.NAICS_D08 AS Expr13
INTO Inventory2012And2008a2
FROM         Inventory2012And2008a1 LEFT OUTER JOIN
                      Inventory2008Flag2008a ON Inventory2012And2008a1.ADDRESS12 = Inventory2008Flag2008a.ADDRESS08                 

UPDATE Inventory2012And2008a2
SET [OBJECTID08]=Expr1,[INFOUSAID08]=Expr2,[ST_NUM08]=Expr4,[ST_NAME08]=Expr5,[ADDRESS08]=Expr6,[CITY08]=Expr7,
    [ZIP_COD08]=Expr8,[COMPANY08]=Expr9,[EMP08]=Expr10,[SOURCE08]=Expr11,[NAICS08]=Expr12,[NAICS_D08]=Expr13

ALTER TABLE Inventory2012And2008a2
DROP COLUMN Expr1,Expr2,Expr3,Expr4,Expr5,Expr6,Expr7,Expr8,Expr9,Expr10,Expr11,Expr12,Expr13

--2012A=2012 address; all 2012 records are labelled and some 2008 records are labelled.
UPDATE Inventory2012And2008a2
SET Note12='2012A'

--select Note12='2008 and 2012'
SELECT *
INTO Inventory2012And2008b
FROM Inventory2012And2008a
WHERE Note12='2008 and 2012'

--combine Note12='2008 and 2012' and '2012A'
--this table includes all 2012 recrods but only 31425 2008 records
INSERT INTO Inventory2012And2008b ([OBJECTID12],[INFOUSAID12],[COMMENT12],[ST_NUM12],[ST_NAME12],[ADDRESS12]
      ,[CITY12],[ZIP_COD12],[COMPANY12],[EMP12],[SOURCE12],[NAICS12],[NAICS_D12],[COUNTY],[OBJECTID08]
      ,[INFOUSAID08],[COMMENT08],[ST_NUM08],[ST_NAME08],[ADDRESS08],[CITY08],[ZIP_COD08],[COMPANY08],[EMP08]
      ,[SOURCE08],[NAICS08],[NAICS_D08],[Note12])
SELECT [OBJECTID12],[INFOUSAID12],[COMMENT12],[ST_NUM12],[ST_NAME12],[ADDRESS12]
      ,[CITY12],[ZIP_COD12],[COMPANY12],[EMP12],[SOURCE12],[NAICS12],[NAICS_D12],[COUNTY],[OBJECTID08]
      ,[INFOUSAID08],[COMMENT08],[ST_NUM08],[ST_NAME08],[ADDRESS08],[CITY08],[ZIP_COD08],[COMPANY08],[EMP08]
      ,[SOURCE08],[NAICS08],[NAICS_D08],[Note12]
FROM Inventory2012And2008a2


SELECT OBJECTID08,IN2012=1
INTO OBJECTID08IN2012
FROM Inventory2012And2008b
GROUP BY OBJECTID08

SELECT     Inventory2008.*, OBJECTID08IN2012.IN2012
INTO Inventory2008a
FROM         Inventory2008 LEFT OUTER JOIN
                      OBJECTID08IN2012 ON Inventory2008.OBJECTID08 = OBJECTID08IN2012.OBJECTID08

--select those records exist only in 2008;
SELECT *
INTO Inventory2008b
FROM Inventory2008a
WHERE IN2012 IS NULL

--append Inventory2008b to Inventory2012And2008b to create a table including all 2008 and 2012 recrods
SELECT *
INTO Inventory2012And2008c
FROM Inventory2012And2008b

INSERT INTO Inventory2012And2008c ([COUNTY],[OBJECTID08]
      ,[INFOUSAID08],[COMMENT08],[ST_NUM08],[ST_NAME08],[ADDRESS08],[CITY08],[ZIP_COD08],[COMPANY08],[EMP08]
      ,[SOURCE08],[NAICS08],[NAICS_D08])
SELECT [COUNTY],[OBJECTID08]
      ,[INFOUSAID08],[COMMENT08],[ST_NUM08],[ST_NAME08],[ADDRESS08],[CITY08],[ZIP_COD08],[COMPANY08],[EMP08]
      ,[SOURCE08],[NAICS08],[NAICS_D08]
FROM Inventory2008b


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--to validate the script of this database
--make 2012 records only table
SELECT DISTINCT [OBJECTID12],[INFOUSAID12],[COMMENT12],[ST_NUM12],[ST_NAME12],[ADDRESS12]
      ,[CITY12],[ZIP_COD12],[COMPANY12],[EMP12],[SOURCE12],[NAICS12],[NAICS_D12],[COUNTY]
INTO Inventory2012only
FROM Inventory2012And2008c
WHERE Note12='2012A' or Note12='2008 and 2012'

--make 2008 records only table
SELECT DISTINCT [OBJECTID08],[INFOUSAID08],[COMMENT08],[ST_NUM08],[ST_NAME08],[ADDRESS08]
      ,[CITY08],[ZIP_COD08],[COMPANY08],[EMP08],[SOURCE08],[NAICS08],[NAICS_D08],[COUNTY]
INTO Inventory2008only
FROM Inventory2012And2008c

SELECT sum(emp08)
FROM Inventory2008only

SELECT sum(emp08)
FROM Inventory2008

SELECT sum(emp12)
FROM Inventory2012only

SELECT sum(emp12)
FROM Inventory2012
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SELECT *
FROM Inventory2012And2008c
--WHERE NOTE12 IS NULL AND ADDRESS08 LIKE '6855 Fair Oaks Blvd%'
WHERE COMPANY08='Software Automation Tech Group' OR COMPANY12='Software Automation Tech Group'

SELECT *
FROM Inventory2012And2008c
WHERE ADDRESS12 LIKE '6855 Fair Oaks Blvd%' --FAIR OAKS BLVD
ORDER BY ST_NUM12
