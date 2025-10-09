"""
    Geom{n, FT, PT}

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
- `properties`: A named tuple containing additional properties of the geometry (arrays of properties per point, segment or triangle).

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> p = (;:normals => [Vec(0.0, 0.0, 1.0)]);

julia> m = Geom{3, Float64, typeof(p)}(v, p);
```
"""
mutable struct Geom{n,FT, PT}
    vertices::Vector{Vec{FT}}
    properties::PT
end

"""
    Mesh{FT}

A struct representing a 3D mesh using floating-point precision `FT`. Equivalent to `Geom{3,FT}`.
See help on `Geom{n,FT}` for details.
```
"""
const Mesh{FT} = Geom{3,FT}

"""
    Points{FT}

A struct representing a point cloud using floating-point precision `FT`. Equivalent to
    `Geom{1,FT}`. See help on `Geom{n,FT}` for details.
```
"""
const Points{FT} = Geom{1,FT}

"""
    Segments{FT}

A struct representing a collection of segments using floating-point precision `FT`.
    Equivalent to `Geom{2,FT}`. See help on `Geom{n,FT}` for details.
```
"""
const Segments{FT} = Geom{2,FT}

"""
    Geom(arity, type = Float64; properties = ())

Generate an empty `Geom` with a list of properties (specified by their element type). By
default a `Geom` object will store the coordinates in double floating precision
(`Float64`) but a lower precision can be specified. Certain compulsory properties
will be added internally.

# Arguments
- `arity`: The arity of the geometry as a compile-time constant (i.e., `Val(1)`, `Val(2)` or
`Val(3)`)
- `properties`: A named tuple specifying the names of the properties and their element type.
- `type`: The floating-point precision type for the mesh data (default is `Float64`).

# Details

An array with the user-supplied element type will be initialized internally. The following
properties are created by VPL internally and do not have to be specified by the user:

- For `Mesh` (`Val(3)`) the propery `normals` will be added.
- For `Segments` (`Val(2)`) the property `radius` will be added.
- For `Points` (`Val(1)`) the properties `areas` and `normals` will be added.


# Returns
A `Geom` object initialized but without any actual vertices or properties.

# Example
```jldoctest
julia> m = Geom(Val(3));

julia> nvertices(m);

julia> length(m);

julia> Geom(Val(3), Float32);
```
"""
function Geom(::Val{1}, ::Type{FT} = Float64; properties = NamedTuple()) where {FT<:AbstractFloat}
    ext_prop = merge(properties, (; areas = FT, normals = Vec{FT}))
    vec_properties = NamedTuple{keys(ext_prop)}(Tuple{Tuple(Vector{val} for val in values(ext_prop))...}(val[] for val in  values(ext_prop)))
    Geom{1, FT, typeof(vec_properties)}(Vec{FT}[], vec_properties)
end

function Geom(::Val{2}, ::Type{FT} = Float64; properties = NamedTuple()) where {FT<:AbstractFloat}
    ext_prop = merge(properties, (; radius = FT))
    vec_properties = NamedTuple{keys(ext_prop)}(Tuple{Tuple(Vector{val} for val in values(ext_prop))...}(val[] for val in  values(ext_prop)))
    Geom{2, FT, typeof(vec_properties)}(Vec{FT}[], vec_properties)
end

function Geom(::Val{3}, ::Type{FT} = Float64; properties = NamedTuple()) where {FT<:AbstractFloat}
    ext_prop = merge(properties, (; normals = Vec{FT}))
    vec_properties = NamedTuple{keys(ext_prop)}(Tuple{Tuple(Vector{val} for val in values(ext_prop))...}(val[] for val in  values(ext_prop)))
    Geom{3, FT, typeof(vec_properties)}(Vec{FT}[], vec_properties)
end


"""
    Geom(geoms)

Merge multiple geometries into a single one

# Arguments
- `geoms`: Vector of geometries to merge.

# Details
This function assumes that all geometry objects have the same arity (i.e., they are all
    point clouds, segment collections or triangular meshes), use the same floating point
    precision to store vertices and contain the same type of properties with the same
    names.

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
    @inbounds ns = arity(geoms[1])
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
    Geom{n, FT, typeof(props)}(verts, props)
end

# Types and size

"""
    eltype(geom::Geom)

Extract the type used to represent coordinates in a geometry object (e.g., `Float64`).

# Fields
- `geom`: The geometry object from which to extract the element type.

# Example
```jldoctest
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> m = Geom(v, Val(3));

julia> eltype(m);
```
"""
Base.eltype(m::Geom{n, FT, PT}) where {n, FT, PT} = FT
Base.eltype(::Type{Geom{n, FT, PT}}) where {n, FT, PT} = FT

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
arity(g::Geom{n,FT,PT}) where {n,FT,PT} = n

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
- `geom`: The geometry object from which to retrieve the vertices.

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

Retrieve the properties of a geom object. Properties are stored as a named tuple. Each
property is an array of objects, one per element within the geom.

# Arguments
- `geom`: The geometry object from which to retrieve the properties.

# Returns
A named tuple containing the properties of the geometry object.

# Example
```jldoctest; output=false
julia> r = Rectangle(properties = (; absorbed_PAR = Float64));

julia> add_property!(r, :absorbed_PAR, [0.0, 0.0]); # One value per triangle, match type above

julia> properties(r);
```
"""
properties(geom::Geom) = geom.properties

