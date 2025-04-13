#=
Figure size generators in accordance to common Elsevier journal publishing guideliens
=#


const pts_per_cm = 28.3465

function fullwidth(ratio = 1.0; factor = 2, textwidth = 16.9)

    x = Int(round(factor * textwidth * pts_per_cm, RoundUp))
    y = Int(round(x * ratio, RoundUp))

    return (x,y)
    
end

function halfwidth(ratio = 1.0; factor = 2, textwidth = 16.9)

    x = Int(round(factor * textwidth / 2 * pts_per_cm, RoundUp))
    y = Int(round(x * ratio, RoundUp))

    return (x,y)
    
end

function customwidth(widthfactor, ratio = 1.0; factor = 2, textwidth = 16.9)

    x = Int(round(factor * widthfactor * textwidth * pts_per_cm, RoundUp))
    y = Int(round(x * ratio, RoundUp))

    return (x,y)

end