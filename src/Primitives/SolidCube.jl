### This file contains public API ###

all_solid_cube_normals(::Type{FT}) where {FT} = (
    Vec{FT}(0, 0, -1),
    Vec{FT}(0, 0, -1),
    Vec{FT}(0, -1, 0),
    Vec{FT}(0, -1, 0),
    Vec{FT}(1, 0, 0),
    Vec{FT}(1, 0, 0),
    Vec{FT}(0, 1, 0),
    Vec{FT}(0, 1, 0),
    Vec{FT}(-1, 0, 0),
    Vec{FT}(-1, 0, 0),
    Vec{FT}(0, 0, 1),
    Vec{FT}(0, 0, 1),
)
struct SolidCubeNormals{VT,TT}
    trans::TT
    normals::VT
end
function SolidCubeNormals(trans)
    FT = eltype(trans)
    SolidCubeNormals(trans, all_solid_cube_normals(FT))
end
function iterate(
    c::SCN,
)::Union{Nothing,Tuple{eltype(SCN),Int64}} where {SCN<:SolidCubeNormals}
    (@inbounds normalize(c.trans * c.normals[1]), 2)
end
function iterate(
    c::SCN,
    i,
)::Union{Nothing,Tuple{eltype(SCN),Int64}} where {SCN<:SolidCubeNormals}
    i > 12 ? nothing : (@inbounds normalize(c.trans * c.normals[i]), i + 1)
end
length(c::SolidCubeNormals) = 12
function eltype(::Type{SolidCubeNormals{VT,TT}}) where {VT,TT}
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
    global all_solid_cube_vertices
    all_solid_cube_vertices(::Type{FT}) where {FT} = (
        v1(FT), v4(FT), v3(FT), # 1, 4, 3
        v1(FT), v3(FT), v2(FT), # 1, 3, 2
        v1(FT), v5(FT), v8(FT), # 1, 5, 8
        v1(FT), v8(FT), v4(FT), # 1, 8, 4
        v4(FT), v8(FT), v7(FT), # 4, 8, 7
        v4(FT), v7(FT), v3(FT), # 4, 7, 3
        v3(FT), v7(FT), v6(FT), # 3, 7, 6
        v3(FT), v6(FT), v2(FT), # 3, 6, 2
        v2(FT), v6(FT), v5(FT), # 2, 6, 5
        v2(FT), v5(FT), v1(FT), # 2, 5, 1
        v5(FT), v6(FT), v7(FT), # 5, 6, 7
        v5(FT), v7(FT), v8(FT)  # 5, 7, 8
    )
end

struct SolidCubeVertices{VT,TT}
    trans::TT
    verts::VT
end
function SolidCubeVertices(trans)
    FT = eltype(trans.linear)
    SolidCubeVertices(trans, all_solid_cube_vertices(FT))
end
function iterate(c::SCV,)::Union{Nothing,Tuple{eltype(SCV),Int64}} where {SCV<:SolidCubeVertices}
    (@inbounds c.trans(c.verts[1]), 2)
end
function iterate(c::SCV,i,)::Union{Nothing,Tuple{eltype(SCV),Int64}} where {SCV<:SolidCubeVertices}
    i > 36 ? nothing : (@inbounds c.trans(c.verts[i]), i + 1)
end
length(c::SolidCubeVertices) = 36
function eltype(::Type{SolidCubeVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end



"""
    SolidCube(;length = 1.0, width = 1.0, height = 1.0)

Create a solid cube with dimensions given by `length`, `width` and `height`,
standard location and orientation.

## Examples
```jldoctest
julia> SolidCube(;length = 1.0, width = 1.0, height = 1.0);
```
"""
function SolidCube(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where {FT}
    SolidCube(LinearMap(SDiagonal(height / FT(2), width / FT(2), length)))
end

# Create a solid_cube from affine transformation
SolidCube(trans::AbstractAffineMap) =
    Primitive(trans, SolidCubeVertices, SolidCubeNormals)

# Create a solid_cube from affine transformation and add it in-place to existing mesh
SolidCube!(m::Mesh, trans::AbstractAffineMap) =
    Primitive!(m, trans, SolidCubeVertices, SolidCubeNormals)
