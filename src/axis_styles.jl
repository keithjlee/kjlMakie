"""
    graystyle!(axis::Axis; backgroundcolor = :lightgray, backgroundalpha = 0.15, grid = true, gridcolor = :white)
"""
function graystyle!(axis::Axis; backgroundcolor = :lightgray, backgroundalpha = 0.15, grid = true, gridcolor = :white)

    # set axis background color
    axis.backgroundcolor = (backgroundcolor, backgroundalpha)

    # clean up decorations
    axis.xticksvisible = axis.yticksvisible = false
    axis.rightspinevisible = axis.topspinevisible = false

    if grid
        axis.xgridvisible = axis.ygridvisible = true
        axis.xgridcolor = axis.ygridcolor = gridcolor
    end
end

function graystyle!(axis::Axis3; backgroundcolor = :lightgray, backgroundalpha = 0.15)

    # set axis background color
    axis.xzpanelcolor = axis.yzpanelcolor = axis.xypanelcolor = (backgroundcolor, backgroundalpha)

    # clean up decorations
    axis.xticksvisible = axis.yticksvisible = axis.zticksvisible = false

    simplifyspines!(axis)

    axis.xgridvisible = axis.ygridvisible = axis.zgridvisible = false

end

function structurestyle!(axis::Axis; ground = false, groundcolor = :black, groundwidth = 2)

    hidedecorations!(axis)
    hidespines!(axis)

    if ground
        axis.bottomspinevisible = true
        axis.spinewidth = groundwidth
        axis.bottomspinecolor = groundcolor
    end

end

function cleanstyle!(axis::Axis3; ground = false, groundcolor = :lightgray, groundalpha = .5)

    hidedecorations!(axis)
    hidespines!(axis)

    if ground
        axis.xypanelcolor = (groundcolor, groundalpha)
    end

end

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