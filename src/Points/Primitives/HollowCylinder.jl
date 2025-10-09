### This file contains public API ###

# Information to generate np points on a hollow cylinder given affine transformation
struct HollowCylinderPointsVertices{FT, TT}
    np::Int
    s::SobolSeq{2}
    trans::TT
end
function HollowCylinderPointsVertices(np, trans)
    s = SobolSeq(2)
    FT = eltype(trans.linear)
    HollowCylinderPointsVertices{FT, typeof(trans)}(np, s, trans)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates on the side of a
# cylinder using polar coordinates
function sobol_to_coords(c::HollowCylinderPointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        u = next!(c.s)
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        z = u[2]
        Vec{FT}(cosa, sina, z)
    end
end

function Base.iterate(c::HollowCylinderPointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::HollowCylinderPointsVertices) = c.np
Base.eltype(::Type{HollowCylinderPointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct HollowCylinderPointsNormals{FT,TT}
    s::SobolSeq{2}
    np::Int
    trans::TT
end
function HollowCylinderPointsNormals(np, trans)
    norm_trans = normal_trans(trans)
    FT = eltype(trans.linear)
    HollowCylinderPointsNormals{FT, typeof(norm_trans)}(SobolSeq(2), np, norm_trans)
end
function Base.iterate(c::HollowCylinderPointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    if i > c.np
        nothing
    else
        u = next!(c.s)
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        norm = Vec{FT}(cosa, sina, 0)
        (c.trans(norm), i + 1)
    end
end
Base.length(c::HollowCylinderPointsNormals) = c.np
Base.eltype(::Type{HollowCylinderPointsNormals{FT, TT}}) where {FT, TT} = Vec{FT}


"""
    HollowCylinderPointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create n points on the surface of a solid cube with dimensions given by `length`, and `height`
located at the origin (and oriented along the XYZ axes).

## Arguments
- `length`: The length of the ellipse.
- `width`: The width of the ellipse.
- `height = 1.0`: The height of the base of the cube.
- `n`: The number of points to be generated.

## Details

The points are generated using a 3D Sobol sequence  and trying to conserve the area around
each point. Note that a Sobol sequence does not guarantee equal areas arounds points (i.e.,
if you were to compute the areas using a Voronoi tessellation approach) and for any value of
`n` there may some larger gaps among the points (but the approximation improves with more points).

## Examples
```jldoctest
julia> HollowCylinderPointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function HollowCylinderPointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Total side area of the cylinder (perimeter using Ramanujan first approximation)
    a = width/2
    b = length/2
    perimeter = pi*(3*(a + b) - sqrt((3a + b)*(a + 3b)))
    area = perimeter*height
    # This is the function below
    HollowCylinderPointsVertices(trans; n = n, area = area)
end

# Create a solid cube from affine transformation, total area and probability of each face
function HollowCylinderPointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0)
    PrimitivePoints(() -> HollowCylinderPointsVertices(n, trans), () -> HollowCylinderPointsNormals(n, trans), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function HollowCylinder!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0)
    Primitive!(p, () -> HollowCylinderPointsVertices(n, trans), () -> HollowCylinderPointsNormals(n, trans), area)
end
