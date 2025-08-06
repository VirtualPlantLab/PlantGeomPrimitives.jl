# Calculate the normals of a mesh and add them (deals with partially compute normals)
"""
    update_normals!(m::Mesh{FT}) where {FT<:AbstractFloat}

Calculate the normals of a mesh and add them as properties.
This function checks if the normals property exists, and if not, it creates it.
It then computes the normals for all vertices in the mesh.

# Arguments
- `m`: The mesh for which to update the normals.

# Returns
Nothing. It modifies the mesh in place by adding the normals as a property.

# Example
```jldoctest
julia> import PlantGeomPrimitives as PG;

julia> vs = [Vec(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];

julia> m = Mesh(vs);

julia> PG.update_normals!(m);

julia> normals(m);
```
"""
function update_normals!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :normals and if not create it
    if !haskey(properties(m), :normals)
        properties(m)[:normals] = Vec{FT}[]
    end
    vs = vertices(m)
    lv = length(vs)
    # 2. If the property :normals is empty, compute the normals for all vertices
    if isempty(normals(m))
        for i in 1:3:lv
            @inbounds v1, v2, v3 = vs[i], vs[i+1], vs[i+2]
            n = L.normalize(L.cross(v2 .- v1, v3 .- v1))
            push!(normals(m), n)
        end
    else
    # 3. If the property :normals is not empty, compute the normals for the remaining vertices
        ln = length(normals(m))
        for i in 3ln:3:(lv - 3)
            @inbounds v1, v2, v3 = vs[i + 1], vs[i + 2], vs[i + 3]
            n = L.normalize(L.cross(v2 .- v1, v3 .- v1))
            push!(normals(m), n)
        end
    end
    return nothing
end

"""
    normals(mesh::Mesh)

Retrieve the normals of a mesh.

# Arguments
- `mesh`: The mesh from which to retrieve the normals.

# Returns
A vector containing the normals of the mesh.

# Example
```jldoctest; output=false
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Mesh(v);

julia> normals(m);
```
"""
normals(mesh::Mesh) = properties(mesh)[:normals]
