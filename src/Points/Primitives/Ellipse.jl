### This file contains public API ###

# Information to generate np points on an ellipse given affine transformation
struct EllipsePointsVertices{FT, TT}
    np::Int
    sampler::PointSampler{2}
    trans::TT
end
function EllipsePointsVertices(np, trans, sampler)
    FT = eltype(trans.linear)
    EllipsePointsVertices{FT, typeof(trans)}(np, sampler, trans)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates in the unit circle
function sobol_to_coords(e::EllipsePointsVertices{FT, TT}) where {FT, TT}
    p = sample!(e.sampler)
    @inbounds θ = p[1]*2π
    @inbounds r = sqrt(p[2])
    Vec{FT}(0.0, r*cos(θ), r*sin(θ))
end

function Base.iterate(e::EllipsePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > e.np ? nothing : (e.trans(sobol_to_coords(e)), i + 1)
end
Base.length(e::EllipsePointsVertices) = e.np
Base.eltype(::Type{EllipsePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct EllipsePointsNormals{FT}
    np::Int
    norm::Vec{FT}
end
function EllipsePointsNormals(np, trans)
    norm_trans = normal_trans(trans)
    FT = eltype(trans)
    norm = norm_trans * Vec{FT}(1.0, 0.0, 0.0)
    EllipsePointsNormals(np, norm)
end
function Base.iterate(e::EllipsePointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    i > e.np ? nothing : (e.norm, i + 1)
end
Base.length(e::EllipsePointsNormals) = e.np
Base.eltype(::Type{EllipsePointsNormals{FT}}) where {FT} = Vec{FT}


"""
    EllipsePointsVertices(;length = 1.0, width = 1.0, n = 20)

Create n points from within the surface of the ellipse with dimensions given by `length` and
`width`, and standard location and orientation (on the YZ plane, with the `length` along the
Z-axis and above the XY plane, normal parallel to the X axis).

## Arguments
- `length`: The length of the ellipse.
- `width`: The width of the ellipse.
- `n`: The number of points to be generated.

## Details

The points are generated using a 2D Sobol sequence  and trying to conserve the area around
each point (this means more points are generated further away from the center of the ellipse).
Note that a Sobol sequence does not guarantee equal areas arounds points (i.e., if you were to
compute the areas using a Voronoi tessellation approach) and for any value of `n` there may
some larger gaps among the points (but the approximation improves with more points).

## Examples
```jldoctest
julia> EllipsePointsVertices(;length = 1.0, width = 1.0, n = 20);
```
"""
function EllipsePoints(; length::FT = 1.0, width::FT = 1.0, n = 20, sampler = PointSampler(2)) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length / FT(2)))
    area = width*length*π/4
    EllipsePoints(trans; n = n, area = area, sampler = sampler)
end

# Create a ellipse from affine transformation
function EllipsePoints(trans::CT.AbstractAffineMap; n = 20, area = 1.0, sampler = PointSampler(2))
    PrimitivePoints(() -> EllipsePointsVertices(n, trans, sampler), () -> EllipsePointsNormals(n, trans), area)
end

# Create a ellipse from affine transformation and add it in-place to existing mesh
function Ellipse!(p::Points, trans::CT.AbstractAffineMap; n = 20, area = 1.0, sampler = PointSampler(2))
    Primitive!(p, () -> EllipsePointsVertices(n, trans, sampler), () -> EllipsePointsNormals(n, trans), area, n)
end
