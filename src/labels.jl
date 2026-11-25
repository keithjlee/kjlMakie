#=
ALL-CAPS labels with light symbol markup. The token rule is Forma's (FormaViz `src/labels.jl`,
forma-typst `caps-upper`): keep the three implementations' RULE identical.

  tokens   runs of letters and digits, with `'`, `′`, `_`, `^`, `\` and balanced `{…}` groups
           attached (`f'_c`, `A_{ps}`, `x^2`, `2x4`).
  caps     a token goes uppercase only when it is a plain alphabetic word of 3+ letters in all
           lowercase or Title case (`rooms`, `Table`) and not a unit (`psf`, `kips`, `rad`, …), or a
           listed 2-letter word (`at`, `of`, `in` …) not right after a number, `·` or `/`.
           Kept as written: 1–2 letter tokens (`h`, `Vu`, `mm`), internal capitals (`kN`, `MPa`),
           digits (`2x4`), markup, Greek. Applies inside brackets too.
  markup   only on a symbol-shaped token: a 1–3 letter (or Greek or ℓ) base, an optional prime,
           then one `_x`/`_{…}` or `^x`/`^{…}` group (`M_u`, `f'_c`, `N_{yy}`, `φM_n`); rendered as
           real sub/superscripts. `\_` is a literal underscore; `\phi`, `\beta` … are Greek.
  glyphs   characters IBM Plex Mono lacks fall back to IBM Plex Sans, per run.
=#

const _GREEK = Dict(
    "alpha" => "α", "beta" => "β", "gamma" => "γ", "delta" => "δ", "epsilon" => "ε", "varepsilon" => "ε",
    "zeta" => "ζ", "eta" => "η", "theta" => "θ", "kappa" => "κ", "lambda" => "λ", "mu" => "μ", "nu" => "ν",
    "xi" => "ξ", "pi" => "π", "rho" => "ρ", "sigma" => "σ", "tau" => "τ", "phi" => "ϕ", "varphi" => "φ",
    "chi" => "χ", "psi" => "ψ", "omega" => "ω", "Gamma" => "Γ", "Delta" => "Δ", "Theta" => "Θ",
    "Lambda" => "Λ", "Pi" => "Π", "Sigma" => "Σ", "Phi" => "Φ", "Psi" => "Ψ", "Omega" => "Ω")

const _ESC_US = ''                                   # placeholder for an escaped `\_`
_greek(s::AbstractString) = replace(s, r"\\([A-Za-z]+)" => m -> get(_GREEK, m[2:end], m))
_unescape(s::AbstractString) = replace(s, _ESC_US => '_')
_isgreek(ch::Char) = ('Ͱ' <= ch <= 'Ͽ') || ('ἀ' <= ch <= '῿')
_tokchar(ch::Char) = isletter(ch) || isdigit(ch) || ch in ('\'', '′', '_', '^', '\\', _ESC_US)

function _tokens(s::AbstractString)
    out = UnitRange{Int}[]
    i, n = firstindex(s), ncodeunits(s)
    while i <= n
        if !_tokchar(s[i])
            i = nextind(s, i); continue
        end
        j, last = i, i
        while j <= n
            ch = s[j]
            if ch == '{'
                depth = 0
                while j <= n
                    depth += s[j] == '{' ? 1 : s[j] == '}' ? -1 : 0
                    last = j; j = nextind(s, j)
                    depth == 0 && break
                end
            elseif _tokchar(ch)
                last = j; j = nextind(s, j)
            else
                break
            end
        end
        push!(out, i:last)
        i = j
    end
    return out
end

"Unit symbols `caps` keeps as written (only 3+ letter ones matter)."
const CAPS_UNITS = Set(["psf", "psi", "ksi", "ksf", "kip", "kips", "plf", "klf", "kcf", "pcf", "lbs", "lbf",
    "mph", "sec", "min", "hr", "hrs", "deg", "rad", "mrad", "mm", "cm", "km", "kN", "MN", "MPa", "kPa", "GPa",
    "ft", "in", "yd", "lb", "kg", "kgf", "tonne", "tonnes", "mil", "mils", "gal", "cfm", "gpm", "rpm", "kWh", "msec"])

"Two-letter words `caps` uppercases (unless they read as a unit after a number, `·` or `/`)."
const CAPS_WORDS2 = Set(["at", "to", "of", "on", "by", "or", "is", "an", "if", "no", "up", "as", "in", "it", "be", "so", "do"])

