import pandas as pd
import numpy as np
from fuzzywuzzy import fuzz, process
from time import perf_counter as perf

# define key variables and parameters
in_csv2020 = r"\\data-svr\Monitoring\Employment Inventory\Employment 2020\SQL\DupeFlagAll20210416.csv" # r"C:\Users\dconly\Desktop\Temporary\temp_csv\sutter_emptest_2020.csv"  # 
in_csv2016 = r"\\data-svr\Monitoring\Employment Inventory\Employment 2016\FINAL 2016 EMP FILE\REGION_EMP16_FINAL_060217-wkg.csv" # r"C:\Users\dconly\Desktop\Temporary\temp_csv\sutter_emptest_2016.csv"  # 

match_threshold = 80 # if fuzzy match below this number, then flag the values as being different

# fields from the 2020 table
fld_coname20 = 'coname'
fld_locnum20 = 'locnum'
fld_staddr20 = 'staddr'
fld_zip = 'zip'
fld_naics = 'naics'
fld_naicsd = 'naicsd'
fld_home = 'home'
fld_locemp20 = 'locemp'
fld_latitude = 'latitude'
fld_longitude = 'longitude'
fld_geo_level = 'geo_level'
fld_naics4 = 'naics4'
fld_dupe_flag = 'dupe_flag'
fld_latlon_uid = 'latlon_uid'
fld_coname16 = 'coname16'
fld_staddr16 = 'staddr16'
fld_emp16 = 'emp16'
fld_notes16 = 'notes16'
fld_infoid16 = 'infoid16'

# fields from the 2016 table
fld16_id = 'INFOID_16'
fld16_coname = 'NAME'
fld16_staddr = 'ADDRESS'
fld16_zip = 'ZIP'

# other fields that get added in this script
fld_jflag = 'join_flag'






# Load and set up master 2020 table and flag function



df = pd.read_csv(in_csv2020)
df16 = pd.read_csv(in_csv2016, usecols = [fld16_id, fld16_coname, fld16_staddr, fld16_zip])

df[fld_jflag] = '_'

df[fld_locnum20] = df[fld_locnum20].astype(float)
df[fld_infoid16] = df[fld_infoid16].astype(float)



# Find and flag records that have ID match in both years but whose names and address significantly differ

"""
* FullExMatch = the LOCNUM in 2020 has a matching INFOID_16 value, and the biz name and address are an EXACT match
* FullFzMatch = the LOCNUM in 2020 has a matching INFOID_16 value, and the biz name and address are a FUZZY match (`fuzz.ratio` > 80)
* IDMatchNameChg = the IDs match between the two years, but the biz name changed
* IDMatchAddrChg = the IDs match between the two years, but the biz address changed
* IDMatchNameAddrChg = the IDs match between the two years, but the biz address and the biz name changed
* NamAddrExMatch = IDs do not match between 2016 and 2020, but the business name and address are an EXACT match
* NamAddrFzMatch = IDs do not match between 2016 and 2020, but the business name and address are a FUZZY match (`fuzz.ratio` > 80)
* NoMatch = The IDs do not match, nor is there a FUZZY match between both the name and address
"""



def avg_match(row, srchname, srchaddr):
    
    row_name = str(row[fld16_coname])
    row_addr = str(row[fld16_staddr])
    
    try:
        fuzzname = fuzz.ratio(row_name, srchname)
        fuzzaddr = fuzz.ratio(row_addr, srchaddr)
    except:
        import pdb; pdb.set_trace()
    
    if fuzzname > match_threshold and fuzzaddr > match_threshold:
        output = (fuzzname + fuzzaddr) / 2
    else:
        output = 0
    
    return output
    
    

def get_fuzzy_matches(in_row, search_df):
    '''If 2016 values for name and address are not in the 2020 table, then do a
    fuzzy match between the 2016 name and 2020 anme, and 2016 address and 2020 address'''
    
    name1 = in_row[fld_coname20]
    addr1 = in_row[fld_staddr20]
    zipcode = in_row[fld_zip]
    
    # filtering to only records within same ZIP code to speed things up.
    temp_df = search_df.loc[search_df[fld16_zip] == zipcode]
    
    fld_avg_fuzzmatch = 'fuzzmatch_avg'
    
    try:
        if temp_df.shape[0] == 0:
            return None
        else:
            temp_df[fld_avg_fuzzmatch] = temp_df.apply(lambda x: avg_match(x, name1, addr1), axis=1)
    except:
        print(name1, addr1, zipcode)
        import pdb; pdb.set_trace()
    max_match = temp_df[fld_avg_fuzzmatch].max()
    
    # if the max match is zero, then pass. It means there is not a fuzzy match
    if max_match == 0:
        return None
    
    # return row with highest overall match, if the match > 0
    # import pdb; pdb.set_trace()
    temp_df = temp_df.loc[temp_df[fld_avg_fuzzmatch] == max_match].iloc[0]
    
    name_fzmatch = temp_df[fld16_coname]
    addr_fzmatch = temp_df[fld16_staddr]
    
    return {'name': name_fzmatch, 'addr': addr_fzmatch}
        
    
    

