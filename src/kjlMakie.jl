module kjlMakie

using Reexport
@reexport using GLMakie
using Colors

include("colors.jl")
include("themes.jl")
export kjl_light
export kjl_dark

#colours
export green
export blue
export pink
export orange
export gray1
export gray2

#gradients
export pink2blue

export white2blue
export white2pink
export white2black

export trans2blue
export trans2pink
export trans2black
export trans2white

export pastel

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

end # module
 
#test123