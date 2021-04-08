"""
Name: raw_data_cleanup_plevel.py
Purpose: For businesses with *parcel-level* (not ZIP-code level) geographic accuracy,
    Take in the raw Data Axle CSV and make an output with the following fields:
        -all input fields (name, address, lat/long, NAICS, etc.)
        -flag field indicating if the record is a potential duplicate and what type
        of duplicate it is. In turn, this can help guide action on how to further clean the file.
        
          
Author: Darren Conly
Last Updated: Apr 2021
Updated by: <name>
Copyright:   (c) SACOG
Python Version: 3.x
"""


import os
import time
import datetime as dt

import pandas as pd
from fuzzywuzzy import fuzz

from pandas_memory_optimization import memory_optimization
from pandas2sqltable import df_to_sqltbl

# fuzzywuzzy fuzz threshold ratio
fuzz_threshold = 80

# fields from raw data file
fld_locnum = 'LOCNUM'
fld_name = 'CONAME'
fld_staddr = 'STADDR'
fld_zip = 'ZIP'
fld_empcnt = 'LOCEMP'
fld_naics = 'NAICS'
fld_naicsdesc = 'NAICSD'
fld_lat = 'latitude'
fld_lon = 'longitude'
fld_geolev = 'geo_level'

# fields to be added
fld_naics4 = 'NAICS4'
fld_latlong_id = 'latlon_uid'
fld_dupeflag = 'dupe_flag'

# geo_levels
glevs_site = ['0', 'P'] # parcel or entry-point level accuracy
glevs_zips = ['4', '2', 'X', 'Z'] # ZIP accuracy; normally coded to ZIP centroid
glev_unknown = '' # may be null, not ''



def prep_master_df(in_csv):
    """Takes in a CSV file and makes dataframe with following fields added:
            -latlong_uid: unique int ID for each lat-long pair
            -NAICS4: 4-digit version of NAICS code, to simplify number of NAICS codes
            -dupe_flag: string field with code indicating what type of 
            potential duplicate the record is
    """
    in_cols = [fld_locnum, fld_name, fld_staddr, fld_zip, fld_empcnt, fld_naics,
               fld_naicsdesc, fld_lat, fld_lon, fld_geolev]
    
    # load raw CSV into dataframe
    print("loading and preparing master dataframe...")
    df = pd.read_csv(in_csv, usecols=in_cols)
    
    # memory_optimization(df) # redefine data types to use less memory -- not using for now because it slows stuff down a lot.
    
    
    df = df.loc[df[fld_geolev].isin(glevs_site)] # only get records with lat-longs representing parcel or entry point
    
    # add field containing left-most 4 digits from NAICS code
    df[fld_naics4] = df[fld_naics].astype('str') \
        .str.slice(0,4) \
        .astype('int')
        
    # set address and name field values to be all upper-case to remove possibility of false non-matches due to case mismatch
    df[fld_name] = df[fld_name].str.upper()
    df[fld_staddr] = df[fld_staddr].str.upper()
        
    # set default value for dupe_flag field--this means "probably no problems with this one!"
    df[fld_dupeflag] = '' 
    
    # Create new field for an int UID for lat-long pairs
    dfu = df[[fld_lat, fld_lon]].drop_duplicates()
    dfu[fld_latlong_id] = dfu.index
    df = df.merge(dfu, left_on=[fld_lat, fld_lon], right_on=[fld_lat, fld_lon])
    
    return df
    

