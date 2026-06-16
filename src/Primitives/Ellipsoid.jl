### This file contains public API ###

function vertex_sphere(θ, φ, trans)
    FT = eltype(trans.linear)
    sθ, cθ = sincos(FT(θ))
    sφ, cφ = sincos(FT(φ))
    trans(Vec{FT}(sθ * cφ, sθ * sφ, 1 + cθ))
end

struct EllipsoidVertices{FT,TT}
    n::Int
    dθ::FT
    dφ::FT
    trans::TT
end
function EllipsoidVertices(n, trans)
    FT = eltype(trans.linear)
    EllipsoidVertices(n, FT(π / n), FT(2π / n), trans)
end

function Base.iterate(c::EllipsoidVertices{FT,TT}, i::Int = 1)::Union{Nothing,Tuple{Vec{FT},Int64}} where {FT,TT}
    n  = c.n
    i > 6n * (n - 1) && return nothing
    ntop = 3n
    nb   = 6n  # vertices per middle band
    if i <= ntop
        # Top cap: n fan triangles from north pole to first latitude ring
        j = div(i - 1, 3)
        v = mod(i - 1, 3) + 1
        v == 1 && (return c.trans(Vec{FT}(0, 0, 2)), i + 1)
        v == 2 && (return vertex_sphere(c.dθ,       j       * c.dφ, c.trans), i + 1)
        v == 3 && (return vertex_sphere(c.dθ,      (j + 1)  * c.dφ, c.trans), i + 1)
    elseif i <= ntop + (n - 2) * nb
        # Middle bands: (n-2) latitude bands, each with n quads split into 2 triangles
        im    = i - ntop - 1
        iband = div(im, nb)
        iw    = mod(im, nb)
        θu    = (iband + 1) * c.dθ   # upper ring (smaller θ)
        θl    = (iband + 2) * c.dθ   # lower ring (larger θ)
        if iw < 3n
            # First triangle of each quad: (top-left, bottom-left, bottom-right)
            j = div(iw, 3)
            v = mod(iw, 3) + 1
            v == 1 && (return vertex_sphere(θu,  j      * c.dφ, c.trans), i + 1)
            v == 2 && (return vertex_sphere(θl,  j      * c.dφ, c.trans), i + 1)
            v == 3 && (return vertex_sphere(θl, (j + 1) * c.dφ, c.trans), i + 1)
        else
            # Second triangle of each quad: (top-left, bottom-right, top-right)
            iw2 = iw - 3n
            j   = div(iw2, 3)
            v   = mod(iw2, 3) + 1
            v == 1 && (return vertex_sphere(θu,  j      * c.dφ, c.trans), i + 1)
            v == 2 && (return vertex_sphere(θl, (j + 1) * c.dφ, c.trans), i + 1)
            v == 3 && (return vertex_sphere(θu, (j + 1) * c.dφ, c.trans), i + 1)
        end
    else
        # Bottom cap: n fan triangles from last latitude ring to south pole (reversed winding)
        ib    = i - ntop - (n - 2) * nb - 1
        j     = div(ib, 3)
        v     = mod(ib, 3) + 1
        θlast = (n - 1) * c.dθ
        v == 1 && (return c.trans(Vec{FT}(0, 0, 0)), i + 1)
        v == 2 && (return vertex_sphere(θlast, (j + 1) * c.dφ, c.trans), i + 1)
        v == 3 && (return vertex_sphere(θlast,  j      * c.dφ, c.trans), i + 1)
    end
end

Base.length(c::EllipsoidVertices) = 6c.n * (c.n - 1)
Base.eltype(::Type{EllipsoidVertices{FT,TT}}) where {FT,TT} = Vec{FT}


"""
    Ellipsoid(;length = 1.0, width = 1.0, height = 1.0, n = 20)

Create a solid ellipsoid with dimensions given by `length`, `width` and `height`,
with the base on the z = 0 plane, discretized using a UV latitude-longitude mesh
with `n` latitude and azimuth subdivisions.

# Arguments
- `length = 1.0`: The length of the ellipsoid along the z axis.
- `width = 1.0`: The width of the ellipsoid along the y axis.
- `height = 1.0`: The height of the ellipsoid along the x axis.
- `n = 20`: Resolution (number of latitude and azimuth subdivisions). Must be >= 3.
  The mesh has `2n(n-1)` triangles.

# Examples
```jldoctest
julia> Ellipsoid(;length = 1.0, width = 1.0, height = 1.0, n = 20);
```
"""
function Ellipsoid(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where {FT}
    trans = CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length / FT(2)))
    Ellipsoid(trans; n = n)
end

# Create an ellipsoid from affine transformation
function Ellipsoid(trans::CT.AbstractAffineMap; n::Int = 20)
    @assert n >= 3 "n must be at least 3"
    Primitive(trans, x -> EllipsoidVertices(n, x))
end

# Create an ellipsoid from affine transformation and add it in-place to existing mesh
function Ellipsoid!(m::Mesh, trans::CT.AbstractAffineMap; n::Int = 20)
    @assert n >= 3 "n must be at least 3"
    Primitive!(m, trans, x -> EllipsoidVertices(n, x))
end
