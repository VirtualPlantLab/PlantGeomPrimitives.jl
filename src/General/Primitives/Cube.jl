"""
    Cube(type = Mesh;length = 1.0, width = 1.0, height = 1.0, hollow = false, n = hollow ? 8 : 12)

Create a hollow or solid cube with dimensions given by `length`, `width` and `height`,
discretized into 8 (if hollow) or 12 triangles (`type = Mesh`) or `n` points (`type = Points`).
The cube is centered at the origin with the base on the XY plane. A hollow cube is missing
both bases.

## Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length`: The length of the cube.
- `width`: The width of the cube.
- `height`: The height of the cube.
- `n`: The number of points to generate. Should be a multiple of 4 (if hollow) or 6. Ignored if
  `type <: Volume` or `type <: Mesh`.
- `hollow`: Whether the cube is hollow or solid. Default is false. Ignored if `type <: Volume`

## Examples
```jldoctest
julia> Cube(;length = 1.0, width = 1.0, height = 1.0);

julia> Cube(Mesh; length = 1.0, width = 1.0, height = 1.0, hollow = false);

julia> Cube(Points; length = 1.0, width = 1.0, height = 1.0, hollow = false, n = 12);

julia> Cube(Mesh; length = 1.0, width = 1.0, height = 1.0, hollow = true);

julia> Cube(Points; length = 1.0, width = 1.0, height = 1.0, hollow = true, n = 8);

julia> Cube(Volume; length = 1.0, width = 1.0, height = 1.0);
```
"""
function Cube(type::DataType = Mesh;
              length = 1.0,
              width = 1.0,
              height = 1.0,
              hollow::Bool = false,
              n::Int = hollow ? 8 : 12)
    if type <: Mesh
        CubeMesh(length = length, width = width, height = height, hollow = hollow)
    elseif type <: Points
        CubePoints(length = length, width = width, height = height, hollow = hollow, n = n)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("`type` must inherit from Mesh, Points or Volume")
    end
end

# See Mesh/Primitives/HollowCube.jl and Mesh/Primitives/SolidCube.jl
function CubeMesh(; hollow, kwargs...)
    hollow ? HollowCubeMesh(;kwargs...) : SolidCubeMesh(;kwargs...)
end

# See Points/Primitives/HollowCube.jl and Points/Primitives/SolidCube.jl
function CubePoints(; hollow, kwargs...)
    hollow ? HollowCubePoints(kwargs...) : SolidCubePoints(kwargs...)
end
