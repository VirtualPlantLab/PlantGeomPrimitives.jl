import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard rectangle primitive
    r = G.Trapezoid(length = 2.0, width = 2.0, ratio = 0.5)
    @test r isa G.Mesh
    @test G.area(r) == 3.0
    @test G.nvertices(r) == 6
    @test G.ntriangles(r) == div(G.nvertices(r), 3)
    @test length(G.normals(r)) == G.ntriangles(r)

    # Check that it works with lower precision
    r = G.Trapezoid(length = 2.0f0, width = 2.0f0, ratio = 0.5f0)
    @test r isa G.Mesh
    @test G.area(r) == 3.0f0
    @test G.nvertices(r) == 6
    @test G.ntriangles(r) == div(G.nvertices(r), 3)
    @test length(G.normals(r)) == G.ntriangles(r)

    # Merging two meshes
    r = G.Trapezoid(length = 2.0, width = 2.0, ratio = 0.5)
    r2 = G.Trapezoid(length = 3.0, width = 0.1, ratio = 0.5)
    function foo()
        r = G.Trapezoid(length = 2.0, width = 2.0, ratio = 0.5)
        r2 = G.Trapezoid(length = 3.0, width = 0.1, ratio = 0.5)
        m = G.Mesh([r, r2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(r) + G.nvertices(r2)
    @test G.ntriangles(m) == G.ntriangles(r) + G.ntriangles(r2)
    @test G.area(m) ≈ G.area(r) + G.area(r2)

    # Create a rectangle using affine maps
    scale = LinearMap(SDiagonal(1.0, 0.1 / 2, 3.0))
    r3 = G.Trapezoid(scale, 0.5)
    @test G.normals(r3) == G.normals(r2)
    @test G.vertices(r3) == G.vertices(r2)

    # Create a rectangle ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(1.0, 0.1 / 2, 3.0))
        m = G.Trapezoid(length = 2.0, width = 2.0, ratio = 0.5)
        G.Trapezoid!(m, scale, 0.5)
        m
    end
    m2 = foo2()
    @test G.normals(m2) == G.normals(m)
    @test G.vertices(m2) == G.vertices(m)
end

# import GLMakie
# import PlantViz as PV
# PV.render(m, normals = true)
# PV.render!(m2, normals = true, color = :red)
