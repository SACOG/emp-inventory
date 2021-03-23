
--flag company08 by name and address
SELECT address08,company08,flag1=1
INTO company08_flag1
FROM sacEMP.dbo.Inventory2008
GROUP BY address08,company08

--flag company08 by name only
SELECT company08,flag2=2
INTO company08_flag2
FROM sacEMP.dbo.Inventory2008
GROUP BY company08

UPDATE sacEMP.dbo.Inventory2012
SET Notes12='2012U'

--flag company08 in Inventory2012
SELECT     Inventory2012.*, company08_flag1.flag1, company08_flag2.flag2
INTO	sacEMP.dbo.Inventory2012a
FROM         Inventory2012 LEFT OUTER JOIN
                      company08_flag2 ON Inventory2012.COMPANY12 = company08_flag2.company08 LEFT OUTER JOIN
                      company08_flag1 ON Inventory2012.ADDRESS12 = company08_flag1.address08 AND Inventory2012.COMPANY12 = company08_flag1.company08
--flag company12 with the same company name and address in Inventory2008               
UPDATE sacEMP.dbo.Inventory2012a
SET Notes12='2008 and 2012'
WHERE flag1=1
--flag company12 with the same company name but different addresses in Inventory2008               
UPDATE sacEMP.dbo.Inventory2012a
SET Notes12='2012U2008'
WHERE flag2=2 and flag1 is null

--flag company12 by name and address
SELECT address12,company12,flag3=3
INTO company12_flag3
FROM sacEMP.dbo.Inventory2012
GROUP BY address12,company12

--flag company08 by name only
SELECT company12,flag4=4
INTO company12_flag4
FROM Inventory2012
GROUP BY company12

--flag company12 in Inventory2008
SELECT     Inventory2008.*, company12_flag3.flag3, company12_flag4.flag4
INTO	sacEMP.dbo.Inventory2008a
FROM         Inventory2008 LEFT OUTER JOIN
                      company12_flag4 ON Inventory2008.COMPANY08 = company12_flag4.company12 LEFT OUTER JOIN
                      company12_flag3 ON Inventory2008.ADDRESS08 = company12_flag3.address12 AND Inventory2008.COMPANY08 = company12_flag3.company12

ALTER TABLE sacEMP.dbo.Inventory2008a
ADD Notes08 nvarchar(20)

UPDATE sacEMP.dbo.Inventory2008a
SET Notes08='2008U'

UPDATE sacEMP.dbo.Inventory2008a
SET Notes08='2008 and 2012'
WHERE flag3=3

UPDATE sacEMP.dbo.Inventory2008a
SET Notes08='2008U2012'
WHERE flag4=4 and flag3 is null

--companies appear in 2012 at least once;some of them have the same name as those flag1
SELECT company08,count(company08)AS countcomp08
INTO countcompany2008U2012
FROM sacEMP.dbo.Inventory2008a
WHERE Notes08='2008U2012'
GROUP BY company08
--companies appear in 2008 at least once;some of them have the same name as those flag3
SELECT company12,count(company12)AS countcomp12
INTO countcompan2012U2008
FROM sacEMP.dbo.Inventory2012a
WHERE Notes12='2012U2008'
GROUP BY company12

--flag company08 with countcomp08
SELECT     Inventory2008a.*, countcompany2008U2012.countcomp08
INTO sacEMP.dbo.Inventory2008b
FROM         Inventory2008a LEFT OUTER JOIN
                      countcompany2008U2012 ON Inventory2008a.COMPANY08 = countcompany2008U2012.company08

--exclude those records flag3=3; in both inventory2008 and inventory2012
UPDATE sacEMP.dbo.Inventory2008b
SET countcomp08=0
WHERE flag3=3

--select those records whose company name only appears once in 2012
SELECT *
INTO sacEMP.dbo.Inventory2008c
FROM  sacEMP.dbo.Inventory2008b
WHERE countcomp08=1

--select those records whose company name  appears at least 2 times in 2012
SELECT *
INTO sacEMP.dbo.Inventory2008d
FROM  sacEMP.dbo.Inventory2008b
WHERE countcomp08>1

--
SELECT     countcompan2012U2008.company12, countcompan2012U2008.countcomp12, countcompany2008U2012.countcomp08
INTO sacEMP.dbo.countcompan2012U2008a
FROM         countcompan2012U2008 LEFT OUTER JOIN
                      countcompany2008U2012 ON countcompan2012U2008.company12 = countcompany2008U2012.company08

