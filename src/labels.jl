#=
All-caps labels. Makie cannot transform text case, so labels are written through `caps`.
=#

_isgreek(c::Char) = ('Ͱ' <= c <= 'Ͽ') || ('ἀ' <= c <= '῿')

"""
    caps(s)

Upper-case a label for the kjlMakie style, keeping as typed:
- units in square brackets: `"displacement [mm]"` → `"DISPLACEMENT [mm]"`;
- Greek letters: `"σ max"` → `"σ MAX"`;
- anything in braces, braces removed: `"{M_u} / {φM_n}"` → `"M_u / φM_n"`.
LaTeXStrings and rich text are returned unchanged.
"""
function caps(s::AbstractString)
    out = IOBuffer()
    depth_sq = 0; depth_br = 0
    for c in s
        if c == '{'
            depth_br += 1; continue
        elseif c == '}' && depth_br > 0
            depth_br -= 1; continue
        elseif c == '['
            depth_sq += 1
        elseif c == ']' && depth_sq > 0
            depth_sq -= 1; print(out, c); continue
        end
        print(out, (depth_sq > 0 || depth_br > 0 || _isgreek(c)) ? c : uppercase(c))
    end
    return String(take!(out))
end
caps(s) = s                                   # LaTeXString, rich text, numbers: unchanged
caps(s::Makie.LaTeXString) = s

_capsattr!(obj, name) = (v = getproperty(obj, name)[]; v isa AbstractString && !(v isa Makie.LaTeXString) &&
    setproperty!(obj, name, caps(v)))

function _capsticks!(ax, name)
    t = getproperty(ax, name)[]
    if t isa Tuple && length(t) == 2 && t[2] isa AbstractVector
        setproperty!(ax, name, (t[1], map(caps, t[2])))
    end
end

"""
    capslabels!(fig_or_axis)

Apply `caps` to every axis title/label, categorical tick label, colorbar label and legend entry
of a figure (or one axis). Idempotent.
"""
function capslabels!(ax::Axis)
    foreach(n -> _capsattr!(ax, n), (:title, :xlabel, :ylabel))
    _capsticks!(ax, :xticks); _capsticks!(ax, :yticks)
    return ax
end
function capslabels!(ax::Axis3)
    foreach(n -> _capsattr!(ax, n), (:title, :xlabel, :ylabel, :zlabel))
    return ax
end
capslabels!(cb::Colorbar) = (_capsattr!(cb, :label); cb)
function capslabels!(leg::Legend)
    groups = leg.entrygroups[]
    for (i, (title, entries)) in enumerate(groups)
        title isa AbstractString && (groups[i] = (caps(title), entries))
        for e in entries
            l = e.label[]
            l isa AbstractString && !(l isa Makie.LaTeXString) && (e.label[] = caps(l))
        end
    end
    notify(leg.entrygroups)
    return leg
end
capslabels!(x) = x
function capslabels!(fig::Figure)
    for c in fig.content
        capslabels!(c)
    end
    return fig
end
