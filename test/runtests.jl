using Test
import Aqua
import VPLGeom

@testset "VPLGeom.jl" begin

    # Aqua
    @testset "Aqua" begin
        Aqua.test_all(VPLGeom, ambiguities = false)
        Aqua.test_ambiguities([VPLGeom])
    end

    # Direct meshing
    @testset "ellipse" begin
        include("test_ellipse.jl")
    end
    @testset "bbox" begin
        include("test_bbox.jl")
    end
    @testset "rectangle" begin
        include("test_rectangle.jl")
    end
    @testset "triangle" begin
        include("test_triangle.jl")
    end
    @testset "trapezoid" begin
        include("test_trapezoid.jl")
    end
    @testset "solid_cube" begin
        include("test_solid_cube.jl")
    end
    @testset "hollow_cube" begin
        include("test_hollow_cube.jl")
    end
    @testset "hollow_cylinder" begin
        include("test_hollow_cylinder.jl")
    end
    @testset "solid_cylinder" begin
        include("test_solid_cylinder.jl")
    end
    @testset "hollow_frustum" begin
        include("test_hollow_frustum.jl")
    end
    @testset "solid_frustum" begin
        include("test_solid_frustum.jl")
    end
    @testset "hollow_cone" begin
        include("test_hollow_cone.jl")
    end
    @testset "solid_cone" begin
        include("test_solid_cone.jl")
    end
    @testset "transformations" begin
        include("test_transformations.jl")
    end
end
