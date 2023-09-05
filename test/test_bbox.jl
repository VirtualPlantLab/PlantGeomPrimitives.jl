import PlantGeomPrimitives as G
using Test

let

    # Standard bbox primitive
    b = G.BBox(G.Vec(0.0, 0.0, 0.0), G.Vec(1.0, 1.0, 1.0))
    @test b isa G.Mesh
    @test G.area(b) == 6.0
    @test G.nvertices(b) == 8
    @test G.ntriangles(b) == 12

    # Check that it works with lower precision
    b = G.BBox(G.Vec(0.0f0, 0.0f0, 0.0f0), G.Vec(1.0f0, 1.0f0, 1.0f0))
    @test b isa G.Mesh
    @test G.area(b) == 6.0f0
    @test G.nvertices(b) == 8
    @test G.ntriangles(b) == 12

end
