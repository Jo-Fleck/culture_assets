
### Pre 1990 homeownership rates for origin countries excluding those in DE sample


## Open Ends

# Countries not organized into households: Each person has unique SERIAL (and PERNUM = PERSONS = 1 & HHWT = PERWT for all obs)
# -> Code is robust

# Consider computing decade averages


## Housekeeping

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

period = "pre_1990";
file_data = "/Users/main/Downloads/ipumsi_00008.csv";

dir_out = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/";

# Import countrycodes and -names
file_country_info = "/Users/main/OneDrive - Istituto Universitario Europeo/data/IPUMS_international/ipums_int_country_codes.csv";
df_country_info = CSV.read(file_country_info, DataFrame;  types=[Int64, String]);
country_dic = Dict(df_country_info.COUNTRYCODE .=> df_country_info.COUNTRYNAME); # Generate country dictionary


## Import and prepate data

df0 = CSV.read(file_data, DataFrame);
select!(df0, [:COUNTRY, :YEAR, :PERNUM, :OWNERSHIP, :HHWT]); # Keep only relevant variables

# Change country codes to names
insertcols!(df0, 1, :COUNTRYNAME => map(x -> country_dic[x], df0[!, :COUNTRY]));
select!(df0, Not(:COUNTRY));

# Assign East and West to Germany
for i = 1:size(df0,1)
    if df0.COUNTRYNAME[i] == "Germany" && ( df0.YEAR[i] == 1970 || df0.YEAR[i] == 1987) df0.COUNTRYNAME[i] = "Germany West" end
    if df0.COUNTRYNAME[i] == "Germany" && ( df0.YEAR[i] == 1971 || df0.YEAR[i] == 1981) df0.COUNTRYNAME[i] = "Germany East" end
end

df = deepcopy(df0);

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


## Diagnostics on missing countries

df_missing_countries = antijoin(df_countries_sample, df_result, on = [:COUNTRYNAME, :YEAR]);

println("");
for i = 1:size(df_missing_countries,1)
    df_tmp = filter(row -> (row.COUNTRYNAME == df_missing_countries.COUNTRYNAME[i] && row.YEAR == df_missing_countries.YEAR[i]), df0); # -> OWNERSHIP is missing
    ownership_missings = sum(ismissing.(df_tmp.OWNERSHIP))
    obs = size(df_tmp,1)
    if ownership_missings == obs
        printstyled(df_missing_countries.COUNTRYNAME[i] * " (" * string(df_missing_countries.YEAR[i]) * ")  -> no homeownership data\n"; bold = true, color = :red)
    else
        printstyled(df_missing_countries.COUNTRYNAME[i] * " (" * string(df_missing_countries.YEAR[i]) * ") has homeownership data but something is wrong\n"; bold = true, color = :blue)
    end
end

# Print result countries/years to the console
println("");
printstyled("Results: countries and years\n"; bold = true, color = :blue);
println("");
print(select(df_result,[:COUNTRYNAME, :YEAR]));
println("");
println("");


## Save results

df_ownership_rate = unstack(df_result, :COUNTRYNAME, :YEAR, :ownership_rate);
df_ownership_rate_weighted = unstack(df_result, :COUNTRYNAME, :YEAR, :ownership_rate_weighted);

CSV.write(dir_out * period * "_origin_countries_ex_DE_sample_homeownership_rate.csv", df_result);
CSV.write(dir_out * period * "_origin_countries_ex_DE_sample_homeownership_rate_long.csv", df_ownership_rate);
CSV.write(dir_out * period * "_origin_countries_ex_DE_sample_homeownership_rate_weighted_long.csv", df_ownership_rate_weighted);
