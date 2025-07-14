### This file contains public API ###

"""
    Segment(;length = 1.0, radius = 1.0)

Create a segment with dimensions given by `length`, and `radius`. This primitive
creates a `Segments` object (i.e., geometry object with arity 2, see VPL documentation
for details). It is not compatible with `Mesh` or `Points` objects. A segment represents a
cylinder in the real world but it is stored in a much more efficient way than if we
generated an explicit triangular mesh for a cylinder. If you want to use the triangular
mesh then please `HollowCylinder()` or `SolidCylinder()` instead.

# Arguments
- `length = 1.0`: The length of the segment (distance between start and endpoint.
- `radius = 1.0`: The radius of the cylinder that the segment represents.

# Examples
```jldoctest
julia> Segment(;length = 1.0, radius = 1.0);
```
"""
function Segment(;length::FT = 1.0, radius::FT = 1.0) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(zero(FT), zero(FT), length))
    Segment(trans, radius = radius)
end

# Create a Segment from affine transformation
function Segment(trans::CT.AbstractAffineMap; radius::FT = 1.0)
    # Standard segment goes from origin to [0,0,1]
    p0 = O(FT)
    p1 = Vec(zero(FT), zero(FT), one(FT))
    # Apply transformation to each vertex and add radius as property
    s = Segments([trans(p0), trans(p1)])
    add_property(s, :radius, [1.0])
    return s
end

# Create a Segment from affine transformation and add it in-place to existing Segments object
function Segment!(segments::Segments, trans::CT.AbstractAffineMap; radius::FT = 1.0)
    # Standard segment goes from origin to [0,0,1]
    p0 = O(FT)
    p1 = Vec(zero(FT), zero(FT), one(FT))
    # Apply transformation to each vertex and add radius as property
    push!(vertices(segments), trans(p0))
    push!(vertices(segments), trans(p1))
    add_property(segments, :radius, [1.0])
    return segments
end
