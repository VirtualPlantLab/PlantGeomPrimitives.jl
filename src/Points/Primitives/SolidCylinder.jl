### This file contains public API ###

# Information to generate np points on a hollow cylinder given affine transformation
struct SolidCylinderPointsVertices{FT, TT}
    np::Int
    s::SobolSeq{3}
    pfaces::SVector{3, Float64}
    trans::TT
end
function SolidCylinderPointsVertices(np, trans, pfaces)
    s = SobolSeq(3)
    FT = eltype(trans.linear)
    SolidCylinderPointsVertices{FT, typeof(trans)}(np, s, trans, pfaces)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates on the side of a
# cylinder using polar coordinates
function sobol_to_coords(c::SolidCylinderPointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        # Select the face where to generate the point
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        # The angle is sampled independently of face
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        if face == 1 # Lateral face of cylinder
            z = u[2]
            Vec{FT}(cosa, sina, z)
        else # Bottom or top faces
            r = sqrt(u[2])
            if face == 2
                Vec{FT}(r*cos(θ), r*sin(θ), 0.0)
            else
                Vec{FT}(r*cos(θ), r*sin(θ), 1.0)
            end
        end
    end
end

function Base.iterate(c::SolidCylinderPointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::SolidCylinderPointsVertices) = c.np
Base.eltype(::Type{SolidCylinderPointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct SolidCylinderPointsNormals{TT, FT}
    s::SobolSeq{3}
    np::Int
    trans::TT
    base_norms::NTuple{2, Vec{FT}}
    pfaces::SVector{3, Float64}
end
function SolidCylinderPointsNormals(np, trans, pfaces)
    norm_trans = normal_trans(trans)
    FT = eltype(trans.linear)
    base_norms = (norm_trans(.-Z(FT)), norm_trans(Z(FT)))
    SolidCylinderPointsNormals(SobolSeq(3), np, norm_trans, base_norms, pfaces)
end
function Base.iterate(c::SolidCylinderPointsNormals{TT, FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {TT, FT}
    if i > c.np
        nothing
    else
        # Select the face where to generate the normal vector
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        if face == 1
            α = u[1]*2*π
            sina = sin(α)
            cosa = cos(α)
            norm = Vec{FT}(cosa, sina, 0.0)
            (c.trans(norm), i + 1)
        elseif face == 2
            (c.norms[1], i + 1)
        else
            (c.norms[2], i + 1)
        end
    end
end
Base.length(c::SolidCylinderPointsNormals) = c.np
Base.eltype(::Type{SolidCylinderPointsNormals{FT, TT}}) where {FT, TT} = Vec{FT}


"""
    SolidCylinderPointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20)

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
julia> SolidCylinderPointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function SolidCylinderPointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Total side area of the cylinder (perimeter using Ramanujan first approximation)
    a = width/2
    b = length/2
    perimeter = pi*(3*(a + b) - sqrt((3a + b)*(a + 3b)))
    side_area = perimeter*height
    # Area of the top and bottom faces
    base_area = pi*a*b
    # Total area and relative areas
    total_area = base_area*2 + side_area
    areas = SVector{3, Float64}(side_area, base_area, base_area)
    pfaces = cumsum(areas./total_area)
    # This is the function below
    SolidCylinderPointsVertices(trans; n = n, area = area, pfaces = pfaces)
end

# Create a solid cube from affine transformation, total area and probability of each face
function SolidCylinderPointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{3, Float64})
    PrimitivePoints(() -> SolidCylinderPointsVertices(n, trans, pfaces), () -> SolidCylinderPointsNormals(n, trans, pfaces), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function SolidCylinder!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{3, Float64})
    Primitive!(p, () -> SolidCylinderPointsVertices(n, trans, pfaces), () -> SolidCylinderPointsNormals(n, trans, pfaces), area)
end
