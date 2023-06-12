import VPLGeom as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard cube primitive
    c = G.HollowCube(length = 1.0, width = 1.0, height = 1.0)
    @test c isa G.Mesh
    @test G.area(c) === 4.0
    @test G.nvertices(c) == 8
    @test G.ntriangles(c) == 8

    # Check a different precision works
    c = G.HollowCube(length = 1.0f0, width = 1.0f0, height = 1.0f0)
    @test c isa G.Mesh
    @test G.area(c) === 4.0f0
    @test G.nvertices(c) == 8
    @test G.ntriangles(c) == 8

    # Mergin two meshes
    c2 = G.HollowCube(length = 0.5, width = 0.5, height = 3.0)
    function foo()
        c2 = G.HollowCube(length = 0.5, width = 0.5, height = 3.0)
        c = G.HollowCube(length = 1.0, width = 1.0, height = 1.0)
        G.Mesh([c, c2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(c) + G.nvertices(c2)
    @test G.ntriangles(m) == G.ntriangles(c) + G.ntriangles(c2)
    @test G.area(m) == G.area(c) + G.area(c2)

    # Create a box using affine maps
    scale = LinearMap(SDiagonal(3 / 2, 0.5 / 2, 0.5))
    c3 = G.HollowCube(scale)
    @test c3.normals == c2.normals
    @test c3.vertices == c2.vertices
    @test c3.faces == c2.faces

    # Create a box ussing affine maps and add it to an existing mesh
    function foo2()
        scale1 = LinearMap(SDiagonal(0.5, 0.5, 1.0))
        scale2 = LinearMap(SDiagonal(1.5, 0.25, 0.5))
        m = G.Mesh()
        G.HollowCube!(m, scale1)
        G.HollowCube!(m, scale2)
        m
    end
    m2 = foo2()
    @test m2.vertices == m.vertices
    @test m2.normals == m.normals
    @test m2.faces == m.faces

end