"""
discretizes a color gradient into discrete colors
"""
function discretize(n::Int; colormap = :tempo)
    return [cgrad(colormap, [0., 1.])[z] for z ∈ range(0., 1., length = n)]
end

"""
turn on/off labels for Axis3
"""
function labelize!(axis::Axis3)
    axis.titlevisible = !axis.titlevisible[]
    axis.xgridvisible = !axis.xgridvisible[]
    axis.xlabelvisible = !axis.xlabelvisible[]
    axis.xspinesvisible = !axis.xspinesvisible[]
    axis.xticklabelsvisible = !axis.xticklabelsvisible[]
    axis.xticksvisible = !axis.xticksvisible[]

    axis.ygridvisible = !axis.ygridvisible[]
    axis.ylabelvisible = !axis.ylabelvisible[]
    axis.yspinesvisible = !axis.yspinesvisible[]
    axis.yticklabelsvisible = !axis.yticklabelsvisible[]
    axis.yticksvisible = !axis.yticksvisible[]

    axis.zgridvisible = !axis.zgridvisible[]
    axis.zlabelvisible = !axis.zlabelvisible[]
    axis.zspinesvisible = !axis.zspinesvisible[]
    axis.zticklabelsvisible = !axis.zticklabelsvisible[]
    axis.zticksvisible = !axis.zticksvisible[]
end

"""
turn on/off labels for Axis3
"""
function labelize!(axis::Axis)
    axis.titlevisible = !axis.titlevisible[]
    axis.xgridvisible = !axis.xgridvisible[]
    axis.xlabelvisible = !axis.xlabelvisible[]
    # axis.xspinesvisible = !axis.xspinesvisible[]
    axis.xticklabelsvisible = !axis.xticklabelsvisible[]
    axis.xticksvisible = !axis.xticksvisible[]

    axis.ygridvisible = !axis.ygridvisible[]
    axis.ylabelvisible = !axis.ylabelvisible[]
    # axis.yspinesvisible = !axis.yspinesvisible[]
    axis.yticklabelsvisible = !axis.yticklabelsvisible[]
    axis.yticksvisible = !axis.yticksvisible[]
end

"""
Scale fontsizes as a scaled factor of default sizes
"""
function labelscale!(axis::Axis, factor::Union{Float64, Int64})
    axis.xlabelsize = labelFontSize * factor
    axis.ylabelsize = labelFontSize * factor
    axis.xticklabelsize = tickFontSize * factor
    axis.yticklabelsize = tickFontSize * factor
    axis.titlesize = titleFontSize * factor
end

"""
Scale fontsizes as a scaled factor of default sizes
"""
function labelscale!(axis::Axis3, factor::Union{Float64, Int64})
    axis.titlesize = titleFontSize * factor
    axis.xlabelsize = labelFontSize * factor
    axis.ylabelsize = labelFontSize * factor
    axis.zlabelsize = labelFontSize * factor
    axis.xticklabelsize = tickFontSize * factor
    axis.yticklabelsize = tickFontSize * factor
    axis.zticklabelsize = tickFontSize * factor
end

"""
Reset font sizes to default
"""
function resetlabelscale!(axis::Axis)
    axis.xlabelsize = labelFontSize
    axis.ylabelsize = labelFontSize
    axis.xticklabelsize = tickFontSize
    axis.yticklabelsize = tickFontSize
    axis.titlesize = titleFontSize
end

"""
Reset font sizes to default
"""
function resetlabelscale!(axis::Axis3)
    axis.titlesize = titleFontSize
    axis.xlabelsize = labelFontSize
    axis.ylabelsize = labelFontSize
    axis.zlabelsize = labelFontSize
    axis.xticklabelsize = tickFontSize
    axis.yticklabelsize = tickFontSize
    axis.zticklabelsize = tickFontSize
end

"""
Change font of an axis
"""
function changefont!(axis::Axis, font::String)
    axis.titlefont = font
    axis.xlabelfont = font
    axis.ylabelfont = font
    axis.xticklabelfont = font
    axis.yticklabelfont = font
end

