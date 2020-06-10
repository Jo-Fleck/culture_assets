### Generosity of UI as measured by NRRs

using CSV, DataFrames, StatsBase, Statistics
using Plots, Plots.PlotMeasures, StatsPlots; gr()

# year 2014
# average wage earners
# include housing benefits (yes)
# hh: a) couple with two childen, spouse out of work b) single w/o kids
# short vs. long duration of unemployment

file_in_NRR = "/Users/main/OneDrive - Istituto Universitario Europeo/data/OECD_NRR/NRR_16052019011132558.csv";
graphNRR_fam_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_fam_2014.pdf";
graphNRR_single_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_single_2014.pdf";
dataNRR_fam_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_fam_2014.csv";
dataNRR_single_out = "/Users/main/Documents/Dropbox/!!EUI/Research/Culture_Assets/Insurance_policies/NRR_single_2014.csv";


df = DataFrame(CSV.read(file_in_NRR; typemap=Dict(Union{Missing, Int64} => Int64, Union{Missing, String} => String)))

# Delete last two rows with flags (all missing)
deletecols!(df, [size(df,2)-1, size(df,2)])

# Keep only HFCS countries
HFCS_ctrs = ["Belgium", "Germany", "Estonia", "Ireland", "Greece", "Spain", "France", "Italy", "Cyprus", "Latvia", "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal", "Slovenia", "Slovak Republic", "Finland"]
HFCS_ctrs = sort(HFCS_ctrs)
df_HFCS = df[∈(HFCS_ctrs).(df.Country), :]

# Keep only relevant variables
df = df_HFCS[:, [:Country, :FAMILY, :DURATION, :EARNINGS, :HBTOPUPS, :TIME, :Value]]

# Restrict sample
df[df[:TIME] .= 2014, :]       # year 2014
df[df[:HBTOPUPS] .= 1, :]                             # 1) include housing benefits
df1 = df[∈(["1EARNERC2C", "SINGLE"]).(df.FAMILY), :]  # 2) hh demographics
df2 = df1[∈(["AW"]).(df1.EARNINGS), :]                # 3) average wage

# 4) duration
# OECD definition: "Long-term unemployment refers to people who have been unemployed for 12 months or more": https://data.oecd.org/unemp/long-term-unemployment-rate.htm
# short term: less than 12 months
# long term: equal or more than 12 months

df2[:SHORTTERM] = zeros(Int64, size(df2, 1))
for i in 1:nrow(df2)
    if df2.DURATION[i] < 12
        df2.SHORTTERM[i] = 1
    end
end

df_data = df2[:, [:Country, :FAMILY, :SHORTTERM, :Value]]

# Average by country, family type and st vs lt
df_data_plot = by(df_data, [:Country, :FAMILY, :SHORTTERM], :Value => mean)

# Arrange in  different hh groups

# Family
df_fam = df_data_plot[∈(["1EARNERC2C"]).(df_data_plot.FAMILY), :]
df_fam_plot = unstack(df_fam, :Country, :SHORTTERM, :Value_mean)
rename!(df_fam_plot, Symbol("0") => Symbol("longterm (>= 12 mos)"), Symbol("1") => Symbol("shortterm (< 12 mos)"))
permutecols!(df_fam_plot, [:Country, Symbol("shortterm (< 12 mos)"), Symbol("longterm (>= 12 mos)")])
sort!(df_fam_plot, Symbol("shortterm (< 12 mos)"))

# Single
df_single = df_data_plot[∈(["SINGLE"]).(df_data_plot.FAMILY), :]
df_single_plot = unstack(df_single, :Country, :SHORTTERM, :Value_mean)
rename!(df_single_plot, Symbol("0") => Symbol("longterm (>= 12 mos)"), Symbol("1") => Symbol("shortterm (< 12 mos)"))
permutecols!(df_single_plot, [:Country, Symbol("shortterm (< 12 mos)"), Symbol("longterm (>= 12 mos)")])
sort!(df_single_plot, Symbol("shortterm (< 12 mos)"))

# Plot

@df df_fam_plot groupedbar(:Country, cols(2:size(df_fam_plot,2)),
ylabel = "% of previous wage",
title = "Net Replacement Rates for average wage earners, 2014\n(couple with two children, spouse out of work)\n ",
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
savefig(graphNRR_fam_out)


@df df_single_plot groupedbar(:Country, cols(2:size(df_single_plot,2)),
ylabel = "% of previous wage",
title = "Net Replacement Rates for average wage earners, 2014\n(single without kids)\n ",
legend = :topleft,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
xrotation=45,
xlims = (0,20),
ylims = (0,100),
tick_direction = :out,
xgrid = false,
fg_legend = :transparent,
tickfont=font(8),
left_margin = 2mm,
bottom_margin = 2mm)
savefig(graphNRR_single_out)

# Save data
CSV.write(dataNRR_fam_out, df_fam_plot)
CSV.write(dataNRR_single_out, df_single_plot)
