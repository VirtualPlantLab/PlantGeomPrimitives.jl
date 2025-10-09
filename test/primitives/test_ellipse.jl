import PlantGeomPrimitives as PGP
using PlantGeomPrimitives
using Test
import CoordinateTransformations: SDiagonal, LinearMap

#let
    ##### Mesh #####
    area(e) = sum(calculate_areas(e))

    # Standard ellipse primitive
    e = Ellipse(length = 2.0, width = 2.0, n = 10)
    @test e isa Mesh{Float64}
    @test abs(area(e)/pi - 1) < 0.07
    @test nvertices(e) == 30
    @test ntriangles(e) == div(nvertices(e), 3)
    @test length(normals(e)) == ntriangles(e)
    @test normals(e)[1] == normals(e)[3]
    @test normals(e)[1] == Vec(1.0, 0.0, 0.0)

    # Check a different precision works
    e = Ellipse(length = 2.0f0, width = 2.0f0, n = 10)
    @test e isa Mesh{Float32}
    @test abs(area(e)/pi - 1f0) < 0.07f0

    # Merging two meshes
    e = Ellipse(length = 2.0, width = 2.0, n = 10)
    e2 = Ellipse(length = 3.0, width = 0.1, n = 10)
    function foo()
        e = Ellipse(length = 2.0, width = 2.0, n = 10)
        e2 = Ellipse(length = 3.0, width = 0.1, n = 10)
        m = Mesh([e, e2])
    end
    m = foo()
    @test nvertices(m) == nvertices(e) + nvertices(e2)
    @test ntriangles(m) == ntriangles(e) + ntriangles(e2)
    @test abs(area(m) - (area(e) + area(e2))) < 3e-15

    # Create a ellipse using affine maps
    scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
    e3 = EllipseMesh(scale, n = 10)
    @test e3 ≈ e2

    # Create a ellipse ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
        m = Ellipse(length = 2.0, width = 2.0, n = 10)
        Ellipse!(m, scale, n = 10)
        m
    end
    m2 = foo2()
    @test m2 == m

    ## Visualize the primitives
    # import GLMakie
    # import PlantViz as PV
    # import ColorTypes: RGB
    # add_property!(m, :colors, [RGB(1, 0, 0) for _ in 1:ntriangles(m)])
    # PV.render(m, normals = true)
    # PV.render!(m2, normals = true)

    ##### Points #####

    area_points(e) = sum(areas(e))

    # Standard ellipse primitive
    np = 30
    e = Ellipse(Points{Float64}, length = 2.0, width = 2.0, n = np)
    @test e isa Points{Float64}
    @test abs(area_points(e)/pi - 1) < 1e-8
    @test nvertices(e) == np
    @test npoints(e) == nvertices(e)
    @test length(normals(e)) == npoints(e)
    @test normals(e)[1] == normals(e)[3]
    @test normals(e)[1] == Vec(1.0, 0.0, 0.0)

    # Check a different precision works
    e = Ellipse(Points{Float32}, length = 2.0f0, width = 2.0f0, n = 10)
    @test e isa Points{Float32}
    @test abs(area_points(e)/pi - 1f0) < 1f-6

    # Merging two point clouds
    e = Ellipse(Points{Float64}, length = 2.0, width = 2.0, n = 10)
    e2 = Ellipse(Points{Float64}, length = 3.0, width = 0.1, n = 10)
    function foo()
        e = Ellipse(Points{Float64}, length = 2.0, width = 2.0, n = 10)
        e2 = Ellipse(Points{Float64}, length = 3.0, width = 0.1, n = 10)
        m = Points([e, e2])
    end
    m = foo()
    @test nvertices(m) == nvertices(e) + nvertices(e2)
    @test npoints(m) == npoints(e) + npoints(e2)
    @test abs(area_points(m) - (area_points(e) + area_points(e2))) < 1e-15

    # Create a ellipse using affine maps
    scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
    e3 = EllipsePoints(scale, n = 10, area = 3*0.1*pi/4)
    @test e3 ≈ e2

    # Create a ellipse ussing affine maps and add it to an existing mesh
    function foo2()
        scale = LinearMap(SDiagonal(1.0, 0.05, 1.5))
        e = Ellipse(Points{Float64}, length = 2.0, width = 2.0, n = 10)
        Ellipse!(e, scale, n = 10, area = 3*0.1*pi/4)
        e
    end
    e2 = foo2()
    @test e2 == m


    @descend foo2()

    @btime Ellipse(Points{Float64}, length = 2.0, width = 2.0, n = 10, sampler = sampler) setup=(
        sampler = PointSampler(2)
    )
    @btime PointSampler(2)
    @btime Ellipse!(e, scale, n = 10, area = 3*0.1*pi/4, sampler = sampler) setup=(
        scale = LinearMap(SDiagonal(1.0, 0.05, 1.5));
        e = Ellipse(Points{Float64}, length = 2.0, width = 2.0, n = 10);
        sampler = PointSampler(2);
        evals = 1
    )


    @btime convert(Dict{Symbol, Union{Vector{Int64}, Vector{Float64}, Vector{Float32}}}, $d)
    dn[:c] = [1f0]
    ## Visualize the primitives
    # using Plots
    # px = getindex.(vertices(e), 1)
    # py = getindex.(vertices(e), 2)
    # pz = getindex.(vertices(e), 3)
    # scatter(py, pz)

#end
