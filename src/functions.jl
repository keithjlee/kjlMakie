"""
    discretize(n::Integer; colormap = :tempo)

Discretize a color gradient into `n` discrete colours. Returns a vector of colors that can be indexed from 1 to `n`.
"""
function discretize(n::Integer; colormap = :tempo)
    return [cgrad(colormap, [0., 1.])[z] for z ∈ range(0., 1., length = n)]
end

"""
    labelize!(axis::Axis3)

Toggle the visibility of the following:
- title
- x/y/z labels
- x/y/z tick value labels
"""
function labelize!(axis::Axis3)
    axis.titlevisible = !axis.titlevisible[]
    # axis.xgridvisible = !axis.xgridvisible[]
    axis.xlabelvisible = !axis.xlabelvisible[]
    # axis.xspinesvisible = !axis.xspinesvisible[]
    axis.xticklabelsvisible = !axis.xticklabelsvisible[]
    # axis.xticksvisible = !axis.xticksvisible[]

    # axis.ygridvisible = !axis.ygridvisible[]
    axis.ylabelvisible = !axis.ylabelvisible[]
    # axis.yspinesvisible = !axis.yspinesvisible[]
    axis.yticklabelsvisible = !axis.yticklabelsvisible[]
    # axis.yticksvisible = !axis.yticksvisible[]

    # axis.zgridvisible = !axis.zgridvisible[]
    axis.zlabelvisible = !axis.zlabelvisible[]
    # axis.zspinesvisible = !axis.zspinesvisible[]
    axis.zticklabelsvisible = !axis.zticklabelsvisible[]
    # axis.zticksvisible = !axis.zticksvisible[]
end

"""
    labelize!(axis::Axis)

Toggle the visibility of the following:
- title
- x/y labels
- x/y tick value labels
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
    labelscale!(axis::Axis, factor::Union{Float64, Int64})

Scale the font size of the title and labels by `factor`
"""
function labelscale!(axis::Axis, factor::Union{Float64, Int64})
    axis.xlabelsize = labelFontSize * factor
    axis.ylabelsize = labelFontSize * factor
    axis.xticklabelsize = tickFontSize * factor
    axis.yticklabelsize = tickFontSize * factor
    axis.titlesize = titleFontSize * factor
end

"""
    labelscale!(axis::Axis3, factor::Union{Float64, Int64})

Scale the font size of the title and labels by `factor`
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
    resetlabelscale!(axis::Axis)

Reset the font size to default
"""
function resetlabelscale!(axis::Axis)
    axis.xlabelsize = labelFontSize
    axis.ylabelsize = labelFontSize
    axis.xticklabelsize = tickFontSize
    axis.yticklabelsize = tickFontSize
    axis.titlesize = titleFontSize
end

"""
    resetlabelscale!(axis::Axis3)

Reset the font size to default
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
    changefont!(axis::Axis, font::String)

Change the label font. Example:

```julia
    fig, ax = scatter(rand(10), rand(10))

    changefont!(ax, "Times New Roman")
```
"""
function changefont!(axis::Axis, font::String)
    axis.titlefont = font
    axis.xlabelfont = font
    axis.ylabelfont = font
    axis.xticklabelfont = font
    axis.yticklabelfont = font
end

"""
    changefont!(axis::Axis, font::String)

Change the label font. Example:

```julia
    fig, ax = scatter(rand(10), rand(10), rand(10))

    changefont!(ax, "Times New Roman")
```
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
    gridtoggle!(axis::Axis)

Toggle the visibility of the grid
"""
function gridtoggle!(axis::Axis)
    axis.xgridvisible = !axis.xgridvisible[]
    axis.ygridvisible = !axis.ygridvisible[]
end

"""
    gridtoggle!(axis::Axis3)

Toggle the visibility of the grid
"""
function gridtoggle!(axis::Axis3)
    axis.xgridvisible = !axis.xgridvisible[]
    axis.ygridvisible = !axis.ygridvisible[]
    axis.zgridvisible = !axis.zgridvisible[]
end

"""
    simplifyspines!(axis::Axis3)

Simplify spines of an Axis3 to have one x/y/z spine
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
    linkaxes!(parentaxis::Axis3, childaxis::Axis3)

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
linkaxes!(parentaxis::Axis3, childaxis::Vector{Axis3})

Link the rotation of a parent Axis3 to a set of child Axis3
"""
function linkaxes!(parentaxis::Axis3, childaxis::Vector{Axis3})
    for child in childaxis
        linkaxes!(parentaxis, child)
    end
end

"""
    linkproperties!(parentaxis::Union{Axis, Axis3}, childaxis::Union{Axis, Axis3}, properties::Vector{Symbol})

Link all properties between two axes (IE font size, tick visibility, etc)
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
    mirrorticks!(axis::Axis)

Add mirrored ticks on the top and right spines
"""
function mirrorticks!(axis::Axis)
    axis.xticksmirrored = !axis.xticksmirrored[]
    axis.yticksmirrored = !axis.yticksmirrored[]
end

"""
    alignticks!(axis::Axis, value::Integer)

Position of ticks: 0 for outside, 1 for inside
"""
function alignticks!(axis::Axis, value::Integer)
    @assert value == 0 || value == 1 "Value must be 0 or 1"

    axis.xtickalign = value
    axis.ytickalign = value
end

"""
    tickstoggle!(axis::Union{Axis, Axis3})

Toggle the visibility of ticks
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

"""
    Get the size of a figure in pts
"""
Base.size(fig::Figure) = fig.scene.viewport.val.widths