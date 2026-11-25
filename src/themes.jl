#=
Themes for data plots (lines, scatter, bars, contours).

Figure units are typographic points: a figure of size `reportsize(…)` embedded at its natural size
(save with `savereport`, PDF/SVG at 1 pt per unit) prints its text at the theme's `fontsize`
(9 pt default).

    kjl_light   white background, left + bottom spines, black, ticks outside
    kjl_grid    light-gray panel, no ticks, white gridlines (the old `graystyle!` look)
    kjl_dark    kjl_light inverted (slides)
    kjl_theme(; style = :light | :grid, dark = false, fontsize = 9, aspect = 1)   for variants,
                e.g. `aspect = nothing` for stacked panels

Fonts: IBM Plex Mono for axis labels, tick labels, legends and text; IBM Plex Sans Bold for
titles. Write labels in CAPS (`caps("displacement [mm]")` keeps units, Greek and `{…}` as
typed; `capslabels!(fig)` does a whole figure).

Colour cycles follow the emphasis rule: the first series is kjl_blue, the rest grayscale.
Lines cycle colour only (so structure drawings stay solid); for several data series spread
`kjl_series(i)` into the plot call: `lines!(ax, x, y; kjl_series(i)...)`.
=#

const KJL_MONO = "IBM Plex Mono"
const KJL_TITLE = "IBM Plex Sans Bold"

# legacy constants (themes_mono.jl uses them)
tickFontSize = 12
labelFontSize = 14
titleFontSize = 14
typeface = "Arial"

