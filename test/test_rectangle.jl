import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard rectangle primitive
    r = G.Rectangle(length = 2.0, width = 2.0)
    @test r isa G.Mesh
    @test G.area(r) == 4.0
    @test G.nvertices(r) == 6
    @test G.ntriangles(r) == 2

    # Check that it works with lower precision
    r = G.Rectangle(length = 2.0f0, width = 2.0f0)
    @test r isa G.Mesh
    @test G.area(r) == 4.0f0
    @test G.nvertices(r) == 6
    @test G.ntriangles(r) == 2

    # Merging two meshes
    r = G.Rectangle(length = 2.0, width = 2.0)
    r2 = G.Rectangle(length = 3.0, width = 0.1)
    function foo()
        r = G.Rectangle(length = 2.0, width = 2.0)
        r2 = G.Rectangle(length = 3.0, width = 0.1)
        m = G.Mesh([r, r2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(r) + G.nvertices(r2)
    @test G.ntriangles(m) == G.ntriangles(r) + G.ntriangles(r2)
    @test G.area(m) ≈ G.area(r) + G.area(r2)

    # Create a rectangle using affine maps
    scale = LinearMap(SDiagonal(1.0, 0.1 / 2, 3.0))
    r3 = G.Rectangle(scale)
    @test r3 == r2

    # Create a rectangle ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(1.0, 0.1 / 2, 3.0))
        m = G.Rectangle(length = 2.0, width = 2.0)
        G.Rectangle!(m, scale)
        m
    end
    m2 = foo2()
    @test m2 == m

end

# import GLMakie
# import PlantViz as PV
# PV.render(m, normals = true)
# PV.render!(m2, normals = true, color = :red)
