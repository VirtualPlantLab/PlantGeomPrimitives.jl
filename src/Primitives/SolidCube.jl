### This file contains public API ###

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
        v1(FT), v3(FT), v4(FT), # 1, 3, 4
        v1(FT), v2(FT), v3(FT), # 1, 2, 3
        v1(FT), v8(FT), v5(FT), # 1, 8, 5
        v1(FT), v4(FT), v8(FT), # 1, 4, 8
        v4(FT), v7(FT), v8(FT), # 4, 7, 8
        v4(FT), v3(FT), v7(FT), # 4, 3, 7
        v3(FT), v6(FT), v7(FT), # 3, 6, 7
        v3(FT), v2(FT), v6(FT), # 3, 2, 6
        v2(FT), v5(FT), v6(FT), # 2, 5, 6
        v2(FT), v1(FT), v5(FT), # 2, 1, 5
        v5(FT), v7(FT), v6(FT), # 5, 7, 6
        v5(FT), v8(FT), v7(FT)  # 5, 8, 7
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
function Base.iterate(c::SCV,)::Union{Nothing,Tuple{eltype(SCV),Int64}} where {SCV<:SolidCubeVertices}
    (@inbounds c.trans(c.verts[1]), 2)
end
function Base.iterate(c::SCV,i,)::Union{Nothing,Tuple{eltype(SCV),Int64}} where {SCV<:SolidCubeVertices}
    i > 36 ? nothing : (@inbounds c.trans(c.verts[i]), i + 1)
end
Base.length(c::SolidCubeVertices) = 36
function Base.eltype(::Type{SolidCubeVertices{VT,TT}}) where {VT,TT}
    @inbounds VT.types[1]
end



"""
    SolidCube(;length = 1.0, width = 1.0, height = 1.0)

Create a solid cube with dimensions given by `length`, `width` and `height`,
standard location and orientation.

# Arguments
- `length = 1.0`: The length of the cube.
- `width = 1.0`: The width of the base of the cube.
- `height = 1.0`: The height of the base of the cube.

# Examples
```jldoctest
julia> SolidCube(;length = 1.0, width = 1.0, height = 1.0);
```
"""
function SolidCube(; length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where {FT}
    SolidCube(CT.LinearMap(CT.SDiagonal(height / FT(2), width / FT(2), length)))
end

# Create a solid_cube from affine transformation
SolidCube(trans::CT.AbstractAffineMap) = Primitive(trans, SolidCubeVertices)

# Create a solid_cube from affine transformation and add it in-place to existing mesh
SolidCube!(m::Mesh, trans::CT.AbstractAffineMap) = Primitive!(m, trans, SolidCubeVertices)
