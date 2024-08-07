### This file contains public API ###

struct SolidFrustumNormals{FT,TT}
    sinβ::FT
    n::Int
    Δ::FT
    trans::TT
    ln::Vec{FT}
    un::Vec{FT}
end
function SolidFrustumNormals(ratio::FT, n, trans::AbstractMatrix{FT}) where {FT}
    SolidFrustumNormals(
        1 / sqrt((one(FT) - ratio)^2 + one(FT)),
        n,
        FT(2pi / n),
        trans,
        trans * Vec{FT}(0, 0, -1),
        trans * Vec{FT}(1, 0, 0),
    )
end

function iterate(c::SolidFrustumNormals{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i == 1
        norm = normal_frustum((c.n - 1) * c.Δ, c.trans, c.sinβ)
        (norm, 2) # Lateral - end
    elseif i == 2
        norm = normal_frustum((c.n - 1) * c.Δ, c.trans, c.sinβ)
        (norm, 3) # Lateral - end
    elseif i < c.n + 2
        j = i - 1 # 2:n
        norm = normal_frustum((j - 2) * c.Δ, c.trans, c.sinβ)
        (norm, i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n # 2:n
        norm = normal_frustum((j - 2) * c.Δ, c.trans, c.sinβ)
        (norm, i + 1) # Lateral - intermediate
    elseif i < 3c.n
        (c.ln, i + 1) # Lower base - intermediate
    elseif i == 3c.n
        (c.ln, i + 1) # Lower base - end
    elseif i < 4c.n
        j = i - 2c.n + 2
        (c.un, i + 1) # Upper base - intermediate
    elseif i == 4c.n
        (c.un, i + 1) # Upper base - end
    else
        nothing
    end
end
length(c::SolidFrustumNormals) = 4c.n
eltype(::Type{SolidFrustumNormals{FT,TT}}) where {FT,TT} = Vec{FT}


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
function iterate(c::SolidFrustumVertices{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    # Odd triangles
    if i < 3*c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_frustum((j - 2) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 2 && (return vertex_frustum((j - 2) * c.Δ, c.trans, true, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - 1) * c.Δ, c.trans, true, c.ratio), i + 1)
    # Even triangles
    elseif i < 6c.n + 1
        j = div(i - 1, 3) + 1 # n+1:2n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_frustum((j - c.n - 1) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 2 && (return vertex_frustum((j - c.n) * c.Δ, c.trans, true, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - c.n) * c.Δ, c.trans, false, c.ratio), i + 1)
    # Bottom base
    elseif i < 9c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 0)), i + 1)
        v == 2 && (return vertex_frustum((j - 2) * c.Δ, c.trans, false, c.ratio), i + 1)
        v == 3 && (return vertex_frustum((j - 1) * c.Δ, c.trans, false, c.ratio), i + 1)
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

length(c::SolidFrustumVertices) = 12c.n
eltype(::Type{SolidFrustumVertices{FT,TT}}) where {FT,TT} = Vec{FT}


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
julia> SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40);
```
"""
function SolidFrustum(;
    length::FT = 1.0,
    width::FT = 1.0,
    height::FT = 1.0,
    ratio::FT = 1.0,
    n::Int = 40,
) where {FT}
    trans = LinearMap(SDiagonal(height / FT(2), width / FT(2), length))
    SolidFrustum(ratio, trans, n = n)
end

# Create a SolidFrustum from affine transformation
function SolidFrustum(ratio, trans::AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 4)
    Primitive(trans, x -> SolidFrustumVertices(ratio, n, x),
                     x -> SolidFrustumNormals(ratio, n, x))
end

# Create a SolidFrustum from affine transformation and add it in-place to existing mesh
function SolidFrustum!(m::Mesh, ratio, trans::AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 4)
    Primitive!(m, trans, x -> SolidFrustumVertices(ratio, n, x),
                         x -> SolidFrustumNormals(ratio, n, x))
end
