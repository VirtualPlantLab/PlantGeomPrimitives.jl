### This file contains public API ###


function normal_cone(α, trans::AbstractMatrix{FT}) where {FT}
    x = Vec{FT}(cos(α)/FT(2), sin(α)/FT(2), FT(1)/FT(2))
    v = x .- O(FT)
    normalize(trans * v)
end

struct HollowConeNormals{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowConeNormals(n, trans::AbstractMatrix{FT}) where {FT}
    HollowConeNormals(n, FT(2pi / n), trans)
end
function iterate(c::HollowConeNormals{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i < c.n + 1
        norm = normal_cone(i * c.Δ + c.Δ / 2, c.trans)
        (norm, i + 1)
    else
        nothing
    end
end
length(c::HollowConeNormals) = c.n
eltype(::Type{HollowConeNormals{FT,TT}}) where {FT,TT} = Vec{FT}


# We need to alter order of vertices to make the normals consistent
function vertex_cone(α, trans, clockwise = true)
    FT = eltype(trans.linear)
    if clockwise
        orig = Vec{FT}(cos(α), sin(α), FT(0))
    else
        orig = Vec{FT}(sin(α), cos(α), FT(0))
    end
    vert = trans(orig)
end


struct HollowConeVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowConeVertices(n, trans)
    FT = eltype(trans.linear)
    HollowConeVertices(n, FT(2pi / n), trans)
end
function iterate(c::HollowConeVertices{FT,TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i > 3c.n
        nothing
    # Tip of the cone
    elseif i == 1 || mod(i - 1, 3) == 0
        (c.trans(Vec{FT}(0, 0, 1)), i + 1)
    else
    # Base of the cone
        p = div(i - 1, 3) + mod(i - 1, 3)
        vert = vertex_cone(p * c.Δ, c.trans, true)
        (vert, i + 1)
    end
end
length(c::HollowConeVertices) = 3c.n
eltype(::Type{HollowConeVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create a hollow cone with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cone (distance between base and apex).
- `width = 1.0`: The width of the base of the cone.
- `height = 1.0`: The height of the base of the cone.
- `n = 20`: The number of triangles to be used in the mesh.

# Examples
```jldoctest
julia> HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function HollowCone(;
    length::FT = 1.0,
    width::FT = 1.0,
    height::FT = 1.0,
    n::Int = 20,
) where {FT}
    trans = LinearMap(SDiagonal(height / FT(2), width / FT(2), length))
    HollowCone(trans, n = n)
end

# Create a HollowCone from affine transformation
function HollowCone(trans::AbstractAffineMap; n::Int = 20)
    Primitive(
        trans,
        x -> HollowConeVertices(n, x),
        x -> HollowConeNormals(n, x)
    )
end

# Create a HollowCone from affine transformation and add it in-place to existing mesh
function HollowCone!(m::Mesh, trans::AbstractAffineMap; n::Int = 20)
    Primitive!(
        m,
        trans,
        x -> HollowConeVertices(n, x),
        x -> HollowConeNormals(n, x)
    )
end
