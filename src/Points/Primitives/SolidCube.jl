### This file contains public API ###

# Information to generate np points on an ellipse given affine transformation
struct SolidCubePointsVertices{FT, TT}
    np::Int
    s::SobolSeq{3}
    pfaces::SVector{6, Float64}
    trans::TT
end
function SolidCubePointsVertices(np, trans, pfaces)
    s = SobolSeq(3)
    FT = eltype(trans.linear)
    SolidCubePointsVertices{FT, typeof(trans)}(np, s, trans, pfaces)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates in the unit circle
function sobol_to_coords(c::SolidCubePointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        if face == 1
            Vec{FT}(2*u[2] - 1, 2*u[3] - 1, 0)
        elseif face == 2
            Vec{FT}(2*u[2] - 1, 1, u[3])
        elseif face == 3
            Vec{FT}(2*u[2] - 1, -1, u[3])
        elseif face == 4
            Vec{FT}(1, 2*u[2] - 1, u[3])
        elseif face == 5
            Vec{FT}(-1, 2*u[2] - 1, u[3])
        else
            Vec{FT}(2*u[2] - 1, 2*u[3] - 1, 1)
        end
    end
end

function Base.iterate(c::SolidCubePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::SolidCubePointsVertices) = c.np
Base.eltype(::Type{SolidCubePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct SolidCubePointsNormals{FT}
    s::SobolSeq{3}
    np::Int
    norms::NTuple{6, Vec{FT}}
    pfaces::SVector{6, Float64}
end
function SolidCubePointsNormals(np, trans, pfaces)
    norm_trans = normal_trans(trans)
    FT = eltype(trans.linear)
    norm1 = norm_trans(Vec{FT}(0.0,  0.0, -1.0))
    norm2 = norm_trans(Vec{FT}(0.0,  1.0, 0.0))
    norm3 = norm_trans(Vec{FT}(0.0, -1.0, 0.0))
    norm4 = norm_trans(Vec{FT}(1.0, 0.0, 0.0))
    norm5 = norm_trans(Vec{FT}(-1.0,  0.0, 0.0))
    norm6 = norm_trans(Vec{FT}(0.0,  0.0, 1.0))
    SolidCubePointsNormals(SobolSeq(3), np, (norm1, norm2, norm3, norm4, norm5, norm6), pfaces)
end
function Base.iterate(c::SolidCubePointsNormals{FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT}
    @inbounds pface = next!(c.s)[1]
    i > c.np ? nothing : (c.norms[findfirst(x -> x > pface, c.pfaces)], i + 1)
end
Base.length(c::SolidCubePointsNormals) = c.np
Base.eltype(::Type{SolidCubePointsNormals{FT}}) where {FT} = Vec{FT}


"""
    SolidCubePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create n points on the surface of a solid cube with dimensions given by `length`, and `height`
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
julia> SolidCubePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function SolidCubePointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Area of each type of face
    area1 = width*height
    area2 = length*height
    area3 = width*length
    # Calculate the probability of a point being on a face (proportional to face area)
    total_area = 2*(area1 + area2 + area3)
    areas = SVector{6, Float64}(area1, area2, area2, area3, area3, area1)
    pfaces = cumsum(areas./total_area)
    # This is the function below
    SolidCubePointsVertices(trans; n = n, pfaces = pfaces, area = total_area)
end

# Create a solid cube from affine transformation, total area and probability of each face
function SolidCubePointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{6, Float64})
    PrimitivePoints(() -> SolidCubePointsVertices(n, trans, pfaces), () -> SolidCubePointsNormals(n, trans, pfaces), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function SolidCube!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{6, Float64})
    Primitive!(p, () -> SolidCubePointsVertices(n, trans, pfaces), () -> SolidCubePointsNormals(n, trans, pfaces), area)
end
