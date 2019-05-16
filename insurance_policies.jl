# Generosity of UI and Basic Income

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

# Import Replacement Rate and make into graph

file_in_NRR = "/Users/main/OneDrive - Istituto Universitario Europeo/data/OECD_NRR/NRR_16052019011132558.csv";
graphNRR_fam_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_fam_2015.pdf";
graphNRR_single_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_single_2015.pdf";

df = DataFrame(CSV.read(file_in_NRR; typemap=Dict(Union{Missing, Int64} => Int64, Union{Missing, String} => String)))

# Delete last two rows with flags (all missing)
deletecols!(df, [size(df,2)-1, size(df,2)])

# Keep only HFCS countries
HFCS_ctrs = ["Belgium", "Germany", "Estonia", "Ireland", "Greece", "Spain", "France", "Italy", "Cyprus", "Latvia", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal", "Slovenia", "Slovakia", "Finland"]
HFCS_ctrs = sort(HFCS_ctrs)

df_HFCS = df[∈(HFCS_ctrs).(df.Country), :]

# Split into data and labels
df_data = df_HFCS[:, [:LOCATION, :FAMILY, :DURATION, :EARNINGS, :HBTOPUPS, :TIME, :Value]]
df_label = df_HFCS[:, [2,4,6,8,10,12]]

# Keep only year 2005
df_data_2005 = df_data[∈([2005]).(df_data.TIME), :]

# year 2014
# average wage
# include housing benefits (yes)
# a) couple with two childen, spouse out of work b) single w/o kids
# short vs. long duration. (bars next to each other)

# 1) Average wage
df_data_2005 = df_data_2005[∈(["AW"]).(df_data_2005.EARNINGS), :]

# 2) include housing benefits
df_data_2005 = df_data_2005[∈([1]).(df_data_2005.HBTOPUPS), :]

# 3) hh demographics
df_data_2005 = df_data_2005[∈(["1EARNERC2C","SINGLE"]).(df_data_2005.FAMILY), :]

# 4) duration
# OECD definition: "Long-term unemployment refers to people who have been unemployed for 12 months or more": https://data.oecd.org/unemp/long-term-unemployment-rate.htm
# short term: less than 12 months
# long term: equal or more than 12 months
df_data_2005_st = df_data_2005[df_data_2005[:DURATION] .< 12, :]
df_data_2005_lt = df_data_2005[df_data_2005[:DURATION] .>= 12, :]

# 5) take average over st and lt durations
NRR_2015_st = by(df_data_2005_st, [:LOCATION, :FAMILY], :Value => mean)
NRR_2015_lt = by(df_data_2005_lt, [:LOCATION, :FAMILY], :Value => mean)

### Plot

ctr_names = repeat(HFCS_ctrs, outer = 2)

groupedbar(ctr_names, rand(40, 1),
group = repeat(["Short-term (< 12 mos)", "Long-term (>= 12 mos)"], inner = 20),
ylabel = "% of previous wage",
title="Net Replacement Rates for average wage earners, 2015\n(couple with two children, spouse out of work)",
legend = :best,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
xticks = ([0.5:1:20.5;], HFCS_ctrs),
xrotation=45,
xlims = (0,20),
ylims = (0,1),
tick_direction = :out,
xgrid = false,
#bar_position = :stacked,
tickfont=font(8),
left_margin = 4mm,
bottom_margin = 4mm)
savefig(graphNRR_fam_out)


# mn = [20, 35, 30, 35, 27,25, 32, 34, 20, 25, 20, 35, 30, 35, 27,25, 32, 34, 20, 25,20, 35, 30, 35, 27,25, 32, 34, 20, 25, 20, 35, 30, 35, 27,25, 32, 34, 20, 25]
# sx = repeat(["Men", "Women"], inner = 20)
# std = [2, 3, 4, 1, 2, 3, 5, 2, 3, 3,2, 3, 4, 1, 2, 3, 5, 2, 3, 3,2, 3, 4, 1, 2, 3, 5, 2, 3, 3,2, 3, 4, 1, 2, 3, 5, 2, 3, 3]
# nam = repeat("G" .* string.(1:20), outer = 2)
# groupedbar(nam, mn,
# #yerr = std,
# group = sx,
# ylabel = "Scores",
# title = "Scores by group and gender",
# bar_width = 0.67,
# lw = 0,
# #c = [:red :darkkhaki],
# markerstrokewidth = 1.5,
# xrotation=90,
# #framestyle = :box,
# #grid = false,
# yticks = 0:20:140)









# ctg = repeat(["Category 1", "Category 2"], inner = 5)
# nam = repeat("G" .* string.(1:10), outer = 2)
#
# groupedbar(nam, rand(10, 2), group = ctg, xlabel = "Groups", ylabel = "Scores",
#         title = "Scores by group and category", bar_width = 0.37,
#         lw = 4.5, framestyle = :box)
#
#



# Get Basic Income summaries (LPD) and make graph
