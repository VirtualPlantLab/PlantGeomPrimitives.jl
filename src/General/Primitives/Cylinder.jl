# Cylinder

"""
    Cylinder(type = Mesh;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = false)

Create a hollow or solid cylinder with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (`type = Mesh`) or `n` points (`type = Points`). The base of
the cylinder is centered at the origin on the XY plane. A hollow cylinder is missing both bases.

## Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length`: The length of the cylinder.
- `width`: The width of the cylinder.
- `height`: The height of the cylinder.
- `n`: The number of triangles or points to generate. Must be even. Ignored if `type <: Volume`.
- `hollow`: Whether the cylinder is hollow or solid. Default is false. Ignored if `type <: Volume`.


# Examples
```jldoctest
julia> Cylinder(; length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Cylinder(Mesh; length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Cylinder(Points; length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Cylinder(Mesh;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = true);

julia> Cylinder(Volume; length = 1.0, width = 1.0, height = 1.0);
```
"""
function Cylinder(type::DataType = Mesh;
                  length = 1.0,
                  width = 1.0,
                  height = 1.0,
                  n::Int = 80,
                  hollow::Bool = false)
    if type <: Mesh
        CylinderMesh(length = length, width = width, height = height, hollow = hollow)
    elseif type <: Points
        CylinderPoints(length = length, width = width, height = height, hollow = hollow, n = n)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("`type` must inherit from Mesh, Points or Volume")
    end
end

# See Mesh/Primitives/HollowCylinder.jl and Mesh/Primitives/SolidCylinder.jl
function CylinderMesh(; hollow, kwargs...)
    hollow ? HollowCylinderMesh(;kwargs...) : SolidCylinderMesh(;kwargs...)
end

# See Points/Primitives/HollowCylinder.jl and Points/Primitives/SolidCylinder.jl
function CylinderPoints(; hollow, kwargs...)
    hollow ? HollowCylinderPoints(kwargs...) : SolidCylinderPoints(kwargs...)
end
