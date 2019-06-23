clear all
macro drop _all
set more off
set mem 3000m

*** CREATE MAPS FOR THE CULTURE AND ASSETS PROJECT

* Need EU map and highlight (color) two different sets of countries:
* 1. HFCS wave 2
* 2. HFCS who shared RA0400 as collected


* Install mapping packages 
ssc install spmap
ssc install shp2dta
ssc install mif2dta
cd "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/maps/ref-countries-2016-60m/CNTR_BN_60M_2016_3035_COASTL"


* Convert shp and dbf files
shp2dta using CNTR_BN_60M_2016_3035_COASTL, database(eudb) coordinates(eucoord)

* There is a problem with the dbf file: "invalid dBase data type.
* -> follow advice from here: 
* https://www.statalist.org/forums/forum/general-stata-discussion/general/1456523-problems-with-shp2dta-and-spmap-mistake-that-leads-to-wrong-connections-on-map
* I opened dbf in Excel, pasted into Stata and saved as "eudb.dta"


* Open ends:
* Merge files (Need ids?)
* Figure out how to apply colors

