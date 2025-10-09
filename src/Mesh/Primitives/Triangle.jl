### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

all_triangle_vertices(::Type{FT}) where {FT} =
    (Vec{FT}(0, -1, 0), Vec{FT}(0, 1, 0), Vec{FT}(0, 0, 1))
struct TriangleMeshVertices{VT,TT}
    trans::TT
    verts::VT
end
function TriangleMeshVertices(trans)
    FT = eltype(trans)
    TriangleMeshVertices(trans, all_triangle_vertices(FT))
end
function Base.iterate(r::RV)::Union{Nothing,Tuple{eltype(RV),Int64}} where {RV<:TriangleMeshVertices}
    (@inbounds r.trans(r.verts[1]), 2)
end
function Base.iterate(r::RV, i)::Union{Nothing,Tuple{eltype(RV),Int64}} where {RV<:TriangleMeshVertices}
    i > 3 ? nothing : (@inbounds r.trans(r.verts[i]), i + 1)
end
Base.length(r::TriangleMeshVertices) = 3
function Base.eltype(::Type{TriangleMeshVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


#########################################################
#################### Constructors #######################
#########################################################

"""
    TriangleMesh(;length = 1.0, width = 1.0)

Create a triangle with dimensions given by `length` and `width`, standard
location and orientation.

# Arguments
- `length = 1.0`: The length of the triangle.
- `width = 1.0`: The width of the triangle.

# Examples
```jldoctest
julia> TriangleMesh(;length = 1.0, width = 1.0);
```
"""
function TriangleMesh(; length::FT = 1.0, width::FT = 1.0) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length))
    TriangleMesh(trans)
end

# Create a triangle from affine transformation
TriangleMesh(trans::CT.AbstractAffineMap) =
    PrimitiveMesh(trans, TriangleMeshVertices)

# Create a triangle from affine transformation and add it in-place to existing mesh
Triangle!(m::Mesh, trans::CT.AbstractAffineMap) =
    Primitive!(m, trans, TriangleMeshVertices)
