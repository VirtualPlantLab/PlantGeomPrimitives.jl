### This file contains public API ###

# Information to generate np points on a hollow cylinder given affine transformation
struct HollowFrustumPointsVertices{FT, TT}
    ratio::FT
    np::Int
    s::SobolSeq{2}
    trans::TT
end
function HollowFrustumPointsVertices(np, trans, ratio)
    s = SobolSeq(2)
    FT = eltype(trans.linear)
    HollowFrustumPointsVertices{FT, typeof(trans)}(ratio, np, s, trans)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates on the side of a
# circular truncated cone (frustum) with radius and height of 1
function sobol_to_coords(c::HollowFrustumPointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        u = next!(c.s)
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        dH = sqrt(u[2])
        z = 1 - dH
        rp = c.ratio + dH*(1 - c.ratio)
        Vec{FT}(cosa*rp, sina*rp, z)
    end
end

function Base.iterate(c::HollowFrustumPointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::HollowFrustumPointsVertices) = c.np
Base.eltype(::Type{HollowFrustumPointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct HollowFrustumPointsNormals{FT,TT}
    s::SobolSeq{2}
    ratio::FT
    np::Int
    trans::TT
end
function HollowFrustumPointsNormals(np, trans, ratio)
    norm_trans = normal_trans(trans)
    HollowFrustumPointsNormals(SobolSeq(2), ratio, np, norm_trans)
end
function Base.iterate(c::HollowFrustumPointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    if i > c.np
        nothing
    else
        u = next!(c.s)
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        dH = sqrt(u[2])
        z = 1 - dH
        rp = c.ratio + dH*(1 - c.ratio)
        n = sqrt(z^2 + rp^2)
        norm = Vec{FT}(rp*cosa/n, rp*sina/n, z/n)
        (c.trans(norm), i + 1)
    end
end
Base.length(c::HollowFrustumPointsNormals) = c.np
Base.eltype(::Type{HollowFrustumPointsNormals{FT, TT}}) where {FT, TT} = Vec{FT}


"""
    HollowFrustumPointsVertices(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 20)

Create n points on the surface of a hollow cone with dimensions given by `length`, and `height`
located at the origin (and oriented along the XYZ axes).

## Arguments
- `length`: The length of the cone.
- `width`: The width of the elliptical base.
- `height`: The height of the elliptical base.
- `ratio`: The ratio of the small radius to the large radius.
- `n`: The number of points to be generated.

## Details

The points are generated using a 3D Sobol sequence  and trying to conserve the area around
each point. Note that a Sobol sequence does not guarantee equal areas arounds points (i.e.,
if you were to compute the areas using a Voronoi tessellation approach) and for any value of
`n` there may some larger gaps among the points (but the approximation improves with more points).

## Examples
```jldoctest
julia> HollowFrustumPointsVertices(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 20);
```
"""
function HollowFrustumPointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, ratio::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Length of the large and small cone
    length_big = length/(1 - ratio)
    length_small = length_big - length
    # Lateral area of the large cone after scaling (https://mathworld.wolfram.com/EllipticFrustum.html)
    a = max(width, height)/2
    b = min(width, height)/2
    h = length_big
    area_big = 2b*sqrt(a^2 + h^2)*Elliptic.E(sqrt((1  -a^2/b^2)/(1 + a^2/h^2)))
    # Lateral are of the small cone after scaling
    a = a*ratio
    b = b*ratio
    h = length_small
    area_small = 2b*sqrt(a^2 + h^2)*Elliptic.E(sqrt((1  -a^2/b^2)/(1 + a^2/h^2)))
    area = area_big - area_small
    # This is the function below
    HollowFrustumPointsVertices(trans; n = n, area = area, ratio = ratio)
end

# Create a solid cube from affine transformation, total area and probability of each face
function HollowFrustumPointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, ratio::Float64 = 1.0)
    PrimitivePoints(() -> HollowFrustumPointsVertices(n, trans, ratio), () -> HollowFrustumPointsNormals(n, trans, ratio), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function HollowFrustum!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, ratio::Float64 = 1.0)
    Primitive!(p, () -> HollowFrustumPointsVertices(n, trans, ratio), () -> HollowFrustumPointsNormals(n, trans, ratio), area)
end
