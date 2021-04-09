"""
Name: pandas2sqltable.py
Purpose: Export a pandas dataframe to a SQL Server table
    https://docs.microsoft.com/en-us/sql/machine-learning/data-exploration/python-dataframe-sql-server?view=sql-server-ver15
        
          
Author: Darren Conly
Last Updated: Apr 2021
Updated by: <name>
Copyright:   (c) SACOG
Python Version: 3.x
"""

import pandas as pd
import urllib

import sqlalchemy as sqla # needed to run pandas df.to_sql() function

def df_to_sqltbl(in_df, dbname, tbl_name, servername='SQL-SVR', trustedconn='yes', if_tbl_exists='replace'):
    
    conn_str = "DRIVER={ODBC Driver 17 for SQL Server};" \
        f"SERVER={servername};" \
        f"DATABASE={dbname};" \
        f"Trusted_Connection={trustedconn}"
        
    conn_str = urllib.parse.quote_plus(conn_str)
    
    # create SQL table from the dataframe
    print("loading df to SQL table...")
    
    engine = sqla.create_engine(f"mssql+pyodbc:///?odbc_connect={conn_str}")
    in_df.to_sql(name=tbl_name, con=engine, if_exists=if_tbl_exists, index=False)
    
    print(f"Successfully loaded dataframe to SQL table {tbl_name} in the {dbname} database.")
    
if __name__ == '__main__':
    test_csv = r"P:\Employment Inventory\Employment 2020\test_csv\test_out95616_UCD.csv"
    
    db="EMP2020"
    test_tbl_name = "TEST"
    
    df = pd.read_csv(test_csv)
    df_to_sqltbl(df, db, test_tbl_name)
    
    
    
        
    
    