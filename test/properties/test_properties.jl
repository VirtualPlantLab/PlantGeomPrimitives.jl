using PlantGeomPrimitives
import PlantGeomPrimitives as PGP
using Test

let

# Create geometry and add vertices and properties automatically (one value)
m = Geom(Val(3), Float32, properties = (;PAR = Float64))
append!(vertices(m), [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)])
PGP.add_property!(m, :PAR, 0.0) # Define by the user
PGP.add_property!(m, :normals, Vec(0f0, 0f0, 1f0), 1) # Defined implicitly because arity = 3
@test isvalid(m)

# Create geometry and add vertices and properties automatically (multiple values)
m2 = Geom(Val(3), Float32, properties = (;PAR = Float64))
n = 10
append!(vertices(m2), [Vec(rand(), rand(), 0.0) for _ in 1:3n])
PGP.add_property!(m2, :PAR, rand(), n) # Define by the user
PGP.add_property!(m2, :normals, [Vec(0f0, 0f0, 1f0) for _ in 1:n]) # Defined implicitly because arity = 3
@test isvalid(m2)

# Transfer properties from one mesh to another
PGP.add_properties!(m, m2)
length(properties(m2)[:PAR]) == n
length(properties(m2)[:normals]) == n
length(properties(m)[:PAR]) == n + 1
length(properties(m)[:normals]) == n + 1
@test !isvalid(m) # because vertices was not updated

# Create arbitrary geometry with all the properties defined in PlantGeomPrimitives
m = Geom(Val(3), Float64, properties = (;areas = Float64, inclinations = Float64,
         orientations = Float64, lengths = Float64, radius = Float64, edges = Vec{Float64},
         normals = Vec{Float64}, slices = Int))
@test has_areas(m)
@test areas(m) == Float64[]
@test has_inclinations(m)
@test inclinations(m) == Float64[]
@test has_orientations(m)
@test orientations(m) == Float64[]
@test has_lengths(m)
@test lengths(m) == Float64[]
@test has_radius(m)
@test radius(m) == Float64[]
@test has_edges(m)
@test edges(m) == Vec{Float64}[]
@test has_normals(m)
@test normals(m) == Vec{Float64}[]
@test has_slices(m)
@test slices(m) == Int64[]


end
