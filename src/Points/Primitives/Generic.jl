### This file does NOT contains public API ###

# Given the affine transformation for a primitive, compute the transformation for its normals
function normal_trans(trans)
    transpose(inv(trans.linear))
end

# Create a point cloud from generators and total area
function PrimitivePoints(generate_points, generate_normals, area::FT) where FT
    # Generate points
    points  = collect(Vec{FT}, generate_points())
    normals = collect(Vec{FT}, generate_normals())
    n        = length(points)
    areas    = fill(area/n, n)
    geom     = Points(points)
    add_property!(geom, :normals, normals)
    add_property!(geom, :areas, areas)
    return geom
end

# As PrimitivePoints but append the points and properties to an existing point cloud
function Primitive!(p::Points, generate_points, generate_normals, area, np)
    # Check for a well-formed Points
    !has_normals(p) && error("Attempt to add points to an existing point cloud without normals")
    !has_areas(p) && error("Attempt to add points to an existing point cloud without areas")
    # Add vertices
    nv0 = nvertices(p)
    resize!(vertices(p), nv + np)
    vertex_iterator = generate_points()
    @simd for i in 1:np
        @inbounds vertices(p)[nv + i] = iterate(vertex_iterator, i)[1]
    end
    # Add normals
    resize!(normals(p), nv + np)
    normal_iterator = generate_normals()
    @simd for i in 1:np
        @inbounds normals(p)[nv + i] = iterate(normal_iterator, i)[1]
    end
    # Add areas
    area_p = area/np
    resize!(areas(p), nv + np)
    @simd for i in 1:np
        @inbounds areas(p)[nv + i] = area_p
    end
    nothing
end
