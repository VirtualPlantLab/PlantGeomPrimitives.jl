"""
    Rectangle(type = Mesh; length = 1.0, width = 1.0, n = 2, ...)

Create a rectangle with dimensions given by `length` and `width` discretized into 2
triangles (`type = Mesh`) or `n` points (`type = Points`). The lower side of the rectangle is
centered at the origin and lies on the YZ plane.

# Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length`: The length of the rectangle.
- `width`: The width of the rectangle.
- `n`: The number of points to generate (ignored if `type <: Mesh` or `type <: Volume`).
- `...`: Other keyword arguments for point sampling (when needed). See `?RectanglePoints` for details.

# Examples
```jldoctest
julia> Rectangle(; length = 1.0, width = 1.0);

julia> Rectangle(Mesh ;length = 1.0, width = 1.0);

julia> Rectangle(Points ;length = 1.0, width = 1.0, n = 2);

julia> Rectangle(Volume ;length = 1.0, width = 1.0, n = 2);
```
"""
function Rectangle(type::DataType = Mesh;
                   length = 1.0,
                   width = 1.0,
                   n::Int = 2, kwargs...)
    if type <: Mesh
        RectangleMesh(length = length, width = width)
    elseif type <: Points
        RectanglePoints(;length = length, width = width, n = n, kwargs...)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("type must be either Mesh or Points")
    end
end

"""
    Trapezoid(type = Mesh;length = 1.0, width = 1.0, ratio = 1.0, n = 2, ...)

Create a trapezoid with dimensions given by `length` and the larger `width` and
the `ratio` between the smaller and larger widths, discretized into 2
triangles (`type = Mesh`) or `n` points (`type = Points`). The lower side of the rectangle is
centered at the origin and lies on the YZ plane.

# Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length`: The length of the trapezoid.
- `width`: The larger width of the trapezoid (the lower base of the trapezoid).
- `ratio`: The ratio between the smaller and larger widths.
- `n`: The number of points to generate (ignored if `type <: Mesh` or `type <: Volume`).
- `...`: Other keyword arguments for point sampling (when needed). See `?TrapezoidPoints` for details.

# Examples
```jldoctest
julia> Trapezoid(; length = 1.0, width = 1.0, ratio = 1.0);

julia> Trapezoid(Mesh; length = 1.0, width = 1.0, ratio = 1.0);

julia> Trapezoid(Points; length = 1.0, width = 1.0, ratio = 1.0);

julia> Trapezoid(Volume; length = 1.0, width = 1.0, ratio = 1.0);
```
"""
function Trapezoid(type::DataType = Mesh;
                   length = 1.0,
                   width = 1.0,
                   ratio = 1.0, kwargs...)
    if type <: Mesh
        TrapezoidMesh(length = length, width = width, ratio = ratio)
    elseif type <: Points
        TrapezoidPoints(;length = length, width = width, ratio = ratio, kwargs...)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("type must be either Mesh or Points")
    end
end

"""
    Triangle(type = Mesh;length = 1.0, width = 1.0, ...)

Create a triangle with dimensions given by `length` and `width`, standard
location and orientation.

# Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length`: The length of the triangle.
- `width`: The width of the triangle.
- `...`: Other keyword arguments for point sampling (when needed). See `?TrianglePoints` for details.

# Examples
```jldoctest
julia> Triangle(; length = 1.0, width = 1.0);

julia> Triangle(Mesh; length = 1.0, width = 1.0);

julia> Triangle(Points; length = 1.0, width = 1.0);

julia> Triangle(Volume; length = 1.0, width = 1.0);
```
"""
function Triangle(type::DataType = Mesh;
                  length = 1.0,
                  width = 1.0, kwargs...)
    if type <: Mesh
        TriangleMesh(length = length, width = width)
    elseif type <: Points
        TrianglePoints(;length = length, width = width, kwargs...)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("type must be either Mesh or Points")
    end
end

"""
    Ellipse(type = Mesh; length = 1.0, width = 1.0, n = 20, ...)

Create an ellipse with dimensions given by `length` and `width`, discretized into `n`
triangles (`type = Mesh`) or `n` points (`type = Points`). The ellipse is centered at the
origin, on the YZ plane.

# Arguments
- `type`: The type geometry object (`Mesh` for triangular mesh, `Point` for point cloud,
`Volume` for volumetric primitive). Default is `Mesh`.
- `length = 1.0`: The length of the ellipse.
- `width = 1.0`: The width of the ellipse.
- `n = 20`: The number of triangles or points to be generated. Must be even.
- `...`: Other keyword arguments for point sampling (when needed). See `?EllipsePoints` for details.

# Examples

```jldoctest
julia> Ellipse(; length = 1.0, width = 1.0, n = 20);

julia> Ellipse(Mesh; length = 1.0, width = 1.0, n = 20);

julia> Ellipse(Points; length = 1.0, width = 1.0, n = 20);

julia> Ellipse(Volume; length = 1.0, width = 1.0, n = 20);
```
"""
function Ellipse(type = Mesh{Float64};
                 length = 1.0,
                 width = 1.0,
                 n = 20, kwargs...)
    if type <: Mesh
        EllipseMesh(length = length, width = width, n = n)
    elseif type <: Points
        EllipsePoints(;length = length, width = width, n = n, kwargs...)
    elseif type <: Volume
        error("Volumetric geometric primitives not yet implemented")
    else
        error("type must be either Mesh or Points")
    end
end
