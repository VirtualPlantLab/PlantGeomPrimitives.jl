### This file contains public API ###

"""
    Mesh

A struct representing a 3D mesh. Every three vertices represents a triangle.

# Fields
- `vertices`: A vector containing the vertices of the mesh.
- `normals`: A vector containing the normals of the mesh.

# Example
```jldoctest; output = false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)]
n = [Vec(0.0, 0.0, 1.0)]
mesh = Mesh(v, n)

# output
Mesh{StaticArraysCore.SVector{3, Float64}}(StaticArraysCore.SVector{3, Float64}[[0.0, 0.0, 0.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]], StaticArraysCore.SVector{3, Float64}[[0.0, 0.0, 1.0]])
```
"""
struct Mesh{VT}
    vertices::Vector{VT}
    normals::Vector{VT}
end

"""
    eltype(mesh::Mesh)

Extract the the type used to represent coordinates in a mesh (e.g., `Float64`).

# Fields
- `mesh`: The mesh from which to extract the element type.

# Example
```jldoctest; output = false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)]
n = [Vec(0.0, 0.0, 1.0)]
mesh = Mesh(v, n)
eltype(mesh)

# output
Float64
```
"""
eltype(m::Mesh{VT}) where VT = eltype(VT)
eltype(::Type{Mesh{VT}}) where VT = eltype(VT)


# Accessor functions
"""
    ntriangles(mesh)

Extract the number of triangles in a mesh.

# Arguments
- `mesh`: The mesh from which to extract the number of triangles.

# Returns
The number of triangles in the mesh as an integer.

# Example
```jldoctest; output = false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)]
n = [Vec(0.0, 0.0, 1.0)]
mesh = Mesh(v, n)
ntriangles(mesh)

# output
1
```
"""
ntriangles(mesh::Mesh) = length(mesh.normals)

"""
    nvertices(mesh)

The number of vertices in a mesh.

# Arguments
- `mesh`: The mesh from which to retrieve the number of vertices.

# Returns
The number of vertices in the mesh as an integer.

# Example
```jldoctest; output = false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)]
n = [Vec(0.0, 0.0, 1.0)]
mesh = Mesh(v, n)
nvertices(mesh)

# output
3
```
"""
nvertices(mesh::Mesh) = length(mesh.vertices)

# Accessor functions
"""
    vertices(mesh::Mesh)

Retrieve the vertices of a mesh.

# Arguments
- `mesh`: The mesh from which to retrieve the vertices.

# Returns
A vector containing the vertices of the mesh.

# Example
```jldoctest; output = false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)]
n = [Vec(0.0, 0.0, 1.0)]
mesh = Mesh(v, n)
vertices(mesh)

# output
3-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [0.0, 0.0, 0.0]
 [0.0, 1.0, 0.0]
 [1.0, 0.0, 0.0]
```
"""
vertices(mesh::Mesh) = mesh.vertices

"""
    normals(mesh::Mesh)

Retrieve the normals of a mesh.

# Arguments
- `mesh`: The mesh from which to retrieve the normals.

# Returns
A vector containing the normals of the mesh.

# Example
```jldoctest; output=false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)]
n = [Vec(0.0, 0.0, 1.0)]
mesh = Mesh(v, n)
normals(mesh)

# output
1-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [0.0, 0.0, 1.0]
```
"""
normals(mesh::Mesh) = mesh.normals

"""
    get_triangle(m::Mesh, i)

Retrieve the vertices for the i-th triangle in a mesh.

# Arguments
- `mesh`: The mesh from which to retrieve the triangle.
- `i`: The index of the triangle to retrieve.

# Returns
A vector containing the three vertices defining the i-th triangle.

# Example
```jldoctest; output = false
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0),
     Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(0.0, 0.0, 1.0)]
n = [Vec(0.0, 0.0, 1.0),Vec(0.0, 0.0, -1.0)]
m = Mesh(v, n)
get_triangle(m, 2)

# output
3-element view(::Vector{StaticArraysCore.SVector{3, Float64}}, [4, 5, 6]) with eltype StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 [0.0, 0.0, 0.0]
 [0.0, 1.0, 0.0]
 [0.0, 0.0, 1.0]
```
"""
function get_triangle(m::Mesh, i)
    v = vertices(m)
    get_triangle(v, i)
end

# Internal function to retrieve the vertices of the i-th triangle (give list of vertices)
function get_triangle(v::AbstractVector, i)
    i1 = (i - 1)*3 + 1
    @view v[SVector{3,Int}(i1, i1+1, i1+2)]
end

"""
    Mesh(type = Float64)

Generate an empty triangular dense mesh that represents a primitive or 3D scene.
By default a `Mesh` object will only accept coordinates in double floating
precision (`Float64`) but a lower precision can be generated by specifying the
corresponding data type as in `Mesh(Float32)`.

# Arguments
- `type`: The floating-point precision type for the mesh data (default is `Float64`).

# Returns
A `Mesh` object with no vertices or normals.

# Example
```jldoctest; output = false
julia> m = Mesh()
Mesh{StaticArraysCore.SVector{3, Float64}}(StaticArraysCore.SVector{3, Float64}[], StaticArraysCore.SVector{3, Float64}[])

julia> nvertices(m)
0

julia> ntriangles(m)
0

julia> Mesh(Float32)
Mesh{StaticArraysCore.SVector{3, Float32}}(StaticArraysCore.SVector{3, Float32}[], StaticArraysCore.SVector{3, Float32}[])
```
"""
function Mesh(::Type{FT} = Float64) where {FT<:AbstractFloat}
    Mesh(Vec{FT}[], Vec{FT}[])
