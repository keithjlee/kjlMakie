#=
Hidden-line vector drawing of 3D line structures (phase 1: lines + nodes, no opaque faces).

CairoMakie has no depth buffer: it draws plots, and the segments inside a plot, in the order
given, so a 3D structure exported to PDF/SVG shows far members painted over near ones. Here the
structure is projected ourselves (orthographic, Axis3's azimuth/elevation convention) and drawn
into a plain 2D `Axis` as ONE `linesegments!` call whose segments are already in back-to-front
order, which CairoMakie preserves:

1. project every member to the screen (x, y) plus a depth (distance toward the viewer);
2. find every on-screen crossing between members that do not share a node;
3. split members at each crossing into a short STUB around the crossing (whose depth is the
   depth at the crossing) and long pieces between; after splitting, pieces only overlap at
   crossings, where the stubs carry the correct depth;
4. nodes become dots (zero-length round-capped segments: outline + fill). Every member gets a
   stub at each end carrying its node's depth, and is split wherever it passes over another
   node's dot, so dots and members are ordered by their depths AT the dot: a node is hidden only
   by a member that is really in front of it;
5. sort everything far → near; with `halo = true` the NEARER member's stub at each crossing is
   first drawn in the background colour, wider, so the far member shows a small gap where the
   near one crosses it (the engineering hidden-line look). Stub lengths follow the crossing angle
   and the line widths, so the gap is just wide enough.

Output is plain 2D, so `structurestyle!` / `fitstructure!` apply as for any 2D drawing.
=#

"""
    view_basis(azimuth, elevation) -> (right, up, toward)

Orthographic view basis, same convention as `Axis3`: the viewer sits in direction
`toward = (cos e cos a, cos e sin a, sin e)` from the scene; `right`/`up` span the screen.
"""
function view_basis(azimuth::Real, elevation::Real)
    d = Vec3d(cos(elevation) * cos(azimuth), cos(elevation) * sin(azimuth), sin(elevation))
    r = Vec3d(-sin(azimuth), cos(azimuth), 0.0)
    u = Vec3d(d[2] * r[3] - d[3] * r[2], d[3] * r[1] - d[1] * r[3], d[1] * r[2] - d[2] * r[1])
    return r, u, d
end

"""
    project3d(points, azimuth, elevation) -> (Vector{Point2d}, depths)

Orthographic screen coordinates and depths (larger = nearer the viewer) of 3D points.
"""
function project3d(P::AbstractVector, azimuth::Real, elevation::Real)
    r, u, d = view_basis(azimuth, elevation)
    xy = [Point2d(sum(r .* p), sum(u .* p)) for p in P]
    z = [sum(d .* p) for p in P]
    return xy, z
end

# on-screen crossing of segments (a,b) and (c,e): parameters (t, s) in (0,1) or nothing
function _crossing(a, b, c, e; tol = 1e-9)
    r = b - a; q = e - c
    den = r[1] * q[2] - r[2] * q[1]
    abs(den) < tol * (sum(abs2, r) + sum(abs2, q)) && return nothing     # parallel
    w = c - a
    t = (w[1] * q[2] - w[2] * q[1]) / den
    s = (w[1] * r[2] - w[2] * r[1]) / den
    (tol < t < 1 - tol && tol < s < 1 - tol) || return nothing
    return t, s
end

_expand(x, n) = x isa AbstractVector ? x : fill(x, n)

"""
    hiddenline!(ax::Axis, starts, ends; azimuth = -3π/4, elevation = π/8, color = kjl_black,
                linewidth = 1.0, nodes = nothing, nodesize = 4.0, nodecolor = :white,
                nodestrokecolor = kjl_black, nodestrokewidth = 0.75, halo = true,
                halowidth = 0.8, background = :white, width = 400, ground = false)

Draw 3D line segments `starts[i] → ends[i]` (3D points) into the 2D axis `ax` as an
orthographic view with correct occlusion (see the file header). `color`/`linewidth` [pt] are
scalars or one per segment. `nodes` (3D points) are drawn as outlined dots of diameter
`nodesize` [pt] over the members that meet there and under nearer members. `halo` cuts a
`halowidth` [pt] gap on each side of the NEARER member into the farther one at every crossing
(colour `background`). `width` is the approximate printed width of the drawing [pt], used to
size the crossing stubs and halos in data units. `ground = true` draws the projected
footprint (bounding rectangle at the lowest z) as a light ground plane behind everything.

Returns the projected 2D endpoints (for limits).
"""
function hiddenline!(ax::Axis, starts::AbstractVector, ends::AbstractVector;
    azimuth::Real = -3pi / 4, elevation::Real = pi / 8,
    color = kjl_black, linewidth = 1.0,
    nodes = nothing, nodesize = 4.0, nodecolor = :white, nodestrokecolor = kjl_black, nodestrokewidth = 0.75,
    halo::Bool = true, halowidth = 0.8, background = :white, width = 400,
    ground::Bool = false, groundcolor = (kjl_lightgray, 0.35), groundpad = 0.04)

    n = length(starts)
    n == length(ends) || error("starts and ends differ in length")
    cols = _expand(color, n); lws = float.(_expand(linewidth, n))
    A, za = project3d(starts, azimuth, elevation)
    B, zb = project3d(ends, azimuth, elevation)

    allxy = vcat(A, B)
    lo = Point2d(minimum(p -> p[1], allxy), minimum(p -> p[2], allxy))
    hi = Point2d(maximum(p -> p[1], allxy), maximum(p -> p[2], allxy))
    span = max(hi[1] - lo[1], hi[2] - lo[2])
    upt = span / width                                        # data units per point
    capδ = 0.03 * span                                        # longest stub half-length

    key(p) = (round(p[1]; sigdigits = 10), round(p[2]; sigdigits = 10), round(p[3]; sigdigits = 10))
    ks = [key(p) for p in starts]; ke = [key(p) for p in ends]
    bx = [(min(A[i][1], B[i][1]), max(A[i][1], B[i][1]), min(A[i][2], B[i][2]), max(A[i][2], B[i][2])) for i in 1:n]
    Ls = [sqrt(sum(abs2, B[i] - A[i])) for i in 1:n]
    hasnodes = nodes !== nothing && !isempty(nodes)
    rnode = hasnodes ? nodesize / 2 + nodestrokewidth : 0.0      # node dot radius [pt]

    # split events per member: (t, stub half-length [data], halo?)
    cuts = [Tuple{Float64,Float64,Bool}[] for _ in 1:n]

    # --- member ends: a stub at each end carries the NODE's depth, so the node (a hair in
    #     front) paints over the members that meet there whatever their direction --------
    if hasnodes
        for i in 1:n
            h = (rnode + lws[i] / 2 + 0.3) * upt
            push!(cuts[i], (0.0, h, false)); push!(cuts[i], (1.0, h, false))
        end
    end

    # --- crossings (x-sweep with bounding boxes; skip members sharing an endpoint) ------
    order = sortperm(bx; by = b -> b[1])
    nearend(t, i, r) = min(t, 1 - t) * Ls[i] < r              # crossing within r of a member end
    for ii in 1:n
        i = order[ii]
        for jj in ii+1:n
            j = order[jj]
            bx[j][1] > bx[i][2] && break
            (bx[j][3] > bx[i][4] || bx[j][4] < bx[i][3]) && continue
            (ks[i] == ks[j] || ks[i] == ke[j] || ke[i] == ks[j] || ke[i] == ke[j]) && continue
            c = _crossing(A[i], B[i], A[j], B[j])
            c === nothing && continue
            t, s = c
            ri = B[i] - A[i]; rj = B[j] - A[j]
            sinθ = abs(ri[1] * rj[2] - ri[2] * rj[1]) / (Ls[i] * Ls[j])
            sθ = max(sinθ, 0.05)
            # stub on each member long enough to contain the other's halo band
            hi_ = min(((lws[j] / 2 + halowidth) / sθ + lws[i] / 2 + 0.5) * upt, capδ)
            hj_ = min(((lws[i] / 2 + halowidth) / sθ + lws[j] / 2 + 0.5) * upt, capδ)
            inear = za[i] + t * (zb[i] - za[i]) > za[j] + s * (zb[j] - za[j])
            # halo only for real crossings: not at shallow angles (members lined up behind each
            # other would get long white smears) and not next to a joint (it would cut the joint)
            rj_ = (max(rnode, lws[i], lws[j]) + halowidth + 1.0) * upt
            h_ok = halo && sinθ > 0.26 && !nearend(t, i, rj_) && !nearend(s, j, rj_)
            push!(cuts[i], (t, hi_, inear && h_ok)); push!(cuts[j], (s, hj_, !inear && h_ok))
        end
    end

    # --- members passing over a node's dot: split there so the dot and the member are
    #     ordered by their depths AT the dot, not by the member's midpoint ----------------
    if hasnodes
        NP, nz = project3d(nodes, azimuth, elevation)
        nk = [key(p) for p in nodes]
        for (k, p) in enumerate(NP), i in 1:n
            r = (rnode + lws[i] / 2) * upt
            (p[1] < bx[i][1] - r || p[1] > bx[i][2] + r || p[2] < bx[i][3] - r || p[2] > bx[i][4] + r) && continue
            (nk[k] == ks[i] || nk[k] == ke[i]) && continue
            Ls[i] > 0 || continue
            v = B[i] - A[i]
            t = clamp(sum((p - A[i]) .* v) / Ls[i]^2, 0.0, 1.0)
            d = sqrt(sum(abs2, A[i] + t * v - p))
            d < r || continue
            push!(cuts[i], (t, sqrt(max(r^2 - d^2, 0.0)) + 0.5upt, false))
        end
    end

    # --- pieces: (depth, kind, p, q, color, width); kind 0 piece, 1 stub, 3 haloed stub ----
    prims = Tuple{Float64,Int,Point2d,Point2d,Any,Float64}[]
    for i in 1:n
        L = Ls[i]
        pt(t) = A[i] + t * (B[i] - A[i])
        dz(t) = za[i] + t * (zb[i] - za[i])
        sort!(cuts[i]; by = first)
        t0 = 0.0
        for (tc, h, hl) in cuts[i]
            dt = L > 0 ? h / L : 0.0
            a, b = max(tc - dt, t0), min(tc + dt, 1.0)
            b <= a && continue
            a > t0 && push!(prims, (dz((t0 + a) / 2), 0, pt(t0), pt(a), cols[i], lws[i]))
            push!(prims, (dz(tc), hl ? 3 : 1, pt(a), pt(b), cols[i], lws[i]))
            t0 = b
        end
        t0 < 1 && push!(prims, (dz((t0 + 1) / 2), 0, pt(t0), pt(1.0), cols[i], lws[i]))
    end

    # nodes: kind 2, a hair in front of their own members' end stubs
    if hasnodes
        bias = 1e-6 * span
        for (p, z) in zip(NP, nz)
            push!(prims, (z + bias, 2, p, p, nothing, 0.0))
        end
    end

    sort!(prims; by = first)

    # --- emit one ordered linesegments! --------------------------------------------------
    pts = Point2d[]; C = Any[]; W = Float64[]
    seg!(p, q, c, w) = (push!(pts, p, q); push!(C, c, c); push!(W, w, w))
    ε = 1e-7 * span                                           # zero-length dots need a direction
    for (z, kind, p, q, c, w) in prims
        if kind == 2
            seg!(p, p + Point2d(ε, 0), nodestrokecolor, nodesize + 2nodestrokewidth)
            seg!(p, p + Point2d(ε, 0), nodecolor, nodesize)
        elseif kind == 3
            # halo with butt-like extent: shorten by the round-cap radius so it stays on the stub
            v = q - p; l = sqrt(sum(abs2, v))
            r = (w / 2 + halowidth) * upt
            if l > 2r
                e = v * (r / l)
                seg!(p + e, q - e, background, w + 2halowidth)
            end
            seg!(p, q, c, w)
        else
            seg!(p, q, c, w)
        end
    end

    if ground
        # footprint at the lowest z, padded, drawn first
        allp = vcat(starts, ends, nodes === nothing ? eltype(starts)[] : nodes)
        xs = extrema(p -> p[1], allp); ys = extrema(p -> p[2], allp); zmin = minimum(p -> p[3], allp)
        m = groundpad * max(xs[2] - xs[1], ys[2] - ys[1])
        corners = [Point3d(xs[1] - m, ys[1] - m, zmin), Point3d(xs[2] + m, ys[1] - m, zmin),
                   Point3d(xs[2] + m, ys[2] + m, zmin), Point3d(xs[1] - m, ys[2] + m, zmin)]
        g, _ = project3d(corners, azimuth, elevation)
        gp = poly!(ax, g; color = groundcolor, strokewidth = 0)
        translate!(gp, 0, 0, -10)                              # always behind
    end
    linesegments!(ax, pts; color = C, linewidth = W, linecap = :round)
    return allxy
end

# ── phase 2: opaque faces ─────────────────────────────────────────────────────────────────

# barycentric coordinates of p in 2D triangle (a, b, c), or nothing if degenerate
function _bary(p, a, b, c)
    v0 = b - a; v1 = c - a; v2 = p - a
    den = v0[1] * v1[2] - v1[1] * v0[2]
    abs(den) < 1e-14 && return nothing
    l1 = (v2[1] * v1[2] - v1[1] * v2[2]) / den
    l2 = (v0[1] * v2[2] - v2[1] * v0[2]) / den
    return (1 - l1 - l2, l1, l2)
end

"""
    FaceSet(points, triangles; azimuth, elevation)

Projected opaque triangles for `hiddenline!`'s `faces`: `points` 3D vertices, `triangles` an
n×3 index matrix. Holds 2D vertices, depths and bounding boxes for occlusion queries.
"""
struct FaceSet
    xy::Vector{Point2d}
    z::Vector{Float64}
    tris::Matrix{Int}
    bbox::Vector{NTuple{4,Float64}}
end
function FaceSet(points::AbstractVector, tris::AbstractMatrix{<:Integer}, azimuth, elevation)
    xy, z = project3d(points, azimuth, elevation)
    bb = [begin
        a, b, c = xy[tris[k, 1]], xy[tris[k, 2]], xy[tris[k, 3]]
        (min(a[1], b[1], c[1]), max(a[1], b[1], c[1]), min(a[2], b[2], c[2]), max(a[2], b[2], c[2]))
    end for k in axes(tris, 1)]
    return FaceSet(xy, z, Matrix{Int}(tris), bb)
end

# is the screen point p at depth zp hidden behind some face (nearer by more than tol)?
function _occluded(F::FaceSet, p, zp, tol)
    for k in eachindex(F.bbox)
        b = F.bbox[k]
        (p[1] < b[1] || p[1] > b[2] || p[2] < b[3] || p[2] > b[4]) && continue
        i, j, l = F.tris[k, 1], F.tris[k, 2], F.tris[k, 3]
        w = _bary(p, F.xy[i], F.xy[j], F.xy[l])
        w === nothing && continue
        (w[1] < -1e-9 || w[2] < -1e-9 || w[3] < -1e-9) && continue
        zf = w[1] * F.z[i] + w[2] * F.z[j] + w[3] * F.z[l]
        zf > zp + tol && return true
    end
    return false
end

"""
    cull_by_faces(starts, ends, F::FaceSet, azimuth, elevation; tol) -> (starts, ends, parent)

Split each 3D segment where its projection crosses a face edge and keep only the pieces not
hidden behind a nearer face (`tol` [data units] keeps lines lying ON a face visible).
`parent[k]` is the input segment of output piece k.
"""
function cull_by_faces(starts, ends, F::FaceSet, azimuth, elevation; tol)
    A, za = project3d(starts, azimuth, elevation)
    B, zb = project3d(ends, azimuth, elevation)
    # unique face edges
    E = Set{Tuple{Int,Int}}()
    for k in axes(F.tris, 1), (a, b) in ((1, 2), (2, 3), (3, 1))
        i, j = F.tris[k, a], F.tris[k, b]
        push!(E, (min(i, j), max(i, j)))
    end
    E = collect(E)
    ebx = [(min(F.xy[i][1], F.xy[j][1]), max(F.xy[i][1], F.xy[j][1]), min(F.xy[i][2], F.xy[j][2]), max(F.xy[i][2], F.xy[j][2])) for (i, j) in E]
    S2 = eltype(starts)[]; E2 = eltype(ends)[]; parent = Int[]
    for s in eachindex(starts)
        a, b = A[s], B[s]
        sx = (min(a[1], b[1]), max(a[1], b[1]), min(a[2], b[2]), max(a[2], b[2]))
        ts = [0.0, 1.0]
        for (e, (i, j)) in enumerate(E)
            q = ebx[e]
            (q[1] > sx[2] || q[2] < sx[1] || q[3] > sx[4] || q[4] < sx[3]) && continue
            c = _crossing(a, b, F.xy[i], F.xy[j])
            c === nothing || push!(ts, c[1])
        end
        sort!(ts); unique!(ts)
        P3(t) = starts[s] + t * (ends[s] - starts[s])
        run0 = nothing
        for k in 1:length(ts)-1
            tm = (ts[k] + ts[k+1]) / 2
            vis = !_occluded(F, a + tm * (b - a), za[s] + tm * (zb[s] - za[s]), tol)
            if vis
                run0 === nothing && (run0 = ts[k])
            elseif run0 !== nothing
                push!(S2, P3(run0)); push!(E2, P3(ts[k])); push!(parent, s); run0 = nothing
            end
        end
        run0 === nothing || (push!(S2, P3(run0)); push!(E2, P3(1.0)); push!(parent, s))
    end
    return S2, E2, parent
end

"""
    hiddenface!(ax::Axis, points, triangles, starts, ends; azimuth, elevation, facecolor,
                colormap, colorrange, edges = nothing, edgecolor, edgewidth, kwargs...)

Phase 2 of `hiddenline!`: opaque triangles (`points` 3D, `triangles` n×3, `facecolor` one
value per point → `colormap`/`colorrange`, or a colour) plus line segments and nodes, with
occlusion between all of them in vector output:
faces are drawn far → near (painter's order by centroid depth); line pieces and nodes behind a
nearer face are removed (lines lying on a face stay); the rest goes through `hiddenline!`
(crossings, halos, node ordering). `edges = (starts, ends)` adds face outlines (mesh lines),
culled the same way, without halos. Remaining keywords go to `hiddenline!`.
Returns the face `mesh!` plot (for a Colorbar).
"""
function hiddenface!(ax::Axis, points::AbstractVector, tris::AbstractMatrix{<:Integer},
    starts::AbstractVector, ends::AbstractVector;
    azimuth::Real = -3pi / 4, elevation::Real = pi / 8,
    facecolor = kjl_lightgray, colormap = kjl_sequential, colorrange = nothing,
    edges = nothing, edgecolor = (kjl_black, 0.3), edgewidth = 0.3,
    color = kjl_black, linewidth = 1.0, nodes = nothing, ground::Bool = false,
    groundcolor = (kjl_lightgray, 0.35), groundpad = 0.04, kwargs...)

    F = FaceSet(points, tris, azimuth, elevation)
    allp = vcat(points, starts, ends)
    span = maximum(d -> -(reverse(extrema(p -> p[d], allp))...), 1:3)
    tol = 1e-4 * span

    if ground
        xs = extrema(p -> p[1], allp); ys = extrema(p -> p[2], allp); zmin = minimum(p -> p[3], allp)
        m = groundpad * max(xs[2] - xs[1], ys[2] - ys[1])
        corners = [Point3d(xs[1] - m, ys[1] - m, zmin), Point3d(xs[2] + m, ys[1] - m, zmin),
                   Point3d(xs[2] + m, ys[2] + m, zmin), Point3d(xs[1] - m, ys[2] + m, zmin)]
        g, _ = project3d(corners, azimuth, elevation)
        gp = poly!(ax, g; color = groundcolor, strokewidth = 0)
        translate!(gp, 0, 0, -10)                              # always behind
    end

    # faces far → near
    cz = [(F.z[tris[k, 1]] + F.z[tris[k, 2]] + F.z[tris[k, 3]]) / 3 for k in axes(tris, 1)]
    ord = sortperm(cz)
    sorted = F.tris[ord, :]
    m = facecolor isa AbstractVector ?
        mesh!(ax, F.xy, sorted; color = facecolor, colormap = colormap,
            colorrange = colorrange === nothing ? extrema(facecolor) : colorrange, shading = NoShading) :
        mesh!(ax, F.xy, sorted; color = facecolor, shading = NoShading)

    # face outlines: culled, then drawn plainly (no halos), under the members
    if edges !== nothing
        es, ee, _ = cull_by_faces(edges[1], edges[2], F, azimuth, elevation; tol)
        if !isempty(es)
            P, _ = project3d(vcat([[a, b] for (a, b) in zip(es, ee)]...), azimuth, elevation)
            linesegments!(ax, P; color = edgecolor, linewidth = edgewidth)
        end
    end

    # members and nodes
    n = length(starts)
    cols = _expand(color, n); lws = _expand(linewidth, n)
    s2, e2, par = cull_by_faces(starts, ends, F, azimuth, elevation; tol)
    nds = nodes === nothing ? nothing :
        [p for p in nodes if begin
            xy, z = project3d([p], azimuth, elevation)
            !_occluded(F, xy[1], z[1], tol)
        end]
    isempty(s2) || hiddenline!(ax, s2, e2; azimuth, elevation, color = cols[par], linewidth = lws[par],
        nodes = nds, kwargs...)
    return m
end
