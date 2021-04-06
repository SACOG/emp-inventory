raw_data_cleanup_plevel
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

import pandas as pd

from pandas_memory_optimization import memory_optimization

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
    
    df = pd.read_csv(in_csv, usecols=in_cols)
    memory_optimization(df) # redefine data types to use less memory
    
    # get left-most 4 digits from NAICS code
    df[fld_naics4] = df[fld_naics].astype('str') \
        .str.slice(0,4) \
        .astype('int')
        
    df[fld_dupeflag] = '0' # set default value for dupe_flag field--this means "probably no problems with this one!"
    
def calc_dupe_flag(in_df):
    
    
    
    
    
    