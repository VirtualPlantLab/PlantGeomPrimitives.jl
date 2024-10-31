### This file contains public API ###

struct SolidFrustumVertices{FT,TT}
    ratio::FT
    n::Int
    Δ::FT
    trans::TT
end
function SolidFrustumVertices(ratio::FT, n, trans) where {FT}
    @assert eltype(trans.linear) == FT
    SolidFrustumVertices(ratio, n, FT(2 * pi / n), trans)
end
function Base.iterate(c::SolidFrustumVertices{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    # Odd triangles
    if i < 3*c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_frustum((j - 2) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 2 && (return vertex_frustum((j - 1) * c.Δ, c.trans, true, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - 2) * c.Δ, c.trans, true, c.ratio), i + 1)
    # Even triangles
    elseif i < 6c.n + 1
        j = div(i - 1, 3) + 1 # n+1:2n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_frustum((j - c.n - 1) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 2 && (return vertex_frustum((j - c.n) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - c.n) * c.Δ, c.trans, true, c.ratio), i + 1)
    # Bottom base
    elseif i < 9c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 0)), i + 1)
        v == 2 && (return vertex_frustum((j - 1) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - 2) * c.Δ, c.trans, false, c.ratio), i + 1)
    # Top base
    elseif i < 12c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 1)), i + 1)
        v == 2 && (return vertex_frustum((j - 2) * c.Δ, c.trans, true, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - 1) * c.Δ, c.trans, true, c.ratio), i + 1)
    else
        nothing
    end
end

Base.length(c::SolidFrustumVertices) = 12c.n
Base.eltype(::Type{SolidFrustumVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 40)

Create a solid frustum with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the frustum (distance between bases).
- `width = 1.0`: The width of the base of the frustum.
- `height = 1.0`: The height of the base of the frustum.
- `ratio = 1.0`: The ratio between the top and bottom base radii.
- `n = 40`: The number of triangles to discretize the frustum into.

# Examples
```jldoctest
julia> SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40, ratio = 0.5);
```
"""
function SolidFrustum(;
    length::FT = 1.0,
    width::FT = 1.0,
    height::FT = 1.0,
    ratio::FT = 1.0,
    n::Int = 40,
) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    SolidFrustum(ratio, trans, n = n)
end

# Create a SolidFrustum from affine transformation
function SolidFrustum(ratio, trans::CT.AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 4)
    Primitive(trans, x -> SolidFrustumVertices(ratio, n, x))
end

# Create a SolidFrustum from affine transformation and add it in-place to existing mesh
function SolidFrustum!(m::Mesh, ratio, trans::CT.AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 4)
    Primitive!(m, trans, x -> SolidFrustumVertices(ratio, n, x))
end
