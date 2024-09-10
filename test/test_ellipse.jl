import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let

    # Standard ellipse primitive
    e = G.Ellipse(length = 2.0, width = 2.0, n = 10)
    @test e isa G.Mesh
    @test abs(G.area(e) / pi - 1.0) < 0.13
    @test G.nvertices(e) == 30
    @test G.ntriangles(e) == div(G.nvertices(e), 3)
    @test length(G.normals(e)) == G.ntriangles(e)

    # Check a different precision works
    e = G.Ellipse(length = 2.0f0, width = 2.0f0, n = 10)
    @test e isa G.Mesh
    @test abs(G.area(e) / Float32(pi) - 1.0f0) < 0.13f0

    # Merging two meshes
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
    @test e3 ≈ e2

    # Create a ellipse ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
        m = G.Ellipse(length = 2.0, width = 2.0, n = 10)
        G.Ellipse!(m, scale, n = 10)
        m
    end
    m2 = foo2()
    @test m2 == m

end

# import GLMakie
# import PlantViz as PV
# PV.render(m, normals = true)
# PV.render!(m2, normals = true, color = :red)