def calc_dupe_flag(in_df, loc_uid_val):
    """Takes in a unique ID value for a lat-long pair, and checks for
    potential duplicate businesses at that same lat-long location"""
    
    flag_notdupe = '0'
    flag_namedupeonly = "DSM_only" # flag indicating that the business has high match with other biz on site, but no other matching attributes, and has > 0 employees
    flag_dupnaics4 = "DMN" # biz has matching name and 4-digit NAICS code with other biz on site
    flag_zeroemp = "DZE" # biz has matching name as other biz on site and has zero employees; could have differing NAICS
    flag_nullnaics4 = "DNN" # bis has matching name to other biz on same site but its NAICS4 is 9999
    
    # make df of all businesses at the location
    df_site = in_df.loc[in_df[fld_latlong_id] == loc_uid_val]
    
    # if only 1 record, then mark the record as being "okay", and not likely a dupe
    if df_site.shape[0] == 1:
        in_df.loc[in_df[fld_latlong_id] == loc_uid_val, fld_dupeflag] = flag_notdupe
        
    else:
        df_site_drecs = df_site.to_dict(orient='records')
        
        # loop through each record on the site
        for drec in df_site_drecs:
            # if a dupe flag has already been given to the record, skip it
            if drec[fld_dupeflag] != '':
                continue
            
            locnum = drec[fld_locnum]
            cname = drec[fld_name]
            empcnt = drec[fld_empcnt]
            naics4 = drec[fld_naics4]
            
            # make a list of all locations at the site where the company name significantly matches
            # the name in the record of the current iteration
            
            # list of all business names at the current lat-long location
            cnames_site = df_site[fld_name]
            
            # list of all names at the site whose name has high match value with the current iteration's name
            cnames_fuzzmatch = [sname for sname in cnames_site if fuzz.ratio(cname, sname) > fuzz_threshold]
            # import pdb; pdb.set_trace()
            # from the dataframe of all locations at the site, make a subset that are just those
            # with a high match value for the current iteration's name AND that do not have the same locnum
            # (because a business cannot be a duplicate of itself)
            df_fuzzymatch = df_site.loc[(df_site[fld_name].isin(cnames_fuzzmatch)) & (df_site[fld_locnum] != locnum)]
            
            # if only 1 record with the same company name, it means there are no duplicate company names
            # for the current record, and you can assume that it is okay and can be marked as a non-duplicate
            if df_fuzzymatch.shape[0] < 1:
                in_df.loc[in_df[fld_locnum] == locnum, fld_dupeflag] = flag_notdupe
                continue
            
            # if more than 1 fuzzy name match on the site, the current record may have duplicates or be a duplicate.
            # For each of the records on the site with a name match, check the current
            # record's NAICS4 value against each of the other records.
            
            out_tags = []
            for lnum in df_fuzzymatch[fld_locnum]:
                row = df_fuzzymatch.loc[df_fuzzymatch[fld_locnum] == lnum]
                

                
                naics4_row = int(row[fld_naics4])
                
                # if the current row's NAICS4 code matches name and NAICS4 with any other business on the same site,
                # then mark it as being a "duplicate with matching NAICS", or "DMN" code
                if naics4 == naics4_row and flag_dupnaics4 not in out_tags:
                    out_tags.append(flag_dupnaics4) # has at least 1 match with 4-letter naics code
                    
                if naics4 == 9999 and flag_nullnaics4 not in out_tags:
                    out_tags.append(flag_nullnaics4)  # has matching name, but its NAICS code is "unestablished"
                    
                if empcnt == 0 and flag_zeroemp not in out_tags:
                    out_tags.append(flag_zeroemp) # duplicates name, but has zero employees

                 
            if len(out_tags) == 0:
                out_tag = flag_namedupeonly
            else:
                out_tag = '_'.join(out_tags) 
                
            in_df.loc[in_df[fld_locnum] == locnum, fld_dupeflag] = out_tag
                    
        
def convert_cats2strings(in_df):
    '''Categorical column data types create issues for exporting DFs to spatial data types,
    so here we convert them to strings'''
    
    df_dtypes = in_df.dtypes
    
    
    for cname in df_dtypes.index:
        if df_dtypes[cname].name == 'category':
            in_df[cname] = in_df[cname].astype('str')
    

