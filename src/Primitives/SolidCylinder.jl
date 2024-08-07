### This file contains public API ###

struct SolidCylinderNormals{FT,TT}
    n::Int
    Δ::FT
    trans::TT
    ln::Vec{FT}
    un::Vec{FT}
end

function SolidCylinderNormals(n, trans::AbstractMatrix{FT}) where {FT}
    SolidCylinderNormals(
        n,
        FT(2pi / n),
        trans,
        trans * Vec{FT}(0, 0, -1),
        trans * Vec{FT}(1, 0, 0),
    )
end
function iterate(c::SolidCylinderNormals{FT,TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i == 1
        norm = normal_cylinder((c.n - 1) * c.Δ, c.trans)
        (norm, 2) # Lateral - end
    elseif i == 2
        norm = normal_cylinder((c.n - 1) * c.Δ, c.trans)
        (norm, 3) # Lateral - end
    elseif i < c.n + 2
        j = i - 1 # 2:n
        norm = normal_cylinder((j - 2) * c.Δ, c.trans)
        (norm, i + 1) # Lateral - intermediate
    elseif i < 2c.n + 1
        j = i - c.n # 2:n
        norm = normal_cylinder((j - 2) * c.Δ, c.trans)
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
length(c::SolidCylinderNormals) = 4c.n
eltype(::Type{SolidCylinderNormals{FT,TT}}) where {FT,TT} = Vec{FT}


struct SolidCylinderVertices{FT,TT}
    n::Int
    Δ::FT
    trans::TT
end
function SolidCylinderVertices(n, trans)
    FT = eltype(trans.linear)
    SolidCylinderVertices(n, FT(2pi / n), trans)
end
function iterate(c::SolidCylinderVertices{FT,TT},i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i < 3*c.n + 1 # Odd triangles
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, false), i + 1)
        v == 2 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, true), i + 1)
        v == 3 && (return vertex_cylinder((j - 1) * c.Δ, c.trans, true), i + 1)
    elseif i < 6c.n + 1 # Even triangles
        j = div(i - 1, 3) + 1 # n+1:2n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return vertex_cylinder((j - c.n - 1) * c.Δ, c.trans, false), i + 1)
        v == 2 && (return vertex_cylinder((j - c.n) * c.Δ, c.trans, true), i + 1)
        v == 3 && (return vertex_cylinder((j - c.n) * c.Δ, c.trans, false), i + 1)
    # Bottom base
    elseif i < 9c.n + 1
        j = div(i - 1, 3) + 1 # 3:n
        v = mod(i - 1 , 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 0)), i + 1)
        v == 2 && (return vertex_cylinder((j - 2) * c.Δ, c.trans, false), i + 1)
        v == 3 && (return vertex_cylinder((j - 1) * c.Δ, c.trans, false), i + 1)
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
length(c::SolidCylinderVertices) = 12c.n
eltype(::Type{SolidCylinderVertices{FT,TT}}) where {FT,TT} = Vec{FT}


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
    trans = LinearMap(SDiagonal(height / FT(2), width / FT(2), length))
    SolidCylinder(trans, n = n)
end

# Create a SolidCylinder from affine transformation
function SolidCylinder(trans::AbstractAffineMap; n::Int = 80)
    @assert iseven(n)
    n = div(n, 4)
    Primitive(trans, x -> SolidCylinderVertices(n, x),
                     x -> SolidCylinderNormals(n, x))
end

# Create a SolidCylinder from affine transformation and add it in-place to existing mesh
function SolidCylinder!(m::Mesh, trans::AbstractAffineMap; n::Int = 80)
    @assert iseven(n)
    n = div(n, 4)
    Primitive!(m, trans, x -> SolidCylinderVertices(n, x),
                         x -> SolidCylinderNormals(n, x))
end