"""
Change font of an axis
"""
function changefont!(axis::Axis3, font::String)
    axis.titlefont = font
    axis.xlabelfont = font
    axis.ylabelfont = font
    axis.zlabelfont = font
    axis.xticklabelfont = font
    axis.yticklabelfont = font
    axis.zticklabelfont = font
end

"""
Toggle grid on and off
"""
function gridtoggle!(axis::Axis)
    axis.xgridvisible = !axis.xgridvisible[]
    axis.ygridvisible = !axis.ygridvisible[]
end

"""
Toggle grid on and off
"""
function gridtoggle!(axis::Axis3)
    axis.xgridvisible = !axis.xgridvisible[]
    axis.ygridvisible = !axis.ygridvisible[]
    axis.zgridvisible = !axis.zgridvisible[]
end

"""
Simplify spines on Axis3 to only have a single X, Y, Z spine
"""
function simplifyspines!(axis::Axis3)

    if axis.xspinecolor_2 != :transparent
        axis.xspinecolor_2 = :transparent
        axis.xspinecolor_3 = :transparent

        axis.yspinecolor_2 = :transparent
        axis.yspinecolor_3 = :transparent

        axis.zspinecolor_2 = :transparent
        axis.zspinecolor_3 = :transparent
    else
        axis.xspinecolor_2 = axis.xspinecolor_1[]
        axis.xspinecolor_3 = axis.xspinecolor_1[]

        axis.yspinecolor_2 = axis.xspinecolor_1[]
        axis.yspinecolor_3 = axis.xspinecolor_1[]

        axis.zspinecolor_2 = axis.xspinecolor_1[]
        axis.zspinecolor_3 = axis.xspinecolor_1[]
    end
    
end

"""
Link the rotation of a parent Axis3 to a child Axis3
"""
function linkaxes!(parentaxis::Axis3, childaxis::Axis3)
    on(parentaxis.azimuth) do az
        childaxis.azimuth[] = az
    end

    on(parentaxis.elevation) do el
        childaxis.elevation[] = el
    end
end

"""
Link the rotation of a parent Axis3 to a set of chiled Axis3s
"""
function linkaxes!(parentaxis::Axis3, childaxis::Vector{Axis3})
    for child in childaxis
        linkaxes!(parentaxis, child)
    end
end

"""
Link arbitrary axis properties
"""
function linkproperties!(parentaxis::Union{Axis, Axis3}, childaxis::Union{Axis, Axis3}, properties::Vector{Symbol})
    @assert typeof(parentaxis) == typeof(childaxis) "Parent and child must have same Axis type (Axis or Axis3)"


    for property in properties
        on(getproperty(parentaxis, property)) do val
            getproperty(childaxis, property)[] = val
        end
    end

end

"""
Add mirrored ticks on the top and right spines
"""
function mirrorticks!(axis::Axis)
    axis.xticksmirrored = !axis.xticksmirrored[]
    axis.yticksmirrored = !axis.yticksmirrored[]
end

"""
Position of ticks: 0 for outside, 1 for inside
"""
function alignticks!(axis::Axis, value::Integer)
    @assert value == 0 || value == 1 "Value must be 0 or 1"

    axis.xtickalign = value
    axis.ytickalign = value
end

"""
Toggle ticks on and off
"""
function tickstoggle!(axis::Union{Axis, Axis3})
    axis.xticksvisible = !axis.xticksvisible[]
    axis.yticksvisible = !axis.yticksvisible[]

    if typeof(axis) == Axis3
        axis.zticksvisible = !axis.zticksvisible[]
    end
end

# """
# Turn X, Y data vectors into Vector{Point2}
# """
# function pointify(X::Vector{T}, Y::Vector{T}) where {T <: Real}

#     @assert length(X) == length(Y) "Input vectors must be equal length"

#     return Point2.(eachrow([X Y]))
# end

# """
# Turn X, Y, Z data vectors into Vector{Point3}
# """
# function pointify(X::Vector{T}, Y::Vector{T}, Z::Vector{T}) where {T <: Real}

#     @assert length(X) == length(Y) == length(Z) "Input vectors must be equal length"

#     return Point3.(eachrow([X Y Z]))
# end