end

"""
    Mesh(nt, type)

Generate a triangular dense mesh with enough memory allocated to store `nt`
triangles. The behaviour is equivalent to generating an empty
mesh but may be computationally more efficient when appending a large number of
primitives. If a lower floating precision is required, this may be specified
as an optional third argument as in `Mesh(10, Float32)`.

# Arguments
- `nt`: The number of triangles to allocate memory for.
- `type`: The floating-point precision type for the mesh data (default is `Float64`).

# Returns
A `Mesh` object with no vertices or normals.

# Example
```jldoctest; output = false
julia> m = Mesh(1_000)
Mesh{StaticArraysCore.SVector{3, Float64}}(StaticArraysCore.SVector{3, Float64}[], StaticArraysCore.SVector{3, Float64}[])

julia> nvertices(m)
0

julia> ntriangles(m)
0

julia> Mesh(1_000, Float32)
Mesh{StaticArraysCore.SVector{3, Float32}}(StaticArraysCore.SVector{3, Float32}[], StaticArraysCore.SVector{3, Float32}[])
```
"""
function Mesh(nt::Number, ::Type{FT} = Float64) where {FT<:AbstractFloat}
    nv = 3nt
    v = Vec{FT}[]
    sizehint!(v, nv)
    n = Vec{FT}[]
    sizehint!(n, nt)
    Mesh(v, n)
end


"""
    Mesh(meshes)

Merge multiple meshes into a single one

# Arguments
- `meshes`: Vector of meshes to merge.

# Returns
A new `Mesh` object that is the result of merging all the input meshes.

# Example
```jldoctest; output = false
julia> e = Ellipse(length = 2.0, width = 2.0, n = 10);

julia> r = Rectangle(length = 10.0, width = 0.2);

julia> m = Mesh([e,r]);
```
"""
function Mesh(meshes::Vector{<:Mesh})
    @assert !isempty(meshes) "At least one mesh must be provided"
    @inbounds VT = Vec{eltype(first(meshes))}
    # Positions where each old mesh starts in the new mesh
    nverts = cumsum(nvertices(m) for m in meshes)
    ntriangs = cumsum(ntriangles(m) for m in meshes)
    # Allocate elements of the new mesh
    verts = Vector{VT}(undef, last(nverts))
    norms = Vector{VT}(undef, last(ntriangs))
    # Fill up the elements of the new mesh
    @inbounds for i in eachindex(meshes)
        mesh = meshes[i]
        # First mesh is simple
        if i == 1
            for v = 1:nverts[1]
                verts[v] = vertices(mesh)[v]
            end
            for f = 1:ntriangs[1]
                norms[f] = normals(mesh)[f]
            end
        # Other meshes start where previous mesh ended
        else
            v0 = nverts[i-1]
            f0 = ntriangs[i-1]
            for v = v0+1:nverts[i]
                verts[v] = vertices(mesh)[v-v0]
            end
            for f = f0+1:ntriangs[i]
                norms[f] = normals(mesh)[f-f0]
            end
        end
    end
    Mesh(verts, norms)
end

# Area of a triangle given its vertices
function area_triangle(v1::Vec{FT}, v2::Vec{FT}, v3::Vec{FT})::FT where {FT<:AbstractFloat}
    e1 = v2 .- v1
    e2 = v3 .- v1
    FT(0.5) * norm(e1 × e2)
end

"""
    area(mesh::Mesh)

Total surface area of a mesh (as the sum of areas of individual triangles).

# Arguments
- `mesh`: Mesh which area is to be calculated.

# Returns
The total surface area of the mesh as a number.

# Example
```jldoctest; output = false
julia> r = Rectangle(length = 10.0, width = 0.2);

julia> area(r)
2.0

julia> r = Rectangle(length = 10f0, width = 0.2f0);

julia> area(r)
2.0f0
```
"""
function area(m::Mesh)
    sum(area_triangle(get_triangle(m, i)...) for i in 1:ntriangles(m))
end

"""
    areas(m::Mesh)

A vector with the areas of the different triangles that form a mesh.

# Arguments
- `mesh`: Mesh which areas are to be calculated.

# Returns
A vector with the areas of the different triangles that form the mesh.

# Example
```jldoctest; output = false
julia> r = Rectangle(length = 10.0, width = 0.2);

julia> areas(r)
2-element Vector{Float64}:
 1.0
 1.0

julia> r = Rectangle(length = 10f0, width = 0.2f0);

julia> areas(r)
2-element Vector{Float32}:
 1.0
 1.0
```
"""
areas(m::Mesh) = [area_triangle(get_triangle(m, i)...) for i in 1:ntriangles(m)]

# Check if two meshes are equal (mostly for testing)
==(m1::Mesh, m2::Mesh) = vertices(m1) == vertices(m2) && normals(m1) == normals(m2)

# Check if two meshes are approximately equal (mostly for testing)
function isapprox(
    m1::Mesh,
    m2::Mesh;
    atol::Real = 0.0,
    rtol::Real = atol > 0.0 ? 0.0 : sqrt(eps(1.0)),
)
    isapprox(vertices(m1), vertices(m2), atol = atol, rtol = rtol) &&
        isapprox(normals(m1), normals(m2), atol = atol, rtol = rtol)
end