"""
    kjl_theme(; style = :light, dark = false, fontsize = 9, aspect = 1, size = reportsize(0.5))

Build a kjlMakie data-plot theme. `style = :light` (white, ticks inside) or `:grid` (light-gray
panel, white gridlines, no ticks); `dark = true` inverts the colours. `aspect = nothing` lets
panels fill their layout cell (stacked plots). Text sizes are in points when the figure is
saved with `savereport`.
"""
function kjl_theme(; style::Symbol = :light, dark::Bool = false, fontsize::Real = 9,
    aspect = 1, size = reportsize(0.5))

    style in (:light, :grid) || error("style must be :light or :grid")
    grid = style === :grid
    fs = fontsize
    tfs = fs - 1                                     # tick labels
    ink = dark ? colorant"#ffffff" : kjl_black
    soft = ink                                       # spines, ticks, tick labels: black (Keith 2026-11-24)
    panel = grid ? (dark ? colorant"#2a2a2a" : kjl_panelgray) : :transparent
    gridc = dark ? colorant"#000000" : colorant"#ffffff"
    lw = 0.6                                         # spine / tick width [pt]

    series_colors = [kjl_blue, ink, soft, kjl_midgray, kjl_lightgray]

    axis = (
        aspect = aspect,
        backgroundcolor = panel,
        xlabelfont = :regular, ylabelfont = :regular,
        xticklabelfont = :regular, yticklabelfont = :regular,
        titlefont = :bold,
        xlabelsize = fs, ylabelsize = fs,
        xticklabelsize = tfs, yticklabelsize = tfs,
        titlesize = fs + 1,
        titlealign = :left,
        titlegap = 4,
        xlabelpadding = 2, ylabelpadding = 3,
        xticklabelpad = 2, yticklabelpad = 2,
        xticklabelcolor = soft, yticklabelcolor = soft,
        xlabelcolor = ink, ylabelcolor = ink, titlecolor = ink,
        topspinevisible = false, rightspinevisible = false,
        leftspinecolor = soft, bottomspinecolor = soft,
        spinewidth = lw,
        xticksvisible = !grid, yticksvisible = !grid,
        xtickalign = 0, ytickalign = 0,                 # ticks OUTSIDE the spines
        xticksmirrored = false, yticksmirrored = false,
        xticksize = 3, yticksize = 3,
        xtickwidth = lw, ytickwidth = lw,
        xtickcolor = soft, ytickcolor = soft,
        xminorticksvisible = false, yminorticksvisible = false,
        xgridvisible = grid, ygridvisible = grid,
        xgridcolor = gridc, ygridcolor = gridc,
        xgridwidth = 1.0, ygridwidth = 1.0,
    )

    axis3 = (
        aspect = :data,
        backgroundcolor = :transparent,
        titlefont = :bold, titlesize = fs + 1, titlealign = :left,
        xlabelfont = :regular, ylabelfont = :regular, zlabelfont = :regular,
        xticklabelfont = :regular, yticklabelfont = :regular, zticklabelfont = :regular,
        xlabelsize = fs, ylabelsize = fs, zlabelsize = fs,
        xticklabelsize = tfs, yticklabelsize = tfs, zticklabelsize = tfs,
        xgridcolor = kjl_lightgray, ygridcolor = kjl_lightgray, zgridcolor = kjl_lightgray,
        azimuth = -3pi / 4,
        elevation = pi / 8,
    )

    return Theme(
        size = size,
        fontsize = fs,
        figure_padding = 4,
        textcolor = ink,
        backgroundcolor = dark ? :black : :transparent,
        fonts = (regular = KJL_MONO, bold = KJL_TITLE, italic = "IBM Plex Mono Italic",
            bold_italic = "IBM Plex Mono Bold Italic"),

        palette = (color = series_colors,
            linestyle = [:solid, :dash, :dot, :dashdot, Linestyle([0.0, 4.0, 6.0, 10.0])],
            marker = [:circle, :rect, :utriangle, :diamond, :xcross]),

        Axis = axis,
        Axis3 = axis3,

        # colour-only cycles: structure drawings made of many lines! calls must stay solid.
        # For several data series use `kjl_series(i)` (blue solid, then grays with dashes).
        Lines = (linewidth = 1.5, cycle = [:color]),
        Scatter = (markersize = 6, strokewidth = 0, cycle = Cycle([:color, :marker]; covary = true)),
        ScatterLines = (linewidth = 1.5, markersize = 5, strokewidth = 0,
            cycle = Cycle([:color, :marker]; covary = true)),
        HLines = (linewidth = 0.8, color = kjl_midgray, linestyle = :dash, cycle = []),
        VLines = (linewidth = 0.8, color = kjl_midgray, linestyle = :dash, cycle = []),
        BarPlot = (color = kjl_blue, gap = 0.25, strokewidth = 0),
        Hist = (color = kjl_blue, strokewidth = 0),
        Band = (color = (kjl_blue, 0.2),),

        Heatmap = (colormap = kjl_sequential,),
        Surface = (colormap = kjl_sequential,),
        Mesh = (colormap = kjl_sequential,),
        Contourf = (colormap = kjl_sequential,),
        Spy = (colormap = trans2black,),

        Colorbar = (labelfont = :regular, ticklabelfont = :regular,
            labelsize = fs, ticklabelsize = tfs, ticklabelcolor = soft,
            ticksvisible = false,                       # no colorbar ticks (Keith 2026-11-24)
            spinewidth = 0, size = 8, labelpadding = 3,
            colormap = kjl_sequential),

        Legend = (framevisible = false, backgroundcolor = :transparent,
            labelfont = :regular, titlefont = :bold, labelsize = fs, titlesize = fs,
            patchsize = (14, 8), patchlabelgap = 4, rowgap = 0, padding = (2, 2, 2, 2)),

        Text = (font = :regular, fontsize = tfs),
    )
end

"""
    kjl_series(i; marker = false)

Style of data series `i` under the emphasis rule, to splat into a plot call:
i = 1 → kjl_blue solid (the highlighted series: ours, the optimum, …);
i ≥ 2 → grayscale (black, dark, mid, light gray) with dash / dot / dash-dot linestyles.
`marker = true` adds a distinct marker (for `scatterlines!`).
`lines!(ax, x, y; label = "ours", kjl_series(1)...)`.
"""
function kjl_series(i::Integer; marker::Bool = false)
    colors = (kjl_blue, kjl_black, kjl_darkgray, kjl_midgray, kjl_lightgray)
    styles = (:solid, :dash, :dot, :dashdot, Linestyle([0.0, 4.0, 6.0, 10.0]))
    markers = (:circle, :rect, :utriangle, :diamond, :xcross)
    k = i == 1 ? 1 : 1 + mod1(i - 1, 4)
    base = (color = colors[k], linestyle = styles[k])
    return marker ? merge(base, (marker = markers[k],)) : base
end

const kjl_light = kjl_theme(style = :light)
const kjl_grid = kjl_theme(style = :grid)
const kjl_dark = kjl_theme(style = :light, dark = true)
