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
#=
Report sizes. Figure units are typographic points: build at the printed width with
`reportsize`, save with `savereport`, embed at natural size (kjl-typst `kjl-fig` default), and the
theme's 9 pt text prints at 9 pt.
=#

"text width of the kjl-typst report template [pt]: US letter, 0.75 in side margins"
const TEXTWIDTH = 504.0

"""
    reportsize(frac = 1.0, ratio = 0.75; textwidth = TEXTWIDTH)

Figure size `(w, h)` in points for a figure printed at `frac` of the text width, height
`ratio × w`. `reportsize(0.5)` is a half-width panel.
"""
reportsize(frac::Real = 1.0, ratio::Real = 0.75; textwidth = TEXTWIDTH) =
    (round(Int, frac * textwidth), round(Int, frac * textwidth * ratio))

"""
    savereport(path, fig; px_per_unit = 4)

Save for embedding at natural size: `.pdf`/`.svg` at 1 pt per figure unit (vector, true text
size); `.png` at `px_per_unit` pixels per point (embed with an explicit width =
figure width in pt).
"""
function savereport(path::AbstractString, fig; px_per_unit = 4)
    if endswith(lowercase(path), ".png")
        save(path, fig; px_per_unit = px_per_unit)
    else
        save(path, fig; pt_per_unit = 1)
    end
    return path
end
