# Data Dictionaries



## Fields *added* to the raw Data Axle table

|     Field  Name     |                         Description                          |    Values     | Calculation  Method or Script |
| :-----------------: | :----------------------------------------------------------: | :-----------: | :---------------------------: |
|       naics4        |                First  4 digits of NAICS code                 |       -       |  raw_data_cleanup_plevel.py   |
|      dupe_flag      |          If  and how the record may be a duplicate           | link to table |  raw_data_cleanup_plevel.py   |
|      ZIP_geom       | ZIP  code that can be joined to SACOG's ZIP code polygon GIS file to allow mapping  of aggregate data at ZIP code level |       -       |       GIS spatial join        |
|      LUTYPE16       |             Land  use type from 2016 parcel file             |       -       |       GIS spatial join        |
|     res_nwfh_f      | 1/0  flag. Value of 1 means the business is not home based but is on a residential  parcel and should thus be investigated for errors. |       -       |     GIS field calculation     |
|      coname16       |             Business  name in 2016, if available             |       -       |       JoinFlags16_20.py       |
|      staddr16       |           Business  address in 2016, if available            |       -       |       JoinFlags16_20.py       |
|        emp16        |        Business  employee count in 2016, if available        |       -       |       JoinFlags16_20.py       |
|       notes16       |        Notes  from SACOG staff in 2016, if available         |       -       |       JoinFlags16_20.py       |
|      infoid16       | Business  ID in 2016, if available. Corresponds to locnum field in Data Axle table |       -       |       JoinFlags16_20.py       |
|      join_flag      | Results  of attempting to join the record to the 2016 table  | link to table |       JoinFlags16_20.py       |
|    sch_tbl_name     | Name  from supplemental school data table with highest fuzzy match to a name in  Data Axle (fuzzy match score must be > 70) |       -       |        school-flag.py         |
| sch_tbl_name_fscore | Fuzzy  match score of the name with highest fuzzy match score from school table with  a name in the Data Axle table (must be > 70, otherwise set to 0) |       -       |        school-flag.py         |
|    sch_tbl_addr     | Street  address from supplemental school data table with highest fuzzy match to a  Street address in Data Axle (fuzzy match score must be > 70) |       -       |        school-flag.py         |
| sch_tbl_addr_fscore | Fuzzy  match score of the street address with highest fuzzy match score from school  table with a street address in the Data Axle table (must be > 70,  otherwise set to 0) |       -       |        school-flag.py         |



## join_flag field values

|  join_flag  value  |                         Description                          |
| :----------------: | :----------------------------------------------------------: |
|    FullExMatch     | Record  has ID match and **exact** matches for both name and address in 2016 |
|    FullFzMatch     | Record  has ID match and **high fuzzy** matches for both name and address in 2016 |
|   IDMatchAddrChg   | Record  has ID match, name has at least a high fuzzy match, but the address changed  significantly since 2016. |
| IDMatchNameAddrChg | Record  has ID match, address has at least a high fuzzy match, but the name changed  significantly since 2016. |
|   IDMatchNameChg   | Record  has ID match, but both the name changed significantly since 2016. |
|   NamAddrExMatch   | Record  does not have an ID match, has an exact name and address match in 2016. |
|   NamAddrFzMatch   | Record  does not have an ID match, has an high fuzzy match for both name and address  in 2016. |
|     NotMatch16     | Record  does not have an ID match, fuzzy name match, or fuzzy address match for 2016.  Assume these businessegit s do not exist in the 2016 table. |





## dupe_flag field values

NOTE - dupe_flags are *not exclusive*. If more than one flag value applies, they are separated by an underscore. E.g., a record with a 9999 NAICS code and zero employees would have dupe_flag of DNN_DZE.

| dupe_flag  value |                         Description                          |
| :--------------: | :----------------------------------------------------------: |
|        0         | Business  does not duplicate any other record at the same location |
|       DMN        | Duplicate  with Matching NAICS - the business shares a name and NAICS code with at least  one other record at the same parcel, and has a non-99 NAICS code |
|       DNN        | Duplicate  with Null NAICS - the business shares a name and NAICS code with at least one  other record at the same parcel, but has a 99 NAICS code |
|       DZE        | Duplicate  with Zero Employees - the business shares a name and NAICS code with at least  one other record at the same parcel, has zero employees |
|     DSM_only     | Duplicate:  String Match only - the business shares a name with at least 1 other record  on the same parcel, but does not share any other characteristics (e.g. has  different NAICS code) |