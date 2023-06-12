import VPLGeom as G
using Test

let

    # Binary STL
    c = G.SolidCube(length = 0.5, width = 2.0, height = 1 / 3)
    G.savemesh(c, fileformat = :STL_BINARY, filename = "meshes/r.bstl")
    c2 = G.loadmesh("meshes/r.bstl")
    @test G.area(c) ≈ G.area(c2)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c2) == G.ntriangles(c2) * 3
    @test c.normals == c2.normals
    @test G.BBox(c) ≈ G.BBox(c2)

    # ASCII STL
    G.savemesh(c, fileformat = :STL_ASCII, filename = "meshes/r.astl")
    c2 = G.loadmesh("meshes/r.astl")
    @test isapprox(G.area(c), G.area(c2), atol = 4e-7)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c2) == G.ntriangles(c2) * 3
    @test c.normals ≈ c2.normals
    @test isapprox(G.BBox(c), G.BBox(c2), atol = 4e-7)

    # BINARY PLY
    G.savemesh(c, fileformat = :PLY_BINARY, filename = "meshes/r.bply")
    # c2 = loadmesh("meshes/r.bply")
    # (MeshIO does not support Binary PLY formats)

    # ASCII PLY
    G.savemesh(c, fileformat = :PLY_ASCII, filename = "meshes/r.aply")
    c2 = G.loadmesh("meshes/r.aply")
    @test G.area(c) ≈ G.area(c2)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c) == G.nvertices(c2)
    @test c.normals ≈ c2.normals
    @test G.BBox(c) ≈ G.BBox(c2)

    # OBJ
    G.savemesh(c, fileformat = :OBJ, filename = "meshes/r.obj")
    c2 = G.loadmesh("meshes/r.obj")
    @test G.area(c) ≈ G.area(c2)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c) == G.nvertices(c2)
    @test c.normals ≈ c2.normals
    @test G.BBox(c) ≈ G.BBox(c2)


end
