# text sizes
tickFontSize = 12
labelFontSize = 14
titleFontSize = 14

# font
typeface = "Arial" #IBM Plex Sans, Libre Caslon Text, Times New Roman, Neue Haas Unica Pro

kjl_light = Theme(
    backgroundcolor = :transparent,

    palette = (color = [kjl_blue, kjl_green, kjl_pink, kjl_orange, kjl_gray, kjl_darkgray, :black],
        marker = [:circle, :rect, :utriangle, :xcross]),

    Axis = (aspect = 1,
        backgroundcolor = :transparent,
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
        xgridcolor = kjl_gray,
        ygridcolor = kjl_gray,
        xgridvisible = false,
        ygridvisible = false,
        xtickalign = 1,
        ytickalign = 1,
        xticksmirrored = true,
        yticksmirrored = true
        ),

    Axis3 = (backgroundcolor = :transparent,
        aspect = (1,1,1),
        xgridcolor = kjl_gray,
        ygridcolor = kjl_gray,
        zgridcolor = kjl_gray,
        titlefont = typeface,
        xlabelfont = typeface,
        ylabelfont = typeface,
        zlabelfont = typeface,
        xticklabelfont = typeface,
        yticklabelfont = typeface,
        zticklabelfont = typeface,
        titlesize = titleFontSize,
        xlabelsize = labelFontSize,
        ylabelsize = labelFontSize,
        zlabelsize = labelFontSize,
        xticklabelsize = tickFontSize,
        yticklabelsize = tickFontSize,
        zticklabelsize = tickFontSize,
        azimuth = -3pi / 4,
        elevation = pi/8
        ),

    Lines = (linewidth = 2,),

    Colorbar = (labelfont = typeface,
        ticksvisible = false,
        spinewidth = 0,
        ticklabelfont = typeface,
        colormap = trans2black,),

    Legend = (backgroundcolor = :white,
        framecolor = :black,
        labelfont = typeface,
        titlefont = typeface),

    Heatmap = (colormap = trans2black,),

    Surface = (colormap = trans2black,),

    Spy = (colormap = trans2black,),

    Scatter = (strokewidth = 1,
        cycle = [:color, :marker],
        strokecolor = :black),

    Hist = (color = kjl_blue,
        strokecolor = :black),

    BarPlot = (color = kjl_blue,
        gap = 0,
        strokewidth = 0,
        strokecolor = :white,),    

    Text = (font = typeface,),
)

kjl_dark = Theme(
    textcolor = :white,

    backgroundcolor = :black,

    palette = (color = [kjl_blue, kjl_green, kjl_pink, kjl_orange, kjl_gray, kjl_darkgray, :black],
        marker = [:circle, :rect, :utriangle, :xcross]),

    Axis = (aspect = 1,
        backgroundcolor = :transparent,
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
        xgridcolor = kjl_darkgray,
        ygridvisible = false,
        ygridcolor = kjl_darkgray,
        xtickalign = 1,
        ytickalign = 1,
        xticksmirrored = true,
        yticksmirrored = true
        ),

    Axis3 = (backgroundcolor = :transparent,
        aspect = (1,1,1),
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
        ztickcolor = :white,
        titlefont = typeface,
        xlabelfont = typeface,
        ylabelfont = typeface,
        zlabelfont = typeface,
        xticklabelfont = typeface,
        yticklabelfont = typeface,
        zticklabelfont = typeface,
        titlesize = titleFontSize,
        xlabelsize = labelFontSize,
        ylabelsize = labelFontSize,
        zlabelsize = labelFontSize,
        xticklabelsize = tickFontSize,
        yticklabelsize = tickFontSize,
        zticklabelsize = tickFontSize,
        xgridcolor = kjl_darkgray,
        ygridcolor = kjl_darkgray,
        zgridcolor = kjl_darkgray,
        azimuth = -3pi / 4,
        elevation = pi/8
        ),

    Lines = (linewidth = 2,),

    Colorbar = (labelfont = typeface,
        ticksvisible = false,
        spinewidth = 0,
        ticklabelfont = typeface,
        colormap = trans2white,),

    Legend = (backgroundcolor = :black,
        framecolor = :white,
        labelfont = typeface,
        titlefont = typeface),

    Heatmap = (colormap = trans2white,),

    Surface = (colormap = trans2white,),

    Spy = (colormap = trans2white,),

    Scatter = (strokewidth = 1,
        cycle = [:color, :marker],
        strokecolor = :black),

    Hist = (color = kjl_blue,
        strokecolor = :white),

    BarPlot = (color = kjl_blue,
        gap = 0,
        strokewidth = 0,
        strokecolor = :black,),    

    Text = (font = typeface,),
)