function _caps_token(t::AbstractString; unitpos::Bool = false, afterop::Bool = false)
    t in CAPS_WORDS2 && return unitpos ? t : uppercase(t)
    t == "per" && return afterop ? t : "PER"
    any(ch -> isdigit(ch) || ch in ('_', '^', '\\', '{', '}', _ESC_US) || _isgreek(ch), t) && return t
    letters = [ch for ch in t if isletter(ch)]
    length(letters) >= 3 || return t
    t in CAPS_UNITS && return t
    lower = all(islowercase, letters)
    title = isuppercase(letters[1]) && all(islowercase, letters[2:end])
    (lower || title) || return t
    return map(ch -> _isgreek(ch) ? ch : uppercase(ch), t)
end

"""
    caps(s) -> String

ALL CAPS by the Forma token rule (see the file header): plain 3+ letter words (lowercase or
Title case, not units) and listed 2-letter words go up; units, 1–2 letter symbols, internal
capitals (`kN`), digits, markup (`M_u`) and Greek keep their case, brackets included.
Write longer symbols with markup (`A_{sh}`), else a Title-case 3-letter symbol goes up.

```julia
caps("moment M_u [kN·m]")          # "MOMENT M_u [kN·m]"
caps("drift vs joint stiffness k") # "DRIFT VS JOINT STIFFNESS k"
```
"""
function caps(s::AbstractString)
    s isa Makie.LaTeXString && return s
    s = replace(s, "\\_" => string(_ESC_US))
    io, pos = IOBuffer(), 1
    prev = ""
    for r in _tokens(s)
        gap = SubString(s, pos, prevind(s, first(r)))
        print(io, gap)
        afterop = occursin(r"[·/]\s*$", gap)
        unitpos = afterop || (!isempty(prev) && isdigit(first(prev)) && all(isspace, gap))
        t = SubString(s, first(r), last(r))
        print(io, _caps_token(t; unitpos, afterop))
        prev = t
        pos = nextind(s, last(r))
    end
    print(io, SubString(s, pos))
    return replace(String(take!(io)), _ESC_US => "\\_")
end
caps(s) = s

function _markup_group(s::AbstractString, i::Int)
    if s[i] == '{'
        depth, j, io = 1, nextind(s, i), IOBuffer()
        while j <= ncodeunits(s)
            ch = s[j]
            depth += ch == '{' ? 1 : ch == '}' ? -1 : 0
            depth == 0 && return String(take!(io)), nextind(s, j)
            ch in ('{', '}') || print(io, ch)
            j = nextind(s, j)
        end
        return String(take!(io)), j
    end
    return string(s[i]), nextind(s, i)
end

_symbase(ch::Char) = ('A' <= ch <= 'Z') || ('a' <= ch <= 'z') || _isgreek(ch) || ch == 'ℓ'

function _symbol_parts(t::AbstractString)
    chars = collect(t)
    k = 0
    while k < length(chars) && _symbase(chars[k+1]); k += 1; end
    1 <= k <= 3 || return nothing
    base = String(chars[1:k])
    i = k + 1
    if i <= length(chars) && chars[i] in ('\'', '′')
        base *= "′"; i += 1
    end
    i <= length(chars) && chars[i] in ('_', '^') || return nothing
    kind = chars[i] == '_' ? :sub : :sup
    i += 1
    i <= length(chars) || return nothing
    rest = String(chars[i:end])
    g, j = _markup_group(rest, firstindex(rest))
    j > ncodeunits(rest) || return nothing
    isempty(g) && return nothing
    return [:base => base, kind => _unescape(g)]
end

"""
    label_parts(s) -> Vector{Pair{Symbol,String}}

Markup runs `kind => text` (`:base`, `:sub`, `:sup`) of a label (see the file header).
"""
function label_parts(s::AbstractString)
    s = _greek(replace(s, "\\_" => string(_ESC_US)))
    out = Pair{Symbol,String}[]
    io = IOBuffer()
    flush!() = (b = _unescape(String(take!(io))); isempty(b) || push!(out, :base => b))
    pos = 1
    for r in _tokens(s)
        print(io, SubString(s, pos, prevind(s, first(r))))
        t = SubString(s, first(r), last(r))
        sp = _symbol_parts(t)
        if sp === nothing
            print(io, t)
        else
            print(io, sp[1][2]); flush!(); push!(out, sp[2])
        end
        pos = nextind(s, last(r))
    end
    print(io, SubString(s, pos))
    flush!()
    return out
end

