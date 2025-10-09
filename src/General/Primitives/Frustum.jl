"""
    Frustum(type = Mesh; length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 40, hollow = false)

Create a hollow or solid frustum with dimensions given by `length`, `width`, `height` and `ratio`
between the radii of the top and bottom bases. The frustum is
discretized into `n` triangles (`type = Mesh`) or `n` points (`type = Points`). The frustum is
centered at the origin with the lower base on the XY plane. A hollow frustum is missing both bases.


## Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length`: The length of the frustum.
- `width`: The width of the frustum.
- `height`: The height of the frustum.
- `ratio = 1.0`: The ratio between the top and bottom base radii.
- `n`: The number of triangles or points to generate. Must be even. Ignored if `type <: Volume`.
- `hollow`: Whether the frustum is hollow or solid. Default is false. Ignored if `type <: Volume`.


## Examples
```jldoctest
julia> Frustum(; length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Frustum(Mesh; length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Frustum(Points; length = 1.0, width = 1.0, height = 1.0, n = 40);

julia> Frustum(Mesh;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = true);

julia> Frustum(Points;length = 1.0, width = 1.0, height = 1.0, n = 40, hollow = true);

julia> Frustum(Volume; length = 1.0, width = 1.0, height = 1.0);
```
"""
function Frustum(type::DataType = Mesh;
                  length = 1.0,
                  width = 1.0,
                  height = 1.0,
                  ratio = 1.0,
                  n::Int = 40,
                  hollow::Bool = false)
    if type <: Mesh
        FrustumMesh(length = length, width = width, height = height, ratio = ratio, hollow = hollow)
    elseif type <: Points
        FrustumPoints(length = length, width = width, height = height, ratio = ratio, hollow = hollow, n = n)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("`type` must inherit from Mesh, Points or Volume")
    end
end

# See Mesh/Primitives/HollowFrustum.jl and Mesh/Primitives/SolidFrustum.jl
function FrustumMesh(; hollow, kwargs...)
    hollow ? HollowFrustumMesh(;kwargs...) : SolidFrustumMesh(;kwargs...)
end

# See Points/Primitives/HollowFrustum.jl and Points/Primitives/SolidFrustum.jl
function FrustumPoints(; hollow, kwargs...)
    hollow ? HollowFrustumPoints(kwargs...) : SolidFrustumPoints(kwargs...)
end
