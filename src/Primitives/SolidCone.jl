### This file contains public API ###

struct SolidConeVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function SolidConeVertices(n, trans)
    FT = eltype(trans.linear)
    SolidConeVertices(n, FT(2pi / n), trans)
end
function iterate(c::SolidConeVertices{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i > 6c.n
        nothing
    elseif i == 1 || mod(i - 1, 3) == 0
        # Tip of the cone
        if i < 3c.n
            (c.trans(Vec{FT}(0, 0, 1)), i + 1)
        else
        # Center of base of the cone
            (c.trans(Vec{FT}(0, 0, 0)), i + 1)
        end
    # Edges of base of the cone
    else
        clockwise = i <= 3c.n ? true : false
        p = div(i - 1, 3) + mod(i - 1, 3)
        vert = vertex_cone(p * c.Δ, c.trans, clockwise)
        (vert, i + 1)
    end
end
length(c::SolidConeVertices) = 6c.n
eltype(::Type{SolidConeVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 40)

Create a solid cone with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cone (distance between base and apex).
- `width = 1.0`: The width of the base of the cone.
- `height = 1.0`: The height of the base of the cone.
- `n = 40`: The number of triangles to be used in the mesh.

# Examples
```jldoctest
julia> SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 40);
```
"""
function SolidCone(;
    length::FT = 1.0,
    width::FT = 1.0,
    height::FT = 1.0,
    n::Int = 40,
) where {FT}
    trans = LinearMap(SDiagonal(height / FT(2), width / FT(2), length))
    SolidCone(trans, n = n)
end

# Create a SolidCone from affine transformation
function SolidCone(trans::AbstractAffineMap; n::Int = 40)
    @assert mod(n, 4) == 0 && iseven(div(n, 4)) "n must be an even multiple of 4"
    n = div(n, 2)
    Primitive(trans, x -> SolidConeVertices(n, x))
end

# Create a SolidCone from affine transformation and add it in-place to existing mesh
function SolidCone!(m::Mesh, trans::AbstractAffineMap; n::Int = 40)
    @assert mod(n, 4) == 0 "n must be a multiple of 4"
    n = div(n, 2)
    Primitive!(m, trans, x -> SolidConeVertices(n, x))
end
