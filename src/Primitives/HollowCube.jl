### This file contains public API ###

const all_hollow_cube_faces = (
    Face(1, 5, 8),
    Face(1, 8, 4),
    Face(4, 8, 7),
    Face(4, 7, 3),
    Face(3, 7, 6),
    Face(3, 6, 2),
    Face(2, 6, 5),
    Face(2, 5, 1),
)
struct HollowCubeFaces end
iterate(c::HollowCubeFaces) = (@inbounds all_hollow_cube_faces[1], 2)
iterate(c::HollowCubeFaces, i) =
    i > 8 ? nothing : (@inbounds all_hollow_cube_faces[i], i + 1)
length(c::HollowCubeFaces) = 8
eltype(::Type{HollowCubeFaces}) = Face


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


all_hollow_cube_vertices(::Type{FT}) where {FT} = (
    Vec{FT}(-1, -1, 0),
    Vec{FT}(-1, 1, 0),
    Vec{FT}(1, 1, 0),
    Vec{FT}(1, -1, 0),
    Vec{FT}(-1, -1, 1),
    Vec{FT}(-1, 1, 1),
    Vec{FT}(1, 1, 1),
    Vec{FT}(1, -1, 1),
)
struct HollowCubeVertices{VT,TT}
    trans::TT
    verts::VT
end
function HollowCubeVertices(trans)
    FT = eltype(trans.linear)
    HollowCubeVertices(trans, all_hollow_cube_vertices(FT))
end
function iterate(
    c::HCV,
)::Union{Nothing,Tuple{eltype(HCV),Int64}} where {HCV<:HollowCubeVertices}
    (@inbounds c.trans(c.verts[1]), 2)
end
function iterate(
    c::HCV,
    i,
)::Union{Nothing,Tuple{eltype(HCV),Int64}} where {HCV<:HollowCubeVertices}
    i > 8 ? nothing : (@inbounds c.trans(c.verts[i]), i + 1)
end
length(c::HollowCubeVertices) = 8
function eltype(::Type{HollowCubeVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end

"""
    HollowCube(;length = 1.0, width = 1.0, height = 1.0)

Create a hollow cube with dimensions given by `length`, `width` and `height`,
standard location and orientation.

## Examples
```jldoctest
julia> HollowCube(;length = 1.0, width = 1.0, height = 1.0);
```
"""
function HollowCube(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where {FT}
    HollowCube(LinearMap(SDiagonal(height / FT(2), width / FT(2), length)))
end

# Create a hollow_cube from affine transformation
HollowCube(trans::AbstractAffineMap) =
    Primitive(trans, HollowCubeVertices, HollowCubeNormals, HollowCubeFaces)

# Create a hollow_cube from affine transformation and add it in-place to existing mesh
HollowCube!(m::Mesh, trans::AbstractAffineMap) =
    Primitive!(m, trans, HollowCubeVertices, HollowCubeNormals, HollowCubeFaces)
