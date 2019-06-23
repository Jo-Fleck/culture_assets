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
cd "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/maps"

shp2dta using CNTR_BN_01M_2016_3035_COASTL, database(eudb) coordinates(eucoord) genid(id)

