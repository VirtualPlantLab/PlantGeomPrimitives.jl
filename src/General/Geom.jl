"""
    Geom{3,FT}

A struct representing a geometry composed of vertices and properties. A geometry can have
three interpretations depending on the value of the parameter `n`:

    - `n = 1`: A point cloud (one vertex per point). Also known as `Points{FT}`.
    - `n - 2`: A collection of segments. Every pair of consecutive vertices represent the start and end point of a segment. Also known as `Segments{FT}`.
    - `n - 3`: A triangular mesh. Every three consecutive vertices represent the vertices of a triangle. Also known as `Mesh{FT}`.

For each geometry, properties per point, segment or triangle are stored in a dictionary of
arrays. These can represent geometry attributes (e.g., normal vectors of points or triangles,
radii of segments), or other properties (e.g., colors for rendering, optical materials for
ray tracing, etc). Users can add their own properties (see `add_property!()`) to any
geometry.

The type parameter `FT` indicates the floating point precision used to specify the vertices.
Properties may be specified with other levels of precision if the user wishes to do so.

# Fields
- `vertices`: A vector containing the vertices of the point cloud, segment collection or triangular mesh.
- `properties`: A dictionary containing additional properties of the geometry (arrays of properties per point, segment or triangle).

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> p = Dict{Symbol, AbstractVector}(:normals => [Vec(0.0, 0.0, 1.0)]);

julia> m = Geom{3, Float64}(v, p);
```
"""
mutable struct Geom{n,FT}
    vertices::Vector{Vec{FT}}
    properties::Dict{Symbol, AbstractVector}
end


"""
    Geom(arity, type = Float64)

Generate an empty geometry that represents a primitive or 3D scene. By default a `Geom`
object will store the coordinates in double floating precision  (`Float64`) but a lower
precision can be specified.

# Arguments
- `arity`: The arity of the geometry as a compile-time constant (i.e., `Val(1)`, `Val(2)` or
`Val(3)`)
- `type`: The floating-point precision type for the mesh data (default is `Float64`).

# Returns
A `Geom` object with no vertices or properties stored in it.

# Example
```jldoctest
julia> m = Geom(Val(3));

julia> nvertices(m);

julia> ntriangles(m);

julia> Geom(Val(3), Float32);
```
"""
macro empty_geom(arity)
    quote
        function $(esc(:Geom))(::Val{$arity}, ::Type{FT} = Float64) where {FT<:AbstractFloat}
            $(esc(:Geom)){$arity, FT}(Vec{FT}[], Dict{Symbol, AbstractVector}())
        end
    end
end
@empty_geom(1)
@empty_geom(2)
@empty_geom(3)

"""
    Mesh(n, arity, type = Float64)

Generate a geometry object with enough memory allocated to store `n`
elements. The behaviour is equivalent to generating an empty geometry but may be
computationally more efficient when appending a large number of elements. If a lower
floating precision is required, this may be specified
as an optional third argument as in `Geom(10, Val(3), Float32)`.

# Arguments
- `n`: The number of elements to allocate memory for.
- `arity`: The arity of the geometry as a compile-time constant (i.e., `Val(1)`, `Val(2)` or
`Val(3)`).
- `type`: The floating-point precision type for the mesh data (default is `Float64`).

# Returns
A `Geom` object with no vertices.

# Example
```jldoctest
julia> m = Geom(1_000, Val(3));

julia> m = Geom(1_000, Val(3), Float32);
```
"""
macro allocate_geom(arity)
    quote
        function $(esc(:Geom))(n::Number, ::Val{$arity}, ::Type{FT} = Float64) where {FT<:AbstractFloat}
            v = Vec{FT}[]
            sizehint!(v, n)
            $(esc(:Geom)){$arity,FT}(v, Dict{Symbol, AbstractVector}())
        end
    end
end
@allocate_geom(1)
@allocate_geom(2)
@allocate_geom(3)


