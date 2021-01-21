
### Compute historical (pre 1990) home-ownership rates

# IPUMS international data; contains a subset of our origin countries for different years


## Housekeeping

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

dir_out = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership _rates/";

file_IPUMS_international = "/Users/main/OneDrive - Istituto Universitario Europeo/data/ACS_property_taxes/usa_00026.csv";
df_in = CSV.read(file_IPUMS_international, DataFrame);




## Plot and save

savefig(dir_out * "Homeownership_rates_IPUMS_international.pdf")

CSV.write(dir_out * "Homeownership_rates_IPUMS_international.csv", df_ACS_1_hh_plot);
