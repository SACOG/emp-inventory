"""
Name: emp_inv_sql2esri_fc.py
Purpose: Export SQL Server employment inventory table to ESRI feature class.

    NOTE - Darren wrote this script because for some reason, if you export SQL to CSV
    then load the CSV to GIS, the non-zero dupe_flag values become null, which should not
    happen. This scripts fixes that by loading SQL table to pandas df, then exporting df 
    to ESRI feature class.
        
          
Author: Darren Conly
Last Updated: June 2021
Updated by: <name>
Copyright:   (c) SACOG
Python Version: 3.x
"""
from time import perf_counter as perf

import pandas as pd
import urllib
import arcpy
from arcgis.features import GeoAccessor 

import sqlalchemy as sqla # needed to run pandas df.to_sql() function
    
# extract SQL Server query results into a pandas dataframe   
def sqlqry_to_df(query_str, dbname, servername='SQL-SVR', trustedconn='yes'):     

    conn_str = "DRIVER={ODBC Driver 17 for SQL Server};" \
        f"SERVER={servername};" \
        f"DATABASE={dbname};" \
        f"Trusted_Connection={trustedconn}"
        
    conn_str = urllib.parse.quote_plus(conn_str)
    engine = sqla.create_engine(f"mssql+pyodbc:///?odbc_connect={conn_str}")
       
    start_time = perf()

    # create SQL table from the dataframe
    print("Executing query. Results loading into dataframe...")
    df = pd.read_sql_query(sql=query_str, con=engine)
    rowcnt = df.shape[0]
    
    et_mins = round((perf() - start_time) / 60, 2)
    print(f"Successfully executed query in {et_mins} minutes. {rowcnt} rows loaded into dataframe.")
    
    return df



def convert_cats2strings(in_df):
    '''Categorical column data types create issues for exporting DFs to spatial data types,
    so here we convert them to strings'''
    
    df_dtypes = in_df.dtypes 
    for cname in df_dtypes.index:
        if df_dtypes[cname].name == 'category':
            in_df[cname] = in_df[cname].astype('str')
            
def export_pointgeo_to_fc(in_df, out_fc_path, fld_lon, fld_lat):
    '''export the resulting dataframe directly to the GIS FGDB you are mapping from'''
    
    arcpy.env.overwriteOutput = True
    convert_cats2strings(in_df)
    
    
    sdf = GeoAccessor.from_xy(in_df, fld_lon, fld_lat)
    sdf.spatial.to_featureclass(out_fc_path)

    print(f"successfully exported to feature class {out_fc_path}")
    



if __name__ == '__main__':
    
    #==========Make dataframe from SQL Server query========
    db = 'EMP2020'
    
    output_fc = r'I:\Projects\Darren\EmpInventory\EmploymentInventory.gdb\TEST_EmpInvGISFlags_20210603'
    qry = '''SELECT  [CONAME]
      ,[LOCNUM]
      ,[SITE]
      ,[STADDR]
      ,[STCITY]
      ,[STATE]
      ,[ZIP]
      ,[HOME]
      ,[LOCEMP]
      ,[FULTYP]
      ,[latitude]
      ,[longitude]
      ,[geo_level]
      ,[naics4]
      ,[latlon_uid]
      ,[coname16]
      ,[staddr16]
      ,[emp16]
      ,[notes16]
      ,[infoid16]
      ,[join_flag]
      ,[ZIP_geom]
      ,[LUTYPE16]
      ,[res_nwfh_f]
      ,[sch_tbl_name]
      ,[sch_tbl_name_fscore]
      ,[sch_tbl_addr]
      ,[sch_tbl_addr_fscore]
      ,[dupe_flag]
  FROM [EMP2020].[dbo].[SACOG_Jan_2020_wFlags_final_noschFilter]
  '''
    
    tdf = sqlqry_to_df(qry, db)
    
    export_pointgeo_to_fc(tdf, output_fc, 'longitude', 'latitude')
    
    
    
        
    
    