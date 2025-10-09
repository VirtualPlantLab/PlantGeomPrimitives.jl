### This file contains public API ###

# Information to generate np points on a hollow cylinder given affine transformation
struct HollowConePointsVertices{FT, TT}
    np::Int
    s::SobolSeq{2}
    trans::TT
end
function HollowConePointsVertices(np, trans)
    s = SobolSeq(2)
    FT = eltype(trans.linear)
    HollowConePointsVertices{FT, typeof(trans)}(np, s, trans)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates on the side of a
# circular cone with radius and height of 1
function sobol_to_coords(c::HollowConePointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        u = next!(c.s)
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        dH = sqrt(u[2])
        z = 1 - dH
        Vec{FT}(cosa*dH, sina*dH, z)
    end
end

function Base.iterate(c::HollowConePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::HollowConePointsVertices) = c.np
Base.eltype(::Type{HollowConePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct HollowConePointsNormals{FT,TT}
    s::SobolSeq{2}
    np::Int
    trans::TT
end
function HollowConePointsNormals(np, trans)
    norm_trans = normal_trans(trans)
    FT = eltype(trans.linear)
    HollowConePointsNormals{FT, typeof(norm_trans)}(SobolSeq(2), np, norm_trans)
end
function Base.iterate(c::HollowConePointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    if i > c.np
        nothing
    else
        u = next!(c.s)
        α = u[1]*2*π
        n = sqrt(0.5)
        sina = sin(α)
        cosa = cos(α)
        norm = Vec{FT}(0.5*cosa/n, 0.5*sina/n, 0.5/n)
        (c.trans(norm), i + 1)
    end
end
Base.length(c::HollowConePointsNormals) = c.np
Base.eltype(::Type{HollowConePointsNormals{FT, TT}}) where {FT, TT} = Vec{FT}


"""
    HollowConePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create n points on the surface of a hollow cone with dimensions given by `length`, and `height`
located at the origin (and oriented along the XYZ axes).

## Arguments
- `length`: The length of the cone.
- `width`: The width of the elliptical base.
- `height = 1.0`: The height of the elliptical base.
- `n`: The number of points to be generated.

## Details

The points are generated using a 3D Sobol sequence  and trying to conserve the area around
each point. Note that a Sobol sequence does not guarantee equal areas arounds points (i.e.,
if you were to compute the areas using a Voronoi tessellation approach) and for any value of
`n` there may some larger gaps among the points (but the approximation improves with more points).

## Examples
```jldoctest
julia> HollowConePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function HollowConePointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Lateral area of the cone after scaling (https://mathworld.wolfram.com/EllipticCone.html)
    a = max(width, height)/2
    b = min(width, height)/2
    h = length
    area = 2b*sqrt(a^2 + h^2)*Elliptic.E(sqrt((1  -a^2/b^2)/(1 + a^2/h^2)))
    # This is the function below
    HollowConePointsVertices(trans; n = n, area = area)
end

# Create a solid cube from affine transformation, total area and probability of each face
function HollowConePointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0)
    PrimitivePoints(() -> HollowConePointsVertices(n, trans), () -> HollowConePointsNormals(n, trans), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function HollowCone!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0)
    Primitive!(p, () -> HollowConePointsVertices(n, trans), () -> HollowConePointsNormals(n, trans), area)
end
