### This file contains public API ###

# Modify affine transformation so that it applies to normal vectors
function normal_trans(trans)
    transpose(inv(trans.linear))
end

# Rotations, translations and scaling of geoms

# In-place affine transformation of a geometry (transform vertices and recalculate
# relevant properties if requested). Only update properties if needed
function transform!(geom::Mesh, trans::CT.AbstractAffineMap; update_properties::Bool = true)
    # Apply transformation to all vertices and overwrite them
    vertices(geom) .= trans.(vertices(geom))
    # For every geometry-related property, recalculate it and overwrite the existing one
    if update_properties
        has_normals(geom) && (normals(geom) .= calculate_normals(geom))
        has_edges(geom) && (edges(geom) .= calculate_edges(geom))
        has_areas(geom) && (areas(geom) .= calculate_areas(geom))
        has_inclinations(geom) && (inclinations(geom) .= calculate_inclinations(geom))
        has_orientations(geom) && (orientations(geom) .= calculate_orientations(geom))
    end
    return nothing
end
function transform!(geom::Segments, trans::CT.AbstractAffineMap; update_properties::Bool = true)
    # Apply transformation to all vertices and overwrite them
    vertices(geom) .= trans.(vertices(geom))
    # For every geometry-related property, recalculate it and overwrite the existing one
    if update_properties
        has_areas(geom) && (areas(geom) .= calculate_areas(geom))
        has_inclinations(geom) && (inclinations(geom) .= calculate_inclinations(geom))
        has_orientations(geom) && (orientations(geom) .= calculate_orientations(geom))
        has_lengths(geom) && (lengths(geom) .= calculate_lengths(geom))
    end
    return nothing
end
function transform!(geom::Points, trans::CT.AbstractAffineMap; update_properties::Bool = true)
    # Apply transformation to all vertices
    @simd for i in eachindex(vertices(geom))
        @inbounds vertices(geom)[i] = trans(vertices(geom)[i])
    end
    # Apply transformation to all normals
    if trans isa CT.LinearMap
        norm_trans = normal_trans(trans)
        @simd for i in eachindex(normals(geom))
            @inbounds normals(geom)[i] = norm_trans*normals(geom)[i]
        end
        # Apply transformation to all areas
        area_trans = L.det(trans.linear)
        @simd for i in eachindex(normals(geom))
        @inbounds areas(geom)[i] = area_trans*areas(geom)[i]
    end
    end

    # For every geometry-related property, recalculate it and overwrite the existing one
    if update_properties
        has_inclinations(geom) && (inclinations(geom) .= calculate_inclinations(geom))
        has_orientations(geom) && (orientations(geom) .= calculate_orientations(geom))
    end
    return nothing
end

"""
    scale!(geom::Geom, vec::Vec; update_properties)

Scale a geom along the three axes provided by `vec`.

# Arguments
- `geom`: The geometry object to be scaled (`Points`, `Segments` or `Mesh`).
- `vec`: A vector containing the scaling factors for the x, y, and z axes.
- `update_properties`: If `true`, the properties of the geometry will be recalculated after scaling. Default is `true`.

# Examples
```jldoctest
julia> m = Rectangle();

julia> scaling_vector = Vec(2.0, 1.5, 3.0);

julia> scale!(m, scaling_vector);
```
"""
function scale!(geom::Geom, vec::Vec; update_properties::Bool = true)
    trans = CT.LinearMap(CT.SDiagonal(vec...))
    transform!(geom, trans; update_properties=update_properties)
end

"""
    rotatex!(geom::Geom, θ; update_properties)

Rotate a geom around the x axis by angle `θ`.

# Arguments
- `geom`: The geometry to be rotated.
- `θ`: Angle of rotation in radians.
- `update_properties`: If `true`, the properties of the geometry will be recalculated after rotation. Default is `true`.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatex!(m, θ)
```
"""
function rotatex!(geom::Geom, θ; update_properties::Bool = true)
    trans = CT.LinearMap(Rotations.RotX(θ))
    transform!(geom, trans; update_properties = update_properties)
end

"""
    rotatey!(geom::Geom, θ; update_properties)

Rotate a geom around the y axis by angle `θ`.

# Arguments
- `geom`: The geometry to be rotated.
- `θ`: Angle of rotation in radians.
- `update_properties`: If `true`, the properties of the geometry will be recalculated after rotation. Default is `true`.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatey!(m, θ);
```
"""
function rotatey!(geom::Geom, θ; update_properties::Bool = true)
    trans = CT.LinearMap(Rotations.RotY(θ))
    transform!(geom, trans; update_properties = update_properties)
end

"""
    rotatez!(geom::Geom, θ; update_properties::Bool = true)

Rotate a geom around the z axis by angle `θ`.

# Arguments
- `geom`: The geometry to be rotated.
- `θ`: Angle of rotation in radians.
- `update_properties`: If `true`, the properties of the geometry will be recalculated after rotation. Default is `true`.

# Examples
```jldoctest
julia> m = Rectangle();

julia> θ = pi/2;

julia> rotatez!(m, θ);
```
"""
function rotatez!(geom::Geom, θ; update_properties::Bool = true)
    trans = CT.LinearMap(Rotations.RotZ(θ))
    transform!(geom, trans; update_properties = update_properties)
end

"""
    rotate!(geom::Geom; x::Vec, y::Vec, z::Vec, update_properties::Bool = true)

Rotate a geom to a new coordinate system given by `x`, `y` and `z`.

# Arguments
- `geom`: The geometry to be rotated.
- `x`: A vector representing the new x-axis.
- `y`: A vector representing the new y-axis.
- `z`: A vector representing the new z-axis.
- `update_properties`: If `true`, the properties of the geometry will be recalculated after rotation. Default is `true`.

# Examples
```jldoctest
julia> m = Rectangle();

julia> x = Vec(1.0, 0.0, 0.0);

julia> y = Vec(0.0, 1.0, 0.0);

julia> z = Vec(0.0, 0.0, -1.0);

julia> rotate!(m; x, y, z);
```
"""
function rotate!(geom::Geom; x::Vec{FT}, y::Vec{FT}, z::Vec{FT}, update_properties::Bool = true) where {FT}
    @inbounds mat = SMatrix{3,3,FT}(x[1], x[2], x[3], y[1], y[2], y[3], z[1], z[2], z[3])
    trans = CT.LinearMap(mat)
    transform!(geom, trans; update_properties = update_properties)
end

"""
    translate!(geom::Geom, v::Vec; update_properties::Bool = true)

Translate the geom by vector `v`.

# Arguments
- `geom`: The geometry to be translated.
- `v`: The vector by which the mesh is to be translated.
- `update_properties`: If `true`, the properties of the geometry will be recalculated after translation. Default is `true`.

# Examples
```jldoctest
julia> m = Rectangle();

julia> v = Vec(2.0, 1.5, 3.0);

julia> translate!(m, v);
```
"""
function translate!(geom::Geom, v::Vec; update_properties::Bool = true)
    trans = CT.Translation(v)
    transform!(geom, trans; update_properties = update_properties)
    return nothing
end
