import PlantGeomPrimitives as G
using Test

let
    input  = joinpath(dirname(@__FILE__), "meshes")
    output = joinpath(dirname(@__FILE__), "test_meshes")
    mkpath(output)

    # Binary STL
    c = G.SolidCube(length = 0.5, width = 2.0, height = 1 / 3)
    update_normals!(c)
    G.save_mesh(c, fileformat = :STL_BINARY, filename = joinpath(output, "r.bstl"))
    c2 = G.load_mesh(joinpath(input, "r.bstl"))
    update_normals!(c2)
    @test G.area(c) ≈ G.area(c2)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c2) == G.ntriangles(c2) * 3
    @test G.normals(c) ≈ G.normals(c2)
    @test G.BBox(c) ≈ G.BBox(c2)

    # ASCII STL
    G.save_mesh(c, fileformat = :STL_ASCII, filename = joinpath(output, "r.astl"))
    c2 = G.load_mesh(joinpath(input, "r.astl"))
    update_normals!(c2)
    @test isapprox(G.area(c), G.area(c2), atol = 4e-7)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c2) == G.ntriangles(c2) * 3
    @test G.normals(c) ≈ G.normals(c2)
    @test isapprox(G.BBox(c), G.BBox(c2), atol = 4e-7)

    # BINARY PLY
    G.save_mesh(c, fileformat = :PLY_BINARY, filename = joinpath(output, "r.bply"))
    # c2 = loadmesh("meshes/r.bply")
    # (MeshIO does not support Binary PLY formats)

    # ASCII PLY
    G.save_mesh(c, fileformat = :PLY_ASCII, filename = joinpath(output, "r.aply"))
    c2 = G.load_mesh(joinpath(input, "r.aply"))
    update_normals!(c2)
    @test G.area(c) ≈ G.area(c2)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c) == G.nvertices(c2)
    @test G.normals(c) ≈ G.normals(c2)
    @test G.BBox(c) ≈ G.BBox(c2)

    # OBJ
    G.save_mesh(c, fileformat = :OBJ, filename = joinpath(output, "r.obj"))
    c2 = G.load_mesh(joinpath(input, "r.obj"))
    update_normals!(c2)
    @test G.area(c) ≈ G.area(c2)
    @test G.ntriangles(c) == G.ntriangles(c2)
    @test G.nvertices(c) == G.nvertices(c2)
    @test G.normals(c) ≈ G.normals(c2)
    @test G.BBox(c) ≈ G.BBox(c2)

end
