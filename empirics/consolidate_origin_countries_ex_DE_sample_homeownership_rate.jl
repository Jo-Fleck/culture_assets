
### Consolidate IPUMS international homeownership rates of different periods + UN data


## Housekeeping

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

dir_out = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/";

file_IPUMSI_pre_1990 = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/pre_1990_origin_countries_ex_DE_sample_homeownership_rate_long.csv";
file_IPUMSI_1990s = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/1990s_origin_countries_ex_DE_sample_homeownership_rate_long.csv";
file_IPUMSI_2000s = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/2000s_origin_countries_ex_DE_sample_homeownership_rate_long.csv";
file_UN = "/Users/main/Documents/Dropbox/Research/Culture_Assets/homeownership_rates/Homeownership_rates_UN_Wiki - UN long.csv";


## Import IPUMSI files, merge and save

df_IPUMSI_pre_1990 = CSV.read(file_IPUMSI_pre_1990, DataFrame);
df_IPUMSI_1990s = CSV.read(file_IPUMSI_1990s, DataFrame);
df_IPUMSI_2000s = CSV.read(file_IPUMSI_2000s, DataFrame);

df_IPUMSI = outerjoin(df_IPUMSI_pre_1990, df_IPUMSI_1990s, df_IPUMSI_2000s, on = :COUNTRYNAME); # Merge IPUMSI data
sort!(df_IPUMSI, :COUNTRYNAME);

CSV.write(dir_out * "IPUMSI_origin_countries_ex_DE_sample_homeownership_rate.csv", df_IPUMSI);


## Merge IPUMSI and UN data and save. Take average if values for country/year exist in both

df_UN = CSV.read(file_UN, DataFrame);
df_IPUMSI_UN_tmp1 = outerjoin(df_IPUMSI, df_UN, on = :COUNTRYNAME, makeunique = true);

# Drop columns with only missing
cols_missing = filter(c -> eltype(df_IPUMSI_UN_tmp1[:,c]) == Missing, names(df_IPUMSI_UN_tmp1));
df_IPUMSI_UN_tmp2 = select(df_IPUMSI_UN_tmp1, Not(cols_missing));

# Sort columns by year
cols_sorted = [names(df_IPUMSI_UN_tmp2)[1]; sort(names(df_IPUMSI_UN_tmp2)[2:end])];
df_IPUMSI_UN_tmp_sorted = select(df_IPUMSI_UN_tmp2, cols_sorted);

# Find duplicate years
cols = sort(names(df_IPUMSI_UN_tmp2)[2:end]);
cols_duplicate = cols[occursin.("_1", cols)];

# Take average of duplicate values
df_IPUMSI_UN = deepcopy(df_IPUMSI_UN_tmp_sorted)
for (idx, col) in enumerate(cols_duplicate)
    col_yr_tmp = split(col,"_")[1]
    col_yr   = Symbol("$col_yr_tmp")
    col_yr_1 = Symbol("$col")

    for i = 1:size(df_IPUMSI_UN,1)

        val1 = df_IPUMSI_UN[i,col_yr]
        val2 = df_IPUMSI_UN[i,col_yr_1]

        if ismissing(val1) && ismissing(val2)
            df_IPUMSI_UN[i,col_yr] = missing
        elseif !ismissing(val1) && ismissing(val2)
            df_IPUMSI_UN[i,col_yr] = val1
        elseif ismissing(val1) && !ismissing(val2)
            df_IPUMSI_UN[i,col_yr] = val2
        else
            df_IPUMSI_UN[i,col_yr] = mean([val1,val2])
        end
    end

end

df_IPUMSI_UN_final = select(df_IPUMSI_UN, Not(cols_duplicate));

CSV.write(dir_out * "IPUMSI_UN_origin_countries_ex_DE_sample_homeownership_rate.csv", df_IPUMSI_UN_final);
