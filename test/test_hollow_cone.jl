import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard hollow cone primitive
    c = G.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10)
    @test c isa G.Mesh
    @test abs(G.area(c) - sqrt(4 + 0.25) * pi / 2) < 0.07
    @test G.nvertices(c) == 11
    @test G.ntriangles(c) == 10
    @test length(c.normals) == 10

    # Check that it works for different floating point precisions
    c = G.HollowCone(length = 2.0f0, width = 1.0f0, height = 1.0f0, n = 10)
    @test c isa G.Mesh
    @test abs(G.area(c) - sqrt(4 + 0.25) * pi / 2) < 0.07
    @test G.nvertices(c) == 11
    @test G.ntriangles(c) == 10
    @test length(c.normals) == 10

    # Merging two meshes
    c = G.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10)
    c2 = G.HollowCone(length = 3.0, width = 0.1, height = 0.2, n = 10)
    function foo()
        c = G.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10)
        c2 = G.HollowCone(length = 3.0, width = 0.1, height = 0.2, n = 10)
        m = G.Mesh([c, c2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(c) + G.nvertices(c2)
    @test G.ntriangles(m) == G.ntriangles(c) + G.ntriangles(c2)
    @test abs(G.area(m) - (G.area(c) + G.area(c2))) < 9e-16

    # Create a hollow cone using affine maps
    scale = LinearMap(SDiagonal(0.1, 0.05, 3.0))
    c3 = G.HollowCone(scale, n = 10)
    @test c3.normals == c2.normals
    @test c3.vertices == c2.vertices
    @test c3.faces == c2.faces

    # Create a cone ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(0.1, 0.05, 3.0))
        m = G.HollowCone(length = 2.0, width = 1.0, height = 1.0, n = 10)
        G.HollowCone!(m, scale, n = 10)
        m
    end
    m2 = foo2()
    @test m2.vertices == m.vertices
    @test m2.normals == m.normals
    @test m2.faces == m.faces

end
