"""
Name:school-flag-addr-only.py
Purpose: Adds flag indicating if there is a fuzzy match between the Data Axle
    record for a school and a supplementary data source.
   
    NOTE - this only matches based on school address and subfiltering for 4-digit NAICS
    code of 6111 (for schools only). This is because there are many records where the schools.csv
    name is so different from the name in DataAxle that they fall below the threshold
    for being fuzzy matched.
    
    
    If there is a high match score, it is a way of saying that the school record
    is legitimate
        
          
Author: Darren Conly
Last Updated: April/May 2021
Updated by: <name>
Copyright:   (c) SACOG
Python Version: 3.x
"""

import pandas as pd
from fuzzywuzzy import fuzz


def match_score(in_row, checkname, checkaddr):
    ''' for the row, return the name, address, and fuzz ratio for each'''
    
    rowname = in_row[col_stb_name]
    rowaddr = in_row[col_stb_addr]
    
    namescore = fuzz.ratio(rowname, checkname)
    addrscore = fuzz.ratio(rowname, checkname)
    
    return [rowname, namescore, rowaddr, addrscore]


def fuzz_match(in_row, compare_df, check_flag='name_address'):
    '''takes row from master df, looks for closest match on name and
    address in the comparison df.
    Returns name and address from the supplemental file, along with the match score'''
    # import pdb; pdb.set_trace()
    
    chkname = in_row[col_coname]
    chkaddr = in_row[col_coaddr]
    
    check_recs = compare_df[[col_stb_name, col_stb_addr]].to_records(index=False)
    
    out_rows = []
    
    for rec in check_recs:
        name = rec[0]
        addr = rec[1]
        
        namescore = fuzz.ratio(name, chkname)
        addrscore = fuzz.ratio(addr, chkaddr)
        
        tot_score = namescore + addrscore
        out_rows.append([name, namescore, addr, addrscore, tot_score])
        
    col_totscore = 'tot_score'
        
    df = pd.DataFrame(out_rows, columns=[col_st_name, col_st_namescore,
                                         col_st_addr, col_st_addrscore, col_totscore])
        
    if check_flag == 'name_address':
        max_score = df[col_totscore].max() # records with the highest match score between compare_df and in_row name and address values.
        # if 2+ records tied for having the highest match score, just pick one of them
        if len(df.shape) > 1:
            df = df.loc[df[col_totscore] == max_score].iloc[0]
    elif check_flag == 'address':
        max_score = df[col_st_addrscore].max()
        # if 2+ records tied for having the highest match score, just pick one of them
        if len(df.shape) > 1:
            df = df.loc[df[col_st_addrscore] == max_score].iloc[0]
    else:
        raise Exception("You must enter 'name_address' or 'address' for the check_flag parameter in the fuzz_match function.")
        
    # import pdb; pdb.set_trace()
    
    is_match = False
    
    if check_flag == 'name_address':
        is_match = df[col_st_namescore] < min_match_threshold or df[col_st_addrscore] < min_match_threshold
    elif check_flag == 'address':
        is_match = df[col_st_addrscore] >= min_match_threshold
    else:
        raise Exception("You must enter 'name_address' or 'address' for the check_flag parameter in the fuzz_match function.")
    
    if is_match:
        # import pdb; pdb.set_trace()
        for col in [col_st_name, col_st_namescore, col_st_addr, col_st_addrscore]:
            in_row[col] = df[col]
        return in_row
    else:
        # if either name or address (depending on check_flag specn) match is below threshold, then it's not a match.        
        return in_row
        


if __name__ == '__main__':
    
    #==================USER PARAMETERS==================
    master_csv_in = r"P:\Employment Inventory\Employment 2020\SQL\RecsAll_w_2016jnflag_20210419.csv" # path to main Data Axle CSV with flags on it
    supp_csv_in = r"\\data-svr\Monitoring\Employment Inventory\Employment 2020\working\pieces\education\Schools_2020_for_Darren2.csv"
    
    min_match_threshold = 70 # if fuzz match for address or name is below this number, will mark as zero (not a match)
    
    col_stb_name = 'SCHL_NAME'
    col_stb_addr = 'FULLSTREET'
    col_stb_cnty = 'County'
    
    supp_csv_cols = [col_stb_name, col_stb_addr, col_stb_cnty]

    col_naics4 = 'naics4'
    col_coname = 'coname'
    col_coaddr = 'staddr'
    
    naics4_school = [6111]
    
    #==================RUN SCRIPT==================
    
    # added columns
    col_st_name = 'stbl_name'
    col_st_namescore = 'stbl_name_fscore'
    col_st_addr = 'stbl_addr'
    col_st_addrscore = 'stbl_addr_fscore'
    
    dfm = pd.read_csv(master_csv_in)
    dfs = pd.read_csv(supp_csv_in, usecols = supp_csv_cols)
    
    # add appropriate flag columns with default vals
    dfm[col_st_name] = '_'
    dfm[col_st_namescore] = 0
    dfm[col_st_addr] = '_'
    dfm[col_st_addrscore] = 0
    
    # filter to only have records that are likely schools
    dfm_school = dfm.loc[dfm[col_naics4].isin(naics4_school)] # .head(100)
    dfm_school_dict = dfm_school.to_dict(orient='index')
    
    
    print("calculating matches and match scores...")
    for key, row in dfm_school_dict.items():
        dfm_school_dict[key] = fuzz_match(row, dfs, check_flag='address')
            
    out_df = pd.DataFrame.from_dict(dfm_school_dict, orient='index')
    
    out_df.to_csv(r'P:\Employment Inventory\Employment 2020\SQL\test_school_flag2.csv', index=False)
    print("success!")