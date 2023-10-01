
# Geometry

```@meta
CurrentModule = PlantGeomPrimitives
```

## Scenes

```@docs
Scene
add!
```

```@docs
colors(scene::Scene)
mesh(scene::Scene)
materials(scene::Scene)
```

## 3D vectors

```@docs
Vec
O(::Type{FT} = Float64) where FT
X(::Type{FT} = Float64) where FT
Y(::Type{FT} = Float64) where FT
Z(::Type{FT} = Float64) where FT
X(s::FT) where FT
Y(s::FT) where FT
Z(s::FT) where FT
```

## Geometry primitives

### Triangle

```@docs
Triangle(;length::FT = 1.0, width::FT = 1.0) where FT
```

### Rectangle

```@docs
Rectangle(;length::FT = 1.0, width::FT = 1.0) where FT
```

### Trapezoid

```@docs
Trapezoid(;length::FT = 1.0, width::FT = 1.0, ratio::FT = 1.0) where FT
```

### Ellipse

```@docs
Ellipse(;length::FT = 1.0, width::FT = 1.0 , n::Int = 20) where FT
```

### Hollow cylinder

```@docs
HollowCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 40) where FT
SolidCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 80) where FT
```

### Hollow cone

```@docs
HollowCone(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where FT
SolidCone(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 40) where FT
```

### Cube

```@docs
SolidCube(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where FT
HollowCube(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where FT
```

### Solid frustum

```@docs
SolidFrustum(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, ratio::FT = 1.0, n::Int = 80) where FT
HollowFrustum(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, ratio::FT = 1.0, n::Int = 40) where FT
```

### Bounding box

```@docs
BBox(m::Mesh{VT}) where VT <: Vec{FT} where FT
BBox(pmin::Vec{FT}, pmax::Vec{FT}) where FT
```

## Rotations, scaling and translations

```@docs
scale!(m::Mesh, vec::Vec)
rotatex!(m::Mesh, θ)
rotatey!(m::Mesh, θ)
rotatez!(m::Mesh, θ)
rotate!(m::Mesh; x::Vec{FT}, y::Vec{FT}, z::Vec{FT}) where FT
translate!(m::Mesh, v::Vec)
```

## Other mesh-related methods

```@docs
Mesh(::Type{FT} = Float64)  where FT <: AbstractFloat
Mesh(nt, nv = nt*3, ::Type{FT} = Float64) where FT <: AbstractFloat
ntriangles(mesh::Mesh)
nvertices(mesh::Mesh)
area(m::Mesh)
areas(m::Mesh)
load_mesh(filename)
save_mesh(mesh; fileformat = STL_BINARY, filename)
```
