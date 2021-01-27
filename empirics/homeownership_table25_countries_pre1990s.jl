
### Homeownership rates for table 25 countries pre 1990


## Open Ends

# What about countries not organized into households? Chile 1960, Germany 1970, Mexico 1960, Netherlands 1960, 1971, Pakistan 1981, Spain 1981
# Consider computing decade averages

# Done:
# Germany - West: 1970, 1987; East: 1971, 1981

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
df_in = CSV.read(file_data, DataFrame);
df = select!(df_in, Not([:GQ, :REGIONW, :SAMPLE, :OWNERSHIPD, :PERSONS, :PERWT, :URBAN, :RESIDENT, :BEDROOMS, :ROOMS])); # Drop redundant variables

# Change country codes to names
insertcols!(df, 1, :COUNTRYNAME => map(x -> country_dic[x], df[!, :COUNTRY]));
select!(df, Not(:COUNTRY));

# Assign East and West to Germany
for i = 1:size(df,1)
    if df.COUNTRYNAME[i] == "Germany" && ( df.YEAR[i] == 1970 || df.YEAR[i] == 1987) df.COUNTRYNAME[i] = "Germany West" end
    if df.COUNTRYNAME[i] == "Germany" && ( df.YEAR[i] == 1971 || df.YEAR[i] == 1981) df.COUNTRYNAME[i] = "Germany East" end
end

# Print sample countries/years to the console
gdf_countries_sample = groupby(df, [:COUNTRYNAME, :YEAR]);
df_countries_sample = combine(gdf_countries_sample, :COUNTRYNAME => unique => :countryname, :YEAR => unique => :year);
select!(df_countries_sample, [:COUNTRYNAME, :YEAR]);

println("");
printstyled("Sample: countries and years\n"; bold = true, color = :green);
println("");
print(df_countries_sample);
println("");
println("");


## Compute homeownership rate

# Keep only one obs per household
filter!(row -> row.PERNUM == 1, df);
select!(df, Not(:PERNUM));

# Keep only informative OWNERSHIP values
# 0: NIU (not in universe); 1 Owned; 2 Not owned; 9 Unknown
dropmissing!(df, :OWNERSHIP);
filter!(row -> (row.OWNERSHIP == 1 || row.OWNERSHIP == 2), df);
replace!(df.OWNERSHIP, 2=>0); # change renters to 0 so mean is homeownership rate

gdf_result = groupby(df, [:COUNTRYNAME, :YEAR]);
df_result = combine(gdf_result, nrow => :observations, :OWNERSHIP => ( p -> ( b = round(mean(p),digits=2) )) => :ownership_rate, [:OWNERSHIP, :HHWT] => ((o, w) -> ( a = round(mean(o, weights(w)), digits=2) )) => :ownership_rate_weighted);

# Print result countries/years to the console
println("");
printstyled("Results: countries and years\n"; bold = true, color = :red);
println("");
print(select(df_result,[:COUNTRYNAME, :YEAR]));
println("");
println("");

df_ownership_rate = unstack(df_result, :COUNTRYNAME, :YEAR, :ownership_rate);
df_ownership_rate_weighted = unstack(df_result, :COUNTRYNAME, :YEAR, :ownership_rate_weighted);
df_ownership_rate_observations = unstack(df_result, :COUNTRYNAME, :YEAR, :observations);

# Save
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate.csv", df_result);
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate_long.csv", df_ownership_rate);
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate_weighted_long.csv", df_ownership_rate_weighted);
CSV.write(dir_out * "table25_countries_pre_1990_homeownership_rate_observations_long.csv", df_ownership_rate_observations);


## Diagnostics

df_missing_countries_years = antijoin(df_countries_sample, df_result, on = [:COUNTRYNAME, :YEAR])
