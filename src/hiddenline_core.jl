#=
Hidden-line core: backend-neutral occlusion for orthographic drawings of 3D structures.

KEEP IDENTICAL in kjlMakie (`src/hiddenline_core.jl`) and FormaViz (`src/hiddenline_core.jl`):
pure Julia, no package dependencies, no colours. Backends (Makie `linesegments!`, the FormaViz
SVG drafting canvas) only draw the ordered primitives this file returns.

Why: vector backends (CairoMakie PDF/SVG, SVG canvases) have no depth buffer; they paint in the
order given. `hidden_order` returns line pieces, node dots and faces in back-to-front order with
correct occlusion:

1. project (orthographic; viewer in direction `toward = (cos e cos a, cos e sin a, sin e)`, the
   Makie `Axis3` azimuth/elevation convention);
2. faces (opaque triangles): every line is split where its projection crosses a face edge and
   pieces behind a nearer face are dropped (lines lying on a face stay); faces are returned in
   painter's order (centroid depth) and are drawn first;
3. on-screen crossings between members that do not share a node: at a real crossing (angle above
   ~15°, not next to a joint) the FAR member is cut so its round-capped ends clear the near
   member's band (half-width w/2 + `clearance`): g = (w_near/2 + clearance + w_far/2)/sinθ.
   Nothing is painted in a background colour, so gaps never show as blobs over a ground plane or
   other members. Other crossings get short depth-carrying stubs so the depth AT the crossing
   decides the order;
4. nodes: every member gets a stub at each end carrying its node's depth, and is split where it
   passes over another node's dot, so a dot is hidden only by a member really in front of it;
5. everything sorted far → near.

Widths, clearance and node radius are in OUTPUT units (pt for Makie, px for a canvas); `width`
is the drawing's approximate output width, which converts them to data units.
=#

const HLPoint2 = NTuple{2,Float64}
const HLPoint3 = NTuple{3,Float64}

_hl3(p) = (Float64(p[1]), Float64(p[2]), Float64(p[3]))
_hldot(a, b) = a[1] * b[1] + a[2] * b[2] + a[3] * b[3]

"""
    hl_basis(azimuth, elevation) -> (right, up, toward)

Orthographic view basis (Makie `Axis3` convention): the viewer sits in direction
`toward = (cos e cos a, cos e sin a, sin e)` from the scene; `right`/`up` span the screen.
"""
function hl_basis(azimuth::Real, elevation::Real)
    d = (cos(elevation) * cos(azimuth), cos(elevation) * sin(azimuth), sin(elevation))
    r = (-sin(azimuth), cos(azimuth), 0.0)
    u = (d[2] * r[3] - d[3] * r[2], d[3] * r[1] - d[1] * r[3], d[1] * r[2] - d[2] * r[1])
    return (r, u, d)
end

"""
    hl_project(points, basis) -> (xy::Vector{NTuple{2}}, depth::Vector)

Screen coordinates and depths (larger = nearer the viewer) of 3D points.
"""
function hl_project(P, basis)
    r, u, d = basis
    xy = HLPoint2[(_hldot(r, _hl3(p)), _hldot(u, _hl3(p))) for p in P]
    z = Float64[_hldot(d, _hl3(p)) for p in P]
    return xy, z
end

_sub2(a, b) = (a[1] - b[1], a[2] - b[2])
_add2(a, b) = (a[1] + b[1], a[2] + b[2])
_mul2(a, s) = (a[1] * s, a[2] * s)
_norm2(a) = sqrt(a[1]^2 + a[2]^2)

# on-screen crossing of (a,b) and (c,e): parameters (t, s) strictly inside both, or nothing
function _hl_crossing(a, b, c, e; tol = 1e-9)
    r = _sub2(b, a); q = _sub2(e, c)
    den = r[1] * q[2] - r[2] * q[1]
    abs(den) < tol * (r[1]^2 + r[2]^2 + q[1]^2 + q[2]^2) && return nothing
    w = _sub2(c, a)
    t = (w[1] * q[2] - w[2] * q[1]) / den
    s = (w[1] * r[2] - w[2] * r[1]) / den
    (tol < t < 1 - tol && tol < s < 1 - tol) || return nothing
    return t, s
end

# ── faces ─────────────────────────────────────────────────────────────────────────────────

