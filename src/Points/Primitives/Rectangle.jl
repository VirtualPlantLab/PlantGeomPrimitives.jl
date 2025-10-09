### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

struct RectanglePointsVertices{FT, TT}
    np::Int
    s::SobolSeq{2}
    trans::TT
end
function RectanglePointsVertices(np, trans)
    s = SobolSeq(2)
    FT = eltype(trans.linear)
    RectanglePointsVertices{FT, typeof(trans)}(np, s, trans)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates in the triangle
function sobol_to_coords(e::RectanglePointsVertices{FT, TT}) where {FT, TT}
    # Generate the next Sobol sample
    u = next!(e.s)
    # Generate the Cartesian coordinates of the point for the reference rectangle
    @inbounds Vec{FT}(0, 2*u[2] - 1, u[1])
end

function Base.iterate(e::RectanglePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > e.np ? nothing : (e.trans(sobol_to_coords(e)), i + 1)
end
Base.length(e::RectanglePointsVertices) = e.np
Base.eltype(::Type{RectanglePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on a rectangle given affine transformation
struct RectanglePointsNormals{FT}
    np::Int
    norm::Vec{FT}
end
function RectanglePointsNormals(np, trans)
    norm_trans = normal_trans(trans)
    norm = norm_trans(Vec{FT}(1.0, 0.0, 0.0))
    RectanglePointsNormals(np, norm)
end
function Base.iterate(e::RectanglePointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    i > e.np ? nothing : (e.norm, i + 1)
end
Base.length(e::RectanglePointsNormals) = e.np
Base.eltype(::Type{RectanglePointsNormals{FT}}) where {FT} = Vec{FT}

#########################################################
#################### Constructors #######################
#########################################################

"""
    RectanglePointsVertices(;length = 1.0, width = 1.0, n = 10)

Create n points from within the surface of a triangle with dimensions given by `length`
and `width`, standard location and orientation (two vertices on the Y axis and the third
on the positive side of the Z axis, normal parallel to the X axis).

# Arguments
- `length`: The length of the triangle.
- `width`: The width of the triangle.
- `n`: The number of points to generate.

# Examples
```jldoctest
julia> RectanglePointsVertices(;length = 1.0, width = 1.0, n = 10);
```
"""
function RectanglePointsVertices(; length::FT = 1.0, width::FT = 1.0, n::Int = 10) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length))
    area = length * width
    RectanglePointsVertices(trans; n = n, area = area)
end

# Create a rectangle from affine transformation
RectanglePointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0) =
    PrimitivePoints(() -> RectanglePointsVertices(n, trans), () -> RectanglePointsNormals(n, trans), area)

# Create a rectangle from affine transformation and add it in-place to existing mesh
Rectangle!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0) =
    Primitive!(p, () -> RectanglePointsVertices(n, trans), () -> RectanglePointsNormals(n, trans), area)
