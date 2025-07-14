module PlantGeomPrimitives

import StaticArrays: SVector, SMatrix, MVector
import GeometryBasics as GB
import Base
import FileIO, MeshIO
import LinearAlgebra as L
import CoordinateTransformations as CT
import Rotations

export Geom, Points, Segments, Mesh,
       arity, nvertices, ntriangles, nsegments, npoints,
       properties, add_property!, add!, delete_property!,
       areas, has_areas, calculate_areas, update_areas!,
       volumes, has_volumes, calculate_volumes, update_volumes!,
       inclinations, has_inclinations, calculate_inclinations, update_inclinations!,
       orientations, has_orientations, calculate_orientations, update_orientations!,
       lengths, has_lengths, calculate_lengths, update_lengths!,
       edges, has_edges, calculate_edges, update_edges!,
       normals, has_normals, calculate_normals, update_normals!,
       slices, has_slices,
       Vec, O, X, Y, Z,
       scale!, rotatex!, rotatey!, rotatez!, rotate!, translate!,
       Triangle, Rectangle, Trapezoid, SolidCube, HollowCube, BBox, Ellipse, HollowCylinder,
       SolidCylinder, HollowCone, SolidCone, HollowFrustum, SolidFrustum, Ellipsoid, Triangle!,
       Rectangle!, Trapezoid!, SolidCube!, Ellipse!, HollowCube!, HollowCylinder!, SolidCylinder!,
       HollowCone!, SolidCone!, HollowFrustum!, SolidFrustum!,
       get_geom, get_triangle, get_segment, get_point, vertices,
       slice!,
       load_mesh, save_mesh

abstract type Material end

"""
    Vec(x, y, z)

3D vector or point with coordinates x, y and z.

```jldoctest
julia> v = Vec(0.0, 0.0, 0.0);

julia> v = Vec(0f0, 0f0, 0f0);
```
"""
const Vec{FT} = SVector{3,FT}

"""
    O()

Returns the origin of the 3D coordinate system as a `Vec` object. By default, the coordinates will be in double
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `O(Float32)`.

```jldoctest
julia>  O();

julia>  O(Float32);
```
"""
function O(::Type{FT} = Float64) where {FT}
    Vec{FT}(0, 0, 0)
end

"""
    Z()

Returns an unit vector in the direction of the Z axis as a `Vec` object. By default, the coordinates will be in double
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `Z(Float32)`.

```jldoctest
julia>  Z();

julia>  Z(Float32);
```
"""
function Z(::Type{FT} = Float64) where {FT}
    Vec{FT}(0, 0, 1)
end

"""
    Z(s)

Returns scaled vector in the direction of the Z axis with length `s` as a `Vec` object using the same floating point precision
as `s`.

```jldoctest
julia>  Z(1.0);

julia>  Z(1f0);
```
"""
function Z(s::FT) where {FT}
    Vec{FT}(0, 0, s)
end

"""
    Y()

Returns an unit vector in the direction of the Y axis as a `Vec` object. By default, the coordinates will be in double
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `Y(Float32)`.

```jldoctest
julia>  Y();

julia>  Y(Float32);
```
"""
function Y(::Type{FT} = Float64) where {FT}
    Vec{FT}(0, 1, 0)
end

"""
    Y(s)

Returns scaled vector in the direction of the Y axis with length `s` as a `Vec` object using the same floating point precision
as `s`.

```jldoctest
julia>  Y(1.0);

julia>  Y(1f0);
```
"""
function Y(s::FT) where {FT}
    Vec{FT}(0, s, 0)
end

"""
    X()

Returns an unit vector in the direction of the X axis as a `Vec` object. By default, the coordinates will be in double
floating precision (`Float64`) but it is possible to generate a version with lower floating precision as in `X(Float32)`.

```jldoctest
julia>  X();

julia>  X(Float32);
```
"""
function X(::Type{FT} = Float64) where {FT}
    Vec{FT}(1, 0, 0)
end

"""
    X(s)

Returns scaled vector in the direction of the X axis with length `s` as a `Vec` object using the same floating point precision
as `s`.

```jldoctest
julia>  X(1.0);

julia>  X(1f0) ;
```
"""
function X(s::FT) where {FT}
    Vec{FT}(s, 0, 0)
end

# Geometry
include("General/Geom.jl")
include("General/Properties.jl")
include("General/Normals.jl")
include("General/Transformations.jl")

# Mesh
include("Mesh/Mesh.jl")
include("Mesh/Edges.jl")
include("Mesh/Areas.jl")
include("Mesh/Slicer.jl")
include("Mesh/MeshIO.jl")


# Primitive constructors (for triangular meshes)
include("Primitives/BBox.jl")
include("Primitives/Generic.jl")
include("Primitives/Triangle.jl")
include("Primitives/Rectangle.jl")
include("Primitives/Trapezoid.jl")
include("Primitives/Ellipse.jl")
include("Primitives/SolidCube.jl")
include("Primitives/HollowCube.jl")
include("Primitives/HollowCylinder.jl")
include("Primitives/SolidCylinder.jl")
include("Primitives/HollowCone.jl")
include("Primitives/SolidCone.jl")
include("Primitives/HollowFrustum.jl")
include("Primitives/SolidFrustum.jl")
include("Primitives/Ellipsoid.jl")

end
