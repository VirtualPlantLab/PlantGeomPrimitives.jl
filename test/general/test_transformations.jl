using PlantGeomPrimitives
import PlantGeomPrimitives as PGP
using Test

let

########### TRANSFORMATION OF TRIANGLES ###########
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];
p = (;normals = [Vec(0.0, 0.0, -1.0)], areas = [0.5]);
m = Geom{3, Float64, typeof(p)}(v, p);

# Scaling
m2 = deepcopy(m)
scale!(m2, PGP.Vec(2.0, 1.0, 1.0))
PGP.calculate_areas(m2)
@test areas(m2)[1] == 2 * areas(m)[1]

# Rotating around x axis
m3 = deepcopy(m)
rotatex!(m3, 45.0)
@test all(getindex.(vertices(m3), 1) .≈ getindex.(vertices(m), 1))
@test all(getindex.(vertices(m3), 2)[2] != getindex.(vertices(m), 2)[2])
@test all(getindex.(vertices(m3), 3)[2] != getindex.(vertices(m), 3)[2])
@test all(normals(m3)[1][2:3] .!= normals(m)[1][2:3])
rotatex!(m3, -45.0)
@test all(vertices(m3) .≈ vertices(m))
@test all(normals(m3) .≈ normals(m))

# Rotating around y axis
m3 = deepcopy(m)
rotatey!(m3, 45.0)
@test all(getindex.(vertices(m3), 1)[3] != getindex.(vertices(m), 1)[3])
@test all(getindex.(vertices(m3), 2) .== getindex.(vertices(m), 2))
@test all(getindex.(vertices(m3), 3)[3] != getindex.(vertices(m), 3)[3])
@test all(normals(m3)[1][[1,3]] .!= normals(m)[1][[1,3]])
rotatey!(m3, -45.0)
@test all(vertices(m3) .≈ vertices(m))
@test all(normals(m3) .≈ normals(m))

# Rotating around z axis
m3 = deepcopy(m)
rotatez!(m3, 45.0)
@test all(getindex.(vertices(m3), 1)[2:3] .!= getindex.(vertices(m), 1)[2:3])
@test all(getindex.(vertices(m3), 2)[2:3] .!= getindex.(vertices(m), 2)[2:3])
@test all(getindex.(vertices(m3), 3) .== getindex.(vertices(m), 3))
@test all(normals(m3)[1] .== normals(m)[1])
rotatez!(m3, -45.0)
@test all(vertices(m3) .≈ vertices(m))
@test all(normals(m3) .≈ normals(m))

# Rotate along all axis simulatenously
m4 = deepcopy(m)
rotate!(m4, x = X(), y = Y(), z = .-Z())
@test all(getindex.(vertices(m4), 1) .== getindex.(vertices(m), 1))
@test all(getindex.(vertices(m4), 2) .== getindex.(vertices(m), 2))
@test all(getindex.(vertices(m4), 3) .== getindex.(vertices(m), 3))
@test all(normals(m4) .== normals(m))

# Translating along the x axis
m4 = deepcopy(m)
translate!(m4, Vec(2.0, 0.0, 0.0))
@test all((getindex.(vertices(m4), 1) .!== getindex.(vertices(m), 1)))
@test all(getindex.(vertices(m4), 2) .≈ getindex.(vertices(m), 2))
@test all(getindex.(vertices(m4), 3) .≈ getindex.(vertices(m), 3))
@test all(normals(m4) .≈ normals(m))
translate!(m4, Vec(-2.0, 0.0, 0.0))
@test all(vertices(m4) .≈ vertices(m))

# Translating along the y axis
m4 = deepcopy(m)
translate!(m4, Vec(0.0, 2.0, 0.0))
@test all((getindex.(vertices(m4), 1) .≈ getindex.(vertices(m), 1)))
@test all(getindex.(vertices(m4), 2) .!== getindex.(vertices(m), 2))
@test all(getindex.(vertices(m4), 3) .≈ getindex.(vertices(m), 3))
@test all(normals(m4) .≈ normals(m))
translate!(m4, Vec(0.0, -2.0, 0.0))
@test all(vertices(m4) .≈ vertices(m))

# Translating along the z axis
m4 = deepcopy(m)
translate!(m4, Vec(0.0, 0.0, 2.0))
@test all((getindex.(vertices(m4), 1) .≈ getindex.(vertices(m), 1)))
@test all(getindex.(vertices(m4), 2) .≈ getindex.(vertices(m), 2))
@test all(getindex.(vertices(m4), 3) .!== getindex.(vertices(m), 3))
@test all(normals(m4) .≈ normals(m))
translate!(m4, Vec(0.0, 0.0, -2.0))
@test all(vertices(m4) .≈ vertices(m))


########### TRANSFORMATION OF SEGMENTS ###########

v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];
p = (;radius = [0.1]);
s = Geom{2, Float64, typeof(p)}(v, p);

# Scale
s2 = deepcopy(s)
scale!(s2, Vec(1.0, 2.0, 1.0))
@test all(vertices(s2)[1] .≈ vertices(s)[1])
@test vertices(s2)[2][2] != vertices(s)[2][2]

# Rotate along all axis simulatenously
s2 = deepcopy(s)
rotate!(s2, x = X(), y = .-Y(), z = Z())
@test all(getindex.(vertices(s2), 1) .== getindex.(vertices(s), 1))
@test any(getindex.(vertices(s2), 2) .!= getindex.(vertices(s), 2))
@test all(getindex.(vertices(s2), 3) .== getindex.(vertices(s), 3))

# Translating along the y axis
s2 = deepcopy(s)
translate!(s2, Vec(0.0, 2.0, 0.0))
@test all(getindex.(vertices(s2), 1) .== getindex.(vertices(s), 1))
@test all(getindex.(vertices(s2), 2) .== 2.0 .+ getindex.(vertices(s), 2))
@test all(getindex.(vertices(s2), 3) .== getindex.(vertices(s), 3))

########### TRANSFORMATION OF POINTS ###########

v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];
p = (;areas = [0.1, 0.2], normals = [Vec(0.0, 0.0, 1.0), Vec(0.0, 0.0, 1.0)]);
p = Geom{1, Float64, typeof(p)}(v, p);

# Scale
p2 = deepcopy(p)
scale!(p2, Vec(1.0, 2.0, 1.0))
@test all(getindex.(vertices(p2), 1) .== getindex.(vertices(p), 1))
@test any(getindex.(vertices(p2), 2) .!= getindex.(vertices(p), 2))
@test all(getindex.(vertices(p2), 3) .== getindex.(vertices(p), 3))
@test all(areas(p2) .== 2.0 .* areas(p))

# Rotate along all axis simulatenously
p2 = deepcopy(p)
rotate!(p2, x = X(), y = .-Y(), z = Z())
@test all(getindex.(vertices(p2), 1) .== getindex.(vertices(p), 1))
@test any(getindex.(vertices(p2), 2) .!= getindex.(vertices(p), 2))
@test all(getindex.(vertices(p2), 3) .== getindex.(vertices(p), 3))
@test all(areas(p2) .== areas(p))

# Translating along the y axis
p2 = deepcopy(p)
translate!(p2, Vec(0.0, 2.0, 0.0))
@test all(getindex.(vertices(p2), 1) .== getindex.(vertices(p), 1))
@test all(getindex.(vertices(p2), 2) .== 2.0 .+ getindex.(vertices(p), 2))
@test all(getindex.(vertices(p2), 3) .== getindex.(vertices(p), 3))
@test all(areas(p2) .== areas(p))

end
