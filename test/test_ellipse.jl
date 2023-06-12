import VPLGeom as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard ellipse primitive
    e = G.Ellipse(length = 2.0, width = 2.0, n = 10)
    @test e isa G.Mesh
    @test abs(G.area(e) / pi - 1.0) < 0.13
    @test G.nvertices(e) == 11
    @test G.ntriangles(e) == 10
    @test all(e.normals[1] .== [1.0, 0.0, 0.0])

    # Check a different precision works
    e = G.Ellipse(length = 2.0f0, width = 2.0f0, n = 10)
    @test e isa G.Mesh
    @test abs(G.area(e) / Float32(pi) - 1.0f0) < 0.13f0

    # Mergin two meshes
    e = G.Ellipse(length = 2.0, width = 2.0, n = 10)
    e2 = G.Ellipse(length = 3.0, width = 0.1, n = 10)
    function foo()
        e = G.Ellipse(length = 2.0, width = 2.0, n = 10)
        e2 = G.Ellipse(length = 3.0, width = 0.1, n = 10)
        m = G.Mesh([e, e2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(e) + G.nvertices(e2)
    @test G.ntriangles(m) == G.ntriangles(e) + G.ntriangles(e2)
    @test abs(G.area(m) - (G.area(e) + G.area(e2))) < 3e-15

    # Create a ellipse using affine maps
    scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
    e3 = G.Ellipse(scale, n = 10)
    @test e3.normals == e2.normals
    @test e3.vertices ≈ e2.vertices
    @test e3.faces == e2.faces

    # Create a ellipse ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
        m = G.Ellipse(length = 2.0, width = 2.0, n = 10)
        G.Ellipse!(m, scale, n = 10)
        m
    end
    m2 = foo2()
    @test m2.vertices == m.vertices
    @test m2.normals == m.normals
    @test m2.faces == m.faces

end
