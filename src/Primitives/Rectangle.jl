### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

struct RectangleNormals{FT}
    norm::Vec{FT}
end
RectangleNormals(trans::AbstractMatrix{FT}) where {FT} =
    RectangleNormals(normalize(trans * X(FT)))
function iterate(r::RectangleNormals{FT})::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    (r.norm, 2)
end
function iterate(r::RectangleNormals{FT}, i)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    i > 2 ? nothing : (r.norm, 3)
end
length(r::RectangleNormals) = 2
eltype(::Type{RectangleNormals{FT}}) where {FT} = Vec{FT}


all_rectangle_vertices(::Type{FT}) where {FT} =
    (Vec{FT}(0, -1, 0), Vec{FT}(0, -1, 1), Vec{FT}(0, 1, 1), Vec{FT}(0, 1, 0))
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
julia> Rectangle(;length = 1.0, width = 1.0)
Mesh{StaticArraysCore.SVector{3, Float64}}(StaticArraysCore.SVector{3, Float64}[[0.0, -0.5, 0.0], [0.0, -0.5, 1.0], [0.0, 0.5, 1.0], [0.0, -0.5, 0.0], [0.0, 0.5, 1.0], [0.0, 0.5, 0.0]], StaticArraysCore.SVector{3, Float64}[[1.0, 0.0, 0.0], [1.0, 0.0, 0.0]])
```
"""
function Rectangle(; length::FT = 1.0, width::FT = 1.0) where {FT}
    trans = LinearMap(SDiagonal(one(FT), width / FT(2), length))
    Rectangle(trans)
end

# Create a rectangle from affine transformation
Rectangle(trans::AbstractAffineMap) = Primitive(trans, RectangleVertices, RectangleNormals)

# Create a rectangle from affine transformation and add it in-place to existing mesh
Rectangle!(m::Mesh, trans::AbstractAffineMap) = Primitive!(m, trans, RectangleVertices, RectangleNormals)
