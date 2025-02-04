using Test
import Aqua
import PlantGeomPrimitives
using Documenter

# Test examples on documentation (jldoctest blocks)
DocMeta.setdocmeta!(
    PlantGeomPrimitives,
    :DocTestSetup,
    :(using PlantGeomPrimitives);
    recursive = true,
)
doctest(PlantGeomPrimitives)

# Aqua
@testset "Aqua" begin
    Aqua.test_all(PlantGeomPrimitives, ambiguities = false)
    Aqua.test_ambiguities([PlantGeomPrimitives])
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

# Make sure normals are correct
@testset "normals" begin
    include("test_normals.jl")
end

# Test the creation of edges
@testset "edges" begin
    include("test_edges.jl")
end

# Test the slicing of meshes
@testset "slicer" begin
    include("test_slicer.jl")
end

# Mesh I/O
@testset "mesh_io" begin
    include("test_meshio.jl")
end

# Different cases where properties are added
@testset "properties" begin
    include("test_properties.jl")
end
