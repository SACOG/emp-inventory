**SACOG Employment Inventory Update Process Methodology --**

**Work conducted August 2016-January 2017**

Base Year Update 2016

Tina Glover <tglover@sacog.org> -- 2.2.17

This document details the process used to create the 2016 SACOG
Employment Inventory for the SACOG region. The base for the employment
inventory is 2016 proprietary InfoGroup (formerly InfoUSA) point level
data geocoded to either street centerline or parcel centroid. InfoGroup
has been consistently improving their employment database but there are
still gaps, particularly in certain sectors. This process is an attempt
to fill those gaps to the best of our abilities. There is a 'source'
field in each file that is originally populated with "INFOUSA2016".
Anytime a record is changed in some way the source field is changed, the
name (or abbreviation) of the source and the year of the source replaces
'INFOUSA2016" to keep track of records that have been adjusted.

1.  **Parcelization of Data** \-- SACOG's GIS unit 're-parcelized' all
    InfoGroup data points. The primary address was used first, and then
    the remaining records were parcelized based on the secondary address
    found in each record. This process helped place records that had a
    PO Box or an out of area address as a primary address but a physical
    location in the region as the secondary address. The secondary
    address was the same as the primary address for almost all physical
    locations originally given, so the secondary address was used
    throughout the remainder of the inventory process.

2.  **Review of Not Matchable files** -- Records that did not match at
    the parcel level were geocoded to street centerline with an offset
    so that the records were most likely to fall on a parcel that was
    close to the street address on the record. Records that still didn't
    match geo-coded to the zip code centroid. Those remaining records
    were assessed, all records with 10 or more employees were
    hand-placed, records with less than 10 employees were deleted. All
    PO Box only addresses were deleted unless the employee count was
    above 10 in which case an internet search was conducted to try to
    identify a physical location for the record via the company name.

3.  **Review of data and removal of Duplicate records from final matched
    file** -- one of the most time-consuming but important step is
    reviewing the final matched file for duplicates and records that may
    need additional review. InfoGroup has significantly improved their
    database in terms of duplicates over what was found in 2012, but
    there were still duplicates in the 2016 dataset. For El Dorado,
    Placer, Sutter, Yolo and Yuba Counties each county's matched file
    was sorted by secondary address and reviewed for duplicates which
    were deleted. Sacramento County (due to its high number of records
    and how unwieldy it was as a whole) was broken into 10 separate
    regions based on the first digit of the street address. The same
    review was done on those 10 separate files. Additionally, a Notes
    field was added to all files so that other issues that should be
    later followed up could be noted here. These notes mostly consisted
    of 'rvw' for an additional review of the record. Sometimes this was
    because the employment count looked high or low, or the address
    didn't look quite right, etc. Other notes were to indicate where a
    NAICS field looked incorrect, or where the record would likely be
    further reviewed because it was in an identified sector.
    
    In most duplicate cases, there is some small difference, such as a
    suite number in the address field or in the company name one record
    has an abbreviation or an additional word spelled, or even capitalized
    differently than another record. In some cases, duplicates appear to
    be the same, except there is a different employment number, or NAICS
    codes. When selecting which record to keep where there are duplicates,
    we generally keep the record that has the highest number of employees
    unless we have competing information that leads us to select the other
    record(s). In most cases this is a minor difference, say 3 employees
    in one record and 4 employees in the other, but in some cases the
    difference can be quite significant -- a difference of more than 100
    employees or more. In those extreme cases it is probably best to label
    all records that may be duplicates for review, so that the
    determination on which record to keep is backed up by additional
    research. We generally will only do this for larger employers, as we
    will not have time to review every record -- and employers with less
    than 10 employees are lowest in priority.
    
    There are healthcare centers in particular, where there may be 3-20
    different doctors (or more of many types) located at the same address,
    and maybe each record shows 3 employees. However, it may be determined
    that while there may be that many doctors at that location, there are
    a much smaller number of support staff that is counted more than once.
    Other odd groupings are lawyers' offices, accountants, dentists and
    other healthcare practitioners. Hospitals are covered in a different
    fashion, particularly because a single hospital can have more than 100
    records associated with it. Shopping malls and some larger shopping
    centers fall in this category as well as multi-floor buildings with a
    high number of tenants. In some cases, multiple companies may have the
    same physical address and still be separate employers, even with the
    same suite number. Address standards vary throughout the region so
    there is no one size fits all in this regard.

