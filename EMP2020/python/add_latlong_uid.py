"""
Name: add_latlong_uid.py
Purpose: Assign a unique ID to each unique lat-long pair.
        
          
Author: Darren Conly
Last Updated: <date>
Updated by: <name>
Copyright:   (c) SACOG
Python Version: 3.x
"""
import pandas as pd

in_csv = r"P:\Employment Inventory\Employment 2020\Data Axle Raw - DO NOT MODIFY\SACOG Jan 2020.csv"

cols = ['LOCNUM', 'latitude', 'longitude']

df = pd.read_csv(in_csv, usecols=cols)

dfu = df['latitude', 'longitude'].drop_duplicates()

