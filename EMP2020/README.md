# 2020 Employment Inventory

**NOTE, THIS IS A DRAFT WORK IN PROGRESS AS OF 4/20/2021**

* About



## About

As part of developing its Metropolitan Transportation Plan-Sustainable Communities Strategy (MTP-SCS), SACOG periodically updates its employment inventory. The primary goals of the inventory are to:

* Estimate the number of jobs, broken out by sector, for each parcel in the SACOG region
* Using parcel-level employment data, track more aggregate measures of employment over time
* Use parcel-level employment data as inputs to the SACSIM travel demand model

<INSERT, AS RELEVANT, 



## Data Sources



### Data Axle

[Data Axle USA](https://www.data-axle.com/) is the primary data source for our employment inventory, providing detailed business-level employment data. The raw data table has over 120 fields, including name, address, NAICS code, lat/long, just to name a few.

### Supplementary Data Sources

Due to several of the data issues described below and for other reasons, SACOG staff incorporated several supplemental data sources into developing its employment inventory.

<4/20/2021 - HOLD for link to Tina's list of metadata>

### Data Issues

While granular and detailed, the raw data set is very messy. Example issues include (but are definitely not limited to):

* Businesses that no longer exist are still included in the data set but not marked as being defunct
* Various types of duplication
* Inaccurate counts with certain large employers
* Businesses that are only geocoded to a site level
* Businesses located in residential areas that are not tagged as being home-based businesses

INCLUDE LINK TO ANY ADDITIONAL INFO THAT TINA WRITES FOR HER SUMMARY ON DATA ISSUES

## Data Axle Flagging

While cleaning up the data issues described above involves significant manual work, SACOG staff wrote several scripts and performed several initial GIS tasks that aim to reduce the amount of manual cleaning work, primarily by adding several fields that flag records with potential issues. By having records flagged, staff should be able to reduce time spent manually checking records for issues.

The process described in this section includes the following high-level steps:

1. Scripts to flag potential duplicates within the raw Data Axle table
2. Use GIS to flag whether the business record is in a residential area
3. Scripts to flag if and how each record in the 2020 Data Axle table relates to any records in the 2016 InfoUSA employment table.

### Step 1 - Flag potential duplicates within the Data Axle table

#### Site-level flags

The first pass of duplicate flagging happened for the roughly 84% of records that had parcel-level or entry-point-level latitude-longitude accuracy. While the process is detailed in the script `raw_data_cleanup_plevel.py`, the basic steps used the following process:

