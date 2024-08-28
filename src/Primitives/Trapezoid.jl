### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

all_trapezoid_vertices(ratio::FT) where {FT} =
    (Vec{FT}(0, ratio, 1), Vec{FT}(0, -ratio, 1), Vec{FT}(0, -1, 0), Vec{FT}(0, 1, 0))
struct TrapezoidVertices{TT, VT}
    trans::TT
    verts::VT
end
function genTrapezoidVertices(trans, ratio)
    FT = eltype(trans.linear)
    TrapezoidVertices(trans, all_trapezoid_vertices(ratio))
end
function iterate(t::TV, i::Int = 1)::Union{Nothing,Tuple{eltype(TV),Int64}} where {TV<:TrapezoidVertices}
     i < 4 && return (@inbounds t.trans(t.verts[i]), i + 1)
     i == 4 && return (@inbounds t.trans(t.verts[1]), i + 1)
     i == 5 && return (@inbounds t.trans(t.verts[3]), i + 1)
     i == 6 && return (@inbounds t.trans(t.verts[4]), i + 1)
     i == 7 && return nothing
end
length(r::TrapezoidVertices) = 6
function eltype(::Type{TrapezoidVertices{TT,VT}}) where {TT,VT}
    @inbounds VT.types[1]
end

#########################################################
#################### Constructors #######################
#########################################################

"""
    Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0)

Create a trapezoid with dimensions given by `length` and the larger `width` and
the `ratio` between the smaller and larger widths. The trapezoid is generted at
the standard location and orientation.

# Arguments
- `length = 1.0`: The length of the trapezoid.
- `width = 1.0`: The larger width of the trapezoid (the lower base of the trapezoid).
- `ratio = 1.0`: The ratio between the smaller and larger widths.

# Examples
```jldoctest
julia> Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0);
```
"""
function Trapezoid(; length::FT = 1.0, width::FT = 1.0, ratio::FT = 1.0) where {FT}
    trans = LinearMap(SDiagonal(one(FT), width / FT(2), length))
    Trapezoid(trans, ratio)
end

# Create a trapezoid from affine transformation
Trapezoid(trans::AbstractAffineMap, ratio) =
    Primitive(trans, x -> genTrapezoidVertices(x, ratio))

# Create a trapezoid from affine transformation and add it in-place to existing mesh
function Trapezoid!(m::Mesh, trans::AbstractAffineMap, ratio)
    Primitive!(m, trans, x -> genTrapezoidVertices(x, ratio))
end
