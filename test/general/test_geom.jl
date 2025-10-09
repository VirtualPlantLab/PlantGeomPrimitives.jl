using PlantGeomPrimitives
using Test

let

# Create empty triangular meshes
m = Geom(Val(3))
@test isvalid(m)
@test isempty(m)
@test eltype(m) == Float64
m = Geom(Val(3), Float32)
@test isvalid(m)
@test isempty(m)
@test eltype(m) == Float32
m = Geom(Val(3), Float32, properties = (;PAR = Float64))
@test isvalid(m)
@test isempty(m)
@test :PAR in keys(properties(m))
@test eltype(properties(m)[:PAR]) == Float64

# Create empty segment collections
m = Geom(Val(2))
@test isvalid(m)
@test isempty(m)
@test eltype(m) == Float64
m = Geom(Val(2), Float32)
@test isvalid(m)
@test isempty(m)
@test eltype(m) == Float32
m = Geom(Val(2), Float32, properties = (;PAR = Float64))
@test isvalid(m)
@test isempty(m)
@test :PAR in keys(properties(m))
@test eltype(properties(m)[:PAR]) == Float64

# Create empty point clouds
m = Geom(Val(1))
@test isvalid(m)
@test isempty(m)
@test eltype(m) == Float64
m = Geom(Val(1), Float32)
@test isvalid(m)
@test isempty(m)
@test eltype(m) == Float32
m = Geom(Val(1), Float32, properties = (;PAR = Float64))
@test isvalid(m)
@test isempty(m)
@test :PAR in keys(properties(m))
@test eltype(properties(m)[:PAR]) == Float64

# Create a triangle with user-specified properties
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];
p = (;normals = [Vec(0.0, 0.0, 1.0)], areas = 0.5);
m = Geom{3, Float64, typeof(p)}(v, p);
@test isvalid(m)
@test length(m) == 1
@test nvertices(m) == 3
@test all(get_geom(m, 1) .== get_triangle(m, 1))
@test all(get_geom(m, 1) .== v)
@test all(properties(m)[:normals] .== p.normals)
@test all(properties(m)[:areas] .== p.areas)

# Create a segment with user-specified properties
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];
p = (;radius = 0.1);
m = Geom{2, Float64, typeof(p)}(v, p);
@test isvalid(m)
@test length(m) == 1
@test nvertices(m) == 2
@test all(get_geom(m, 1) .== get_segment(m, 1))
@test all(get_geom(m, 1) .== v)
@test all(properties(m)[:radius] .== p.radius)

# Create a point with user-specified properties
v = [Vec(0.0, 0.0, 0.0)];
p = (;areas = 0.1, normals = [Vec(0.0, 0.0, 1.0)]);
m = Geom{1, Float64, typeof(p)}(v, p);
@test isvalid(m)
@test length(m) == 1
@test nvertices(m) == 1
@test all(get_geom(m, 1) .== get_point(m, 1))
@test all(get_geom(m, 1) .== v[1])
@test all(properties(m)[:areas] .== p.areas)

# Create invalid triangular mesh
v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)]; # wrong # vertices
p = (;normals = [Vec(0.0, 0.0, 1.0)]);
m = Geom{3, Float64, typeof(p)}(v, p);
@test !isvalid(m)

v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(0.0, 1.0, 1.0)];
p = (;normal = [Vec(0.0, 0.0, 1.0)]); # wrong prop names
m = Geom{3, Float64, typeof(p)}(v, p);
@test !isvalid(m)

v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];
p = (;normals = [Vec(0.0, 0.0, 1.0)], areas = [0.5, 1.0]); # wrong prop length
m = Geom{3, Float64, typeof(p)}(v, p);
@test !isvalid(m)

# Create invalid segments collection
v = [Vec(0.0, 0.0, 0.0)]; # wrong # vertices
p = (;radius = 0.1);
m = Geom{2, Float64, typeof(p)}(v, p);
@test !isvalid(m)

v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];
p = (;radii = 0); # wrong prop names
m = Geom{2, Float64, typeof(p)}(v, p);
@test !isvalid(m)

v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0)];
p = (;radius = [0.1, 1.0]); # wrong prop length
m = Geom{2, Float64, typeof(p)}(v, p);
@test !isvalid(m)

# Create invalid cloud points
v = [Vec(0.0, 0.0, 0.0)];
p = (;area = 0.1, normals = [Vec(0.0, 0.0, 1.0)]); # wrong prop names
m = Geom{1, Float64, typeof(p)}(v, p);
@test !isvalid(m)

v = [Vec(0.0, 0.0, 0.0)];
p = (;areas = [0.1, 2.5], normals = [Vec(0.0, 0.0, 1.0)]); # wrong prop length
m = Geom{1, Float64, typeof(p)}(v, p);
@test !isvalid(m)

end
