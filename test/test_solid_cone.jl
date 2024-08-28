import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard solid cone primitive
    c = G.SolidCone(length = 2.0, width = 1.0, height = 1.0, n = 40)
    @test c isa G.Mesh
    @test abs(G.area(c) - sqrt(4 + 0.25^2) * pi / 2 - pi * 0.25) < 0.05
    @test G.nvertices(c) == 120
    @test G.ntriangles(c) == 40

    # Check that it works with lower precision
    c = G.SolidCone(length = 2.0f0, width = 1.0f0, height = 1.0f0, n = 40)
    @test c isa G.Mesh
    @test abs(G.area(c) - sqrt(4 + 0.25^2) * pi / 2 - pi * 0.25) < 0.05f0
    @test G.nvertices(c) == 120
    @test G.ntriangles(c) == 40

    # Mergin two meshes
    c = G.SolidCone(length = 2.0, width = 1.0, height = 1.0, n = 40)
    c2 = G.SolidCone(length = 3.0, width = 0.1, height = 0.2, n = 40)
    function foo()
        c = G.SolidCone(length = 2.0, width = 1.0, height = 1.0, n = 40)
        c2 = G.SolidCone(length = 3.0, width = 0.1, height = 0.2, n = 40)
        m = G.Mesh([c, c2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(c) + G.nvertices(c2)
    @test G.ntriangles(m) == G.ntriangles(c) + G.ntriangles(c2)
    @test abs(G.area(m) - (G.area(c) + G.area(c2))) < 2e-15

    # Create a solid cone using affine maps
    scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
    c3 = G.SolidCone(scale, n = 40)
    @test c3.normals == c2.normals
    @test c3.vertices == c2.vertices

    # Create a solid cone ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
        m = G.SolidCone(length = 2.0, width = 1.0, height = 1.0, n = 40)
        G.SolidCone!(m, scale, n = 40)
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
