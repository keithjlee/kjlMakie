module kjlMakie

using Reexport
@reexport using GLMakie
using Colors

include("colors.jl")
include("figure_sizes.jl")
include("themes.jl")
export kjl_theme
export kjl_light
export kjl_grid
export kjl_dark
export kjl_series

# legacy themes (Arial / IBM Plex Mono, mirrored ticks); prefer kjl_light / kjl_grid
include("themes_mono.jl")
export kjl_light_mono
export kjl_dark_mono

#colours
export kjl_blue
export kjl_red
export kjl_pink
export kjl_green
export kjl_turquoise
export kjl_orange
export kjl_yellow
export kjl_categorical
export kjl_tan
export kjl_brown
export kjl_gray
export kjl_darkgray
export kjl_black, kjl_midgray, kjl_lightgray, kjl_grays, kjl_panelgray, kjl_diagramgray

#colour roles
export kjl_emphasis
export kjl_alert
export kjl_tension
export kjl_compression
export kjl_neutral
export force_color
export symmetric_range
export neutral_colormap

export caitlin_blue
export caitlin_pink

#gradients
export kjl_diverging
export kjl_sequential
export kjl_sequential_neg
export pink2blue

export white2blue
export white2pink
export white2red
export white2orange
export white2black

export trans2blue
export trans2pink
export trans2black
export trans2white

#utility functions
include("functions.jl")
export discretize
export labelize!
export labelscale!
export changefont!
export resetlabelscale!
export gridtoggle!
export simplifyspines!
export linkaxes!
export linkproperties!

export mirrorticks!
export alignticks!
export tickstoggle!

export fixlimits!
export signedband!
export diagramband!
export zerobase!

#labels
include("labels.jl")
export caps
export capslabels!
export kjl_label
export label_parts
export CAPS_UNITS, CAPS_WORDS2

#styles
include("axis_styles.jl")
export plotstyle!
export graystyle!
export structurestyle!
export fitlimits!
export fitstructure!
export cleanstyle!
export asapstyle!

#hidden-line 3D → 2D vector drawing
include("hiddenline.jl")
export hiddenline!
export hiddenface!
export hidden_order
export hl_basis, hl_project, hl_cull
export view_basis
export project3d

#sizes
export halfwidth
export fullwidth
export customwidth
export TEXTWIDTH
export reportsize
export savereport

end # module
