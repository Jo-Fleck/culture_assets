### Generosity of Pension System as measured by NPRR

# The net replacement rate is defined as the individual net pension entitlement divided by net pre-retirement earnings, taking account of personal income taxes and social security contributions paid by workers and pensioners.

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

# year 2014
# average wage earners
# include housing benefits (yes)
# hh: a) couple with two childen, spouse out of work b) single w/o kids
# short vs. long duration of unemployment

file_in_NPRR = "/Users/main/OneDrive - Istituto Universitario Europeo/data/OECD_NPRR/PAG_2014_19052019171639703.csv";
graphNPRR_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NPRR_2014.pdf";
dataNPRR_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NPRR_2014.csv";

df = DataFrame(CSV.read(file_in_NPRR; typemap=Dict(Union{Missing, Int64} => Int64, Union{Missing, String} => String)))

df = df[:, [:Country, :IND, :Value,]]

# Keep only HFCS countries
HFCS_ctrs = ["Belgium", "Germany", "Estonia", "Ireland", "Greece", "Spain", "France", "Italy", "Cyprus", "Latvia", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal", "Slovenia", "Slovak Republic", "Finland"]
HFCS_ctrs = sort(HFCS_ctrs)
df_HFCS = df[∈(HFCS_ctrs).(df.Country), :]

# Replace Indicator with Gender
df_plot = unstack(df_HFCS, :Country, :IND, :Value)
rename!(df_plot, Symbol("PEN7B") => Symbol("male"), Symbol("PEN8B") => Symbol("female"))
sort!(df_plot, Symbol("female"))


# Plot

@df df_plot groupedbar(:Country, cols(2:size(df_plot,2)),
ylabel = "pension entitlement / pre retirement earnings",
title = "Net Pension Replacement Rates for average wage earners, 2014",
titlefont=font(12),
yaxis=font(9),
legend = :topleft,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
xrotation=45,
xlims = (0,size(df_plot,1)),
ylims = (0,110),
tick_direction = :out,
xgrid = false,
fg_legend = :transparent,
tickfont=font(8),
left_margin = 2mm,
bottom_margin = 0mm)
savefig(graphNPRR_out)

CSV.write(dataNPRR_out, df_plot)
