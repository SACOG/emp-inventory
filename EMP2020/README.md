# 2020 Employment Inventory

**NOTE, THIS IS A DRAFT WORK IN PROGRESS AS OF May 2021, CHECK ALL LINK REFS WHEN FINALIZED**

* [About](#about)
* [Data Sources](#data-sources)
* [Data Axle Flagging](#data-axle-flagging)



## About

As part of developing its Metropolitan Transportation Plan-Sustainable Communities Strategy (MTP-SCS), SACOG periodically updates its employment inventory. The primary goals of the inventory are to:

* Estimate the number of jobs, broken out by sector, for each parcel in the SACOG region
* Using parcel-level employment data, track more aggregate measures of employment over time
* Use parcel-level employment data as inputs to the SACSIM travel demand model





## Data Sources



### Data Axle

[Data Axle USA](https://www.data-axle.com/) is the primary data source for our employment inventory, providing detailed business-level employment data. The raw data table has over 120 fields, including name, address, NAICS code, lat/long, just to name a few.

### Supplementary Data Sources

Due to several of the data issues described below and for other reasons, SACOG staff incorporated several supplemental data sources into developing its employment inventory.

<4/20/2021 - HOLD for link to TG list of metadata and supplemental data sources>

### Data Issues

While granular and detailed, the raw data set is very messy. Example issues include (but are definitely not limited to):

* Businesses that no longer exist are still included in the data set but not marked as being defunct
* Various types of duplication
* Inaccurate counts with certain large employers
* Businesses that are only geocoded to a site level
* Businesses located in residential areas that are not tagged as being home-based businesses

<INCLUDE LINK TO ANY ADDITIONAL INFO THAT TG WRITES FOR SUMMARY ON DATA ISSUES>

## Data Axle Flagging

While cleaning up the data issues described above involves significant manual work, SACOG staff wrote several scripts and performed several initial GIS tasks that aim to reduce the amount of manual cleaning work, primarily by adding several fields that flag records with potential issues. By having records flagged, staff should be able to reduce time spent manually checking records for issues.

The process described in this section includes the following high-level steps:

1. Scripts to flag potential duplicates within the raw Data Axle table
2. Use GIS to flag whether the business record is in a residential area
3. Scripts to flag if and how each record in the 2020 Data Axle table relates to any records in the 2016 InfoUSA employment table.

### Step 1 - Flag potential duplicates within the Data Axle table

#### Site-level flags

The first pass of duplicate flagging happened for the roughly 84% of records that had parcel-level or entry-point-level latitude-longitude accuracy. While the process is detailed in the script `raw_data_cleanup_plevel.py`, the basic steps used the following process:  

*Flow Diagram for Flagging Potential Duplicates for Address Level Business Locations*
<img title='Flagging Potential Duplicates for ZIP-Code Level Business Locations' src="https://github.com/SACOG/emp-inventory/blob/ba3623f0c5e1851f5bd7cb5c5f648deb10c75909/EMP2020/DupeFlagProcess_Parcel.png">  

#### ZIP-code level flags

About 16% of Data Axle records were geocoded only to a ZIP code centroid. Many of these are businesses that only have a P.O. Box, for example, and thus do not have a physical parcel address. 
  

*Flow Diagram for Flagging Potential Duplicates for ZIP-Code Level Business Locations*
<img title='Flagging Potential Duplicates for ZIP-Code Level Business Locations' src="https://github.com/SACOG/emp-inventory/blob/ba3623f0c5e1851f5bd7cb5c5f648deb10c75909/EMP2020/DupeFlagProcess_ZIP.png">

### Step 2 - Add 2016 land use data field

Knowing the land use for each Data Axle (DA) record helps identify if employment makes sense. E.g., if a business is marked as non-home business, has employees, but is located on a residential parcel, that is suspicious and requires further checking.

We tagged the land use data to each DA record by creating a layer of land uses from the 2016 parcel polygon file, then using a GIS spatial join to tag the land uses to individual DA records.

### Step 3 - Join 2016 employment inventory data

Joining several attributes from the cleaned, finalized 2016 employment inventory help determine if a 2020 record is likely to be a duplicate, as well as show changes in a business's size or location between 2016-2020, where possible. NOTE that DA data are pretty messy, and well over half of 2020 records did not have a 2016 match.

The details of the process are contained in the [JoinFlags16_20.py script](https://github.com/SACOG/emp-inventory/blob/dc/improve-2016-fuzzy-tagger/EMP2020/python/JoinFlags16_20.py) which, in addition to joining 2016 records' data to 2020 records, also adds a join_flag field indicating how well the join happened (e.g., was it successful, sort of successful, etc.). The join_flag values are described in the [data dictionary](https://github.com/SACOG/emp-inventory/blob/ba3623f0c5e1851f5bd7cb5c5f648deb10c75909/EMP2020/Data_Dictionary.md)

### Step 4 - Add school matching flags

Data Axle's raw file has many inaccuracies in its records concerning school employment. To improve quality of school employment data, we integrate school employment data from (**Need data source for schools.csv**). Integration starts with flagging which Data Axle records have, or likely have, a matching record in the supplemental school data. The script  (**insert link to school flagging script**) contains the details on how we checked and flagged matches between Data Axle and the supplemental schools database. Several school flag columns were created and added to the Data Axle main table. These columns' names and descriptions are in the [data dictionary](https://github.com/SACOG/emp-inventory/blob/ba3623f0c5e1851f5bd7cb5c5f648deb10c75909/EMP2020/Data_Dictionary.md)

### Resulting "augmented" master Data Axle table

The culmination of the data flagging steps outline above is an augmented version of the raw Data Axle table that contains all the fields from the original raw table, plus the flag fields indicating potential duplicity, which school records are questionable, whether the land use makes sense for the business type, and a few other fields, which are described in more detail in the [data dictionary](https://github.com/SACOG/emp-inventory/blob/ba3623f0c5e1851f5bd7cb5c5f648deb10c75909/EMP2020/Data_Dictionary.md).

Important to keep in mind is that these steps DO NOT result in the final, cleaned employment inventory. Extensive manual checks and cross-referencing of additional data sources is needed to create the final version whose employment data is used to develop the base-year land use parcel file for the MTP-SCS. These additional procedures are described in more detail in <INSERT LINK TO MORE COMPREHENSIVE DOCUMENTATION WHEN AVAILABLE>.

