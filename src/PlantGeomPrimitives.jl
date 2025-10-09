module PlantGeomPrimitives

import StaticArrays: SVector, SMatrix, MVector
import GeometryBasics as GB
import Base
import FileIO, MeshIO
import LinearAlgebra as L
import CoordinateTransformations as CT
import Rotations
import Elliptic
import Sobol: SobolSeq, next!
import ArgCheck: @argcheck

# Helpers to create points and vectors
export Vec, O, X, Y, Z

# Basic geometry
export Geom, Points, Segments, Mesh,
       arity, nvertices, ntriangles, nsegments, npoints,
       properties, get_geom, get_geom, get_triangle, get_segment, get_point, vertices,
       areas, has_areas, calculate_areas, update_areas!,
       inclinations, has_inclinations, calculate_inclinations, update_inclinations!,
       orientations, has_orientations, calculate_orientations, update_orientations!,
       lengths, has_lengths, calculate_lengths, update_lengths!,
       edges, has_edges, calculate_edges, update_edges!,
       normals, has_normals, calculate_normals, update_normals!,
       radius, has_radius,
       slices, has_slices,
       scale!, rotatex!, rotatey!, rotatez!, rotate!, translate!, transform!,
       Triangle, Triangle!,
       Rectangle, Rectangle!,
       Trapezoid, Trapezoid!,
       SolidCube, SolidCube!,
       HollowCube, HollowCube!,
       BBox,
       Ellipse, Ellipse!,
       HollowCylinder, HollowCylinder!,
       SolidCylinder, SolidCylinder!,
       HollowCone, HollowCone!,
       SolidCone, SolidCone!,
       HollowFrustum, HollowFrustum!,
       SolidFrustum, SolidFrustum!,
       Ellipsoid

# export
#
#        slice!,
#        load_mesh, save_mesh

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
include("General/Transformations.jl")

# # Mesh
include("Mesh/Mesh.jl")
# include("Mesh/Slicer.jl")
# include("Mesh/MeshIO.jl")
include("Mesh/Properties.jl")

# # Points
include("Points/Points.jl")
# include("Points/Slicer.jl")
# include("Points/Properties.jl")

# # Segments
include("Segments/Segments.jl")
# include("Segments/Slicer.jl")
# include("Segments/Properties.jl")

# # Primitive constructors (general, dispatch different geom methods)
include("General/Primitives/Cone.jl")
include("General/Primitives/Cube.jl")
include("General/Primitives/Cylinder.jl")
include("General/Primitives/Flat.jl")
include("General/Primitives/Frustum.jl")

# # Primitive constructors (for triangular meshes)
include("Mesh/Primitives/BBox.jl")
include("Mesh/Primitives/Generic.jl")
include("Mesh/Primitives/Triangle.jl")
include("Mesh/Primitives/Rectangle.jl")
include("Mesh/Primitives/Trapezoid.jl")
include("Mesh/Primitives/Ellipse.jl")
include("Mesh/Primitives/SolidCube.jl")
include("Mesh/Primitives/HollowCube.jl")
include("Mesh/Primitives/HollowCylinder.jl")
include("Mesh/Primitives/SolidCylinder.jl")
include("Mesh/Primitives/HollowCone.jl")
include("Mesh/Primitives/SolidCone.jl")
include("Mesh/Primitives/HollowFrustum.jl")
include("Mesh/Primitives/SolidFrustum.jl")
include("Mesh/Primitives/Ellipsoid.jl")

# # Primitive constructors (for point clouds)
# include("Points/Primitives/PointSampler.jl")
# include("Points/Primitives/Generic.jl")
# include("Points/Primitives/Triangle.jl")
# include("Points/Primitives/Rectangle.jl")
# include("Points/Primitives/Trapezoid.jl")
# include("Points/Primitives/Ellipse.jl")
# include("Points/Primitives/SolidCube.jl")
# include("Points/Primitives/HollowCube.jl")
# include("Points/Primitives/HollowCylinder.jl")
# include("Points/Primitives/SolidCylinder.jl")
# include("Points/Primitives/HollowCone.jl")
# include("Points/Primitives/SolidCone.jl")
# include("Points/Primitives/HollowFrustum.jl")
# include("Points/Primitives/SolidFrustum.jl")
# include("Points/Primitives/Ellipsoid.jl")

end
