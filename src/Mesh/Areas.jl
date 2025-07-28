# Area of a triangle given its vertices
"""
    area_triangle(v1::Vec, v2::Vec, v3::Vec)

Calculates the area of a triangle given its vertices.

# Arguments
- `v1`, `v2`, `v3`: Vertices of the triangle as vectors.

# Returns
The area of the triangle.

# Example
```jldoctest
julia> v1 = Vec(0.0, 0.0, 0.0);

julia> v2 = Vec(1.0, 0.0, 0.0);

julia> v3 = Vec(0.0, 1.0, 0.0);

julia> area_triangle(v1, v2, v3);
```
"""
function area_triangle(v1::Vec{FT}, v2::Vec{FT}, v3::Vec{FT})::FT where {FT<:AbstractFloat}
    e1 = v2 .- v1
    e2 = v3 .- v1
    FT(0.5) * L.norm(L.cross(e1, e2))
end

"""
    area(mesh::Mesh)

Total surface area of a mesh (as the sum of areas of individual triangles).

# Arguments
- `mesh`: Mesh which area is to be calculated.

# Returns
The total surface area of the mesh as a number.

# Example
```jldoctest
julia> r = Rectangle(length = 10.0, width = 0.2);

julia> area(r);

julia> r = Rectangle(length = 10f0, width = 0.2f0);

julia> area(r);
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
```jldoctest
julia> r = Rectangle(length = 10.0, width = 0.2);

julia> areas(r);

julia> r = Rectangle(length = 10f0, width = 0.2f0);

julia> areas(r);
```
"""
areas(m::Mesh) = [area_triangle(get_triangle(m, i)...) for i in 1:ntriangles(m)]
