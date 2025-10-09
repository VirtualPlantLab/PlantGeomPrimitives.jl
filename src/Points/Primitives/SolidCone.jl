### This file contains public API ###

# Information to generate np points on a hollow cylinder given affine transformation
struct SolidConePointsVertices{FT, TT}
    np::Int
    s::SobolSeq{3}
    pfaces::SVector{2, Float64}
    trans::TT
end
function SolidConePointsVertices(np, trans, pfaces)
    s = SobolSeq(3)
    FT = eltype(trans.linear)
    SolidConePointsVertices{FT, typeof(trans)}(np, s, trans, pfaces)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates on the side of a
# cylinder using polar coordinates
function sobol_to_coords(c::SolidConePointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        # Select the face where to generate the point
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        # The angle is sampled independently of face
        α = u[2]*2*π
        sina = sin(α)
        cosa = cos(α)
        if face == 1 # Lateral face of cone
            dH = sqrt(u[2])
            z = 1 - dH
            Vec{FT}(cosa*dH, sina*dH, z)
        else # Bottom face
            r = sqrt(u[2])
            Vec{FT}(r*cos(θ), r*sin(θ), 0.0)
        end
    end
end

function Base.iterate(c::SolidConePointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::SolidConePointsVertices) = c.np
Base.eltype(::Type{SolidConePointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct SolidConePointsNormals{TT, FT}
    s::SobolSeq{3}
    np::Int
    trans::TT
    base_norms::Vec{FT}
    pfaces::SVector{2, Float64}
end
function SolidConePointsNormals(np, trans, pfaces)
    norm_trans = normal_trans(trans)
    FT = eltype(trans.linear)
    base_norm = norm_trans(.-Z(FT))
    SolidConePointsNormals(SobolSeq(3), np, norm_trans, base_norm, pfaces)
end
function Base.iterate(c::SolidConePointsNormals{TT, FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {TT, FT}
    if i > c.np
        nothing
    else
        # Select the face where to generate the normal vector
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        if face == 1
            α = u[1]*2*π
            n = sqrt(0.5)
            sina = sin(α)
            cosa = cos(α)
            norm = Vec{FT}(0.5*cosa/n, 0.5*sina/n, 0.5/n)
            (c.trans(norm), i + 1)
        else
            (c.norms, i + 1)
        end
    end
end
Base.length(c::SolidConePointsNormals) = c.np
Base.eltype(::Type{SolidConePointsNormals{FT, TT}}) where {FT, TT} = Vec{FT}


"""
    SolidConePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create n points on the surface of a solid cone with dimensions given by `length`, and `height`
located at the origin (and oriented along the XYZ axes).

## Arguments
- `length`: The length of the cone.
- `width`: The width of the base of the cone.
- `height = 1.0`: The height of the base of the cone.
- `n`: The number of points to be generated.

## Details

The points are generated using a 3D Sobol sequence  and trying to conserve the area around
each point. Note that a Sobol sequence does not guarantee equal areas arounds points (i.e.,
if you were to compute the areas using a Voronoi tessellation approach) and for any value of
`n` there may some larger gaps among the points (but the approximation improves with more points).

## Examples
```jldoctest
julia> SolidConePointsVertices(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function SolidConePointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Lateral area of the cone after scaling (https://mathworld.wolfram.com/EllipticCone.html)
    a = max(width, height)/2
    b = min(width, height)/2
    h = length
    side_area = 2b*sqrt(a^2 + h^2)*Elliptic.E(sqrt((1  -a^2/b^2)/(1 + a^2/h^2)))
    # Area of the top and bottom faces
    base_area = pi*a*b
    # Total area and relative areas
    total_area = base_area + side_area
    areas = SVector{2, Float64}(side_area, base_area)
    pfaces = cumsum(areas./total_area)
    # This is the function below
    SolidConePointsVertices(trans; n = n, area = area, pfaces = pfaces)
end

# Create a solid cube from affine transformation, total area and probability of each face
function SolidConePointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{3, Float64})
    PrimitivePoints(() -> SolidConePointsVertices(n, trans, pfaces), () -> SolidConePointsNormals(n, trans, pfaces), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function SolidCone!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{3, Float64})
    Primitive!(p, () -> SolidConePointsVertices(n, trans, pfaces), () -> SolidConePointsNormals(n, trans, pfaces), area)
end
