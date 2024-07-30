### This file contains public API ###

# Rotations, translations and scaling of triangular meshes

# In-place affine transformation of a mesh
function transform!(m::Mesh, trans::AbstractAffineMap)
    vertices(m) .= trans.(vertices(m))
    norm_trans   = transpose(inv(trans.linear))
    @simd for i = 1:length(normals(m))
        @inbounds normals(m)[i] = normalize(norm_trans*normals(m)[i])
    end
    return nothing
end


"""
    scale!(m::Mesh, Vec)

Scale a mesh `m` along the three axes provided by `vec`
"""
function scale!(m::Mesh, vec::Vec)
    trans = LinearMap(SDiagonal(vec...))
    transform!(m, trans)
end

"""
    rotatex!(m::Mesh, θ)

Rotate a mesh `m` around the x axis by `θ` rad.
"""
function rotatex!(m::Mesh, θ)
    trans = LinearMap(RotX(θ))
    transform!(m, trans)
end

"""
    rotatey!(m::Mesh, θ)

Rotate a mesh `m` around the y axis by `θ` rad.
"""
function rotatey!(m::Mesh, θ)
    trans = LinearMap(RotY(θ))
    transform!(m, trans)
end

"""
    rotatez!(m::Mesh, θ)

Rotate a mesh `m` around the z axis by `θ` rad.
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

Translate the mesh `m` by vector `v`
"""
function translate!(m::Mesh, v::Vec)
    trans = Translation(v)
    vertices(m) .= trans.(vertices(m))
    return nothing
end
