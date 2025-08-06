# Auxilliary function to add properties (from p2 to p1)
"""
    function add_properties!(p1::Dict{Symbol, AbstractVector}, p2::Dict{Symbol, AbstractVector})

Merge properties from `p2` into `p1`. Both dictionaries must have the same keys.
If a key exists in `p2` but not in `p1`, it will be added to `p1`.
If a key exists in both, the values from `p2` will be appended to the existing values in `p1`.

# Arguments
- `p1`: The first dictionary of properties to which the second will be added.
- `p2`: The second dictionary of properties to be merged into the first.

# Returns
The modified `p1` dictionary with properties from `p2` added.

# Example
```jldoctest
julia> import PlantGeomPrimitives as PG;

julia> p1 = Dict{Symbol, AbstractVector}(:prop1 => [1.0, 2.0], :prop2 => [3.0, 4.0]);

julia> p2 = Dict{Symbol, AbstractVector}(:prop1 => [5.0, 6.0], :prop2 => [7.0, 8.0]);

julia> merged_properties = PG.add_properties!(p1, p2);

julia> merged_properties;
```
"""
function add_properties!(p1::Dict{Symbol, AbstractVector}, p2::Dict{Symbol, AbstractVector})
    # Both are empty
    isempty(p1) && isempty(p2) && (return nothing)
    # If not, they must have the same properties
    k1, k2 = (keys(p1), keys(p2))
    @assert k1 == k2 "Properties of both meshes must be the same"
    # Transfer properties
    for k in k1
        add_property!(p1, k, p2[k])
    end
    return p1
end

# Add a new property to an existing dictionary of properties
# If the types are different, create union that contains all types
"""
    add_property!(p::Dict{Symbol, AbstractVector}, prop::Symbol, data::AbstractVector)

Add data to an existing property in a dictionary of properties.
If the property already exists, the new data is appended to the existing property.
If the property does not exist, please use `add_properties!` instead.

# Arguments
- `p`: The dictionary of properties to which the property will be added.
- `prop`: The name of the property to be added as a `Symbol`, given that `prop` is in `p`.
- `data`: The data to be added to the property (an array or a single value).

# Returns
The modified dictionary of properties with the new property added.

# Example
```jldoctest
julia> p = Dict{Symbol, AbstractVector}(:prop1 => [1.0, 2.0]);

julia> prop = :prop1;

julia> data = [3.0, 4.0];

julia> add_property!(p, prop, data);

julia> p;
```
"""
function add_property!(p::Dict{Symbol, AbstractVector}, prop::Symbol, data::AbstractVector)
    if haskey(p, prop)
        etype1 = eltype(p[prop])
    else
        error("Property $prop does not exist in the dictionary. Please use `add_properties!` instead.")
    end
    etype2 = eltype(data)
    if etype2 isa etype1
        append!(p[prop], data)
    else
        etype3 = Union{etype1, etype2}
        p[prop] = convert(Vector{etype3}, p[prop])
        append!(p[prop], data)
    end
    return p
end

"""
    add_property!(m::Mesh, prop::Symbol, data, nt = ntriangles(m))

Add a property to a mesh. The property is identified by a name (`prop`) and is stored as an
array of values (`data`), one per triangle. If the property already exists, the new data is
appended to the existing property, otherwise a new property is created. It is possible to
pass a single object for `data`, in which case the property will be set to the same value for
all triangles.

# Arguments
- `mesh`: The mesh to which the property is to be added.
- `prop`: The name of the property to be added as a `Symbol`.
- `data`: The data to be added to the property (an array or a single value).
- `nt`: The number of triangles to be assumed if `data` is not an array. By default this is the number of triangles in the mesh.

# Returns
The mesh with updated properties.

# Example
```jldoctest
julia> r = Rectangle();

julia> add_property!(r, :absorbed_PAR, [0.0, 0.0]);

julia> properties(r);
```
"""
function add_property!(m::Mesh, prop::Symbol, data, nt = ntriangles(m))
    # Check if the data is an array and if not convert it to an array with length nt
    vecdata = data isa AbstractVector ? data : fill(data, nt)
    # Create new property if the one being added does not exist (make sure to copy)
    if !haskey(properties(m), prop)
        properties(m)[prop] = copy(vecdata)
    # Otherwise add to existing property
    else
        add_property!(properties(m), prop, vecdata)
    end
    return m
end
