### Generosity of UI and Basic Income

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

## Import Replacement Rate and make into graph

# year 2014
# average wage earners
# include housing benefits (yes)
# hh: a) couple with two childen, spouse out of work b) single w/o kids
# short vs. long duration of unemployment

file_in_NRR = "/Users/main/OneDrive - Istituto Universitario Europeo/data/OECD_NRR/NRR_16052019011132558.csv";
graphNRR_fam_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_fam_2014.pdf";
graphNRR_single_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_single_2014.pdf";

df = DataFrame(CSV.read(file_in_NRR; typemap=Dict(Union{Missing, Int64} => Int64, Union{Missing, String} => String)))

# Delete last two rows with flags (all missing)
deletecols!(df, [size(df,2)-1, size(df,2)])

# Keep only HFCS countries
HFCS_ctrs = ["Belgium", "Germany", "Estonia", "Ireland", "Greece", "Spain", "France", "Italy", "Cyprus", "Latvia", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal", "Slovenia", "Slovak Republic", "Finland"]
HFCS_ctrs = sort(HFCS_ctrs)

df_HFCS = df[∈(HFCS_ctrs).(df.Country), :]

# Keep only relevant variables
df_data = df_HFCS[:, [:Country, :FAMILY, :DURATION, :EARNINGS, :HBTOPUPS, :TIME, :Value]]

# Keep only year 2014
df_data_2014 = df_data[∈([2014]).(df_data.TIME), :]

# 1) Average wage
df_data_2014 = df_data_2014[∈(["AW"]).(df_data_2014.EARNINGS), :]

# 2) include housing benefits
df_data_2014 = df_data_2014[∈([1]).(df_data_2014.HBTOPUPS), :]

# 3) hh demographics
df_data_2014 = df_data_2014[∈(["1EARNERC2C","SINGLE"]).(df_data_2014.FAMILY), :]

# 4) duration
# OECD definition: "Long-term unemployment refers to people who have been unemployed for 12 months or more": https://data.oecd.org/unemp/long-term-unemployment-rate.htm
# short term: less than 12 months
# long term: equal or more than 12 months
df_data_2014_st = df_data_2014[df_data_2014[:DURATION] .< 12, :]
df_data_2014_lt = df_data_2014[df_data_2014[:DURATION] .>= 12, :]

# 5) take average over st and lt durations
NRR_2014_st = by(df_data_2014_st, [:Country, :FAMILY], :Value => mean)
NRR_2014_st = sort(NRR_2014_st, :Country)
NRR_2014_st_fam = NRR_2014_st[∈(["1EARNERC2C"]).(NRR_2014_st.FAMILY), :]
NRR_2014_st_single = NRR_2014_st[∈(["SINGLE"]).(NRR_2014_st.FAMILY), :]

NRR_2014_lt = by(df_data_2014_lt, [:Country, :FAMILY], :Value => mean)
NRR_2014_lt = sort(NRR_2014_lt, :Country)
NRR_2014_lt_fam = NRR_2014_lt[∈(["1EARNERC2C"]).(NRR_2014_lt.FAMILY), :]
NRR_2014_lt_single = NRR_2014_lt[∈(["SINGLE"]).(NRR_2014_lt.FAMILY), :]


### Plot

# Family

data_plot_fam = [NRR_2014_st_fam.Value_mean; NRR_2014_lt_fam.Value_mean]  # needs to be appended for plotting
ctr_names = repeat(HFCS_ctrs, outer = 2)

groupedbar(ctr_names, data_plot_fam,
group = repeat(["Shortterm (<  12 mos)","Longterm (>= 12 mos)"], inner = 20),
ylabel = "% of previous wage",
title = "Net Replacement Rates for average wage earners, 2014\n(couple with two children, spouse out of work)\n ",
legend = :topleft,
legendfontvalign = :top,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
xticks = ([0.5:1:20.5;], HFCS_ctrs),
xrotation=45,
xlims = (0,20),
ylims = (0,110),
tick_direction = :out,
xgrid = false,
fg_legend = :transparent,
tickfont=font(8),
left_margin = 4mm,
bottom_margin = -1mm)
savefig(graphNRR_fam_out)

# Single

data_plot_single = [NRR_2014_st_single.Value_mean; NRR_2014_lt_single.Value_mean]  # needs to be appended for plotting
ctr_names = repeat(HFCS_ctrs, outer = 2)

groupedbar(ctr_names, data_plot_single,
group = repeat(["Shortterm (<  12 mos)","Longterm (>= 12 mos)"], inner = 20),
ylabel = "% of previous wage",
title = "Net Replacement Rates for average wage earners, 2014\n(single without kids)\n ",
legend = :topleft,
legendfontvalign = :top,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
xticks = ([0.5:1:20.5;], HFCS_ctrs),
xrotation=45,
xlims = (0,20),
ylims = (0,110),
tick_direction = :out,
xgrid = false,
fg_legend = :transparent,
tickfont=font(8),
left_margin = 4mm,
bottom_margin = -1mm)
savefig(graphNRR_single_out)
