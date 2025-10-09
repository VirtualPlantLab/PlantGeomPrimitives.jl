### This file contains public API ###
#=
This file contains general functions to work with properties (add, merge)
It also contains accessor functions for all the properties defined in this package
The functions to calculate specific properties and add them to the geoms are specificied
for each arity separately in their respective folders (or in the primitive constructors)
Up to four methods can be defined per property
 - property() -> Retrieve property from a geom (here)
 - has_property() -> Check if property is defined in a geom (here)
 - calculate_property() -> Perform calculations for all geom elements, return results (not here)
 - update_property!() -> Perform calculations that are missing, add results to property (not here)
=#

# Auxilliary function to add properties (from g2 to g1)
function add_properties!(g1::Geom, g2::Geom)
    # They must have the same properties
    k1, k2 = (keys(properties(g1)), keys(properties(g2)))
    @assert k1 == k2 "Properties of both geometries must be the same"
    # Transfer properties
    for k in k1
        add_property!(g1, k, properties(g2)[k])
    end
    return g1
end

"""
    add_property!(m::Geom, prop::Symbol, data::Vector)
    add_property!(m::Geom, prop::Symbol, data, n)

Add values to the property to a geometry object.

## Arguments
- `geom`: The geometry object to which the property is to be added.
- `prop`: The name of the property to be added as a `Symbol`.
- `data`: The data to be added to the property (an array or a single value).
- `n`: The number of elements to be assumed if `data` is a single object

## Details

The property is identified by a name (`prop`) and `data` is either a vector of values or a
single value (that will be expanded to an array of length `n`). The property must already
exist and the element typeof `data` must be compatible with the property stored in the
geometry object.

The default value for `n` may not be adequate (it takes the length of `data`). An edge case
    is when we want to add a single property value but this value is not a scalar (e.g., add
    a normal vector). In that case make sure to set `n = 1`.

## Returns
The geometry object with updated properties.

## Example
```jldoctest
julia> r = Rectangle(areas = Float64);

julia> add_property!(r, :areas, [0.0, 0.0]);
```
"""
function add_property!(g::Geom, prop::Symbol, data::Vector)
    @argcheck haskey(properties(g), prop) "Attempt to add values to a property that does not exist"
    @argcheck eltype(getindex(properties(g), prop)) == eltype(data) "The data must contain the same type of value as the property"
    p::typeof(data) = getindex(properties(g), prop)
    nc = length(p)
    n = length(data)
    resize!(p, nc + n)
    @simd for i in 1:n
        @inbounds p[nc + i] = data[i]
    end
    return g
end

function add_property!(g::Geom, prop::Symbol, data, n = length(data))
    @argcheck haskey(properties(g), prop)
    p::Vector{typeof(data)} = properties(g)[prop]
    nc = length(p)
    resize!(p, nc + n)
    @simd for i in 1:n
        @inbounds p[nc + i] = data
    end
    return g
end

# Extract a property through a function with the name of the property
macro gen_property(name)
    quote
        @doc """
        $($name)(geom::Geom)

        Retrieve the $($name) of a geom.

        ## Arguments
        - `geom`: The geometry object from which to retrieve the $($name).

        # Returns
        A vector containing the $($name) of the geom or raise an error if the property is not present.
        """
        function $(esc(name))(geom::Geom)
            properties(geom)[$(QuoteNode(name))]
        end
    end
end
@gen_property areas
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
        @doc """
            has_$($name)(geom::Geom)

        Check whether a geom has $($name) stored in them (i.e., whether it has the property
        :$($name))

        # Arguments
        - `geom`: The geometry object being checked.

        # Returns
        A boolean (`true` or `false`).
        """
        function $(esc(function_name))(geom::Geom)
            $(QuoteNode(name)) in keys(properties(geom))
        end
    end
end
@gen_has_property areas
@gen_has_property inclinations
@gen_has_property orientations
@gen_has_property lengths
@gen_has_property radius
@gen_has_property edges
@gen_has_property normals
@gen_has_property slices