def dupe_flag_field(in_df):
    latlon_uids = in_df[fld_latlong_id].unique()
    tot_uids = len(latlon_uids)
    
    print("checking duplicate status for each unique site...")
    for i, latlongid in enumerate(latlon_uids):
        calc_dupe_flag(in_df, latlongid)
        
        if i % 1000 == 0:
            print(f"{i} of {tot_uids} unique lat-long locations checked for duplicates...")
            
def export_to_fc(in_df, out_path):
    '''export the resulting dataframe directly to the GIS FGDB you are mapping from'''
    
    import arcpy
    import geopandas as gpd
    from arcgis.features import GeoAccessor, GeoSeriesAccessor
    
    arcpy.env.overwriteOutput = True
    convert_cats2strings(in_df)
    
    
    #-----------------------
    # stupidly, the to_featureclass function throws an error. DC raised issue on ESRI Geonet on 4/7/2021
    # (subject "System Error when exporting Spatially Enabled DataFrame to Feature Class")
    
    sdf = GeoAccessor.from_xy(in_df, fld_lon, fld_lat)
    
    # import pdb; pdb.set_trace()
    sdf.spatial.to_featureclass(out_path)
    #-----------------------------
    
    # # As a workaround, am exporting geopandas gdf to geojson, then exporting geojson to feature class
    # gdf = gpd.GeoDataFrame(in_df, geometry=gpd.points_from_xy(in_df[fld_lon], in_df[fld_lat]))
    
    # temp_geojson = r'I:\Projects\Darren\EmpInventory\geojson\TEMP.geojson'
    
    # import pdb; pdb.set_trace()
    # gdf.to_file(temp_geojson, driver='GeoJSON')
    
    # arcpy.JSONToFeatures_conversion(temp_geojson, out_path)
    
    print(f"successfully exported to feature class {out_path}")
    
    
if __name__ == '__main__':
    csv_in = r"P:\Employment Inventory\Employment 2020\Data Axle Raw - DO NOT MODIFY\SACOG Jan 2020.csv" # "P:\Employment Inventory\Employment 2020\Data Axle Raw - DO NOT MODIFY\SACOG Jan 2020.csv" # r"C:\Users\dconly\GitRepos\emp-inventory\EMP2020\CSV\testrecs95814.csv"
    
    make_csv = False
    out_csv_dir = r'P:\Employment Inventory\Employment 2020\test_csv'
    
    make_fc = True
    out_fc_name = "EmpInvTest"
    output_fgdb = r"I:\Projects\Darren\EmpInventory\EmploymentInventory.gdb"
    
    make_sql = True
    sql_db = "EMP2020"
    sql_tbl_name = "TestDupeFlag"
    
    #===============================================================================
    dt_suffix = str(dt.datetime.now().strftime('%Y%m%d_%H%M'))
    
    if out_fc_name is None:
        out_fc_name = os.path.splitext(os.path.basename(csv_in))[0]
        out_fc_name = f"{out_fc_name}{dt_suffix}"
    out_fc_path = os.path.join(output_fgdb, out_fc_name)
    
    start_time = time.time()
    
    master_df = prep_master_df(csv_in)
    dupe_flag_field(master_df)
    
    if make_fc:
        export_to_fc(master_df, out_fc_path) 
    
    if make_csv:
        out_csv_name = f"{out_fc_name}.csv"
        out_csv_path = os.path.join(out_csv_dir, out_csv_name)
        master_df.to_csv(out_csv_path, index=False)
        print(f"Successfully exported CSV to {out_csv_path}")
        
    if make_sql:
        sql_tbl_name = f"{sql_tbl_name}{dt_suffix}"
        df_to_sqltbl(master_df, sql_db, sql_tbl_name)
    
    elapsed = time.time() - start_time
    elapsed_mins = round(elapsed / 60, 1)
    print(f"Cleaning process completed in {elapsed_mins} minutes.")
    
    
    
    
    
    