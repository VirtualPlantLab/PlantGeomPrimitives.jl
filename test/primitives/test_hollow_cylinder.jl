import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let
    # Standard hollow cylinder primitive
    c = G.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20)
    @test c isa G.Mesh
    @test abs(G.area(c) / pi - 2.0) < 0.04
    @test G.nvertices(c) == 60
    @test G.ntriangles(c) == div(G.nvertices(c), 3)
    @test length(G.normals(c)) == G.ntriangles(c)

    # Check that it works with lower precision
    c = G.HollowCylinder(length = 2.0f0, width = 1.0f0, height = 1.0f0, n = 20)
    @test c isa G.Mesh
    @test abs(G.area(c) / pi - 2.0f0) < 0.04f0
    @test G.nvertices(c) == 60
    @test G.ntriangles(c) == div(G.nvertices(c), 3)
    @test length(G.normals(c)) == G.ntriangles(c)

    # Merging two meshes
    c = G.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20)
    c2 = G.HollowCylinder(length = 3.0, width = 0.1, height = 0.2, n = 20)
    function foo()
        c = G.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20)
        c2 = G.HollowCylinder(length = 3.0, width = 0.1, height = 0.2, n = 20)
        m = G.Mesh([c, c2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(c) + G.nvertices(c2)
    @test G.ntriangles(m) == G.ntriangles(c) + G.ntriangles(c2)
    @test abs(G.area(m) - (G.area(c) + G.area(c2))) < 1e-14

    # Create a hollow cylinder using affine maps
    scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
    c3 = G.HollowCylinder(scale, n = 20)
    @test c3 == c2

    # Create a cylinder ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
        m = G.HollowCylinder(length = 2.0, width = 1.0, height = 1.0, n = 20)
        G.HollowCylinder!(m, scale, n = 20)
        m
    end
    m2 = foo2()
    @test m2 == m
end

# import GLMakie
# import PlantViz as PV
# PV.render(m, normals = true)
# PV.render!(m2, normals = true, color = :red)
