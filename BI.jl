### Adequacy of Guaranteed Minimum Income benefits as measured by Basic Income (BI)

# This indicator measures the income of jobless families relying on minimum-income safety-net benefits as a percentage of the median disposable income in the population. This can be compared with a poverty line defined as a fixed percentage of median income. For instance, if the poverty threshold is 50% of median income, a value of 30% means that benefit entitlements alleviate poverty risks of 60%

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

# year 2014
# include housing benefits (yes)
# hh: a) couple with two childen, spouse out of work b) single w/o kids

file_in_BI = "/Users/main/OneDrive - Istituto Universitario Europeo/data/OECD_BI/IA_19052019160633316.csv";
graphBI_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/BI_2014.pdf";
dataBI_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/BI_2014.csv";


df = DataFrame(CSV.read(file_in_BI; typemap=Dict(Union{Missing, Int64} => Int64, Union{Missing, String} => String)))

# Delete last two rows with flags (all missing)
deletecols!(df, [size(df,2)-1, size(df,2)])

# Keep only HFCS countries
HFCS_ctrs = ["Belgium", "Germany", "Estonia", "Ireland", "Greece", "Spain", "France", "Italy", "Cyprus", "Latvia", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal", "Slovenia", "Slovak Republic", "Finland"]
HFCS_ctrs = sort(HFCS_ctrs)
df_HFCS = df[∈(HFCS_ctrs).(df.Country), :]

# Keep only relevant variables
df = df_HFCS[:, [:Country, :FAMILY, :HBTOPUPS, :TIME, :Value]]

# Restrict sample
df1 = df[df[:TIME] .== 2014, :]       # year 2014
df2 = df1[df1[:HBTOPUPS] .== 1, :]                             # 1) include housing benefits
df3 = df2[∈(["1EARNERC2C", "SINGLE"]).(df2.FAMILY), :]  # 2) hh demographics

# Arrange by country  and family type
df_data = df3[:, [:Country, :FAMILY, :Value]]
df_data_plot = unstack(df_data, :Country, :FAMILY, :Value)
rename!(df_data_plot, Symbol("1EARNERC2C") => Symbol("Couple with two children, spouse out of work"), Symbol("SINGLE") => Symbol("Single without kids"))
sort!(df_data_plot, Symbol("Couple with two children, spouse out of work"))


# Plot

@df df_data_plot groupedbar(:Country, cols(2:size(df_data_plot,2)),
ylabel = "% of median disposable income",
title = "Guaranteed Minimum Income Benefits, 2014",
legend = :topleft,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
xrotation=45,
xlims = (0,20),
ylims = (0,110),
tick_direction = :out,
xgrid = false,
fg_legend = :transparent,
tickfont=font(8),
left_margin = 2mm,
bottom_margin = 2mm)
savefig(graphBI_out)

# Save data
CSV.write(dataBI_out, df_data_plot)
