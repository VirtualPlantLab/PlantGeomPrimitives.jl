"""
    normals(geom::Geom)

Retrieve the normals of a geometry.

# Arguments
- `geom`: The geometry from which to retrieve the normals. Could be a `Mesh` or `Points`.

# Returns
A vector containing the normals of the geometry.

# Example
```jldoctest; output=false
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Mesh(v);

julia> update_normals!(m);

julia> normals(m);
```
"""
normals(geom::Geom) = properties(geom)[:normals]

"""
    has_normals(geom::Geom)

Check where a geometry has normals stored in them (i.e., whether it has the property
:normals)

# Arguments
- `geom`: The geometry being checked.

# Returns
A boolean (`true` or `false`).

# Example
```jldoctest; output=false
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Mesh(v);

julia> has_normals(m);
```
"""
has_normals(geom::Geom) = :normals in keys(properties(geom))
