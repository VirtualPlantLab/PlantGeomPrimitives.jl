import PlantGeomPrimitives as PGP
using Test


module dummy
    struct bar end

    struct foo end

    struct oomp end
end

let

import .dummy as D

r = PGP.Rectangle()
e = PGP.Ellipse()
t = PGP.Triangle()

PGP.add_property!(r, :prop, D.bar())
@test eltype(PGP.properties(r)[:prop]) == D.bar
PGP.add!(r, e, prop = D.foo())
@test eltype(PGP.properties(r)[:prop]) == Union{D.bar, D.foo}
PGP.add!(r, t, prop = D.oomp())
@test eltype(PGP.properties(r)[:prop]) == Union{D.bar, D.foo, D.oomp}


# Merging meshes
# Make sure property unions are created
PGP.add_property!(e, :prop, D.foo())
PGP.add_property!(t, :prop, D.bar())
m = PGP.Mesh([t, e])
@test eltype(PGP.properties(m)[:prop]) == Union{D.bar, D.foo}
@test eltype(PGP.properties(e)[:prop]) == D.foo
@test eltype(PGP.properties(t)[:prop]) == D.bar
# Make sure original meshes are not modified
l1 = length(PGP.properties(e)[:prop])
l2 = length(PGP.properties(t)[:prop])
l3 = length(PGP.properties(m)[:prop])
@test l1 + l2 == l3
nv1 = PGP.nvertices(e)
nv2 = PGP.nvertices(t)
nv3 = PGP.nvertices(m)
@test nv1 + nv2 == nv3

end
