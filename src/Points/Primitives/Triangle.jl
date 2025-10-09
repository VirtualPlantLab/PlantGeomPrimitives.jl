### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

struct TrianglePointsVertices{FT, TT}
    np::Int
    s::SobolSeq{2}
    trans::TT
end
function TrianglePointsVertices(np, trans)
    s = SobolSeq(2)
    FT = eltype(trans.linear)
    TrianglePointsVertices{FT, typeof(trans)}(np, s, trans)
end


# Convert a Sobol sample from the unit square to Cartesian coordinates in the triangle
function sobol_to_coords(e::TrianglePointsVertices{FT, TT}) where {FT, TT}
    # Generate the next Sobol sample
    u = next!(e.s)
    # Compute barycentric coordinatesd
    @inbounds su1 = sqrt(u[1])
    b1 = 1 - su1
    @inbounds b2 = u[2]*su1
    b3 = 1 - b1 - b2
    # Generate the Cartesian coordinates of the point
    b1*Vec{FT}(0, -1, 0) + b2*Vec{FT}(0, 1, 0) + b3*Vec{FT}(0, 0, 1)
end

function Base.iterate(e::TrianglePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > e.np ? nothing : (e.trans(sobol_to_coords(e)), i + 1)
end
Base.length(e::TrianglePointsVertices) = e.np
Base.eltype(::Type{TrianglePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on a triangle given affine transformation
struct TrianglePointsNormals{FT}
    np::Int
    norm::Vec{FT}
end
function TrianglePointsNormals(np, trans)
    norm_trans = normal_trans(trans)
    norm = norm_trans(Vec{FT}(1.0, 0.0, 0.0))
    TrianglePointsNormals(np, norm)
end
function Base.iterate(e::TrianglePointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    i > e.np ? nothing : (e.norm, i + 1)
end
Base.length(e::TrianglePointsNormals) = e.np
Base.eltype(::Type{TrianglePointsNormals{FT}}) where {FT} = Vec{FT}

#########################################################
#################### Constructors #######################
#########################################################

"""
    TrianglePointsVertices(;length = 1.0, width = 1.0, n = 10)

Create n points from within the surface of a triangle with dimensions given by `length`
and `width`, standard location and orientation (two vertices on the Y axis and the third
on the positive side of the Z axis, normal parallel to the X axis).

# Arguments
- `length`: The length of the triangle.
- `width`: The width of the triangle.
- `n`: The number of points to generate.

# Examples
```jldoctest
julia> TrianglePointsVertices(;length = 1.0, width = 1.0, n = 10);
```
"""
function TrianglePointsVertices(; length::FT = 1.0, width::FT = 1.0, n::Int = 10) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length))
    area = length * width / FT(2)
    TrianglePointsVertices(trans; n = n, area = area)
end

# Create a triangle from affine transformation
TrianglePointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0) =
    PrimitivePoints(() -> TrianglePointsVertices(n, trans), () -> TrianglePointsNormals(n, trans), area)

# Create a triangle from affine transformation and add it in-place to existing mesh
Triangle!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0) =
    Primitive!(p, () -> TrianglePointsVertices(n, trans), () -> TrianglePointsNormals(n, trans), area)
