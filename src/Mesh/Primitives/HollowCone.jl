### This file contains public API ###

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


struct HollowConeMeshVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowConeMeshVertices(n, trans)
    FT = eltype(trans.linear)
    HollowConeMeshVertices(n, FT(2pi / n), trans)
end
function Base.iterate(c::HollowConeMeshVertices{FT,TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
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
Base.length(c::HollowConeMeshVertices) = 3c.n
Base.eltype(::Type{HollowConeMeshVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowConeMesh(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create a hollow cone with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cone (distance between base and apex).
- `width = 1.0`: The width of the base of the cone.
- `height = 1.0`: The height of the base of the cone.
- `n = 20`: The number of triangles to be used in the mesh.

# Examples
```jldoctest
julia> HollowConeMesh(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function HollowConeMesh(;
    length::FT = 1.0,
    width::FT = 1.0,
    height::FT = 1.0,
    n::Int = 20,
) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    HollowConeMesh(trans, n = n)
end

# Create a HollowCone from affine transformation
function HollowConeMesh(trans::CT.AbstractAffineMap; n::Int = 20)
    PrimitiveMesh(trans, x -> HollowConeMeshVertices(n, x))
end

# Create a HollowCone from affine transformation and add it in-place to existing mesh
function HollowCone!(m::Mesh, trans::CT.AbstractAffineMap; n::Int = 20)
    Primitive!(m, trans, x -> HollowConeMeshVertices(n, x))
end
