import PlantGeomPrimitives as G
import ColorTypes: RGB, Colorant
using Test

# Note: Colorant is an abstract type from the ColorTypes package
# Note: Concrete types that inherit from Material are defined in the PlantRayTracer package

struct ExampleMaterial <: G.Material
end

let

# Empty constructor
sc = G.Scene()
@test sc isa G.Scene
@test G.mesh(sc) isa G.Mesh
@test G.ntriangles(G.mesh(sc)) == 0
@test G.vertices(sc) isa Array{G.Vec{Float64}, 1}
@test isempty(G.vertices(sc))
@test G.nvertices(sc) == 0
@test G.normals(sc) isa Array{G.Vec{Float64}, 1}
@test isempty(G.normals(sc))
@test G.colors(sc) isa Array{Colorant, 1}
@test isempty(G.colors(sc))
@test G.materials(sc) isa Array{G.Material, 1}
@test isempty(G.materials(sc))
@test G.material_ids(sc) isa Array{Int, 1}
@test isempty(G.material_ids(sc))

# Adding empty mesh without colors or materials
G.add!(sc; mesh = G.Mesh())
@test G.nvertices(sc) == 0
@test isempty(G.colors(sc))
@test isempty(G.materials(sc))
@test isempty(G.material_ids(sc))

# Adding mesh without colors or materials
G.add!(sc; mesh = G.Triangle())
@test G.nvertices(sc) == 3
@test G.ntriangles(G.mesh(sc)) == 1
@test isempty(G.colors(sc))
@test isempty(G.materials(sc))
@test isempty(G.material_ids(sc))
sc2 = G.Scene(mesh = G.Triangle())
G.mesh(sc) == G.mesh(sc2)
G.materials(sc) == G.materials(sc2)
G.colors(sc) == G.colors(sc2)

## Adding mesh with one color but no materials
sc = G.Scene()
G.add!(sc; mesh = G.Triangle(), colors = RGB(1, 0, 0))
@test G.nvertices(sc) == 3
@test G.ntriangles(G.mesh(sc)) == div(G.nvertices(sc), 3)
@test length(G.colors(sc)) == G.nvertices(sc)
@test isempty(G.materials(sc))
@test isempty(G.material_ids(sc))
sc2 = G.Scene(mesh = G.Triangle(), colors = RGB(1, 0, 0))
G.mesh(sc) == G.mesh(sc2)
G.materials(sc) == G.materials(sc2)
G.colors(sc) == G.colors(sc2)

# Adding mesh with multiple colors and no materials
sc = G.Scene()
G.add!(sc; mesh = G.Rectangle(), colors = [RGB(1, 0, 0), RGB(0, 1, 0)])
@test G.nvertices(sc) == 6
@test G.ntriangles(G.mesh(sc)) == div(G.nvertices(sc), 3)
@test length(G.colors(sc)) == G.nvertices(sc)
@test G.colors(sc)[1] == G.colors(sc)[2] == G.colors(sc)[3] == RGB(1, 0, 0)
@test G.colors(sc)[4] == G.colors(sc)[5] == G.colors(sc)[6] == RGB(0, 1, 0)
@test isempty(G.materials(sc))
@test isempty(G.material_ids(sc))
sc2 = G.Scene(mesh = G.Rectangle(), colors = [RGB(1, 0, 0), RGB(0, 1, 0)])
G.mesh(sc) == G.mesh(sc2)
G.materials(sc) == G.materials(sc2)
G.colors(sc) == G.colors(sc2)


# Adding mesh with multiple colors and one material
sc = G.Scene()
G.add!(sc; mesh = G.Rectangle(), colors = [RGB(1, 0, 0), RGB(0, 1, 0)], materials = ExampleMaterial())
@test G.nvertices(sc) == 6
@test G.ntriangles(G.mesh(sc)) == div(G.nvertices(sc), 3)
@test length(G.colors(sc)) == G.nvertices(sc)
@test G.colors(sc)[1] == G.colors(sc)[2] == G.colors(sc)[3] == RGB(1, 0, 0)
@test G.colors(sc)[4] == G.colors(sc)[5] == G.colors(sc)[6] == RGB(0, 1, 0)
@test length(G.materials(sc)) == 1
@test G.materials(sc)[1] isa ExampleMaterial
@test length(G.material_ids(sc)) == G.ntriangles(G.mesh(sc))
@test G.material_ids(sc)[1] == 1
sc2 = G.Scene(mesh = G.Rectangle(), colors = [RGB(1, 0, 0), RGB(0, 1, 0)], materials = ExampleMaterial())
G.mesh(sc) == G.mesh(sc2)
G.materials(sc) == G.materials(sc2)
G.colors(sc) == G.colors(sc2)

# Adding mesh with multiple colors and materials
sc = G.Scene()
G.add!(sc; mesh = G.Rectangle(), colors = [RGB(1, 0, 0), RGB(0, 1, 0)], materials = [ExampleMaterial() for i in 1:2])
@test G.nvertices(sc) == 6
@test G.ntriangles(G.mesh(sc)) == div(G.nvertices(sc), 3)
@test length(G.colors(sc)) == G.nvertices(sc)
@test G.colors(sc)[1] == G.colors(sc)[2] == G.colors(sc)[3] == RGB(1, 0, 0)
@test G.colors(sc)[4] == G.colors(sc)[5] == G.colors(sc)[6] == RGB(0, 1, 0)
@test length(G.materials(sc)) == 2
@test G.materials(sc)[1] isa ExampleMaterial
@test length(G.material_ids(sc)) == G.ntriangles(G.mesh(sc))
@test G.material_ids(sc) == [1,2]
sc2 = G.Scene(mesh = G.Rectangle(), colors = [RGB(1, 0, 0), RGB(0, 1, 0)], materials = [ExampleMaterial() for i in 1:2])
G.mesh(sc) == G.mesh(sc2)
G.materials(sc) == G.materials(sc2)
G.colors(sc) == G.colors(sc2)

end