const _FALLBACK_FONT = "IBM Plex Sans"

function _rich_runs(t::AbstractString)
    main = Makie.to_font(KJL_MONO)
    runs = Tuple{String,Union{Nothing,String}}[]
    for ch in t
        fb = !isspace(ch) && Makie.FreeTypeAbstraction.glyph_index(main, ch) == 0 ? _FALLBACK_FONT : nothing
        if !isempty(runs) && runs[end][2] == fb
            runs[end] = (runs[end][1] * ch, fb)
        else
            push!(runs, (string(ch), fb))
        end
    end
    return [fb === nothing ? s : Makie.rich(s; font = fb) for (s, fb) in runs]
end

"""
    kjl_label(s; caps = true) -> String or Makie rich text

A Makie label from a plain string: `caps` (when `caps = true`), then markup as real
sub/superscripts and missing glyphs in the fallback font. `LaTeXString`s and `rich(...)` pass
through. `capslabels!(fig)` applies it to a whole figure (`savereport` does not; call it before saving).

```julia
kjl_label("N_{yy} [kN/m]")      # N with subscript yy, " [kN/m]"
```
"""
kjl_label(s; kw...) = s
function kjl_label(s::AbstractString; caps::Bool = true)
    s isa Makie.LaTeXString && return s
    t = caps ? kjlMakie.caps(s) : String(s)
    parts = label_parts(t)
    runs = Any[]
    for (k, p) in parts
        r = _rich_runs(p)
        k === :base ? append!(runs, r) : push!(runs, (k === :sub ? Makie.subscript : Makie.superscript)(r...))
    end
    isempty(runs) && return t
    length(runs) == 1 && runs[1] isa AbstractString && return runs[1]
    return Makie.rich(runs...)
end

_plain(x) = x isa AbstractString && !(x isa Makie.LaTeXString)
_label_value(v; kw...) = _plain(v) ? kjl_label(v; kw...) : v
_label_value(v::AbstractVector; kw...) = any(_plain, v) ? Any[_label_value(x; kw...) for x in v] : v

function _relabel!(obs; kw...)
    v = obs[]
    _plain(v) || return
    new = kjl_label(v; kw...)
    new == v || (obs[] = new)
    return
end

function _relabel_ticks!(obs; kw...)
    v = obs[]
    (v isa Tuple && length(v) == 2 && v[2] isa AbstractVector) || return
    new = _label_value(v[2]; kw...)
    isequal(new, v[2]) || (obs[] = (v[1], new))
    return
end

function _relabel_text!(plots; kw...)
    for p in plots
        if p isa Makie.Text
            obs = p[:text]
            new = _label_value(obs[]; kw...)
            isequal(new, obs[]) || (obs[] = new)
        end
        _relabel_text!(p.plots; kw...)
    end
    return
end

"""
    capslabels!(fig_or_axis; caps = true)

Route every label through `kjl_label`: axis titles and labels, categorical tick labels, `text!`
annotations, colorbar labels, `Label` blocks and legend entries. Idempotent; rich text and
`LaTeXString`s pass through (use `rich("…")` to keep one label exactly as typed).
"""
function capslabels!(ax::Axis; caps::Bool = true)
    foreach(o -> _relabel!(o; caps), (ax.title, ax.subtitle, ax.xlabel, ax.ylabel))
    foreach(o -> _relabel_ticks!(o; caps), (ax.xticks, ax.yticks))
    _relabel_text!(ax.scene.plots; caps)
    return ax
end
function capslabels!(ax::Axis3; caps::Bool = true)
    foreach(o -> _relabel!(o; caps), (ax.title, ax.xlabel, ax.ylabel, ax.zlabel))
    return ax
end
capslabels!(cb::Colorbar; caps::Bool = true) = (_relabel!(cb.label; caps); cb)
capslabels!(l::Label; caps::Bool = true) = (_relabel!(l.text; caps); l)
function capslabels!(leg::Legend; caps::Bool = true)
    for (title, entries) in leg.entrygroups[], e in entries
        _relabel!(e.attributes[:label]; caps)
    end
    groups = leg.entrygroups[]
    if any(g -> _plain(g[1]), groups)
        leg.entrygroups[] = [(_plain(g[1]) ? kjl_label(g[1]; caps) : g[1], g[2]) for g in groups]
    end
    return leg
end
capslabels!(x; kw...) = x
function capslabels!(fig::Figure; caps::Bool = true)
    for c in fig.content
        capslabels!(c; caps)
    end
    return fig
end
