#=
Colours.

Use the ROLE names (kjl_emphasis, kjl_tension, kjl_compression, kjl_neutral, kjl_grays) and
the role colormaps (kjl_diverging, kjl_sequential) in figure code, never literal hues:

    emphasis        kjl_blue    the one highlighted series (neutral/good: ours, the optimum, the
                                chosen design); everything else is grayscale (kjl_grays), told apart
                                by linestyle / alpha / linewidth
    alert           kjl_red     emphasis of a BAD item when no other colours are present: a failed
                                run, the highest cost in a bar plot, a violated limit
    tension (+)     kjl_blue    positive side of any signed quantity
    compression (−) kjl_red     negative side of any signed quantity
    zero            white       (kjl_diverging = red → white → blue, centred with `symmetric_range`)
    categorical     kjl_categorical  several series compared as equals: blue, green, yellow, grays
    internal forces ONE diagram (N, V, M): black line, 50 % black fill (`diagramband!`);
                                several compared: kjl_categorical, same 50 % fill
    neutral         kjl_orange  non-force fields mapped to colour (displacement, utilization, …):
                                kjl_sequential = white → orange, zero = white
=#

# base colours
const kjl_pink = colorant"#f52565"
const kjl_red = kjl_pink                      # same hue: the "red" of the palette
const kjl_blue = colorant"#2559f5"
const kjl_green = colorant"#58bc82"
const kjl_turquoise = colorant"#119da4"
const kjl_yellow = colorant"#f5bb25"
const kjl_orange = colorant"#ff5800"
const kjl_tan = colorant"#e9d985"
const kjl_brown = colorant"#c3b299"
const kjl_gray = colorant"#cbd4c2"
const kjl_darkgray = colorant"#50514f"

# roles
const kjl_emphasis = kjl_blue
const kjl_alert = kjl_red
const kjl_tension = kjl_blue
const kjl_compression = kjl_red
const kjl_neutral = kjl_orange

"""
categorical series that are compared as EQUALS (several internal-force diagrams, load cases …):
blue, green, yellow, then grays. Red is never categorical (it means compression / bad).
"""
const kjl_categorical = [kjl_blue, kjl_green, kjl_yellow, colorant"#1a1a1a", colorant"#50514f", colorant"#8a8b89"]

# grayscale ramp for de-emphasised series and structure linework (dark → light)
const kjl_black = colorant"#1a1a1a"
const kjl_midgray = colorant"#8a8b89"
const kjl_lightgray = colorant"#c4c5c3"
const kjl_grays = [kjl_black, kjl_darkgray, kjl_midgray, kjl_lightgray]

# backgrounds
const kjl_panelgray = colorant"#fafafa"       # kjl_grid axis background (white gridlines)

# Legacy
const caitlin_blue = colorant"#3EA8DE"
const caitlin_pink = colorant"#FF7BAC"

# Colour gradients

const pink2blue = cgrad([kjl_pink, :white, kjl_blue])

const white2blue = cgrad([:white, kjl_blue])
const white2pink = cgrad([:white, kjl_pink])
const white2red = white2pink
const white2orange = cgrad([:white, kjl_orange])
const white2black = cgrad([:white, :black])

const trans2blue = cgrad([:transparent, kjl_blue])
const trans2pink = cgrad([:transparent, kjl_pink])
const trans2black = cgrad([:transparent, :black])
const trans2white = cgrad([:transparent, :white])

# role colormaps
"signed quantities: negative/compression → kjl_red, 0 → white, positive/tension → kjl_blue. Pair with `symmetric_range`."
const kjl_diverging = pink2blue
"neutral (non-force) magnitudes: 0 → white, max → kjl_orange"
const kjl_sequential = white2orange
"neutral magnitudes that are all ≤ 0 (e.g. downward deflection): min → kjl_orange, 0 → white"
const kjl_sequential_neg = cgrad([kjl_orange, :white])

"""
    force_color(x)

`kjl_tension` (blue) for x ≥ 0, `kjl_compression` (red) for x < 0.
"""
force_color(x::Real) = x < 0 ? kjl_compression : kjl_tension

"""
    symmetric_range(values)

`(-m, m)` with `m = maximum(abs, values)` (or `(-1, 1)` if all zero): the colorrange that puts
zero at the white centre of `kjl_diverging`.
"""
function symmetric_range(v)
    m = maximum(abs, v; init = 0.0)
    return m == 0 ? (-1.0, 1.0) : (-float(m), float(m))
end

"""
    neutral_colormap(values) -> (colormap, colorrange)

Colormap and range for a neutral (non-force) field such that zero is white:
all ≥ 0 → `kjl_sequential` on (0, max); all ≤ 0 → `kjl_sequential_neg` on (min, 0);
mixed signs → `kjl_diverging` on a symmetric range (the sign then matters, so red/blue).
"""
function neutral_colormap(v)
    lo, hi = extrema(v)
    if lo >= 0
        return kjl_sequential, (0.0, hi > 0 ? float(hi) : 1.0)
    elseif hi <= 0
        return kjl_sequential_neg, (float(lo), 0.0)
    else
        return kjl_diverging, symmetric_range(v)
    end
end
