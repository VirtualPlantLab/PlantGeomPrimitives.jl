### This file contains public API ###

all_hollow_cube_normals(::Type{FT}) where {FT} = (
    Vec{FT}(0, -1, 0),
    Vec{FT}(0, -1, 0),
    Vec{FT}(1, 0, 0),
    Vec{FT}(1, 0, 0),
    Vec{FT}(0, 1, 0),
    Vec{FT}(0, 1, 0),
    Vec{FT}(-1, 0, 0),
    Vec{FT}(-1, 0, 0),
)
struct HollowCubeNormals{VT,TT}
    trans::TT
    normals::VT
end
function HollowCubeNormals(trans)
    FT = eltype(trans)
    HollowCubeNormals(trans, all_hollow_cube_normals(FT))
end
function iterate(
    c::HCN,
)::Union{Nothing,Tuple{eltype(HCN),Int64}} where {HCN<:HollowCubeNormals}
    (@inbounds normalize(c.trans * c.normals[1]), 2)
end
function iterate(
    c::HCN,
    i,
)::Union{Nothing,Tuple{eltype(HCN),Int64}} where {HCN<:HollowCubeNormals}
    i > 8 ? nothing : (@inbounds normalize(c.trans * c.normals[i]), i + 1)
end
length(c::HollowCubeNormals) = 8
function eltype(::Type{HollowCubeNormals{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end


let
    v1(::Type{FT}) where FT = Vec{FT}(-1, -1, 0)
    v2(::Type{FT}) where FT = Vec{FT}(-1, 1, 0)
    v3(::Type{FT}) where FT = Vec{FT}(1, 1, 0)
    v4(::Type{FT}) where FT = Vec{FT}(1, -1, 0)
    v5(::Type{FT}) where FT = Vec{FT}(-1, -1, 1)
    v6(::Type{FT}) where FT = Vec{FT}(-1, 1, 1)
    v7(::Type{FT}) where FT = Vec{FT}(1, 1, 1)
    v8(::Type{FT}) where FT = Vec{FT}(1, -1, 1)
    global all_hollow_cube_vertices
    all_hollow_cube_vertices(::Type{FT}) where {FT} = (
        v1(FT), v5(FT), v8(FT),  # 1, 5, 8
        v1(FT), v8(FT), v4(FT),  # 1, 8, 4
        v4(FT), v8(FT), v7(FT),  # 4, 8, 7
        v4(FT), v7(FT), v3(FT),  # 4, 7, 3
        v3(FT), v7(FT), v6(FT),  # 3, 7, 6
        v3(FT), v6(FT), v2(FT),  # 3, 6, 2
        v2(FT), v6(FT), v5(FT),  # 2, 6, 5
        v2(FT), v5(FT), v1(FT)   # 2, 5, 1
    )
end

struct HollowCubeVertices{VT,TT}
    trans::TT
    verts::VT
end
function HollowCubeVertices(trans)
    FT = eltype(trans.linear)
    HollowCubeVertices(trans, all_hollow_cube_vertices(FT))
end
function iterate(c::HCV)::Union{Nothing,Tuple{eltype(HCV),Int64}} where {HCV<:HollowCubeVertices}
    (@inbounds c.trans(c.verts[1]), 2)
end
function iterate(c::HCV,i)::Union{Nothing,Tuple{eltype(HCV),Int64}} where {HCV<:HollowCubeVertices}
    i > 24 ? nothing : (@inbounds c.trans(c.verts[i]), i + 1)
end
length(c::HollowCubeVertices) = 24
function eltype(::Type{HollowCubeVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end

"""
    HollowCube(;length = 1.0, width = 1.0, height = 1.0)

Create a hollow cube (a prism) with dimensions given by `length`, `width` and `height`,
standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cube.
- `width = 1.0`: The width of the base of the cube.
- `height = 1.0`: The height of the base of the cube.

## Examples
```jldoctest
julia> HollowCube(;length = 1.0, width = 1.0, height = 1.0)
Mesh{StaticArraysCore.SVector{3, Float64}}(StaticArraysCore.SVector{3, Float64}[[-0.5, -0.5, 0.0], [-0.5, -0.5, 1.0], [0.5, -0.5, 1.0], [-0.5, -0.5, 0.0], [0.5, -0.5, 1.0], [0.5, -0.5, 0.0], [0.5, -0.5, 0.0], [0.5, -0.5, 1.0], [0.5, 0.5, 1.0], [0.5, -0.5, 0.0]  …  [-0.5, 0.5, 1.0], [0.5, 0.5, 0.0], [-0.5, 0.5, 1.0], [-0.5, 0.5, 0.0], [-0.5, 0.5, 0.0], [-0.5, 0.5, 1.0], [-0.5, -0.5, 1.0], [-0.5, 0.5, 0.0], [-0.5, -0.5, 1.0], [-0.5, -0.5, 0.0]], StaticArraysCore.SVector{3, Float64}[[0.0, -1.0, 0.0], [0.0, -1.0, 0.0], [1.0, 0.0, 0.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 1.0, 0.0], [-1.0, 0.0, 0.0], [-1.0, 0.0, 0.0]])
```
"""
function HollowCube(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where {FT}
    HollowCube(LinearMap(SDiagonal(height / FT(2), width / FT(2), length)))
end

# Create a hollow_cube from affine transformation
HollowCube(trans::AbstractAffineMap) =
    Primitive(trans, HollowCubeVertices, HollowCubeNormals)

# Create a hollow_cube from affine transformation and add it in-place to existing mesh
HollowCube!(m::Mesh, trans::AbstractAffineMap) =
    Primitive!(m, trans, HollowCubeVertices, HollowCubeNormals)
