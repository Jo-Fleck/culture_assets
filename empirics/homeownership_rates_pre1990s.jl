
### Homeownership rates for table 25 countries pre 1990


## Open Ends

# Explore if NFAMS > 1 makes a difference...
# Consider computing decade averages
# How to get more countries/years efficiently? (IPUMS does not yet have API!)


## Housekeeping

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

dir_out = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/";

# Import countrycodes and -names
file_country_info = "/Users/main/OneDrive - Istituto Universitario Europeo/data/IPUMS_international/ipums_int_country_codes.csv";
df_country_info = CSV.read(file_country_info, DataFrame;  types=[Int64, String]);
country_dic = Dict(df_country_info.COUNTRYCODE .=> df_country_info.COUNTRYNAME); # Generate country dictionary


## Import and prepate data

file_data = "/Users/main/Downloads/ipumsi_00004.csv";
df = CSV.read(file_data, DataFrame);
select!(df, Not([:GQ, :REGIONW, :SAMPLE, :OWNERSHIPD, :PERSONS, :PERWT, :URBAN, :RESIDENT, :BEDROOMS, :ROOMS])); # Drop redundant variables


## Compute homeownership rate

# Keep only one obs per household
filter!(row -> row.PERNUM == 1, df);
select!(df, Not(:PERNUM));

# Keep only informative OWNERSHIP values
# 0	NIU (not in universe)
# 1	Owned
# 2	Not owned
# 9	Unknown
dropmissing!(df, :OWNERSHIP);
filter!(row -> (row.OWNERSHIP == 1 || row.OWNERSHIP == 2), df);
replace!(df.OWNERSHIP, 2=>0); # change renters to 0 so mean is homeownership rate

gdf = groupby(df, [:COUNTRY, :YEAR]);
df_main = combine(gdf, nrow => :observations, :OWNERSHIP => ( p -> ( b = round(mean(p),digits=2) )) => :ownership_rate, [:OWNERSHIP, :HHWT] => ((o, w) -> ( a = round(mean(o, weights(w)), digits=2) )) => :ownership_rate_weighted);
insertcols!(df_main, 1, :COUNTRYNAME => map(x -> country_dic[x], df_main[!, :COUNTRY]));
select!(df_main, Not(:COUNTRY));

df_ownership_rate = unstack(df_main, :COUNTRYNAME, :YEAR, :ownership_rate);
df_ownership_rate_weighted = unstack(df_main, :COUNTRYNAME, :YEAR, :ownership_rate_weighted);
df_ownership_rate_observations = unstack(df_main, :COUNTRYNAME, :YEAR, :observations);

CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate.csv", df_main);
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate_long.csv", df_ownership_rate);
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate_weighted_long.csv", df_ownership_rate_weighted);
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate_observations_long.csv", df_ownership_rate_observations);
