### This file contains public API ###

# Information to generate np points on a hollow cylinder given affine transformation
struct SolidFrustumPointsVertices{FT, TT}
    ratio::FT
    np::Int
    s::SobolSeq{3}
    pfaces::SVector{2, Float64}
    trans::TT
end
function SolidFrustumPointsVertices(np, trans, pfaces, ratio)
    s = SobolSeq(3)
    FT = eltype(trans.linear)
    SolidFrustumPointsVertices{FT, typeof(trans)}(ratio, np, s, trans, pfaces)
end

# Convert a Sobol sample from the unit square to Cartesian coordinates on the side of a
# cylinder using polar coordinates
function sobol_to_coords(c::SolidFrustumPointsVertices{FT, TT}) where {FT, TT}
    @inbounds begin
        # Select the face where to generate the point
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        # The angle is sampled independently of face
        α = u[1]*2*π
        sina = sin(α)
        cosa = cos(α)
        if face == 1 # Lateral face of cone
            dH = sqrt(u[2])
            z = 1 - dH
            rp = c.ratio + dH*(1 - c.ratio)
            Vec{FT}(cosa*rp, sina*rp, z)
        else # Bottom face
            r = sqrt(u[2])
            Vec{FT}(r*cos(θ), r*sin(θ), 0.0)
        end
    end
end

function Base.iterate(c::SolidFrustumPointsVertices{FT, TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT, TT}
    i > c.np ? nothing : (c.trans(sobol_to_coords(c)), i + 1)
end
Base.length(c::SolidFrustumPointsVertices) = c.np
Base.eltype(::Type{SolidFrustumPointsVertices{FT, TT}}) where {FT, TT} = Vec{FT}


# Information to generate np normals on an ellipse given affine transformation
struct SolidFrustumPointsNormals{TT, FT}
    s::SobolSeq{3}
    ratio::FT
    np::Int
    trans::TT
    base_norms::Vec{FT}
    pfaces::SVector{2, Float64}
end
function SolidFrustumPointsNormals(np, trans, pfaces, ratio)
    norm_trans = normal_trans(trans)
    FT = eltype(trans.linear)
    base_norm = norm_trans(.-Z(FT))
    SolidFrustumPointsNormals(SobolSeq(3), ratio, np, norm_trans, base_norm, pfaces)
end
function Base.iterate(c::SolidFrustumPointsNormals{TT, FT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {TT, FT}
    if i > c.np
        nothing
    else
        # Select the face where to generate the normal vector
        u = next!(c.s)
        pface = u[1]
        face = findfirst(x -> x > pface, e.pfaces)
        if face == 1
            α = u[2]*2*π
            sina = sin(α)
            cosa = cos(α)
            dH = sqrt(u[3])
            z = 1 - dH
            rp = c.ratio + dH*(1 - c.ratio)
            n = sqrt(z^2 + rp^2)
            norm = Vec{FT}(rp*cosa/n, rp*sina/n, z/n)
            (c.trans(norm), i + 1)
        else
            (c.norms, i + 1)
        end
    end
end
Base.length(c::SolidFrustumPointsNormals) = c.np
Base.eltype(::Type{SolidFrustumPointsNormals{FT, TT}}) where {FT, TT} = Vec{FT}


"""
    SolidFrustumPointsVertices(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 20)

Create n points on the surface of a solid cone with dimensions given by `length`, and `height`
located at the origin (and oriented along the XYZ axes).

## Arguments
- `length`: The length of the cone.
- `width`: The width of the base of the cone.
- `height = 1.0`: The height of the base of the cone.
- `ratio`: The ratio of the small radius to the large radius.
- `n`: The number of points to be generated.

## Details

The points are generated using a 3D Sobol sequence  and trying to conserve the area around
each point. Note that a Sobol sequence does not guarantee equal areas arounds points (i.e.,
if you were to compute the areas using a Voronoi tessellation approach) and for any value of
`n` there may some larger gaps among the points (but the approximation improves with more points).

## Examples
```jldoctest
julia> SolidFrustumPointsVertices(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 20);
```
"""
function SolidFrustumPointsVertices(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, ratio::FT = 1.0, n::Int = 20) where {FT}
    # Affine transformation (only scaling)
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    # Lateral area of the cone after scaling (https://mathworld.wolfram.com/EllipticFrustum.html)
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
    SolidFrustumPointsVertices(trans; n = n, area = area, pfaces = pfaces)
end

# Create a solid cube from affine transformation, total area and probability of each face
function SolidFrustumPointsVertices(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{3, Float64}, ratio::Float64 = 1.0)
    PrimitivePoints(() -> SolidFrustumPointsVertices(n, trans, pfaces, ratio), () -> SolidFrustumPointsNormals(n, trans, pfaces, ratio), area)
end

# Create a solid cube from affine transformation, total area and probability of each face
# and add it in-place to existing mesh
function SolidFrustum!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0, pfaces::SVector{3, Float64}, ratio::Float64 = 1.0)
    Primitive!(p, () -> SolidFrustumPointsVertices(n, trans, pfaces, ratio), () -> SolidFrustumPointsNormals(n, trans, pfaces, ratio), area)
end
