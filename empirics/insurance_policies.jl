### Generosity of UI as measured by UI NRRs

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
rename!(df_fam_plot, Symbol("0") => :longterm, Symbol("1") => :shortterm)
permutecols!(df_fam_plot, [:Country, :shortterm, :longterm])
sort!(df_fam_plot, :shortterm)

# Single
df_single = df_data_plot[∈(["SINGLE"]).(df_data_plot.FAMILY), :]
df_single_plot = unstack(df_single, :Country, :SHORTTERM, :Value_mean)
rename!(df_single_plot, Symbol("0") => :longterm, Symbol("1") => :shortterm)
permutecols!(df_single_plot, [:Country, :shortterm, :longterm])
sort!(df_single_plot, :shortterm)

# Plot

@df df_fam_plot groupedbar(:Country, cols(2:size(df_fam_plot,2)),
ylabel = "% of previous wage",
xlabel = "shortterm (< 12 mos); longterm (>= 12 mos)",
title = "Net Replacement Rates for average wage earners, 2014\n(couple with two children, spouse out of work)\n ",
legend = :topleft,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
#xticks = ([0.5:1:20.5;], HFCS_ctrs),
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
xlabel = "shortterm (< 12 mos); longterm (>= 12 mos)",
title = "Net Replacement Rates for average wage earners, 2014\n(single without kids)\n ",
legend = :topleft,
background_color_legend = false,
bar_width = 0.67,
lw = 0,
markerstrokewidth = 1.5,
size = (600, 400),
#xticks = ([0.5:1:20.5;], HFCS_ctrs),
xrotation=45,
xlims = (0,20),
ylims = (0,110),
tick_direction = :out,
xgrid = false,
fg_legend = :transparent,
tickfont=font(8),
left_margin = 2mm,
bottom_margin = 2mm)
savefig(graphNRR_single_out)







df_fam[:shortterm] =
df_fam_plot = df_fam[:, [:Country, :SHORTTERM, :Value]]

sort!(df_plot_fam, [:SHORTTERM, :Value_mean])

df_plot_single = df_data_plot[∈(["SINGLE"]).(df_data_plot.FAMILY), :]
sort!(df_plot_single, [:SHORTTERM, :Value_mean])

# Plot











df_plot_single_st
df_plot_single_lt


# sort: 1. st vs lt 2. family 3. country
sort!(df_data_plot, [:SHORTTERM, :FAMILY, :Country]);

### Plot
data_plot_fam = [NRR_2014_st_fam.Value_mean; NRR_2014_lt_fam.Value_mean]  # needs to be appended for
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
savefig(graphNRR_fam_out_new)










# Plot levels
@df df_data_plot groupedbar(:Country, cols(2:size(df_data_plot,2)),
#bar_position = :stack,
title="Total State Spending in 2017",
yaxis="% in current USD",
legend=:best,
#xticks = ([0:1:20;], df_data_plot.Country),
xrotation=90,
tickfont=font(6),
#xlims = (0,50),
tick_direction = :out,
xgrid = false,
left_margin = 0mm,
bottom_margin = 6mm)






# Family

data_plot_fam = [NRR_2014_st_fam.Value_mean; NRR_2014_lt_fam.Value_mean]  # needs to be appended for
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
