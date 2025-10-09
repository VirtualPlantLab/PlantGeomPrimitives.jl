# Cones

"""
    Cone(type = Mesh;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = false)

Create a hollow or solid cone with dimensions given by `length`, `width` and `height`,
discretized into `n` triangles (`type = Mesh`) or `n` points (`type = Points`). The base of
the cone is centered at the origin on the XY plane. A hollow cone is missing the base.

# Arguments
- `type`: The type of the cone representation (Mesh or Points). Default is Mesh.
- `length`: The length of the cone (distance between base and apex).
- `width`: The width of the base of the cone.
- `height`: The height of the base of the cone.
- `n`: The number of triangles or points to generate. Must be even.Ignored if `type <: Volume`.
- `hollow`: Whether the cone is hollow or solid. Default is false (solid). Ignored if `type <: Volume`.

# Examples
```jldoctest
julia> Cone(;length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Cone(Mesh;length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Cone(Points;length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Cone(Mesh;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = true);

julia> Cone(Points;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = true);

julia> Cone(Volume; length = 1.0, width = 1.0, height = 1.0);
```
"""
function Cone(type::DataType = Mesh;
              length = 1.0,
              width = 1.0,
              height = 1.0,
              n::Int = 40,
              hollow::Bool = false)
    if type <: Mesh
        ConeMesh(length = length, width = width, height = height, hollow = hollow)
    elseif type <: Points
        ConePoints(length = length, width = width, height = height, hollow = hollow, n = n)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("`type` must inherit from Mesh, Points or Volume")
    end
end

# See Mesh/Primitives/HollowCone.jl and Mesh/Primitives/SolidCone.jl
function ConeMesh(; hollow, kwargs...)
    hollow ? HollowConeMesh(;kwargs...) : SolidConeMesh(;kwargs...)
end

# See Points/Primitives/HollowCone.jl and Points/Primitives/SolidCone.jl
function ConePoints(; hollow, kwargs...)
    hollow ? HollowConePoints(kwargs...) : SolidConePoints(kwargs...)
end