"""
    Geom(vertices, arity)

Generate a geometry obkect from a vector of vertices and arity.

# Arguments
- `vertices`: List of vertices (each vertex implement as `Vec`).
- `arity`: The arity of the geometry as a compile-time constant (i.e., `Val(1)`, `Val(2)` or
`Val(3)`).

# Returns
A `Geom` object.

# Example
```jldoctest
julia> verts = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> Geom(verts, Val(3));
```
"""
macro vertices_geom(arity)
    quote
        function $(esc(:Geom))(vertices::Vector{<:Vec}, ::Val{$arity})
            @assert !isempty(vertices)
            FT = eltype(first(vertices))
            $(esc(:Geom)){$arity,FT}(vertices, Dict{Symbol, AbstractVector}())
        end
    end
end
@vertices_geom(1)
@vertices_geom(2)
@vertices_geom(3)

"""
    Geom(geoms)

Merge multiple geometries into a single one

# Arguments
- `geoms`: Vector of geometries to merge.

# Details
This function assumes that all geometry objects have the same arity (i.e., they are all
    point clouds, segment collections or triangular meshes), use the same floating point
    precision to store vertices and contain the same type of properties with the same
    names. When this is not the case, the arity and floating-point precision of the first
    geometry object will be used.

# Returns
A new `Geom` object that is the result of merging all the input geometry objects.

# Example
```jldoctest
julia> e = Ellipse(length = 2.0, width = 2.0, n = 10);

julia> r = Rectangle(length = 10.0, width = 0.2);

julia> m = Geom([e,r]);
```
"""
function Geom(geoms::Vector{<:Geom})
    @assert !isempty(geoms) "At least one mesh must be provided"
    @inbounds n = arity(geoms[1])
    @inbounds FT = eltype(geoms[1])
    # Initialize vertices and properties (create copy to avoid modifying first geom)
    @inbounds verts = copy(vertices(geoms[1]))
    @inbounds props = copy(properties(geoms[1]))
    # Append vertices and add properties
    if length(geoms) > 1
        @inbounds for i in 2:length(geoms)
            append!(verts, vertices(geoms[i]))
            add_properties!(props, properties(geoms[i]))
        end
    end
    # Wrap vertices and properties in a geometry object
    Geom{n, FT}(verts, props)
end


"""
    add!(geom1, geom2; kwargs...)

Manually add a geometry to an existing geometry with optional properties captured as keywords.

# Arguments
- `geom1`: The current geometry we want to extend.
- `geom2`: A new geometry we want to add.
- `kwargs`: Properties to be set per triangle in the new mesh.

# Details

Make sure to be consistent with the properties (both geometries should end up with the same
list of properties). For example, if the scene was created with `:colors``, then you should
provide `:colors` for the new mesh as well. Note that amny properties already present in
`geom2` will also be added to `geom1` (e.g., the `:normals` property automatically generated
for a triangular mesh).

# Example
```jldoctest
julia> t1 = Triangle(length = 1.0, width = 1.0);

julia> using ColorTypes: RGB

julia> add_property!(t1, :colors, rand(RGB));

julia> t2 = Rectangle(length = 5.0, width = 0.5);

julia> add!(t1, t2, colors = rand(RGB));
```
"""
function add!(geom1, geom2; kwargs...)
    # Add the vertices
    append!(vertices(geom1), vertices(geom2))
    # Add properties already in geom2
    for (k, v) in properties(geom2)
        add_property!(geom1, k, v, length(geom2))
    end
    # Set optional properties per triangle
    for (k, v) in kwargs
        add_property!(geom1, k, v, length(geom2))
    end
    return geom1
end


# Types and size

"""
    eltype(geom::Geom)

Extract the the type used to represent coordinates in a geometry object (e.g., `Float64`).

# Fields
- `geom`: The geometry object from which to extract the element type.

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Geom(v, Val(3));

julia> eltype(m);
```
"""
Base.eltype(m::Geom{n, FT}) where {n, FT} = FT
Base.eltype(::Type{Geom{n, FT}}) where {n, FT} = FT

