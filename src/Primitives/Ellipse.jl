### This file contains public API ###

struct EllipseVertices{FT,TT}
    nt::Int
    Δ::FT
    trans::TT
end
function EllipseVertices(nt, trans)
    FT = eltype(trans.linear)
    EllipseVertices(nt, FT(2pi / nt), trans)
end
function Base.iterate(e::EllipseVertices{FT,TT})::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    (e.trans(Vec{FT}(0, 0, 1)), 2)
end
function Base.iterate(e::EllipseVertices{FT,TT}, i)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    if i > 3e.nt
        nothing
    elseif mod(i - 1, 3) == 0
        (e.trans(Vec{FT}(0, 0, 1)), i + 1)
    else
        p = div(i - 1, 3) + mod(i - 1, 3) - 1
        α = p * e.Δ
        sina = sin(α)
        cosa = cos(α)
        orig = Z(FT) .+ sina .* Z(FT) .+ cosa .* Y(FT)
        vert = e.trans(orig)
        (vert, i + 1)
    end
end
Base.length(e::EllipseVertices) = 3e.nt
Base.eltype(::Type{EllipseVertices{FT}}) where {FT} = Vec{FT}


"""
    Ellipse(;length = 1.0, width = 1.0, n = 20)

Create a triangular mesh approximating an ellipse with dimensions given by `length` and
`width`, discretized into `n` triangles (must be even) and standard location and orientation.

# Arguments
- `length = 1.0`: The length of the ellipse.
- `width = 1.0`: The width of the ellipse.
- `n = 20`: The number of triangles to be used in the mesh.

# Examples
```jldoctest
julia> Ellipse(;length = 1.0, width = 1.0, n = 20);
```
"""
function Ellipse(; length::FT = 1.0, width::FT = 1.0, n::Int = 20) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(one(FT), width / FT(2), length / FT(2)))
    Ellipse(trans; n = n)
end

# Create a ellipse from affine transformation
function Ellipse(trans::CT.AbstractAffineMap; n::Int = 20)
    Primitive(trans, x -> EllipseVertices(n, x))
end

# Create a ellipse from affine transformation and add it in-place to existing mesh
function Ellipse!(m::Mesh, trans::CT.AbstractAffineMap; n::Int = 20)
    Primitive!(m, trans, x -> EllipseVertices(n, x))
end