"""
    HLFaces

Projected opaque triangles: 2D vertices `xy`, depths `z`, `tris` (n×3 indices), bounding boxes.
Build with `hl_faces(points, tris, basis)`.
"""
struct HLFaces
    xy::Vector{HLPoint2}
    z::Vector{Float64}
    tris::Matrix{Int}
    bbox::Vector{NTuple{4,Float64}}
end
function hl_faces(points, tris::AbstractMatrix{<:Integer}, basis)
    xy, z = hl_project(points, basis)
    bb = [begin
        a, b, c = xy[tris[k, 1]], xy[tris[k, 2]], xy[tris[k, 3]]
        (min(a[1], b[1], c[1]), max(a[1], b[1], c[1]), min(a[2], b[2], c[2]), max(a[2], b[2], c[2]))
    end for k in axes(tris, 1)]
    return HLFaces(xy, z, Matrix{Int}(tris), bb)
end

"face indices in painter's order (far → near by centroid depth)"
hl_face_order(F::HLFaces) =
    sortperm([(F.z[F.tris[k, 1]] + F.z[F.tris[k, 2]] + F.z[F.tris[k, 3]]) / 3 for k in axes(F.tris, 1)])

function _hl_bary(p, a, b, c)
    v0 = _sub2(b, a); v1 = _sub2(c, a); v2 = _sub2(p, a)
    den = v0[1] * v1[2] - v1[1] * v0[2]
    abs(den) < 1e-14 && return nothing
    l1 = (v2[1] * v1[2] - v1[1] * v2[2]) / den
    l2 = (v0[1] * v2[2] - v2[1] * v0[2]) / den
    return (1 - l1 - l2, l1, l2)
end

"is the screen point `p` at depth `zp` behind some face (nearer by more than `tol`)?"
function hl_occluded(F::HLFaces, p, zp, tol)
    for k in eachindex(F.bbox)
        b = F.bbox[k]
        (p[1] < b[1] || p[1] > b[2] || p[2] < b[3] || p[2] > b[4]) && continue
        i, j, l = F.tris[k, 1], F.tris[k, 2], F.tris[k, 3]
        w = _hl_bary(p, F.xy[i], F.xy[j], F.xy[l])
        w === nothing && continue
        (w[1] < -1e-9 || w[2] < -1e-9 || w[3] < -1e-9) && continue
        w[1] * F.z[i] + w[2] * F.z[j] + w[3] * F.z[l] > zp + tol && return true
    end
    return false
end

"""
    hl_cull(starts, ends, F::HLFaces, basis; tol) -> (starts, ends, parent)

Split 3D segments where their projections cross a face edge; keep the pieces not behind a
nearer face (`tol` [data units] keeps lines lying ON a face visible). `parent[k]` = input index.
"""
function hl_cull(starts, ends, F::HLFaces, basis; tol)
    S = [_hl3(p) for p in starts]; E = [_hl3(p) for p in ends]
    A, za = hl_project(S, basis); B, zb = hl_project(E, basis)
    edges = Set{Tuple{Int,Int}}()
    for k in axes(F.tris, 1), (a, b) in ((1, 2), (2, 3), (3, 1))
        i, j = F.tris[k, a], F.tris[k, b]
        push!(edges, (min(i, j), max(i, j)))
    end
    edges = collect(edges)
    ebx = [(min(F.xy[i][1], F.xy[j][1]), max(F.xy[i][1], F.xy[j][1]), min(F.xy[i][2], F.xy[j][2]), max(F.xy[i][2], F.xy[j][2])) for (i, j) in edges]
    S2 = HLPoint3[]; E2 = HLPoint3[]; parent = Int[]
    lerp3(a, b, t) = (a[1] + t * (b[1] - a[1]), a[2] + t * (b[2] - a[2]), a[3] + t * (b[3] - a[3]))
    for s in eachindex(S)
        a, b = A[s], B[s]
        sx = (min(a[1], b[1]), max(a[1], b[1]), min(a[2], b[2]), max(a[2], b[2]))
        ts = [0.0, 1.0]
        for (e, (i, j)) in enumerate(edges)
            q = ebx[e]
            (q[1] > sx[2] || q[2] < sx[1] || q[3] > sx[4] || q[4] < sx[3]) && continue
            c = _hl_crossing(a, b, F.xy[i], F.xy[j])
            c === nothing || push!(ts, c[1])
        end
        sort!(ts); unique!(ts)
        run0 = nothing
        for k in 1:length(ts)-1
            tm = (ts[k] + ts[k+1]) / 2
            vis = !hl_occluded(F, _add2(a, _mul2(_sub2(b, a), tm)), za[s] + tm * (zb[s] - za[s]), tol)
            if vis
                run0 === nothing && (run0 = ts[k])
            elseif run0 !== nothing
                push!(S2, lerp3(S[s], E[s], run0)); push!(E2, lerp3(S[s], E[s], ts[k])); push!(parent, s); run0 = nothing
            end
        end
        run0 === nothing || (push!(S2, lerp3(S[s], E[s], run0)); push!(E2, E[s]); push!(parent, s))
    end
    return S2, E2, parent
