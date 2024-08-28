import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard Solid cylinder primitive
    c = G.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40)
    @test c isa G.Mesh
    @test abs(G.area(c) / (2pi + pi / 2) - 1.0) < 0.03
    @test G.nvertices(c) == 120
    @test G.ntriangles(c) == 40

    # Checking that it works at lower precisions
    c = G.SolidCylinder(length = 2.0f0, width = 1.0f0, height = 1.0f0, n = 40)
    @test c isa G.Mesh
    @test abs(G.area(c) / (2.0f0pi + pi / 2.0f0) - 1.0f0) < 0.03f0
    @test G.nvertices(c) == 120
    @test G.ntriangles(c) == 40

    # Mergin two meshes
    c = G.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40)
    c2 = G.SolidCylinder(length = 3.0, width = 0.1, height = 0.2, n = 40)
    function foo()
        c = G.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40)
        c2 = G.SolidCylinder(length = 3.0, width = 0.1, height = 0.2, n = 40)
        m = G.Mesh([c, c2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(c) + G.nvertices(c2)
    @test G.ntriangles(m) == G.ntriangles(c) + G.ntriangles(c2)
    @test abs(G.area(m) - (G.area(c) + G.area(c2))) < 1.6e-14

    # Create a Solid cylinder using affine maps
    scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
    c3 = G.SolidCylinder(scale, n = 40)
    @test c3.normals == c2.normals
    @test c3.vertices == c2.vertices

    # Create a cylinder ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
        m = G.SolidCylinder(length = 2.0, width = 1.0, height = 1.0, n = 40)
        G.SolidCylinder!(m, scale, n = 40)
        m
    end
    m2 = foo2()
    @test m2.vertices == m.vertices
    @test m2.normals == m.normals
end

# import GLMakie
# import PlantViz as PV
# PV.render(m, normals = true)
# PV.render!(m2, normals = true, color = :red)