--if countcomp12>=1 and countcomp08 is null,company12 has net increase of establishments with that name (421 net increases)
SELECT company12,countcomp12
INTO sacEMP.dbo.countcompan2012U2008b
FROM sacEMP.dbo.countcompan2012U2008a
WHERE countcomp08 is null

--if countcomp12=countcomp08=1, that company appeared in 2008 and 2012 once at different address
SELECT company12,countcomp12,countcomp08
INTO sacEMP.dbo.countcompan2012U2008c1
FROM sacEMP.dbo.countcompan2012U2008a
WHERE countcomp12=countcomp08

--if countcomp12>1 and countcomp08> and countcomp12=countcomp08, company12 and company08 have the same counts of establishments
--at different places
SELECT company12,countcomp12,countcomp08
INTO sacEMP.dbo.countcompan2012U2008c2
FROM sacEMP.dbo.countcompan2012U2008a
WHERE (countcomp12=countcomp08) and (countcomp12>=2 and countcomp08>=2)

--if countcomp12>coountcomp08, more company12 than company08;
SELECT company12,countcomp12,countcomp08
INTO sacEMP.dbo.countcompan2012U2008d
FROM sacEMP.dbo.countcompan2012U2008a
WHERE countcomp12>countcomp08

--if countcomp12<coountcomp08, less company12 than company08;
SELECT company12,countcomp12,countcomp08
INTO sacEMP.dbo.countcompan2012U2008e
FROM sacEMP.dbo.countcompan2012U2008a
WHERE countcomp12<countcomp08

 --BACKUP
 SELECT *
 INTO [sacEMP].[dbo].[Inventory2012a0]
 FROM [sacEMP].[dbo].[Inventory2012a]  
 
 SELECT     Inventory2008c.OBJECTID08, Inventory2008c.INFOUSAID08, Inventory2008c.COMMENT08, Inventory2008c.ST_NUM08, Inventory2008c.ST_NAME08, 
                      Inventory2008c.ADDRESS08, Inventory2008c.CITY08, Inventory2008c.ZIP_COD08, Inventory2008c.COMPANY08, Inventory2008c.EMP08, Inventory2008c.SOURCE08, 
                      Inventory2008c.NAICS08, Inventory2008c.NAICS_D08, Inventory2008c.COUNTY, Inventory2008c.flag3, Inventory2008c.flag4, countcompan2012U2008c1.countcomp12, 
                      countcompan2012U2008c1.countcomp08
INTO [sacEMP].[dbo].Inventory2008cc1
FROM         Inventory2008c LEFT OUTER JOIN
                      countcompan2012U2008c1 ON Inventory2008c.COMPANY08 = countcompan2012U2008c1.company12
--select company08 appearing only once in 2008 and 2012
SELECT *
INTO [sacEMP].[dbo].Inventory2008cc2
FROM [sacEMP].[dbo].Inventory2008cc1
WHERE countcomp12=1 and countcomp08=1

--flag company08 appearing only once in 2008 and 2012
SELECT     Inventory2012a.*, Inventory2008cc2.OBJECTID08, Inventory2008cc2.INFOUSAID08, Inventory2008cc2.COMMENT08, Inventory2008cc2.ST_NUM08, 
                      Inventory2008cc2.ST_NAME08, Inventory2008cc2.ADDRESS08, Inventory2008cc2.CITY08, Inventory2008cc2.ZIP_COD08, Inventory2008cc2.COMPANY08, 
                      Inventory2008cc2.EMP08, Inventory2008cc2.SOURCE08, Inventory2008cc2.NAICS08, Inventory2008cc2.NAICS_D08, Inventory2008cc2.flag3, Inventory2008cc2.flag4, 
                      Inventory2008cc2.countcomp12, Inventory2008cc2.countcomp08
INTO [sacEMP].[dbo].Inventory2012b
FROM         Inventory2012a LEFT OUTER JOIN
                      Inventory2008cc2 ON Inventory2012a.COMPANY12 = Inventory2008cc2.COMPANY08

--create a subset with flag3=3 and flag4=4
SELECT [OBJECTID08],[INFOUSAID08],[COMMENT08],[ST_NUM08],[ST_NAME08],[ADDRESS08],[CITY08],[ZIP_COD08],
      [COMPANY08],[EMP08],[SOURCE08],[NAICS08],[NAICS_D08],[COUNTY],[flag3],[flag4],[Notes08],[countcomp08]     
