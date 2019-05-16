# Generosity of UI and Basic Income

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures; gr()

# Import Replacement Rate and make into graph

file_in_NRR = "/Users/main/OneDrive - Istituto Universitario Europeo/data/OECD_NRR/NRR_16052019011132558.csv";

df = DataFrame(CSV.read(file_in_NRR; typemap=Dict(Union{Missing, Int64} => Int64, Union{Missing, String} => String)))

# Delete last two rows with flags (all missing)
deletecols!(df, [size(df,2)-1, size(df,2)])

# Keep only HFCS countries
HFCS_ctrs = ["Belgium", "Germany", "Estonia", "Ireland", "Greece", "Spain", "France", "Italy", "Cyprus", "Latvia", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal", "Slovenia", "Slovakia", "Finland"]
df_HFCS = df[∈(HFCS_ctrs).(df.Country), :]

# Split into data and labels
df_data = df_HFCS[:, [:LOCATION, :FAMILY, :DURATION, :EARNINGS, :HBTOPUPS, :TIME, :Value]]
df_label = df_HFCS[:, [2,4,6,8,10,12]]

# Keep only year 2005
df_data_2005 = df_data[∈([2005]).(df_data.TIME), :]




test = unique(df_label.Country)

unique(df.FAMILY)

# Get Basic Income summaries (LPD) and make graph
