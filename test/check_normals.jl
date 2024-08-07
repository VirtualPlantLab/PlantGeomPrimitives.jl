import PlantGeomPrimitives as G
using Test

#let

# Helper functions to check the normals of a primitive
function check_normal(v1, v2, v3, n)
    @show G.normal(v1, v2, v3) , n
    @test all(abs.(G.normal(v1, v2, v3) .- n) .< 5e-2)
end

function check_primitive(p)
    np = G.ntriangles(p)
    for i in 1:np
        v1, v2, v3 = G.get_triangle(p, i)
        n = G.normals(p)[i]
        check_normal(v1, v2, v3, n)
    end
end

# Ellipse
e = G.Ellipse(;length = 1.0, width = 1.0, n = 20);
check_primitive(e)
G.scale!(e, G.Vec(1.0, 1.0, 2.0))
check_primitive(e)
G.rotatex!(e, pi/4)
check_primitive(e)
G.translate!(e, G.Vec(2.0, 0.0, 0.0))
check_primitive(e)

# Hollow cone
c = G.HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 10);
check_primitive(c)
G.scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
G.rotatex!(c, pi/4)
check_primitive(c)
G.translate!(c, G.Vec(2.0, 0.0, 0.0))
check_primitive(c)

# Solid cone
cs = G.SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 20);
check_primitive(c)
scale!(c, G.Vec(1.0, 1.0, 2.0))
check_primitive(c)
G.rotatex!(c, pi/4)
check_primitive(c)
G.translate!(c, Vec(2.0, 0.0, 0.0))
check_primitive(c)


check_primitive()
check_primitive(HollowCube(;length = 1.0, width = 1.0, height = 1.0))
check_primitive(HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40))
check_primitive(HollowFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40))
check_primitive(Rectangle(;length = 1.0, width = 1.0))
check_primitive(SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 40))
check_primitive(SolidCube(;length = 1.0, width = 1.0, height = 1.0))
check_primitive(SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 80))
check_primitive(SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40))
check_primitive(Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0))
check_primitive(Triangle(;length = 1.0, width = 1.0))

#end
