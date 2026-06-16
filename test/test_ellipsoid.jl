import PlantGeomPrimitives as G
using Test
import CoordinateTransformations: SDiagonal, LinearMap

let
    n = 20

    # Standard Ellipsoid primitive
    e = G.Ellipsoid(length = 2.0, width = 1.0, height = 1.0, n = n)
    @test e isa G.Mesh
    @test G.nvertices(e) == 6n * (n - 1)
    @test G.ntriangles(e) == div(G.nvertices(e), 3)
    @test length(G.normals(e)) == G.ntriangles(e)

    # Area test: sphere of diameter 2 (length=width=height=2) -> area = 4π
    e_sphere = G.Ellipsoid(length = 2.0, width = 2.0, height = 2.0, n = n)
    @test abs(G.area(e_sphere) / (4π) - 1.0) < 0.02

    # Outward normals: each face normal must point away from the ellipsoid center
    center = G.Vec(0.0, 0.0, 1.0)  # canonical (0,0,1) mapped by SDiagonal(1,1,1)
    for i in 1:G.ntriangles(e_sphere)
        tri      = G.get_triangle(e_sphere, i)
        centroid = (tri[1] .+ tri[2] .+ tri[3]) ./ 3
        @test sum(G.normals(e_sphere)[i] .* (centroid .- center)) > 0
    end

    # Float32 variant
    e32 = G.Ellipsoid(length = 2.0f0, width = 1.0f0, height = 1.0f0, n = n)
    @test e32 isa G.Mesh
    @test G.nvertices(e32) == 6n * (n - 1)
    @test G.ntriangles(e32) == div(G.nvertices(e32), 3)
    @test length(G.normals(e32)) == G.ntriangles(e32)

    # Merging two meshes
    e2 = G.Ellipsoid(length = 3.0, width = 0.5, height = 0.5, n = n)
    function foo()
        e  = G.Ellipsoid(length = 2.0, width = 1.0, height = 1.0, n = n)
        e2 = G.Ellipsoid(length = 3.0, width = 0.5, height = 0.5, n = n)
        G.Mesh([e, e2])
    end
    m = foo()
    @test G.nvertices(m)  == G.nvertices(e)  + G.nvertices(e2)
    @test G.ntriangles(m) == G.ntriangles(e) + G.ntriangles(e2)
    @test abs(G.area(m) - (G.area(e) + G.area(e2))) < 1e-10

    # Affine map equivalence: keyword constructor and explicit LinearMap must agree
    scale = LinearMap(SDiagonal(0.5 / 2, 0.5 / 2, 0.5 / 2))
    e3 = G.Ellipsoid(scale; n = n)
    e4 = G.Ellipsoid(length = 0.5, width = 0.5, height = 0.5, n = n)
    @test G.normals(e3)   == G.normals(e4)
    @test G.vertices(e3)  == G.vertices(e4)

    # In-place Ellipsoid!
    function foo2()
        m2     = G.Ellipsoid(length = 2.0, width = 1.0, height = 1.0, n = n)
        scale2 = LinearMap(SDiagonal(0.25 / 2, 0.5 / 2, 1.5 / 2))
        G.Ellipsoid!(m2, scale2; n = n)
        m2
    end
    m2 = foo2()
    e5 = G.Ellipsoid(length = 1.5, width = 0.5, height = 0.25, n = n)
    @test G.nvertices(m2)  == G.nvertices(e) + G.nvertices(e5)
    @test G.ntriangles(m2) == G.ntriangles(e) + G.ntriangles(e5)
end


#= import GLMakie
import PlantViz as PV
e = G.Ellipsoid(length = 1.0, width = 1.0, height = 1.0, n = n)
G.add_property!(e, :colors, RGB(1.0, 0.0, 0.0))
PV.render(e, normals = true)
=#