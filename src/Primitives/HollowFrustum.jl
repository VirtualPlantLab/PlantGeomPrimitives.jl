### This file contains public API ###

function vertex_frustum(α::FT, trans, upper, ratio::FT)::Vec{FT} where {FT}
    if upper
        sina = sin(α) * ratio
        cosa = cos(α) * ratio
        orig = Z(FT) .+ sina .* Y(FT) .+ cosa .* X(FT)
    else
        sina = sin(α)
        cosa = cos(α)
        orig = sina .* Y(FT) .+ cosa .* X(FT)
    end
    vert = trans(orig)
end


struct HollowFrustumVertices{FT,TT}
    ratio::FT
    n::Int
    Δ::FT
    trans::TT
end
function HollowFrustumVertices(ratio::FT, n, trans) where {FT}
    @assert eltype(trans.linear) == FT
    HollowFrustumVertices(ratio, n, FT(2 * pi / n), trans)
end
function Base.iterate(c::HollowFrustumVertices{FT,TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i < 3*c.n + 1 # Odd triangles
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_frustum((j - 2) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 2 && (return vertex_frustum((j - 1) * c.Δ, c.trans, true, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - 2) * c.Δ, c.trans, true, c.ratio), i + 1)
    elseif i < 6c.n + 1 # Even triangles
        j = div(i - 1, 3) + 1 # n+1:2n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_frustum((j - c.n - 1) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 2 && (return vertex_frustum((j - c.n) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - c.n) * c.Δ, c.trans, true, c.ratio), i + 1)
    else
        nothing
    end
end
Base.length(c::HollowFrustumVertices) = 6c.n
Base.eltype(::Type{HollowFrustumVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowFrustum(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 40)

Create a hollow frustum with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the frustum (distance between bases).
- `width = 1.0`: The width of the base of the frustum.
- `height = 1.0`: The height of the base of the frustum.
- `ratio = 1.0`: The ratio between the top and bottom base radii.
- `n = 40`: The number of triangles to discretize the frustum into.

# Examples
```jldoctest
julia> HollowFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40, ratio = 0.5);
```
"""
function HollowFrustum(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0,ratio::FT = 1.0,
                       n::Int = 40) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    HollowFrustum(ratio, trans, n = n)
end

# Create a HollowFrustum from affine transformation
function HollowFrustum(ratio, trans::CT.AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 2)
    Primitive(trans, x -> HollowFrustumVertices(ratio, n, x))
end

# Create a HollowFrustum from affine transformation and add it in-place to existing mesh
function HollowFrustum!(m::Mesh, ratio, trans::CT.AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 2)
    Primitive!(m, trans, x -> HollowFrustumVertices(ratio, n, x))
end
