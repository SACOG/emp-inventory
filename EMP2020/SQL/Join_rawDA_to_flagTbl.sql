/*
Name: Join_rawDA_to_flagTbl.sql
Purpose: Join the raw Data Axle employment inventory table to tables containing a variety of
	flags to help QA and clean the raw data. The query should clearly show which columns are added.
           
Author: Darren Conly
Last Updated: May 2021
Updated by: <name>
Copyright:   (c) SACOG
SQL Flavor: SQL Server
*/


--may need to set data types for LOCNUM ID field to be same in order to match on join
--ALTER TABLE [dbo].[EmpInvDupeFlag_All_20210504_ZIP_LU]
--ADD locnum2 INT

--UPDATE [dbo].[EmpInvDupeFlag_All_20210504_ZIP_LU]
--SET locnum2 = ROUND(locnum,0)



SELECT
	r.*,
    f.naics4,
    f.dupe_flag,
    f.latlon_uid,
    f.coname16,
    f.staddr16,
    f.emp16,
    f.notes16,
    f.infoid16,
    f.join_flag,
    f.ZIP_geom,
    f.LUTYPE16,
    f.res_nwfh_f,
	sf.stbl_name AS sch_tbl_name,
	sf.stbl_name_fscore AS sch_tbl_name_fscore,
	sf.stbl_addr AS sch_tbl_addr,
	sf.stbl_addr_fscore AS sch_tbl_addr_fscore
INTO SACOG_Jan_2020_wFlags_final
FROM SACOG_Jan_2020 r
	JOIN EmpInvDupeFlag_All_20210504_ZIP_LU f
		ON f.locnum2 = r.locnum
	LEFT JOIN school_flags sf
		ON r.locnum = sf.locnum




