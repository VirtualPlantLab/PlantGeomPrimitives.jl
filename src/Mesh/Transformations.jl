### This file contains public API ###

# Rotations, translations and scaling of triangular meshes

# In-place affine transformation of a mesh
function transform!(m::Mesh, trans::AbstractAffineMap)
    vertices(m) .= trans.(vertices(m))
    norm_trans   = transpose(inv(trans.linear))
    @simd for i in eachindex(normals(m))
        @inbounds normals(m)[i] = normalize(norm_trans*normals(m)[i])
    end
    return nothing
end


"""
    scale!(m::Mesh, vec::Vec)

Scale a mesh `m` along the three axes provided by `vec`.

# Arguments
- `m`: The mesh to be scaled.
- `vec`: A vector containing the scaling factors for the x, y, and z axes.

# Examples
```jldoctest
julia> m = Rectangle();

julia> scaling_vector = Vec(2.0, 1.5, 3.0);

julia> scale!(m, scaling_vector);
```
"""
function scale!(m::Mesh, vec::Vec)
    trans = LinearMap(SDiagonal(vec...))
    transform!(m, trans)
end

"""
    rotatex!(m::Mesh, θ)

Rotate a mesh `m` around the x axis by angle `θ`.

# Arguments
- `m`: The mesh to be scaled.
- `θ`: Angle of rotation in radians.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatex!(m, θ)
```
"""
function rotatex!(m::Mesh, θ)
    trans = LinearMap(RotX(θ))
    transform!(m, trans)
end

"""
    rotatey!(m::Mesh, θ)

Rotate a mesh `m` around the y axis by angle `θ`.

# Arguments
- `m`: The mesh to be scaled.
- `θ`: Angle of rotation in radians.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatey!(m, θ);
```
"""
function rotatey!(m::Mesh, θ)
    trans = LinearMap(RotY(θ))
    transform!(m, trans)
end

"""
    rotatez!(m::Mesh, θ)

Rotate a mesh `m` around the z axis by angle `θ`.

# Arguments
- `m`: The mesh to be scaled.
- `θ`: Angle of rotation in radians.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatez!(m, θ);
```
"""
function rotatez!(m::Mesh, θ)
    trans = LinearMap(RotZ(θ))
    transform!(m, trans)
end

"""
    rotate!(m::Mesh; x::Vec, y::Vec, z::Vec)

Rotate a mesh `m` to a new coordinate system given by `x`, `y` and `z`
"""
function rotate!(m::Mesh; x::Vec{FT}, y::Vec{FT}, z::Vec{FT}) where {FT}
    @inbounds mat = SMatrix{3,3,FT}(x[1], x[2], x[3], y[1], y[2], y[3], z[1], z[2], z[3])
    trans = LinearMap(mat)
    transform!(m, trans)
end

"""
    translate!(m::Mesh, v::Vec)

Translate the mesh `m` by vector `v`.

# Arguments
- `m`: The mesh to be translated.
- `v`: The vector by which the mesh is to be translated.

# Examples
```jldoctest
julia> m = Rectangle();

julia> v = Vec(2.0, 1.5, 3.0);

julia> translate!(m, v);
```
"""
function translate!(m::Mesh, v::Vec)
    trans = Translation(v)
    vertices(m) .= trans.(vertices(m))
    return nothing
end
