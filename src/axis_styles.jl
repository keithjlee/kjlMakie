#=
Axis styles.

Data axes take their look from the theme (`kjl_light` / `kjl_grid`); `plotstyle!` and `graystyle!`
re-apply either look to an existing axis whatever the active theme.

Structure axes (drawings of a model, not data): `structurestyle!` hides the axis, keeps the
true data aspect and a transparent background; `fitlimits!` / `fitstructure!` pad the limits
from the plotted data so nodes, markers and labels at the extremities are not clipped.
=#

"""
    plotstyle!(axis::Axis)

The `kjl_light` look on an existing axis: white/transparent background, left + bottom spines
only, ticks inside, no grid.
"""
function plotstyle!(axis::Axis)
    axis.backgroundcolor = :transparent
    axis.topspinevisible = axis.rightspinevisible = false
    axis.leftspinevisible = axis.bottomspinevisible = true
    axis.xticksvisible = axis.yticksvisible = true
    axis.xtickalign = axis.ytickalign = 1
    axis.xticksmirrored = axis.yticksmirrored = false
    axis.xgridvisible = axis.ygridvisible = false
    return axis
end

"""
    graystyle!(axis::Axis; backgroundcolor = kjl_panelgray, backgroundalpha = 1.0, grid = true, gridcolor = :white)

The `kjl_grid` look on an existing axis: light-gray panel, no ticks, left + bottom spines only,
white gridlines.
"""
function graystyle!(axis::Axis; backgroundcolor = kjl_panelgray, backgroundalpha = 1.0, grid = true, gridcolor = :white)

    axis.backgroundcolor = (backgroundcolor, backgroundalpha)

    axis.xticksvisible = axis.yticksvisible = false
    axis.rightspinevisible = axis.topspinevisible = false

    if grid
        axis.xgridvisible = axis.ygridvisible = true
        axis.xgridcolor = axis.ygridcolor = gridcolor
        axis.xgridwidth = axis.ygridwidth = 1.0
    end
    return axis
end

function graystyle!(axis::Axis3; backgroundcolor = kjl_panelgray, backgroundalpha = 1.0)

    axis.xzpanelcolor = axis.yzpanelcolor = axis.xypanelcolor = (backgroundcolor, backgroundalpha)

    axis.xticksvisible = axis.yticksvisible = axis.zticksvisible = false

    simplifyspines!(axis)

    axis.xgridvisible = axis.ygridvisible = axis.zgridvisible = false
    return axis
end

"""
    structurestyle!(axis::Axis; scale = false, unit = nothing, ground = false)

2D structure drawing: no axis decorations, transparent background, true data aspect
(`DataAspect()`). `scale = true` keeps light left + bottom spines with ticks and tick labels
as a scale bar; `unit` (e.g. `"m"`) labels it (`[m]`). `ground = true` draws the bottom spine as
a ground line. Pair with `fitlimits!` / `fitstructure!` so nothing at the edges is clipped.
"""
function structurestyle!(axis::Axis; scale::Bool = false, unit = nothing, ground::Bool = false,
    groundcolor = kjl_black, groundwidth = 1.5, scalecolor = kjl_midgray)

    hidedecorations!(axis)
    hidespines!(axis)
    axis.backgroundcolor = :transparent
    axis.aspect = DataAspect()

    if scale
        axis.leftspinevisible = axis.bottomspinevisible = true
        axis.leftspinecolor = axis.bottomspinecolor = scalecolor
        axis.xticksvisible = axis.yticksvisible = true
        axis.xticklabelsvisible = axis.yticklabelsvisible = true
        axis.xtickcolor = axis.ytickcolor = scalecolor
        axis.xticklabelcolor = axis.yticklabelcolor = scalecolor
        axis.xtickalign = axis.ytickalign = 0
        axis.xticksize = axis.yticksize = 2.5
        if unit !== nothing
            axis.xlabelvisible = true
            axis.xlabel = "[" * string(unit) * "]"
            axis.xlabelcolor = scalecolor
        end
    end

    if ground
        axis.bottomspinevisible = true
        axis.spinewidth = groundwidth
        axis.bottomspinecolor = groundcolor
    end
    return axis
end

"""
    structurestyle!(axis::Axis3; ground = false, groundcolor = kjl_lightgray, groundalpha = 0.35)

3D structure drawing: no decorations, no panels, `aspect = :data` (true proportions).
`ground = true` shades the bottom (xy) panel as a ground plane.
"""
function structurestyle!(axis::Axis3; ground::Bool = false, groundcolor = kjl_lightgray, groundalpha = 0.35)

    hidedecorations!(axis)
    hidespines!(axis)
    axis.aspect = :data
    axis.xzpanelvisible = axis.yzpanelvisible = false
    axis.xypanelvisible = ground
    ground && (axis.xypanelcolor = (groundcolor, groundalpha))
    axis.viewmode = :fitzoom
    axis.protrusions = 0
    return axis
