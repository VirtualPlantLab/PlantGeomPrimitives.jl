import VPLGeom as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard hollow frustum primitive
    c = G.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20)
    @test c isa G.Mesh
    exact_area = (pi + 0.5pi) / 2 * sqrt(2^2 + 0.25^2)
    @test abs(G.area(c) - exact_area) < 0.1
    @test G.nvertices(c) == 20
    @test G.ntriangles(c) == 20
    @test length(c.normals) == 20

    # Check that it works at lower precision
    c = G.HollowFrustum(
        length = 2.0f0,
        width = 1.0f0,
        height = 1.0f0,
        ratio = 0.5f0,
        n = 20,
    )
    @test c isa G.Mesh
    exact_area = (pi + 0.5pi) / 2 * sqrt(2^2 + 0.25^2)
    @test abs(G.area(c) - exact_area) < 0.1
    @test G.nvertices(c) == 20
    @test G.ntriangles(c) == 20
    @test length(c.normals) == 20

    # Mergin two meshes
    c = G.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20)
    c2 = G.HollowFrustum(length = 3.0, width = 0.1, height = 0.2, ratio = 1 / 10, n = 20)
    function foo()
        c = G.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20)
        c2 =
            G.HollowFrustum(length = 3.0, width = 0.1, height = 0.2, ratio = 1 / 10, n = 20)
        m = G.Mesh([c, c2])
    end
    m = foo()
    @test G.nvertices(m) == G.nvertices(c) + G.nvertices(c2)
    @test G.ntriangles(m) == G.ntriangles(c) + G.ntriangles(c2)
    @test abs(G.area(m) - (G.area(c) + G.area(c2))) < 1e-15

    # Create a hollow frustum using affine maps
    scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
    c3 = G.HollowFrustum(1 / 10, scale, n = 20)
    @test c3.normals == c2.normals
    @test c3.vertices == c2.vertices
    @test c3.faces == c2.faces

    # Create a frustum ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(0.2 / 2, 0.1 / 2, 3.0))
        m = G.HollowFrustum(length = 2.0, width = 1.0, height = 1.0, ratio = 0.5, n = 20)
        G.HollowFrustum!(m, 1 / 10, scale, n = 20)
        m
    end
    m2 = foo2()
    @test m2.vertices == m.vertices
    @test m2.normals == m.normals
    @test m2.faces == m.faces

end
