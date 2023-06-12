import VPLGeom as G
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
    @test all(getindex.(m3.vertices, 1) .≈ getindex.(m.vertices, 1))
    @test all(getindex.(m3.vertices, 2) .!== getindex.(m.vertices, 2))
    @test all(getindex.(m3.vertices, 3) .!== getindex.(m.vertices, 3))
    @test all(m3.normals .≈ m.normals)
    G.rotatex!(m3, -45.0)
    @test all(m3.vertices .≈ m.vertices)

    # Rotating around y axis
    m3 = deepcopy(m)
    G.rotatey!(m3, 45.0)
    @test all(
        (getindex.(m3.vertices, 1) .!== getindex.(m.vertices, 1)) .==
        [false, true, true, false],
    )
    @test all(getindex.(m3.vertices, 2) .≈ getindex.(m.vertices, 2))
    @test all(
        (getindex.(m3.vertices, 3) .!== getindex.(m.vertices, 3)) .==
        [false, true, true, false],
    )
    @test all(m3.normals .!== m.normals)
    G.rotatey!(m3, -45.0)
    @test all(m3.vertices .≈ m.vertices)

    # Rotating around z axis
    m3 = deepcopy(m)
    G.rotatez!(m3, 45.0)
    @test all((getindex.(m3.vertices, 1) .!== getindex.(m.vertices, 1)))
    @test all(getindex.(m3.vertices, 2) .!== getindex.(m.vertices, 2))
    @test all(getindex.(m3.vertices, 3) .≈ getindex.(m.vertices, 3))
    @test all(m3.normals .!== m.normals)
    G.rotatez!(m3, -45.0)
    @test all(m3.vertices .≈ m.vertices)

    # Translating along the x axis
    m4 = deepcopy(m)
    G.translate!(m4, G.Vec(2.0, 0.0, 0.0))
    @test all((getindex.(m4.vertices, 1) .!== getindex.(m.vertices, 1)))
    @test all(getindex.(m4.vertices, 2) .≈ getindex.(m.vertices, 2))
    @test all(getindex.(m4.vertices, 3) .≈ getindex.(m.vertices, 3))
    @test all(m4.normals .≈ m.normals)
    G.translate!(m4, G.Vec(-2.0, 0.0, 0.0))
    @test all(m4.vertices .≈ m.vertices)

    # Translating along the y axis
    m4 = deepcopy(m)
    G.translate!(m4, G.Vec(0.0, 2.0, 0.0))
    @test all((getindex.(m4.vertices, 1) .≈ getindex.(m.vertices, 1)))
    @test all(getindex.(m4.vertices, 2) .!== getindex.(m.vertices, 2))
    @test all(getindex.(m4.vertices, 3) .≈ getindex.(m.vertices, 3))
    @test all(m4.normals .≈ m.normals)
    G.translate!(m4, G.Vec(0.0, -2.0, 0.0))
    @test all(m4.vertices .≈ m.vertices)

    # Translating along the z axis
    m4 = deepcopy(m)
    G.translate!(m4, G.Vec(0.0, 0.0, 2.0))
    @test all((getindex.(m4.vertices, 1) .≈ getindex.(m.vertices, 1)))
    @test all(getindex.(m4.vertices, 2) .≈ getindex.(m.vertices, 2))
    @test all(getindex.(m4.vertices, 3) .!== getindex.(m.vertices, 3))
    @test all(m4.normals .≈ m.normals)
    G.translate!(m4, G.Vec(0.0, 0.0, -2.0))
    @test all(m4.vertices .≈ m.vertices)

end
