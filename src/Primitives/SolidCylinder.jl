### This file contains public API ###

struct SolidCylinderVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function SolidCylinderVertices(n, trans)
    FT = eltype(trans.linear)
    SolidCylinderVertices(n, FT(2pi / n), trans)
end
function Base.iterate(c::SolidCylinderVertices{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
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
    # Bottom base
    elseif i < 9c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 0)), i + 1)
        v == 2 && (return vertex_cylinder((j - 1) * c.Δ, c.trans, false), i + 1)
        v == 3 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, false), i + 1)
    # Top base
    elseif i < 12c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 1)), i + 1)
        v == 2 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, true), i + 1)
        v == 3 && (return vertex_cylinder((j - 1) * c.Δ, c.trans, true), i + 1)
    else
        nothing
    end
end
Base.length(c::SolidCylinderVertices) = 12c.n
Base.eltype(::Type{SolidCylinderVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 80)

Create a solid cylinder with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cylinder (distance between bases).
- `width = 1.0`: The width of the base of the cylinder.
- `height = 1.0`: The height of the base of the cylinder.
- `n = 80`: The number of triangles to discretize the cylinder into.

# Examples
```jldoctest
julia> SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 80);
```
"""
function SolidCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 80) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length))
    SolidCylinder(trans, n = n)
end

# Create a SolidCylinder from affine transformation
function SolidCylinder(trans::CT.AbstractAffineMap; n::Int = 80)
    @assert iseven(n)
    n = div(n, 4)
    Primitive(trans, x -> SolidCylinderVertices(n, x))
end

# Create a SolidCylinder from affine transformation and add it in-place to existing mesh
function SolidCylinder!(m::Mesh, trans::CT.AbstractAffineMap; n::Int = 80)
    @assert iseven(n)
    n = div(n, 4)
    Primitive!(m, trans, x -> SolidCylinderVertices(n, x))
end
