### This file contains public API ###

# Information to generate np points on an ellipse given affine transformation
struct HollowCubePointsVertices{FT, TT}
    np::Int
    s::SobolSeq{3}
    pfaces::SVector{4, Float64}
    trans::TT
end
function HollowCubePointsVertices(np, trans, pfaces)
    s = SobolSeq(3)
    FT = eltype(trans.linear)
    HollowCubePointsVertices{FT, typeof(trans)}(np, s, trans, pfaces)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates in the unit circle
function sobol_to_coords(e::HollowCubePointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        u = next!(e.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        if face == 1
            Vec{FT}(2*u[2] - 1, 1, u[3])
        elseif face == 2
            Vec{FT}(2*u[2] - 1, -1, u[3])
        elseif face == 3
            Vec{FT}(1, 2*u[2] - 1, u[3])
        elseif face == 4
            Vec{FT}(-1, 2*u[2] - 1, u[3])
        end
    end
end

function Base.iterate(e::HollowCubePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > e.np ? nothing : (e.trans(sobol_to_coords(e)), i + 1)
end
Base.length(e::HollowCubePointsVertices) = e.np
Base.eltype(::Type{HollowCubePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct HollowCubePointsNormals{FT}
    s::SobolSeq{3}
    np::Int
    norms::NTuple{4, Vec{FT}}
    pfaces::SVector{4, Float64}
end
function HollowCubePointsNormals(np, trans, pfaces)
    norm_trans = normal_trans(trans)
    norm1 = norm_trans(Vec{FT}(0.0,  1.0, 0.0))
    norm2 = norm_trans(Vec{FT}(0.0, -1.0, 0.0))
    norm3 = norm_trans(Vec{FT}(1.0, 0.0, 0.0))
    norm4 = norm_trans(Vec{FT}(-1.0,  0.0, 0.0))
    HollowCubePointsNormals(SobolSeq(3), np, (norm1, norm2, norm3, norm4), pfaces)
end
function Base.iterate(c::HollowCubePointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    @inbounds pface = next!(c.s)[1]
    @inbounds i > c.np ? nothing : (c.norms[findfirst(x -> x > pface, c.pfaces)], i + 1)
end
Base.length(e::HollowCubePointsNormals) = e.np
Base.eltype(::Type{HollowCubePointsNormals{FT}}) where {FT} = Vec{FT}


"""
    HollowCubePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create n points on the surface of a hollow cube with dimensions given by `length`, and `height`
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
julia> HollowCubePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function HollowCubePointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Area of each type of face
    area1 = length*height
    area2 = width*length
    # Calculate the probability of a point being on a face (proportional to face area)
    total_area = 2*(area1 + area2)
    areas = SVector{6, Float64}(area1, area1, area2, area2)
    pfaces = cumsum(areas./total_area)
    HollowCubePointsVertices(trans; n = n, area = total_area, pfaces = pfaces)
end

# Create a ellipse from affine transformation
function HollowCubePointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{6, Float64})
    PrimitivePoints(() -> HollowCubePointsVertices(n, trans, pfaces), () -> HollowCubePointsNormals(n, trans, pfaces), area)
end

# Create a ellipse from affine transformation and add it in-place to existing mesh
function HollowCube!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{6, Float64})
    Primitive!(p, () -> HollowCubePointsVertices(n, trans, pfaces), () -> HollowCubePointsNormals(n, trans, pfaces), area)
end