INTO [sacEMP].[dbo].[Inventory2008b1]
FROM [sacEMP].[dbo].[Inventory2008b]
WHERE flag3=3 and flag4=4
--[Inventory2008b1]has 14 duplicate records
DELETE FROM [sacEMP].[dbo].[Inventory2008b1]
WHERE objectid08='17747' or objectid08='42925' or objectid08='33915' or objectid08='37149' or
      objectid08='14675' or objectid08='25091' or objectid08='4675' or objectid08='25286' or
      objectid08='44436' or objectid08='20041' or objectid08='44428' or objectid08='17008' or
      objectid08='39577' or objectid08='44426' 


--join [Inventory2008b1] to update 2008 attributes
SELECT     Inventory2012b.*, Inventory2008b1.OBJECTID08 AS Expr1, Inventory2008b1.INFOUSAID08 AS Expr2, Inventory2008b1.COMMENT08 AS Expr3, 
                      Inventory2008b1.ST_NUM08 AS Expr4, Inventory2008b1.ST_NAME08 AS Expr5, Inventory2008b1.ADDRESS08 AS Expr6, Inventory2008b1.CITY08 AS Expr7, 
                      Inventory2008b1.ZIP_COD08 AS Expr8, Inventory2008b1.COMPANY08 AS Expr9, Inventory2008b1.EMP08 AS Expr10, Inventory2008b1.SOURCE08 AS Expr11, 
                      Inventory2008b1.NAICS08 AS Expr12, Inventory2008b1.NAICS_D08 AS Expr13, Inventory2008b1.COUNTY AS Expr14, Inventory2008b1.flag3 AS Expr15, 
                      Inventory2008b1.flag4 AS Expr16, Inventory2008b1.Notes08, Inventory2008b1.countcomp08 AS Expr17
INTO [sacEMP].[dbo].Inventory2012c
FROM         Inventory2012b LEFT OUTER JOIN
                      Inventory2008b1 ON Inventory2012b.COMPANY12 = Inventory2008b1.COMPANY08 AND Inventory2012b.ADDRESS12 = Inventory2008b1.ADDRESS08

UPDATE [sacEMP].[dbo].Inventory2012c
SET [OBJECTID08]=Expr1,[INFOUSAID08]=Expr2,[ST_NUM08]=Expr4,[ST_NAME08]=Expr5,[ADDRESS08]=Expr6,[CITY08]=Expr7,
    [ZIP_COD08]=Expr8,[COMPANY08]=Expr9,[EMP08]=Expr10,[SOURCE08]=Expr11,[NAICS08]=Expr12,[NAICS_D08]=Expr13
WHERE flag1=1
              
ALTER TABLE [sacEMP].[dbo].Inventory2012c
DROP COLUMN Notes08,Expr1,Expr2,Expr3,Expr4,Expr5,Expr6,Expr7,Expr8,Expr9,Expr10,Expr11,Expr12,Expr13,Expr14,Expr15,Expr16,Expr17

--
SELECT     Inventory2012c.OBJECTID12, Inventory2012c.INFOUSAID12, Inventory2012c.ST_NUM12, Inventory2012c.ST_NAME12, Inventory2012c.ADDRESS12, 
                      Inventory2012c.COMPANY12, Inventory2012c.CITY12, Inventory2012c.flag1, Inventory2012c.flag2, Inventory2008b.OBJECTID08, Inventory2008b.INFOUSAID08, 
                      Inventory2008b.COMMENT08, Inventory2008b.ST_NUM08, Inventory2008b.ST_NAME08, Inventory2008b.ADDRESS08, Inventory2008b.CITY08, 
                      Inventory2008b.ZIP_COD08, Inventory2008b.COMPANY08, Inventory2008b.EMP08, Inventory2008b.SOURCE08, Inventory2008b.NAICS08, 
                      Inventory2008b.NAICS_D08, Inventory2008b.flag3, Inventory2008b.flag4, Inventory2008b.Notes08, Inventory2008b.countcomp08
INTO T1
FROM         Inventory2012c INNER JOIN
                      Inventory2008b ON Inventory2012c.ST_NUM12 = Inventory2008b.ST_NUM08 AND Inventory2012c.INFOUSAID12 = Inventory2008b.INFOUSAID08

SELECT *
FROM T1
WHERE flag1 is null
                   
--append Inventory2008c1 to inventory2012a
--append Inventory2008e to inventory2012a
--append Inventory2008d1 to inventory2012a
--append Inventory2008d2 to inventory2012a


select *
from sacEMP.dbo.Inventory2008a
where company08='CHIPOTLE MEXICAN GRILL'

select *
from sacEMP.dbo.Inventory2012a
where company12='CHIPOTLE MEXICAN GRILL'













