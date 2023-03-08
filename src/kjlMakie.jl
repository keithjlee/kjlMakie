module kjlMakie

using CairoMakie
using Colors

include("colors.jl")
include("themes.jl")
export kjl_light
export kjl_dark
export red2blue
export pink2blue
export white2blue
export pink2blue
export green
export blue
export pink
export red
export orange
export gray1
export gray2
export pastelß

include("functions.jl")
export discretize
export labelize!
export labelscale!
export changefont!
export resetlabelscale!
export gridtoggle!
export simplifyspines!
export linkaxes!

end # module
 
#test123