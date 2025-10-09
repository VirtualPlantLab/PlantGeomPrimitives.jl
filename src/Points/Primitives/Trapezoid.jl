### This file contains public API ###

#########################################################
##################### Iterators #########################
#########################################################

struct TrapezoidPointsVertices{FT, TT}
    np::Int
    r::FT
    s::SobolSeq{2}
    trans::TT
end
function TrapezoidPointsVertices(np, trans, ratio)
    s = SobolSeq(2)
    FT = eltype(trans.linear)
    TrapezoidPointsVertices{FT, typeof(trans)}(np, ratio, s, trans)
end


# Convert a Sobol sample from the unit square to Cartesian coordinates in the triangle
function sobol_to_coords(t::TrapezoidPointsVertices{FT, TT}) where {FT, TT}
    # Generate the next Sobol sample
    u = next!(t.s)
    # Non-uniform sample on z
    @inbounds z = (-2 + sqrt(4 - 4*(1 - t.r)*(1 + t.r)*u[1]))/(-2*(1 - t.r))
    # Uniform sample on y but scaled by width
    rz = 1 - (1 - t.r)*z
    @inbounds y = -u[2]*rz + u[2]*2*rz
    # Generate the Cartesian coordinates of the point in the reference trapezoid
    Vec{FT}(0, y, z)
end

function Base.iterate(e::TrapezoidPointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > e.np ? nothing : (e.trans(sobol_to_coords(e)), i + 1)
end
Base.length(e::TrapezoidPointsVertices) = e.np
Base.eltype(::Type{TrapezoidPointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on a triangle given affine transformation
struct TrapezoidPointsNormals{FT}
    np::Int
    norm::Vec{FT}
end
function TrapezoidPointsNormals(np, trans)
    norm_trans = normal_trans(trans)
    norm = norm_trans(Vec{FT}(1.0, 0.0, 0.0))
    TrapezoidPointsNormals(np, norm)
end
function Base.iterate(e::TrapezoidPointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    i > e.np ? nothing : (e.norm, i + 1)
end
Base.length(e::TrapezoidPointsNormals) = e.np
Base.eltype(::Type{TrapezoidPointsNormals{FT}}) where {FT} = Vec{FT}

#########################################################
#################### Constructors #######################
#########################################################

"""
    TrapezoidPointsVertices(;length = 1.0, width = 1.0, ratio = 1.0, n = 10)

Create n points from within the surface of a trapezoid with dimensions given by `length`
and `width`, standard location and orientation (on the YZ plane, with larger base lying on
the y axis).

# Arguments
- `length`: The length of the trapezoid.
- `width`: The width of the trapezoid.
- `ratio = 1.0`: The ratio between the smaller and larger widths.
- `n`: The number of points to generate.

# Examples
```jldoctest
julia> TrapezoidPointsVertices(;length = 1.0, width = 1.0, n = 10, ratio = 1.0);
```
"""
function TrapezoidPointsVertices(; length::FT = 1.0, width::FT = 1.0, n::Int = 10, ratio::FT = 1.0) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length))
    area = length * width*(1 + ratio) / FT(2)
    TrapezoidPointsVertices(trans; n = n, area = area, ratio = ratio)
end

# Create a triangle from affine transformation
TrapezoidPointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, ratio::Float64 = 1.0) =
    PrimitivePoints(() -> TrapezoidPointsVertices(n, trans, r = ratio), () -> TrapezoidPointsNormals(n, trans), area)

# Create a triangle from affine transformation and add it in-place to existing mesh
Trapezoid!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, ratio::Float64 = 1.0) =
    Primitive!(p, () -> TrapezoidPointsVertices(n, trans, r = ratio), () -> TrapezoidPointsNormals(n, trans), area)
