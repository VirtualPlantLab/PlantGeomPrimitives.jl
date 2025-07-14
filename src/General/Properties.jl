### This file contains public API ###
#=
This file contains general functions to work with properties (add, merge, delete)
It also contains accessor functions for all the properties defined in this package
The functions to calculate specific properties and add them to the geoms are specificied
for each arity separately in their respective folders (or in the primitive constructors)
Up to four methods can be defined per property
 - property() -> Retrieve property from a geom (here)
 - has_property() -> Check if property is defined in a geom (here)
 - calculate_property() -> Perform calculations for all triangles, return results (not here)
 - update_property!() -> Perform calculations that are missing, add results to property (not here)
=#

# Auxilliary function to add properties (from p2 to p1)
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
function add_property!(p::Dict{Symbol, AbstractVector}, prop::Symbol, data::AbstractVector)
    etype1 = eltype(p[prop])
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
    add_property!(m::Geom, prop::Symbol, data, nt = ntriangles(m))

Add a property to a geometry object. The property is identified by a name (`prop`) and is
stored as an array of values (`data`), one per triangle. If the property already exists, the
new data is appended to the existing property, otherwise a new property is created. It is
possible to pass a single object for `data`, in which case the property will be set to the
same value for all triangles.

# Arguments
- `geom`: The geometry object to which the property is to be added.
- `prop`: The name of the property to be added as a `Symbol`.
- `data`: The data to be added to the property (an array or a single value).
- `nt`: The number of triangles to be assumed if `data` is not an array. By default this is the number of triangles in the mesh.

# Returns
The geometry object with updated properties.

# Example
```jldoctest
julia> r = Rectangle();

julia> add_property!(r, :absorbed_PAR, [0.0, 0.0]);
```
"""
function add_property!(g::Geom, prop::Symbol, data, n = length(g))
    # Check if the data is an array and if not convert it to an array with length nt
    vecdata = data isa AbstractVector ? data : fill(data, n)
    # Create new property if the one being added does not exist (make sure to copy)
    if !haskey(properties(g), prop)
        properties(g)[prop] = copy(vecdata)
    # Otherwise add to existing property
    else
        add_property!(properties(g), prop, vecdata)
    end
    return g
end

"""
    delete_property!(geom::Geom, prop::Symbol)

Delete the property `prop` from the geometry object `geom`.

# Arguments
- `geom`: The geometry object to which the property is to be added.
- `prop`: The name of the property to be added as a `Symbol`.

# Returns
The geometry object with updated properties.

# Example
```jldoctest
julia> r = Rectangle();

julia> add_property!(r, :absorbed_PAR, [0.0, 0.0]);

julia> delete_property!(r, :absorbed_PAR);
```
"""
function delete_property!(geom::Geom, prop::Symbol)
    delete!(properties(geom), prop)
    geom
end


# Extract a property through a function with the name of the property
macro gen_property(name)
    quote
        function $(esc(name))(geom::Geom)
            properties(geom)[$(QuoteNode(name))]
        end
    end
end
@gen_property areas
@gen_property volumes
@gen_property inclinations
@gen_property orientations
@gen_property lengths
@gen_property radius
@gen_property edges
@gen_property normals
@gen_property slices


macro gen_has_property(name)
    function_name = Symbol("has_"*"$name")
    quote
        function $(esc(function_name))(geom::Geom)
            $(QuoteNode(name)) in keys(properties(geom))
        end
    end
end
@gen_has_property areas
@gen_has_property volumes
@gen_has_property inclinations
@gen_has_property orientations
@gen_has_property lengths
@gen_has_property radius
@gen_has_property edges
@gen_has_property normals
@gen_has_property slices
