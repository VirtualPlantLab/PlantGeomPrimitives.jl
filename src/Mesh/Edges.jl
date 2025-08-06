# Calculate the edges of a mesh and add them as properties (deals with partially computed normals)
"""
    update_edges!(m::Mesh{FT}) where {FT<:AbstractFloat}

Calculate the edges of a mesh and add them as properties.
This function checks if the edges property exists, and if not, it creates it.
It then computes the edges for all vertices in the mesh.

# Arguments
- `m`: The mesh for which to update the edges.

# Returns
Nothing. It modifies the mesh in place by adding the edges as a property.

# Example
```jldoctest
julia> import PlantGeomPrimitives as PG;

julia> vs = [Vec(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];

julia> m = Mesh(vs);

julia> PG.update_edges!(m);

julia> edges(m);
```
"""
function update_edges!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :edges and if not create it
    if !haskey(properties(m), :edges)
        properties(m)[:edges] = Vec{Vec{FT}}[]
    end
    vs = vertices(m)
    lv = length(vs)
    # 2. If the property :edges is empty, compute the edges for all vertices
    if isempty(edges(m))
        for i in 1:3:lv
            push_edges!(vs, m, i)
        end
    else
    # 3. If the property :edges is not empty, compute the edges for the remaining vertices
        ln = length(edges(m))
        for i in 3ln:3:(lv - 3)
            push_edges!(vs, m, i + 1)
        end
    end
end

# Create the three edges stored as a vector of vectors
"""
    push_edges!(vs, m, i0)

Create the three edges stored as a vector of vectors from
the vertices `vs` starting at index `i0` and add them to the
mesh's property.

# Arguments
- `vs`: The vertices of the mesh.
- `m`: The mesh to which the edges will be added.
- `i0`: The starting index in the vertices vector from which to create the edges.

# Returns
Nothing. It modifies the mesh in place by adding the edges.

# Example
```jldoctest
julia> import PlantGeomPrimitives as PG;

julia> vs = [Vec(0.0, 0.0, 0.0), Vec(1.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];

julia> m = Mesh(vs);

julia> PG.update_edges!(m);

julia> PG.push_edges!(vs, m, 1);

julia> edges(m);
```
"""
function push_edges!(vs, m, i0)
    @inbounds v1, v2, v3 = vs[i0], vs[i0+1], vs[i0+2]
    e1 = L.normalize(v2 .- v1)
    e2 = L.normalize(v3 .- v1)
    e3 = L.normalize(v2 .- v3)
    push!(edges(m), Vec(e1, e2, e3))
    return nothing
end

"""
    edges(mesh::Mesh)

Retrieve the edges of a mesh (three edges per triangle).

## Arguments
- `mesh`: The mesh from which to retrieve the edges.

## Returns
A vector containing the edges of the mesh.
"""
edges(mesh::Mesh) = properties(mesh)[:edges]
