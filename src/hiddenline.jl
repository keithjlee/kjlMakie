#=
Makie adapter for the hidden-line core (`hiddenline_core.jl`, kept identical in FormaViz).

CairoMakie has no depth buffer, so a 3D structure exported to PDF/SVG through `Axis3` shows far
members painted over near ones. These functions draw an orthographic view into a plain 2D
`Axis` in the back-to-front order computed by `hidden_order`, which CairoMakie preserves:
faces first (painter's order), then ONE `linesegments!` of member pieces and node dots
(zero-length round-capped segments: outline + fill). Output is plain 2D, so `structurestyle!` /
`fitstructure!` apply as for any 2D drawing.
=#

include("hiddenline_core.jl")

"""
    view_basis(azimuth, elevation) -> (right, up, toward)

Orthographic view basis, `Axis3` convention (see `hl_basis`).
"""
view_basis(azimuth::Real, elevation::Real) = hl_basis(azimuth, elevation)

"""
    project3d(points, azimuth, elevation) -> (Vector{Point2d}, depths)

Orthographic screen coordinates and depths (larger = nearer the viewer) of 3D points.
"""
function project3d(P::AbstractVector, azimuth::Real, elevation::Real)
    xy, z = hl_project(P, hl_basis(azimuth, elevation))
    return [Point2d(p...) for p in xy], z
end

_expand(x, n) = x isa AbstractVector ? x : fill(x, n)

function _ground!(ax, pts3, basis, groundcolor, groundpad)
    xs = extrema(p -> p[1], pts3); ys = extrema(p -> p[2], pts3); zmin = minimum(p -> p[3], pts3)
    m = groundpad * max(xs[2] - xs[1], ys[2] - ys[1])
    corners = [(xs[1] - m, ys[1] - m, zmin), (xs[2] + m, ys[1] - m, zmin),
               (xs[2] + m, ys[2] + m, zmin), (xs[1] - m, ys[2] + m, zmin)]
    g, _ = hl_project(corners, basis)
    gp = poly!(ax, [Point2d(p...) for p in g]; color = groundcolor, strokewidth = 0)
    translate!(gp, 0, 0, -10)                                  # always behind (CairoMakie z-sorts)
    return gp
end

function _emit!(ax, prims, cols, nodesize, nodecolor, nodestrokecolor, nodestrokewidth, span)
    pts = Point2d[]; C = Any[]; W = Float64[]
    seg!(p, q, c, w) = (push!(pts, Point2d(p...), Point2d(q...)); push!(C, c, c); push!(W, w, w))
    ε = 1e-7 * span                                            # zero-length dots need a direction
    for pr in prims
        if pr.kind === :node
            q = (pr.p[1] + ε, pr.p[2])
            seg!(pr.p, q, nodestrokecolor, nodesize + 2nodestrokewidth)
            seg!(pr.p, q, nodecolor, nodesize)
        else
            seg!(pr.p, pr.q, cols[pr.i], pr.w)
        end
    end
    isempty(pts) || linesegments!(ax, pts; color = C, linewidth = W, linecap = :round)
end

"""
    hiddenline!(ax::Axis, starts, ends; azimuth = -3π/4, elevation = π/8, color = kjl_black,
                linewidth = 1.0, nodes = nothing, nodesize = 4.0, nodecolor = :white,
                nodestrokecolor = kjl_black, nodestrokewidth = 0.75, halo = true,
                halowidth = 0.6, width = 400, ground = false)

Draw 3D segments `starts[i] → ends[i]` into the 2D axis `ax` as an orthographic view with
correct occlusion (`hidden_order`). `color`/`linewidth` [pt]: scalar or per segment. `nodes`
(3D points): outlined dots of diameter `nodesize` [pt], hidden only by members really in front.
`halo` cuts a gap into the farther member at each real crossing, `halowidth` [pt] clear of the
nearer member's edges. `width` = printed width of the drawing [pt]. `ground = true` draws the
projected footprint at the lowest z as a light ground plane behind everything.
Returns the projected 2D endpoints.
"""
function hiddenline!(ax::Axis, starts::AbstractVector, ends::AbstractVector;
    azimuth::Real = -3pi / 4, elevation::Real = pi / 8,
    color = kjl_black, linewidth = 1.0,
    nodes = nothing, nodesize = 4.0, nodecolor = :white, nodestrokecolor = kjl_black, nodestrokewidth = 0.75,
    halo::Bool = true, halowidth = 0.6, background = :white, width = 400,
    ground::Bool = false, groundcolor = (kjl_lightgray, 0.35), groundpad = 0.04)

    basis = hl_basis(azimuth, elevation)
    n = length(starts)
    H = hidden_order(starts, ends; basis, widths = float.(_expand(linewidth, n)), nodes,
        noderadius = nodesize / 2 + nodestrokewidth, gaps = halo, clearance = halowidth, width)
    if ground
        _ground!(ax, vcat([_hl3(p) for p in starts], [_hl3(p) for p in ends]), basis, groundcolor, groundpad)
    end
    _emit!(ax, H.prims, _expand(color, n), nodesize, nodecolor, nodestrokecolor, nodestrokewidth, H.span)
    xy, _ = hl_project(vcat(starts, ends), basis)
    return [Point2d(p...) for p in xy]
end

"""
    hiddenface!(ax::Axis, points, triangles, starts, ends; azimuth, elevation, facecolor,
                colormap, colorrange, edges = nothing, edgecolor, edgewidth, kwargs...)

`hiddenline!` with opaque triangles (`points` 3D, `triangles` n×3; `facecolor` one value per
point → `colormap`/`colorrange`, or one colour): faces drawn far → near, members and nodes
behind a nearer face removed (lines lying on a face stay). `edges = (starts, ends)` adds face
outlines, culled the same way, drawn plainly under the members. Returns the face plot (for a
`Colorbar`).
"""
function hiddenface!(ax::Axis, points::AbstractVector, tris::AbstractMatrix{<:Integer},
    starts::AbstractVector, ends::AbstractVector;
    azimuth::Real = -3pi / 4, elevation::Real = pi / 8,
    facecolor = kjl_lightgray, colormap = kjl_sequential, colorrange = nothing,
    edges = nothing, edgecolor = (kjl_black, 0.3), edgewidth = 0.3,
    color = kjl_black, linewidth = 1.0,
    nodes = nothing, nodesize = 4.0, nodecolor = :white, nodestrokecolor = kjl_black, nodestrokewidth = 0.75,
    halo::Bool = true, halowidth = 0.6, width = 400,
    ground::Bool = false, groundcolor = (kjl_lightgray, 0.35), groundpad = 0.04)

    basis = hl_basis(azimuth, elevation)
    n = length(starts)
    H = hidden_order(starts, ends; basis, widths = float.(_expand(linewidth, n)), nodes,
        noderadius = nodesize / 2 + nodestrokewidth, faces = (points, tris), gaps = halo,
        clearance = halowidth, width)
    F = H.faces
    ground && _ground!(ax, vcat([_hl3(p) for p in points], [_hl3(p) for p in starts], [_hl3(p) for p in ends]),
        basis, groundcolor, groundpad)
    xy = [Point2d(p...) for p in F.xy]
    sorted = F.tris[H.faceorder, :]
    m = facecolor isa AbstractVector ?
        mesh!(ax, xy, sorted; color = facecolor, colormap = colormap,
            colorrange = colorrange === nothing ? extrema(facecolor) : colorrange, shading = NoShading) :
        mesh!(ax, xy, sorted; color = facecolor, shading = NoShading)
    if edges !== nothing
        es, ee, _ = hl_cull(edges[1], edges[2], F, basis; tol = 1e-4 * H.span)
        if !isempty(es)
            P, _ = hl_project(vcat([[a, b] for (a, b) in zip(es, ee)]...), basis)
            linesegments!(ax, [Point2d(p...) for p in P]; color = edgecolor, linewidth = edgewidth)
        end
    end
    _emit!(ax, H.prims, _expand(color, n), nodesize, nodecolor, nodestrokecolor, nodestrokewidth, H.span)
    return m
end