4.  **Folding in K-12 Schools data** -- (1,125 records for the region)
    SACOG maintains a public and private K-12 schools point .shp file
    that is updated annually based on the California Department of
    Education Dataquest data available for enrollment and staffing at:
    <http://data1.cde.ca.gov/dataquest/> . We select the 'create your
    own report' option under 'other' and separately select 'enrollment'
    and then the four different staffing options 'FTE Administrators,
    FTE Pupil Svs, FTE Teachers and \# Classified Staff'. Summing these
    four categories results in our employment total -- we round up if
    there is a partial number. This number best represents the number of
    employees at the school site although it doesn't include unpaid
    volunteers and does not break out part time employees for a total
    employee count. The SACOG database also includes a notes field that
    details if a school has closed or moved. This database lags by at
    least one year in the staffing report so for the 2016 update we had
    to use the 2015-2016 school year. Public school sites are almost
    always shown in this data, while private schools come from a
    different database. InfoGroup record employment for K-12 schools are
    rarely correct; they appear to follow a general categorization based
    on the type (elementary, junior, high) of school. Many schools are
    missing from the InfoGroup database so are added to the SACOG
    inventory. In addition, some InfoGroup records have incorrect NAICS
    codes ascribed to them. A separate review of all InfoGroup records
    that had a "Primary & Secondary Schools" NAICS description was done.
    Many daycare centers and other types of schools including learning
    centers and fine arts schools had an incorrect NAICS code along with
    the standard InfoGroup employment number for a school assigned to
    them. In these cases, the NAICS code and description was changed to
    best identify that locations true type as well as an assessment of
    the employment count at each site. In all of these cases the Source
    was changed to 'SACOG2016'. Private schools found in the InfoGroup
    database that weren't in the DOE database were retained in the
    inventory. There were several public-school sites that closed but
    were re-opened as private schools, once confirmed as no data change,
    the source remained 'INFOUSA2016'. School district administration
    offices were also often ascribed a schools NAICS code, these were
    adjusted for both employee count and NAICS description and the
    source changed to either 'DOE1516' or 'SACOG2016'. Some school
    districts had multiple employment sites and took additional internet
    research or contact with school officials to determine the sites and
    number of employees at each site; particularly for the larger school
    districts and the county offices of education.

5.  **Folding in Colleges/Universities data** -- (61 records for the
    region) We have a rather short list of colleges/universities in the
    region -- these are not representative of all tech/trade schools in
    the region, only the larger colleges/universities. Some of this data
    came from the Sacramento Business Journal list of colleges and
    universities, but also included research on individual websites to
    determine both enrollment and staffing. The Los Rios Community
    College District sent us a list of enrollment counts and staffing at
    each of their locations, the source for each is listed as
    'LRCCD2016'. CSUS data came from the Sacramento State Human
    Resources Offices, UC Davis data came from the University of
    California Office of the President's Statistical Summary and Data.

6.  **Folding in Local Government Data** -- We have a pretty thorough
    list of local government data for the region compiled specifically
    for this update. The data comes primarily from city and county
    budget documents that detail the number of employees by department.
    The employment data is pretty accurate from this data source except
    for the larger jurisdictions where employees of the same department
    may be located at multiple sites. Major exceptions are City of
    Sacramento, County of Sacramento and Placer County. We used a
    combination of budget documents, InfoGroup data, additional
    city/county website research and personal knowledge in determining
    how many employees to place at various locations. Sacramento and
    Placer Counties have clustered areas of county offices and in some
    cases, there is one record that represents multiple sites within
    that clustered area. For the most part, the InfoGroup data for city
    and county government sites was incorrect and incomplete or there
    were many duplicates.

7.  **Folding in State Government Data** -- InfoGroup data for State
    government sites is not good, as there are missing departments,
    duplicates and incorrect employment counts across the board. Point
    level state government data is not available so SACOG developed its
    own database. Luis Elizondo used the following strategy in compiling
    a list of sites and employment numbers for each site.

> **1**. Visit State Agencies website at:
> <http://www.ca.gov/Apps/Agencies.aspx> browse through each website,
> some sites would have the number of employees in their 'about us'
> section of their site.
>
> **2**. Contact Personnel or Human Resource Dept. by email or phone.
>
> **3.** Additional Internet Research
>
> **4**. Ground truthing of some of the Smaller Agencies was conducted
> by driving by the building and viewing the parking lot in order to
> derive an estimate.
>
> **5.** Review Sacramento Business Journal and Past History Numbers
> (2015), but would double check for timeliness and accuracy
>
> **6.** This list is not a complete depiction of state government
> offices, we also used some InfoGroup data, but tried to compare it to
> other sources of information before accepting it as true. The focus
> was to include as much as possible, but not overstate the state
> government employment, particularly in the downtown area.

8.  **Folding in Hospital Data** -- Hospital data is generally very
    difficult to deal with. We have a relatively short list of
    'hospitals' that doesn't really cover medical that well because it
    doesn't include clinics or non-hospital sites such as most Kaiser
    locations. Site level hospital employment is also challenging as
    most SACOG area hospitals are part of a larger healthcare network
    and site level employment is not available. Our goal is to at least
    have records in place for major hospitals and major healthcare
    centers. InfoGroup lists dozens or even more than a hundred records
    at major hospitals which either duplicate or leave out substantial
    numbers of employees. In most cases for the inventory these records
    are deleted from the working database and a single record is placed
    at the site to capture all estimated employment at that site.

