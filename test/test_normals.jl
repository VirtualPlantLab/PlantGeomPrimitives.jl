import PlantGeomPrimitives as G
#import GLMakie
#import PlantViz as PV
using Test
using LinearAlgebra: ×, normalize

let

function compute_normal(v1, v2, v3)
    e1 = v2 .- v1
    e2 = v3 .- v1
    normalize(e1 × e2)
end

# Helper functions to check the normals of a primitive
function check_normal(v1, v2, v3, n)
    @test all(abs.(compute_normal(v1, v2, v3) .- n) .< 10eps())
end

function check_primitive(p)
    G.update_normals!(p)
    np = G.ntriangles(p)
    for i in 1:np
        v1, v2, v3 = G.get_triangle(p, i)
        n = G.normals(p)[i]
        check_normal(v1, v2, v3, n)
    end
end

# Ellipse
e = G.Ellipse(;length = 1.0, width = 1.0, n = 20);
ge = G.GLMesh(e)
check_primitive(e)
#PV.render(e, normals = true)
G.scale!(e, G.Vec(1.0, 1.0, 2.0))
check_primitive(e)
#PV.render(e, normals = true)
G.rotatex!(e, pi/4)
check_primitive(e)
#PV.render(e, normals = true)
G.translate!(e, G.Vec(2.0, 0.0, 0.0))
check_primitive(e)
#PV.render(e, normals = true)

# Hollow cone
c = G.HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 10);
check_primitive(c)
#PV.render(c, normals = true)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
#PV.render(c, normals = true)
G.rotatex!(c, pi/4)
check_primitive(c)
#PV.render(c, normals = true)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)
#PV.render(c, normals = true)

# Solid cone
c = G.SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 40);
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.rotatex!(c, pi/4)
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)

# Hollow cube
c = G.HollowCube(;length = 1.0, width = 1.0, height = 1.0);
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.rotatex!(c, pi/4)
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)


# Solid cube
c = G.SolidCube(;length = 1.0, width = 1.0, height = 1.0);
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.rotatex!(c, pi/4)
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)


# Hollow cylinder
c = G.HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 20);
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.rotatex!(c, pi/4)
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)

# Solid cylinder
c = G.SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40);
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.rotatex!(c, pi/4)
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)
#PV.render(c, normals = true, wireframe = true)

# Hollow frustum
f = G.HollowFrustum(;length = 1.0, width = 1.0, height = 1.0, ratio = 1.0, n = 20);
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)
G.scale!(f, G.Vec(1.0, 1.0, 2.0))
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)
G.rotatex!(f, pi/4)
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)
G.translate!(f, G.Vec(2.0, 0.0, 0.0))
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)

# Solid frustum
f = G.SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40);
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)
G.scale!(f, G.Vec(1.0, 1.0, 2.0))
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)
G.rotatex!(f, pi/4)
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)
G.translate!(f, G.Vec(2.0, 0.0, 0.0))
check_primitive(f)
#PV.render(f, normals = true, wireframe = true)

# Rectangle
r = G.Rectangle(;length = 1.0, width = 1.0);
check_primitive(r)
#PV.render(r, normals = true, wireframe = true)
G.scale!(r, G.Vec(1.0, 1.0, 2.0))
check_primitive(r)
#PV.render(r, normals = true, wireframe = true)
G.rotatex!(r, pi/4)
check_primitive(r)
#PV.render(r, normals = true, wireframe = true)
G.translate!(r, G.Vec(2.0, 0.0, 0.0))
check_primitive(r)
#PV.render(r, normals = true, wireframe = true)

# Trapezoid
t = G.Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0);
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)
G.scale!(t, G.Vec(1.0, 1.0, 2.0))
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)
G.rotatex!(t, pi/4)
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)
G.translate!(t, G.Vec(2.0, 0.0, 0.0))
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)

# Triangle
t = G.Triangle(;length = 1.0, width = 1.0);
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)
G.scale!(t, G.Vec(1.0, 1.0, 2.0))
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)
G.rotatex!(t, pi/4)
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)
G.translate!(t, G.Vec(2.0, 0.0, 0.0))
check_primitive(t)
#PV.render(t, normals = true, wireframe = true)

end
