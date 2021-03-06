green  = colorant"#48B674"
blue = colorant"#3EA8DE"
red = colorant"#EA2127"
orange = colorant"#F9A11D"
gray1 = colorant"#B2B2B2"
gray2 = colorant"#808080"

red2blue = cgrad([red, gray1, blue])
green2blue = cgrad([green, gray1, blue])
white2blue = cgrad([:white, blue])
white2red = cgrad([:white, red])
trans2blue = cgrad([:transparent, blue])

# text sizes
tickFontSize = 18
labelFontSize = 20
titleFontSize = 25

# font
typeface = "Arial" #IBM Plex Sans, Libre Caslon Text, Times New Roman

kjl_light = Theme(
    backgroundcolor = :transparent,

    Axis = (backgroundcolor = :transparent,
        xlabelfont = typeface,
        xlabelsize = labelFontSize,
        ylabelfont = typeface,
        ylabelsize = labelFontSize,
        xticklabelfont= typeface,
        xticklabelsize = labelFontSize,
        yticklabelfont = typeface,
        yticklabelsize = labelFontSize,
        titlefont = typeface,
        titlesize = titleFontSize,
        xgridvisible = false,
        ygridvisible = false),

    Axis3 = (backgroundcolor = :transparent,
        aspect = :data,
        titlevisible = false,
        xgridvisible = false,
        xlabelvisible = false,
        xspinesvisible = false,
        xticklabelsvisible = false,
        xticksvisible = false,
        ygridvisible = false,
        ylabelvisible = false,
        yspinesvisible = false,
        yticklabelsvisible = false,
        yticksvisible = false,
        zgridvisible = false,
        zlabelvisible = false,
        zspinesvisible = false,
        zticklabelsvisible = false,
        zticksvisible = false
        ),

    Lines = (linewidth = 4,
        linestyle = :solid),

    Colorbar = (labelfont = typeface,
        ticklabelfont = typeface),

    Legend = (bgcolor = :white,
        framecolor = :black),

    cycle = [green, blue, orange, red, gray1, gray2, :black],

    Heatmap = (colormap = trans2blue,),

    Surface = (colormap = trans2blue,),

    Spy = (colormap = trans2blue,),

    Scatter = (strokewidth = 1,
        strokecolor = :white)
)

kjl_dark = Theme(
    textcolor = :white,
    backgroundcolor = :transparent,
    Axis = (backgroundcolor = :transparent,
        xlabelfont = typeface,
        xlabelsize = labelFontSize,
        ylabelfont = typeface,
        ylabelsize = labelFontSize,
        xticklabelfont= typeface,
        xticklabelsize = labelFontSize,
        yticklabelfont = typeface,
        yticklabelsize = labelFontSize,
        titlefont = typeface,
        titlesize = titleFontSize,
        bottomspinecolor = :white,
        topspinecolor = :white,
        leftspinecolor = :white,
        rightspinecolor = :white,
        xtickcolor = :white,
        ytickcolor = :white,
        xgridvisible = false,
        xgridcolor = :white,
        ygridvisible = false,
        ygridcolor = :white),

    Axis3 = (backgroundcolor = :transparent,
        aspect = :data,
        titlevisible = false,
        xgridvisible = false,
        xlabelvisible = false,
        xspinesvisible = false,
        xticklabelsvisible = false,
        xticksvisible = false,
        ygridvisible = false,
        ylabelvisible = false,
        yspinesvisible = false,
        yticklabelsvisible = false,
        yticksvisible = false,
        zgridvisible = false,
        zlabelvisible = false,
        zspinesvisible = false,
        zticklabelsvisible = false,
        zticksvisible = false,
        xspinecolor_1 = :white,
        xspinecolor_2 = :white,
        xspinecolor_3 = :white,
        xlabelcolor = :white,
        xticklabelcolor = :white,
        xtickcolor = :white,
        yspinecolor_1 = :white,
        yspinecolor_2 = :white,
        yspinecolor_3 = :white,
        ylabelcolor = :white,
        yticklabelcolor = :white,
        ytickcolor = :white,
        zspinecolor_1 = :white,
        zspinecolor_2 = :white,
        zspinecolor_3 = :white,
        zlabelcolor = :white,
        zticklabelcolor = :white,
        ztickcolor = :white
        ),

    Lines = (linewidth = 4,
        linestyle = :solid),

    Colorbar = (labelfont = typeface,
        ticklabelfont = typeface),

    Legend = (bgcolor = :black,
        framecolor = :white),

    cycle = [green, blue, orange, red, gray1, gray2, :white],

    Heatmap = (colormap = trans2blue,),

    Surface = (colormap = trans2blue,),

    Spy = (colormap = trans2blue,),

    Scatter = (strokewidth = 1,
        strokecolor = :white)
)
