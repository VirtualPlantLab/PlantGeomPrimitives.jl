### This file contains public API ###

# Rotations, translations and scaling of triangular meshes

# In-place affine transformation of a geometry
function transform!(m::Geom, trans::CT.AbstractAffineMap)
    vertices(m) .= trans.(vertices(m))
    norm_trans   = transpose(inv(trans.linear))
    if has_normals(m)
        @simd for i in eachindex(normals(m))
            @inbounds normals(m)[i] = L.normalize(norm_trans*normals(m)[i])
        end
    end
    return nothing
end


"""
    scale!(g::Geom, vec::Vec)

Scale a geom `g` along the three axes provided by `vec`.

# Arguments
- `g`: The geometry to be scaled (`Points`, `Segments` or `Mesh`).
- `vec`: A vector containing the scaling factors for the x, y, and z axes.

# Examples
```jldoctest
julia> m = Rectangle();

julia> scaling_vector = Vec(2.0, 1.5, 3.0);

julia> scale!(m, scaling_vector);
```
"""
function scale!(g::Geom, vec::Vec)
    trans = CT.LinearMap(CT.SDiagonal(vec...))
    transform!(g, trans)
end

"""
    rotatex!(g::Geom, θ)

Rotate a geometry `g` around the x axis by angle `θ`.

# Arguments
- `g`: The geometry to be rotated.
- `θ`: Angle of rotation in radians.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatex!(m, θ)
```
"""
function rotatex!(g::Geom, θ)
    trans = CT.LinearMap(Rotations.RotX(θ))
    transform!(g, trans)
end

"""
    rotatey!(g::Geom, θ)

Rotate a geometry `g` around the y axis by angle `θ`.

# Arguments
- `g`: The geometry to be rotated.
- `θ`: Angle of rotation in radians.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatey!(m, θ);
```
"""
function rotatey!(g::Geom, θ)
    trans = CT.LinearMap(Rotations.RotY(θ))
    transform!(g, trans)
end

"""
    rotatez!(g::Geom, θ)

Rotate a geometry `g` around the z axis by angle `θ`.

# Arguments
- `g`: The geometry to be rotated.
- `θ`: Angle of rotation in radians.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatez!(m, θ);
```
"""
function rotatez!(g::Geom, θ)
    trans = CT.LinearMap(Rotations.RotZ(θ))
    transform!(g, trans)
end

"""
    rotate!(g::Geom; x::Vec, y::Vec, z::Vec)

Rotate a geometry `g` to a new coordinate system given by `x`, `y` and `z`
"""
function rotate!(g::Geom; x::Vec{FT}, y::Vec{FT}, z::Vec{FT}) where {FT}
    @inbounds mat = SMatrix{3,3,FT}(x[1], x[2], x[3], y[1], y[2], y[3], z[1], z[2], z[3])
    trans = CT.LinearMap(mat)
    transform!(g, trans)
end

"""
    translate!(g::Geom, v::Vec)

Translate the geometry `g` by vector `v`.

# Arguments
- `g`: The geometry to be translated.
- `v`: The vector by which the mesh is to be translated.

# Examples
```jldoctest
julia> m = Rectangle();

julia> v = Vec(2.0, 1.5, 3.0);

julia> translate!(m, v);
```
"""
function translate!(g::Geom, v::Vec)
    trans = CT.Translation(v)
    vertices(g) .= trans.(vertices(g))
    return nothing
end
