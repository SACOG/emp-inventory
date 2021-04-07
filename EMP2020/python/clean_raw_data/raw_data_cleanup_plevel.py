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

import pandas as pd
from fuzzywuzzy import fuzz

from pandas_memory_optimization import memory_optimization

# fuzzywuzzy fuzz threshold ratio
fuzz_threshold = 70

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
    memory_optimization(df) # redefine data types to use less memory
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
    
    flag_dupnaics4 = "DMN"
    flag_zeroemp = "DZE"
    flag_nullnaics4 = "DNN"
    
    # make df of all businesses at the location
    df_site = in_df.loc[in_df[fld_latlong_id] == loc_uid_val]
    
    # if only 1 record, then mark the record as being "okay", and not likely a dupe
    if df_site.shape[0] == 1:
        in_df.loc[in_df[fld_latlong_id] == loc_uid_val, fld_dupeflag] = '0'
        
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
            # cnames_site = dict(zip(df_site[fld_name], df_site[fld_locnum] ))
            cnames_site = df_site[fld_name]
            cnames_fuzzmatch = [sname for sname in cnames_site if fuzz.ratio(cname, sname) > fuzz_threshold]
            
            df_fuzzymatch = df_site.loc[df_site[fld_name].isin(cnames_fuzzmatch)]
            
            # if only 1 record with the same company name, it means there are no duplicate company names
            # for the current record, and you can assume that it is okay and can be marked as a non-duplicate
            if df_fuzzymatch.shape[0] < 2:
                in_df.loc[in_df[fld_locnum] == locnum, fld_dupeflag] = '0'
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
                # import pdb; pdb.set_trace()
                if naics4 == naics4_row and flag_dupnaics4 not in out_tags:
                    out_tags.append(flag_dupnaics4) # has at least 1 match with 4-letter naics code
                    
                if naics4 == 9999 and flag_nullnaics4 not in out_tags:
                    out_tags.append(flag_nullnaics4)  # has matching name, but its NAICS code is "unestablished"
                    
                if empcnt == 0 and flag_zeroemp not in out_tags:
                    out_tags.append(flag_zeroemp) # duplicates name, but has zero employees
                    
                out_tag = '_'.join(out_tags) 
                
            in_df.loc[in_df[fld_locnum] == locnum, fld_dupeflag] = out_tag
                    
        
        
    
    

def dupe_flag_field(in_df):
    latlon_uids = in_df[fld_latlong_id].unique()
    tot_uids = len(latlon_uids)
    
    print("checking duplicate status for each unique site...")
    for i, latlongid in enumerate(latlon_uids):
        calc_dupe_flag(in_df, latlongid)
        
        if i % 1000 == 0:
            print(f"{i} of {tot_uids} unique lat-long locations checked for duplicates...")
    
    
if __name__ == '__main__':
    csv_in = "P:\Employment Inventory\Employment 2020\Data Axle Raw - DO NOT MODIFY\SACOG Jan 2020.csv" # r"C:\Users\dconly\GitRepos\emp-inventory\EMP2020\CSV\testrecs95814.csv"
    
    start_time = time.time()
    master_df = prep_master_df(csv_in)
    
    dupe_flag_field(master_df)
    
    
    master_df.to_csv(r"P:\Employment Inventory\Employment 2020\test_csv\test_outFullRegion.csv", index=False)
    
    elapsed = time.time() - start_time
    elapsed_mins = elapsed / 60
    print(f"Cleaning process completed in {elapsed_mins} minutes.")
    
    
    
    
    
    