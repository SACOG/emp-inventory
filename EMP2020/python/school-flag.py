"""
Name:school-flag.py
Purpose: Adds flag indicating if there is a fuzzy match between the Data Axle
    record for a school and a supplementary data source. 
    
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
from fuzzywuzzy import process as fuzzproc


def match_score(in_row, checkname, checkaddr):
    ''' for the row, return the name, address, and fuzz ratio for each'''
    
    rowname = in_row[col_stb_name]
    rowaddr = in_row[col_stb_addr]
    
    namescore = fuzz.ratio(rowname, checkname)
    addrscore = fuzz.ratio(rowname, checkname)
    
    return [rowname, namescore, rowaddr, addrscore]


def fuzz_match(in_row, compare_df):
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
        
    max_score = df[col_totscore].max()
    
    # df = df.loc[df[col_totscore] == max_score].iloc[0]
    
    try:
        if len(df.shape) > 1:
            df = df.loc[df[col_totscore] == max_score].iloc[0]
    except:
        import pdb; pdb.set_trace()
    
    if df[col_st_namescore] < min_match_threshold or df[col_st_addrscore] < min_match_threshold:
        return in_row
    else:

        
        for col in [col_st_name, col_st_namescore, col_st_addr, col_st_addrscore]:
            in_row[col] = df[col]
        
        return in_row
        

    

    

if __name__ == '__main__':
    
    #==================USER PARAMETERS==================
    master_csv_in = r"P:\Employment Inventory\Employment 2020\SQL\RecsAll_w_2016jnflag_20210419.csv" # path to main Data Axle CSV with flags on it
    supp_csv_in = r"\\data-svr\Monitoring\Employment Inventory\Employment 2020\working\pieces\education\Schools_2020_for_Darren.csv"
    
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
        # try:
        dfm_school_dict[key] = fuzz_match(row, dfs)
        # except:
        #     import pdb; pdb.set_trace()
            
    out_df = pd.DataFrame.from_dict(dfm_school_dict, orient='index')
    
    out_df.to_csv(r'P:\Employment Inventory\Employment 2020\SQL\test_school_flag.csv', index=False)
    print("success!")