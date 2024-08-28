### This file contains public API ###

function vertex_cylinder(α, trans, upper)
    FT = eltype(trans.linear)
    sina = sin(α)
    cosa = cos(α)
    if upper
        orig = Vec{FT}(0, 0, 1) .+ sina .* Y(FT) .+ cosa .* X(FT)
    else
        orig = sina .* Y(FT) .+ cosa .* X(FT)
    end
    vert = trans(orig)
end


struct HollowCylinderVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function HollowCylinderVertices(n, trans)
    FT = eltype(trans.linear)
    HollowCylinderVertices(n, FT(2pi / n), trans)
end
function iterate(c::HollowCylinderVertices{FT,TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i < 3*c.n + 1 # Odd triangles
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, false), i + 1)
        v == 2 && (return vertex_cylinder((j - 1) * c.Δ, c.trans, true), i + 1)
        v == 3 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, true), i + 1)
    elseif i < 6c.n + 1 # Even triangles
        j = div(i - 1, 3) + 1 # n+1:2n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_cylinder((j - c.n - 1) * c.Δ, c.trans, false), i + 1)
        v == 2 && (return vertex_cylinder((j - c.n) * c.Δ, c.trans, false), i + 1)
        v == 3 && (return vertex_cylinder((j - c.n) * c.Δ, c.trans, true), i + 1)
    else
        nothing
    end
end
length(c::HollowCylinderVertices) = 6c.n
eltype(::Type{HollowCylinderVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40)

Create a hollow cylinder with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cylinder (distance between bases).
- `width = 1.0`: The width of the base of the cylinder.
- `height = 1.0`: The height of the base of the cylinder.
- `n = 40`: The number of triangles to discretize the cylinder into.

# Examples
```jldoctest
julia> HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40);
```
"""
function HollowCylinder(;
    length::FT = 1.0,
    width::FT = 1.0,
    height::FT = 1.0,
    n::Int = 40,
) where {FT}
    trans = LinearMap(SDiagonal(height / FT(2), width / FT(2), length))
    HollowCylinder(trans, n = n)
end

# Create a HollowCylinder from affine transformation
function HollowCylinder(trans::AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 2)
    Primitive(trans, x -> HollowCylinderVertices(n, x))
end

# Create a HollowCylinder from affine transformation and add it in-place to existing mesh
function HollowCylinder!(m::Mesh, trans::AbstractAffineMap; n::Int = 40)
    @assert iseven(n)
    n = div(n, 2)
    Primitive!(m, trans, x -> HollowCylinderVertices(n, x))
end