def get_jflag_1(in_row):
    
    jflag_fullmatch = 'FullExMatch'
    jflag_idfuzzmatch = 'FullFzMatch'
    jflag_newname = "IDMatchNameChg" 
    jflag_newaddr = "IDMatchAddrChg" 
    jflag_nmaddrchg = "IDMatchNameAddrChg" 
    jflag_nmaddrematch = 'NamAddrExMatch' 
    jflag_nmaddrfmatch = 'NamAddrFzMatch' 
    jflag_nomatch16 = 'NotMatch16' 
    
    id16 = in_row[fld_infoid16]
    id20 = in_row[fld_locnum20]
    name16 = str(in_row[fld_coname16])
    name20 = str(in_row[fld_coname20])
    addr16 = str(in_row[fld_staddr16])
    addr20 = str(in_row[fld_staddr20])
    
    id_match = id16 == id20
    name_addr_ematch = name16 == name20 and addr16 == addr20

    # if there's a fuzzy match for name and address, populate the name and address 2016 fields in the master df    
    fuzz_dict = None
    
    # comparing "20" fields to "16" fieles within master table (not comparing to or looking at 2016 table)
    if id_match:
        t1 = perf()
        name_fuzzmatch = fuzz.ratio(name20, name16) > match_threshold
        addr_fuzzmatch = fuzz.ratio(addr20, addr16) > match_threshold
        
        if name_addr_ematch:
            output = jflag_fullmatch
        elif name_fuzzmatch and addr_fuzzmatch: # if there's fuzzy match between name and address, and id match
            output = jflag_idfuzzmatch
        elif name_fuzzmatch and not addr_fuzzmatch: # address changed, and id match
            output = jflag_newaddr
        elif addr_fuzzmatch and not name_fuzzmatch: # biz name changed, and id match
            output = jflag_newname
        elif not addr_fuzzmatch and not name_fuzzmatch: # biz name and address changed, and id match
            output = jflag_nmaddrchg
        else:
            output = 'ERROR'
        # print(f"{perf() - t1} seconds. did not need fuzzy search.")
    else:
        if name_addr_ematch:
            output = jflag_nmaddrematch # no id match, but exact name and address match
        else:
            t1 = perf()
            fuzz_dict = get_fuzzy_matches(in_row, df16)
            
            if fuzz_dict: # if there's a fuzzy match for 2016 in the 2016 table, then update the "16" fields in the master table
                df.loc[df[fld_locnum20] == id20, fld_coname16] = fuzz_dict['name']
                df.loc[df[fld_locnum20] == id20, fld_staddr16] = fuzz_dict['addr'] 
                
                output = jflag_nmaddrfmatch # no id match, but fuzzy name and address match to 2016 (requires looking up to 2016 table)
            else:
                output = jflag_nomatch16
            # print(f"{perf() - t1} seconds, performed fuzzy search.")
    
    return output
        
"""
TESTING DATAFRAME WITH ONLY 10 ROWS
dft = df.head(10)
dft_rows = dft.shape[0]

stime = perf()
print(f"applying to test dataframe with {dft_rows} rows...")
dft[fld_jflag] = dft.apply(lambda x: get_jflag_1(x), axis=1)

elapsed = perf() - stime
print(f"completed in {elapsed} seconds")
"""

# FULL RUN, THIS LIKELY TAKES 4-5 HOURS
df_rows = df.shape[0]
# apply the function above to calculate each record's join flag
print(f"applying to FULL dataframe with {df_rows} rows...")
df[fld_jflag] = df.apply(lambda x: get_jflag_1(x), axis=1)


"""
# TEST CELL, DELETE WHEN DONE (4/27/2021)
df_test = df.loc[df[fld_coname20] == 'SUTTER ROSEVILLE MEDICAL CTR']

dft1 = df_test.iloc[0]
dft1

df[fld_jflag].value_counts()
"""
out_csv = r"\\data-svr\Monitoring\Employment Inventory\Employment 2020\SQL\RecsAll_w_2016jnflag_20210427.csv"
print(f"writing to csv {out_csv}")
# df.to_csv(out_csv, index=False)