end

# --- limits from the plotted data --------------------------------------------------------

function _plotted_limits(axis)
    bb = nothing
    for p in axis.scene.plots
        r = Makie.data_limits(p)
        all(isfinite, Makie.origin(r)) && all(isfinite, Makie.widths(r)) || continue
        bb = bb === nothing ? r : Makie.union(bb, r)
    end
    bb === nothing && error("fitlimits!: nothing plotted")
    return bb
end

"""
    fitlimits!(axis; pad = 0.04, padabs = 0.0)

Set the limits to the extent of the plotted data plus a margin of `pad × (largest span) +
padabs` (data units) on EVERY side, so a flat structure gets the same margin top and bottom as
left and right; returns the padded spans. Use instead of autolimits for structure drawings: markers (nodes) and labels at
the extremities are otherwise clipped by the axis.
"""
function fitlimits!(axis::Axis; pad = 0.04, padabs = 0.0)
    bb = _plotted_limits(axis)
    o, w = Makie.origin(bb), Makie.widths(bb)
    m = pad * max(w[1], w[2]) + padabs
    limits!(axis, o[1] - m, o[1] + w[1] + m, o[2] - m, o[2] + w[2] + m)
    return (w[1] + 2m, w[2] + 2m)
end

function fitlimits!(axis::Axis3; pad = 0.04, padabs = 0.0)
    bb = _plotted_limits(axis)
    o, w = Makie.origin(bb), Makie.widths(bb)
    m = pad * maximum(w) + padabs
    limits!(axis, o[1] - m, o[1] + w[1] + m, o[2] - m, o[2] + w[2] + m, o[3] - m, o[3] + w[3] + m)
    return (w[1] + 2m, w[2] + 2m, w[3] + 2m)
end

"""
    fitstructure!(fig, axis; width = 0.85TEXTWIDTH, maxheight = 0.6TEXTWIDTH, pad = 0.03, padpt = 8)

Limits from the plotted data, then the axis cell sized to the TRUE data aspect: plot area
`width` points wide (narrower if the height would exceed `maxheight`), figure resized to its
layout. No empty bands around the drawing, so it embeds at natural size. The margin on every
side is `pad × (largest span)` plus `padpt` POINTS (room for node markers and end labels,
which the axis would otherwise clip; raise `padpt` for long labels at the edges).
"""
function fitstructure!(fig, axis::Axis; width = 0.85TEXTWIDTH, maxheight = 0.6TEXTWIDTH,
    pad = 0.03, padpt = 8)
    bb = _plotted_limits(axis)
    wx, wy = Makie.widths(bb)[1], Makie.widths(bb)[2]
    base = pad * max(wx, wy)
    # plot-area size for the unpadded aspect, then the margin that gives `padpt` points
    r0 = (wx + 2base) / max(wy + 2base, eps())
    aw = min(width, maxheight * r0)
    m = (base + padpt * (wx + 2base) / aw) / (1 - 2padpt / aw)
    o = Makie.origin(bb)
    limits!(axis, o[1] - m, o[1] + wx + m, o[2] - m, o[2] + wy + m)
    r = (wx + 2m) / (wy + 2m)                         # width / height
    aw, ah = width, width / r
    if ah > maxheight
        ah = maxheight; aw = ah * r
    end
    axis.aspect = nothing
    axis.width = aw
    axis.height = ah
    resize_to_layout!(fig)
    return fig
end

function cleanstyle!(axis::Axis3; ground = false, groundcolor = :lightgray, groundalpha = .5)

    hidedecorations!(axis)
    hidespines!(axis)

    if ground
        axis.xypanelcolor = (groundcolor, groundalpha)
    end

end

# legacy: prefer structurestyle!
function asapstyle!(axis::Axis; ground = false, groundcolor = :black, groundwidth = 2)

    hidedecorations!(axis)
    hidespines!(axis)

    axis.aspect = DataAspect()

    if ground
        axis.bottomspinevisible = true
        axis.spinewidth = groundwidth
        axis.bottomspinecolor = groundcolor
    end

end

function asapstyle!(axis::Axis3; ground = false, groundcolor = :lightgray, groundalpha = .5)

    hidedecorations!(axis)
    hidespines!(axis)

    axis.aspect = :data

    if ground
        axis.xypanelcolor = (groundcolor, groundalpha)
    end

end
