# text sizes
tickFontSize = 18
labelFontSize = 20
titleFontSize = 20

# font
typeface = "Arial" #IBM Plex Sans, Libre Caslon Text, Times New Roman, Neue Haas Unica Pro

kjl_light = Theme(
    backgroundcolor = :transparent,

    palette = (color = [blue, green, pink, orange, gray1, gray2, :black],
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
        xgridcolor = gray2,
        ygridcolor = gray2,
        xgridvisible = false,
        ygridvisible = false,
        xtickalign = 1,
        ytickalign = 1,
        xticksmirrored = true,
        yticksmirrored = true
        ),

    Axis3 = (backgroundcolor = :transparent,
        aspect = (1,1,1),
        xgridcolor = gray2,
        ygridcolor = gray2,
        zgridcolor = gray2,
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

    Lines = (linewidth = 4,),

    Colorbar = (labelfont = typeface,
        ticksvisible = false,
        spinewidth = 0,
        ticklabelfont = typeface,
        colormap = trans2black,),

    Legend = (bgcolor = :white,
        framecolor = :black,
        labelfont = typeface,
        titlefont = typeface),

    Heatmap = (colormap = trans2black,),

    Surface = (colormap = trans2black,),

    Spy = (colormap = trans2black,),

    Scatter = (strokewidth = 1,
        cycle = [:color, :marker],
        strokecolor = :white),

    Hist = (color = blue,
        strokecolor = :black),

    BarPlot = (color = blue,
        gap = 0,
        strokewidth = 1,
        strokecolor = :white,),    

    Text = (font = typeface,),
)

kjl_dark = Theme(
    textcolor = :white,

    backgroundcolor = :black,

    palette = (color = [blue, green, pink, orange, gray1, gray2, :white],
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
        xgridcolor = gray1,
        ygridvisible = false,
        ygridcolor = gray1,
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
        xgridcolor = gray1,
        ygridcolor = gray1,
        zgridcolor = gray1,
        azimuth = -3pi / 4,
        elevation = pi/8
        ),

    Lines = (linewidth = 4,),

    Colorbar = (labelfont = typeface,
        ticksvisible = false,
        spinewidth = 0,
        ticklabelfont = typeface,
        colormap = trans2white,),

    Legend = (bgcolor = :black,
        framecolor = :white,
        labelfont = typeface,
        titlefont = typeface),

    Heatmap = (colormap = trans2white,),

    Surface = (colormap = trans2white,),

    Spy = (colormap = trans2white,),

    Scatter = (strokewidth = 1,
        cycle = [:color, :marker],
        strokecolor = :black),

    Hist = (color = blue,
        strokecolor = :white),

    BarPlot = (color = blue,
        gap = 0,
        strokewidth = 1,
        strokecolor = :black,),    

    Text = (font = typeface,),
)