"""
    get_geom(geom, i)
    get_point(geom, i)
    get_segment(geom, i)
    get_triangle(geom, i)

Retrieve the vertices for the i-th element in the geom. Aliases are provided for `Points`,
    `Segments` and `Mesh`.

# Arguments
- `geom`: The geometry object from which we want to retrieve an element (one or more vertices).
- `i`: The index of the element to retrieve.

# Returns
For segments and triangular meshes it returns a view of the vertices defining the i-th
geometry element (two or three vertices). In case of points, a single value is returned.

See https://docs.julialang.org/en/v1/base/arrays/#Views-(SubArrays-and-other-view-types) for
details on views.


# Example
```jldoctest
julia> r = Rectangle();

julia> get_geom(r, 2);
```
"""
function get_geom(geom, i)
    n = arity(geom)
    v = vertices(geom)
    if n == 1
        v[i]
    elseif n == 2
        i1 = (i - 1)*2 + 1
        @view v[SVector{2,Int}(i1, i1+1)]
    else
        i1 = (i - 1)*3 + 1
        @view v[SVector{3,Int}(i1, i1+1, i1+2)]
    end
end


# Aliases to get_geom(geom, i)
get_point(geom, i) = get_geom(geom, i)
get_segment(geom, i) = get_geom(geom, i)
get_triangle(geom, i) = get_geom(geom, i)


"""
    isvalid(geom)

Check that the argument is a valid geometry object.

## Arguments
- `geom`: The geometry object geom being checked.

## Details

Following checks are performed:

- Arity must be between 1 and 3.
- The number of vertices must be a multiple of arity.
- The compulsory properties are present.
- For each property it is either empty or there is one property per element.

# Returns
True or false

# Example
```jldoctest
julia> r = Rectangle();

julia> isvalid(r);
```
"""
function Base.isvalid(geom::Geom{1, FT, PT}) where {FT, PT}
    (arity(geom) == 1) &&
    (:normals in keys(properties(geom))) &&
    (:areas in keys(properties(geom))) &&
    all(isempty(p) || (length(p) == length(geom)) for p in properties(geom))
end
function Base.isvalid(geom::Geom{2, FT, PT}) where {FT, PT}
    (arity(geom) == 2) &&
    (rem(nvertices(geom), 2) == 0) &&
    (:radius in keys(properties(geom))) &&
    all(isempty(p) || (length(p) == length(geom)) for p in properties(geom))
end
function Base.isvalid(geom::Geom{3, FT, PT}) where {FT, PT}
    (arity(geom) == 3) &&
    (rem(nvertices(geom), 3) == 0) &&
    (:normals in keys(properties(geom))) &&
    all(isempty(p) || (length(p) == length(geom)) for p in properties(geom))
end


"""
    isempty(geom)

Check that the a geometry has no vertices or properties stored in it.

## Arguments
- `geom`: The geometry object being checked.

## Details

Following checks are performed:

- Arity must be between 1 and 3.
- The number of vertices must be a multiple of arity.
- The compulsory properties are present.
- For each property it is either empty or there is one property per element.

# Returns
True or false

# Example
```jldoctest
julia> r = Rectangle();

julia> isvalid(r);
```
"""
function Base.isempty(m::Geom)
    (isempty(vertices(m))) &&
    all(isempty(p) for p in properties(m))
end

# Comparisons

# Check if two meshes are equal (mostly for testing)
function Base.:(==)(m1::Geom{n,FT,PT}, m2::Geom{n,FT,PT}) where {n,FT,PT}
    keys(properties(m1)) != keys(properties(m2)) && return false
    vertices(m1) != vertices(m2) && return false
    for k in keys(properties(m1))
        k1 = properties(m1)[k]
        k2 = properties(m2)[k]
        length(k1) != length(k2) && return false
        any(k1 .!= k2) && return false
    end
    return true
end

# Check if two meshes are approximately equal (mostly for testing)
function Base.isapprox(m1::Geom{n,FT,PT}, m2::Geom{n,FT,PT}; atol::Real = 0.0,
                      rtol::Real = atol > 0.0 ? 0.0 : sqrt(eps(1.0)))  where {n,FT,PT}
    keys(properties(m1)) != keys(properties(m2)) && return false
    !isapprox(vertices(m1), vertices(m2), atol = atol, rtol = rtol) && return false
    for k in keys(properties(m1))
        k1 = properties(m1)[k]
        k2 = properties(m2)[k]
        length(k1) != length(k2) && return false
        !isapprox(k1, k2, atol = atol, rtol = rtol) && return false
    end
    return true
end
