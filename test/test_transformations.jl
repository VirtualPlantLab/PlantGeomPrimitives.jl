import PlantGeomPrimitives as G
using Test

let

    m = G.Rectangle()
    m_area = G.area(m)

    # Scaling
    m2 = deepcopy(m)
    G.scale!(m2, G.Vec(1.0, 1.0, 2.0))
    G.area(m2) == 2 * m_area

    # Rotating around x axis
    m3 = deepcopy(m)
    G.rotatex!(m3, 45.0)
    @test all(getindex.(G.vertices(m3), 1) .≈ getindex.(G.vertices(m), 1))
    @test all(getindex.(G.vertices(m3), 2) .!== getindex.(G.vertices(m), 2))
    @test all(getindex.(G.vertices(m3), 3) .!== getindex.(G.vertices(m), 3))
    @test all(G.normals(m3) .≈ G.normals(m))
    G.rotatex!(m3, -45.0)
    @test all(G.vertices(m3) .≈ G.vertices(m))

    # Rotating around y axis
    m3 = deepcopy(m)
    G.rotatey!(m3, 45.0)
    @test all(
        (getindex.(G.vertices(m3), 1) .!== getindex.(G.vertices(m), 1)) .==
        [true, true, false, true, false, false],
    )
    @test all(getindex.(G.vertices(m3), 2) .≈ getindex.(G.vertices(m), 2))
    @test all(
        (getindex.(G.vertices(m3), 3) .!== getindex.(G.vertices(m), 3)) .==
        [true, true, false, true, false, false],
    )
    @test all(G.normals(m3) .!== G.normals(m))
    G.rotatey!(m3, -45.0)
    @test all(G.vertices(m3) .≈ G.vertices(m))

    # Rotating around z axis
    m3 = deepcopy(m)
    G.rotatez!(m3, 45.0)
    @test all((getindex.(G.vertices(m3), 1) .!== getindex.(G.vertices(m), 1)))
    @test all(getindex.(G.vertices(m3), 2) .!== getindex.(G.vertices(m), 2))
    @test all(getindex.(G.vertices(m3), 3) .≈ getindex.(G.vertices(m), 3))
    @test all(G.normals(m3) .!== G.normals(m))
    G.rotatez!(m3, -45.0)
    @test all(G.vertices(m3) .≈ G.vertices(m))

    # Rotate along all axis simulatenously
    m4 = deepcopy(m)
    G.rotate!(m4, x = G.X(), y = G.Y(), z = .-G.Z())
    @test all(getindex.(G.vertices(m4), 1) .== getindex.(G.vertices(m), 1))
    @test all(getindex.(G.vertices(m4), 2) .== getindex.(G.vertices(m), 2))
    @test all((getindex.(G.vertices(m4), 3) .== getindex.(G.vertices(m), 3)) .==
        [false, false, true, false, true, true])
    @test all(G.normals(m4) .== G.normals(m))

    # Translating along the x axis
    m4 = deepcopy(m)
    G.translate!(m4, G.Vec(2.0, 0.0, 0.0))
    @test all((getindex.(G.vertices(m4), 1) .!== getindex.(G.vertices(m), 1)))
    @test all(getindex.(G.vertices(m4), 2) .≈ getindex.(G.vertices(m), 2))
    @test all(getindex.(G.vertices(m4), 3) .≈ getindex.(G.vertices(m), 3))
    @test all(G.normals(m4) .≈ G.normals(m))
    G.translate!(m4, G.Vec(-2.0, 0.0, 0.0))
    @test all(G.vertices(m4) .≈ G.vertices(m))

    # Translating along the y axis
    m4 = deepcopy(m)
    G.translate!(m4, G.Vec(0.0, 2.0, 0.0))
    @test all((getindex.(G.vertices(m4), 1) .≈ getindex.(G.vertices(m), 1)))
    @test all(getindex.(G.vertices(m4), 2) .!== getindex.(G.vertices(m), 2))
    @test all(getindex.(G.vertices(m4), 3) .≈ getindex.(G.vertices(m), 3))
    @test all(G.normals(m4) .≈ G.normals(m))
    G.translate!(m4, G.Vec(0.0, -2.0, 0.0))
    @test all(G.vertices(m4) .≈ G.vertices(m))

    # Translating along the z axis
    m4 = deepcopy(m)
    G.translate!(m4, G.Vec(0.0, 0.0, 2.0))
    @test all((getindex.(G.vertices(m4), 1) .≈ getindex.(G.vertices(m), 1)))
    @test all(getindex.(G.vertices(m4), 2) .≈ getindex.(G.vertices(m), 2))
    @test all(getindex.(G.vertices(m4), 3) .!== getindex.(G.vertices(m), 3))
    @test all(G.normals(m4) .≈ G.normals(m))
    G.translate!(m4, G.Vec(0.0, 0.0, -2.0))
    @test all(G.vertices(m4) .≈ G.vertices(m))

end