9.  **Folding in Large Employers** -- Large employer data primarily
    comes from the Sacramento Business Journal book of lists and other
    research sources. We used the 2016 Book of Lists as well as lists
    from the weekly Business Journal paper. There were a couple of
    companies that had different employee numbers ascribed to them in
    different lists, an assessment was made to determine the most
    reasonable number of employees at each location and assigned
    accordingly. Many large employers were not in the InfoGroup data, or
    if a record existed, the employee count was either zero, or an
    unreasonably low number. In a couple of instances, the InfoGroup
    data showed records that had unreasonably high numbers of employees,
    after confirming those numbers were incorrect, they were changed and
    'SACOG2016' was placed in the Source field.

10. Reviewing/Adjusting by NAICS code -- After the above adjustments had
    been made, the data was sorted by NAICS code to look for outliers.
    For example, if all major grocery stores were listed and most had
    employment of 80-100 and one store had employment of 20, we looked
    at that site and determined whether 20 was a reasonable employment
    number for that site or if it should be 80-100. Some of these
    adjustments could be made straight from the interpretation of the
    data. Other times this step resulted in additional records that
    needed to be further researched. Notes were assigned to them to
    follow up in remaining steps below.

11. Miscellaneous Adjustments

    a.  Dealing with records of zero employment -- most records with
        zero employment are ATM's or Redbox (or similar) sites, these
        have all been deleted from the inventory. In other cases, if
        InfoGroup doesn't have an employment estimate for a business
        they will leave a zero in the employment field. If a number
        hasn't been located for that record through the other processes
        that we go through, we undertook additional research to identify
        the number of employees at that site. In addition, many zero
        record employers are therapists of some sort that are assumed to
        work in an office with other therapists. An assessment is made
        of any other records at that location and a determination is
        made whether to keep the record or delete it, and if it is kept,
        to put in a reasonable number of employees for that site.

    b.  Dealing with locations such as malls and large shopping centers
        with many records -- separate research was undertaken to
        identify the number of employees at large malls and shopping
        centers. In many cases the InfoGroup data for those sites was
        incomplete or incorrect. In those cases, the InfoGroup records
        were deleted and a single record was placed at the site to
        capture all employment at that site.

    c.  Dealing with full-service restaurants -- through the cleaning
        process it was identified that there were numerous undercounts
        in the employment totals for many full-service restaurants.
        Primarily through personal knowledge, individual adjustments
        were made to better reflect the number of employees at each
        location. All restaurants that were designated 'Full-Service
        Restaurants' with 1-4 employees were adjusted to 5 employees.

    d.  Dealing with nail/hair salons -- through the cleaning process it
        was identified that there were numerous undercounts in the
        employment totals for many nail salons and beauty salons. Many
        salons contract space out to hair stylists, nail technicians and
        other types of independent contractors so do not count those
        persons as employees in their records. In some cases, individual
        names of stylists or technicians are in the database, but there
        are many missing. These records were sorted by NAICS code and
        then by address to determine the total employment count at each
        site. Some sites had both a nail salon and a beauty salon at the
        same site or multiple individual stylists at the same site. All
        salons that were in a retail area were viewed, for any salon
        that didn't have a combined total of 5 or more employees at each
        location, the employee record was adjusted to 5 employees. This
        process likely undercounts employees in some locations and
        overcounts them in others, but the effect is relatively small
        and more descriptive of the actual number of employees at a
        given site. Residential based salon employment was not adjusted
        as those appeared to be primarily work from home sites.

12. Review of remaining records tagged for additional review -- the
    final review was a mish mash of leftover records that needed further
    research to identify a reasonable number of employees at an
    individual site. A variety of research was conducted to best reflect
    the most reasonable employee estimate for each site.

List of Source Definitions:

INFOUSA2016 -- Original InfoGroup 2016 data

BIZJ16 -- Sacramento Business Journal 2016 data taken from weekly data
tables and year end 'Book of Lists' primarily for larger businesses in
the four county El Dorado-Placer-Sacramento-Yolo area.

CDCR2016 -- California Department of Corrections 2016 data on prison
employment

DOE1516 -- California State Department of Education 15/16 School Year as
accessed through the Dataquest website:
<http://data1.cde.ca.gov/dataquest/>

LRCCD2016 -- Los Rios Community College District 2016 data received from
LRCCD

SACOG16 -- Sacramento Area Council of Governments 2016 data that has
been researched by SACOG staff via personal knowledge, ground truthing,
and/or internet research.

SACBEE2016 -- Sacramento Bee 2016 data from articles as identified by
SACOG staff.