"""
    arity(geom::Geom)

Extract the arity of the geometry (1 = point cloud, 2 = segment collection, 3 = triangular
mesh).

# Fields
- `geom`: The geometry which arity we wish to know.

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Mesh(v);

julia> arity(m);
```
"""
arity(g::Geom{n,FT}) where {n,FT} = n

"""
    length(geom)

Extract the number of elements in a geometry.

# Arguments
- `geom`: The geometry from which to extract the number of elements.

# Details
An element will be a point, segment or triangle depending on the arity of the geometry
object.

# Returns
The number of elements in the geometry as an integer.

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Geom(v, Val(3));

julia> length(m);
```
"""
Base.length(geom::Geom) = div(nvertices(geom), arity(geom))

"""
    nvertices(geom)

The number of vertices in a geom.

# Arguments
- `geom`: The geometry from which to retrieve the number of vertices.

# Returns
The number of vertices in the geometry as an integer.

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Geom(v, Val(3));

julia> nvertices(m);
```
"""
nvertices(geom::Geom) = length(vertices(geom))

# Accessor functions
"""
    vertices(geom::Geom)

Retrieve the vertices of a mesh.

# Arguments
- `geom`: The geometry obecjt from which to retrieve the vertices.

# Returns
A vector containing the vertices of the mesh.

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Geom(v, Val(3));

julia> vertices(m);
```
"""
vertices(geom::Geom) = geom.vertices

"""
    properties(geom::Geom)

Retrieve the properties of a geom object. Properties are stored as a dictionary with one
entry per type of property. Each property is an array of objects, one per triangle. Each
property is identified by a symbol.

# Arguments
- `geom`: The geometry object from which to retrieve the normals.

# Returns
A vector containing the normals of the geometry object.

# Example
```jldoctest; output=false
julia> r = Rectangle();

julia> add_property!(r, :absorbed_PAR, [0.0, 0.0]);

julia> properties(r);
```
"""
properties(geom::Geom) = geom.properties

"""
    get_geom(geom::Geom, i)

Retrieve the vertices for the i-th element in the geometry.

# Arguments
- `geom`: The geometry from which we want to retrieve an element.
- `i`: The index of the element to retrieve.

# Returns
A vector containing the vertices defining the i-th geometry element (between one and three
vertices will be returned depending on the arity of the geometry object).

# Example
```jldoctest
julia> r = Rectangle();

julia> get_geom(r, 2);
```
"""
function get_geom(geom::Geom, i)
    n = arity(geom)
    v = vertices(geom)
    if n == 1
        get_point(v, i)
    elseif n == 2
        get_segment(v, i)
    else
        get_triangle(v, i)
    end
end


# Internal function to retrieve the vertices of the i-th segment (give list of vertices)
function get_point(v::AbstractVector, i)
    v[i]
end

# Internal function to retrieve the vertices of the i-th segment (give list of vertices)
function get_segment(v::AbstractVector, i)
    i1 = (i - 1)*2 + 1
    @view v[SVector{3,Int}(i1, i1+1)]
end

# Internal function to retrieve the vertices of the i-th triangle (give list of vertices)
function get_triangle(v::AbstractVector, i)
    i1 = (i - 1)*3 + 1
    @view v[SVector{3,Int}(i1, i1+1, i1+2)]
end

# Comparisons

# Check if two meshes are equal (mostly for testing)
# We just test the vertices, not the properties. Both geometries must have the same
# n-arity and floating point precision
function Base.:(==)(m1::Geom{n,FT}, m2::Geom{n,FT}) where {n,FT}
    vertices(m1) == vertices(m2)
end

# Check if two geometries are approximately equal (mostly for testing)
# We just test the vertices, not the properties. Both geometries must have the same
# n-arity and floating point precision
function Base.isapprox(m1::Geom{n,FT}, m2::Geom{n,FT}; atol::Real = 0.0,
                      rtol::Real = atol > 0.0 ? 0.0 : sqrt(eps(1.0))) where {n, FT}
    isapprox(vertices(m1), vertices(m2), atol = atol, rtol = rtol)
end
