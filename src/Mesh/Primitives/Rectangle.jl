### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

all_rectangle_vertices(::Type{FT}) where {FT} =
    (Vec{FT}(0, 1, 1), Vec{FT}(0, -1, 1), Vec{FT}(0, -1, 0),  Vec{FT}(0, 1, 0))
struct RectangleMeshVertices{VT,TT}
    trans::TT
    verts::VT
end
function RectangleMeshVertices(trans)
    FT = eltype(trans.linear)
    RectangleMeshVertices(trans, all_rectangle_vertices(FT))
end
function Base.iterate(r::RV, i::Int = 1)::Union{Nothing,Tuple{eltype(RV),Int64}} where {RV<:RectangleMeshVertices}
     i < 4 && return (@inbounds r.trans(r.verts[i]), i + 1)
     i == 4 && return (@inbounds r.trans(r.verts[1]), i + 1)
     i == 5 && return (@inbounds r.trans(r.verts[3]), i + 1)
     i == 6 && return (@inbounds r.trans(r.verts[4]), i + 1)
     i == 7 && return nothing
end
Base.length(r::RectangleMeshVertices) = 6
function Base.eltype(::Type{RectangleMeshVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


#########################################################
#################### Constructors #######################
#########################################################

"""
    RectangleMesh(;length = 1.0, width = 1.0)

Create a rectangle with dimensions given by `length` and width, standard location
and orientation.

# Arguments
- `length = 1.0`: The length of the rectangle.
- `width = 1.0`: The width of the rectangle.

# Examples
```jldoctest
julia> RectangleMesh(;length = 1.0, width = 1.0);
```
"""
function RectangleMesh(; length::FT = 1.0, width::FT = 1.0) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length))
    RectangleMesh(trans)
end

# Create a rectangle from affine transformation
RectangleMesh(trans::CT.AbstractAffineMap) = PrimitiveMesh(trans, RectangleMeshVertices)

# Create a rectangle from affine transformation and add it in-place to existing mesh
Rectangle!(m::Mesh, trans::CT.AbstractAffineMap) = Primitive!(m, trans, RectangleMeshVertices)
