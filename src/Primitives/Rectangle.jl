### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

all_rectangle_vertices(::Type{FT}) where {FT} =
    (Vec{FT}(0, 1, 1), Vec{FT}(0, -1, 1), Vec{FT}(0, -1, 0),  Vec{FT}(0, 1, 0))
struct RectangleVertices{VT,TT}
    trans::TT
    verts::VT
end
function RectangleVertices(trans)
    FT = eltype(trans.linear)
    RectangleVertices(trans, all_rectangle_vertices(FT))
end
function iterate(r::RV, i::Int = 1)::Union{Nothing,Tuple{eltype(RV),Int64}} where {RV<:RectangleVertices}
     i < 4 && return (@inbounds r.trans(r.verts[i]), i + 1)
     i == 4 && return (@inbounds r.trans(r.verts[1]), i + 1)
     i == 5 && return (@inbounds r.trans(r.verts[3]), i + 1)
     i == 6 && return (@inbounds r.trans(r.verts[4]), i + 1)
     i == 7 && return nothing
end
length(r::RectangleVertices) = 6
function eltype(::Type{RectangleVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


#########################################################
#################### Constructors #######################
#########################################################

"""
    Rectangle(;length = 1.0, width = 1.0)

Create a rectangle with dimensions given by `length` and width, standard location
and orientation.

# Arguments
- `length = 1.0`: The length of the rectangle.
- `width = 1.0`: The width of the rectangle.

# Examples
```jldoctest
julia> Rectangle(;length = 1.0, width = 1.0);
```
"""
function Rectangle(; length::FT = 1.0, width::FT = 1.0) where {FT}
    trans = LinearMap(SDiagonal(one(FT), width / FT(2), length))
    Rectangle(trans)
end

# Create a rectangle from affine transformation
Rectangle(trans::AbstractAffineMap) = Primitive(trans, RectangleVertices)

# Create a rectangle from affine transformation and add it in-place to existing mesh
Rectangle!(m::Mesh, trans::AbstractAffineMap) = Primitive!(m, trans, RectangleVertices)