end

# ── ordering ──────────────────────────────────────────────────────────────────────────────

"""
    hidden_order(starts, ends; basis, widths = 1.0, nodes = nothing, noderadius = 2.0,
                 faces = nothing, gaps = true, clearance = 0.6, width = 400.0, upt = nothing)

Back-to-front drawing order of 3D segments `starts[i] → ends[i]` (+ optional `nodes`, 3D points,
drawn as dots of `noderadius`), with occlusion by opaque `faces = (points, tris)` if given.
`widths` (scalar or per segment), `clearance` and `noderadius` are in output units; `width` is
the drawing's output width (or give `upt`, data units per output unit).

Returns a NamedTuple:
- `prims`: Vector of `(kind, p, q, i, w)` in drawing order; `kind = :seg` (screen points `p → q`,
  `i` = INPUT segment index for styling, `w` = width) or `:node` (`p` = centre, `i` = node index);
- `faces`: the projected `HLFaces` (or `nothing`) and `faceorder` (painter's order) — draw these
  first;
- `upt`, `span`: scale information (data units per output unit, drawing span).
"""
function hidden_order(starts, ends; basis, widths = 1.0, nodes = nothing, noderadius = 2.0,
    faces = nothing, gaps::Bool = true, clearance = 0.6, width = 400.0, upt = nothing)

    n0 = length(starts)
    n0 == length(ends) || error("starts and ends differ in length")
    W0 = widths isa AbstractVector ? Float64.(widths) : fill(Float64(widths), n0)
    S0 = [_hl3(p) for p in starts]; E0 = [_hl3(p) for p in ends]
    N0 = nodes === nothing ? HLPoint3[] : [_hl3(p) for p in nodes]

    # span (for scale and tolerances) over everything drawn
    allxy, _ = hl_project(vcat(S0, E0, N0, faces === nothing ? HLPoint3[] : [_hl3(p) for p in faces[1]]), basis)
    lo1, hi1 = extrema(p -> p[1], allxy); lo2, hi2 = extrema(p -> p[2], allxy)
    span = max(hi1 - lo1, hi2 - lo2, eps())
    upt = upt === nothing ? span / width : Float64(upt)
    capδ = 0.03 * span

    # --- faces: cull lines and nodes behind them ------------------------------------------
    F = nothing; faceorder = Int[]; parent = collect(1:n0); S = S0; E = E0; N = N0
    if faces !== nothing
        F = hl_faces(faces[1], faces[2], basis)
        faceorder = hl_face_order(F)
        tol = 1e-4 * span
        S, E, parent = hl_cull(S0, E0, F, basis; tol)
        if !isempty(N0)
            nxy, nz = hl_project(N0, basis)
            keep = [!hl_occluded(F, nxy[k], nz[k], tol) for k in eachindex(N0)]
            N = N0[keep]
        end
    end
    n = length(S)
    lws = W0[parent]
    A, za = hl_project(S, basis); B, zb = hl_project(E, basis)
    Ls = [_norm2(_sub2(B[i], A[i])) for i in 1:n]
    hasnodes = !isempty(N)
    rnode = hasnodes ? Float64(noderadius) : 0.0

    key(p) = (round(p[1]; sigdigits = 10), round(p[2]; sigdigits = 10), round(p[3]; sigdigits = 10))
    ks = [key(p) for p in S]; ke = [key(p) for p in E]
    bx = [(min(A[i][1], B[i][1]), max(A[i][1], B[i][1]), min(A[i][2], B[i][2]), max(A[i][2], B[i][2])) for i in 1:n]
    cuts = [Tuple{Float64,Float64,Bool}[] for _ in 1:n]          # (t, half-length [data], is a gap)

    # member ends carry the node depth (the node, a hair in front, paints over its members)
    if hasnodes
        for i in 1:n
            h = (rnode + lws[i] / 2 + 0.3) * upt
            push!(cuts[i], (0.0, h, false)); push!(cuts[i], (1.0, h, false))
        end
    end

    # crossings
    order = sortperm(bx; by = b -> b[1])
    nearend(t, i, r) = min(t, 1 - t) * Ls[i] < r
    for ii in 1:n
        i = order[ii]
        for jj in ii+1:n
            j = order[jj]
            bx[j][1] > bx[i][2] && break
            (bx[j][3] > bx[i][4] || bx[j][4] < bx[i][3]) && continue
            (ks[i] == ks[j] || ks[i] == ke[j] || ke[i] == ks[j] || ke[i] == ke[j]) && continue
            (Ls[i] > 0 && Ls[j] > 0) || continue
            c = _hl_crossing(A[i], B[i], A[j], B[j])
            c === nothing && continue
            t, s = c
            ri = _sub2(B[i], A[i]); rj = _sub2(B[j], A[j])
            sinθ = abs(ri[1] * rj[2] - ri[2] * rj[1]) / (Ls[i] * Ls[j])
            inear = za[i] + t * (zb[i] - za[i]) > za[j] + s * (zb[j] - za[j])
            rj_ = (max(rnode, lws[i], lws[j]) + clearance + 1.0) * upt
            if gaps && sinθ > 0.26 && !nearend(t, i, rj_) && !nearend(s, j, rj_)
                nn, ff, tf = inear ? (i, j, s) : (j, i, t)
                g = ((lws[nn] / 2 + clearance + lws[ff] / 2) / sinθ) * upt
                push!(cuts[ff], (tf, min(g, capδ), true))
            else
                sθ = max(sinθ, 0.05)
                push!(cuts[i], (t, min((lws[j] / (2sθ) + lws[i] / 2 + 0.5) * upt, capδ), false))
                push!(cuts[j], (s, min((lws[i] / (2sθ) + lws[j] / 2 + 0.5) * upt, capδ), false))
            end
        end
    end

    # members passing over a node dot: split there
    if hasnodes
        NP, nz = hl_project(N, basis)
        nk = [key(p) for p in N]
        for (k, p) in enumerate(NP), i in 1:n
            r = (rnode + lws[i] / 2) * upt
            (p[1] < bx[i][1] - r || p[1] > bx[i][2] + r || p[2] < bx[i][3] - r || p[2] > bx[i][4] + r) && continue
            (nk[k] == ks[i] || nk[k] == ke[i]) && continue
            Ls[i] > 0 || continue
            v = _sub2(B[i], A[i])
            t = clamp(((p[1] - A[i][1]) * v[1] + (p[2] - A[i][2]) * v[2]) / Ls[i]^2, 0.0, 1.0)
            d = _norm2(_sub2(_add2(A[i], _mul2(v, t)), p))
            d < r || continue
            push!(cuts[i], (t, sqrt(max(r^2 - d^2, 0.0)) + 0.5upt, false))
        end
    end

    # pieces
    prims = Tuple{Float64,Symbol,HLPoint2,HLPoint2,Int,Float64}[]
    for i in 1:n
        L = Ls[i]
        pt(t) = _add2(A[i], _mul2(_sub2(B[i], A[i]), t))
        dz(t) = za[i] + t * (zb[i] - za[i])
        sort!(cuts[i]; by = first)
        t0 = 0.0
        for (tc, h, isgap) in cuts[i]
            dt = L > 0 ? h / L : 0.0
            a, b = max(tc - dt, t0), min(tc + dt, 1.0)
            b <= a && continue
            a > t0 && push!(prims, (dz((t0 + a) / 2), :seg, pt(t0), pt(a), parent[i], lws[i]))
            isgap || push!(prims, (dz(tc), :seg, pt(a), pt(b), parent[i], lws[i]))
            t0 = b
        end
        t0 < 1 && push!(prims, (dz((t0 + 1) / 2), :seg, pt(t0), pt(1.0), parent[i], lws[i]))
    end
    if hasnodes
        NP, nz = hl_project(N, basis)
        # node index refers to the INPUT nodes vector
        nidx = faces === nothing || isempty(N0) ? collect(eachindex(N)) :
            [findfirst(==(p), N0) for p in N]
        bias = 1e-6 * span
        for k in eachindex(N)
            push!(prims, (nz[k] + bias, :node, NP[k], NP[k], nidx[k], 2rnode))
        end
    end
    sort!(prims; by = first)

    return (prims = [(kind = p[2], p = p[3], q = p[4], i = p[5], w = p[6]) for p in prims],
        faces = F, faceorder = faceorder, upt = upt, span = span)
end
