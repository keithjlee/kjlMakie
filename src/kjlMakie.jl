module kjlMakie

using Reexport
@reexport using GLMakie
using Colors

include("colors.jl")
include("themes.jl")
export kjl_light
export kjl_dark

include("themes_mono.jl")
export kjl_light_mono
export kjl_dark_mono

#colours
export kjl_blue
export kjl_pink
export kjl_green
export kjl_turquoise
export kjl_orange
export kjl_tan
export kjl_brown
export kjl_gray
export kjl_darkgray

export caitlin_blue
export caitlin_pink

#gradients
export pink2blue

export white2blue
export white2pink
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

#styles
include("axis_styles.jl")
export graystyle!
export cleanstyle!
export asapstyle!

end # module