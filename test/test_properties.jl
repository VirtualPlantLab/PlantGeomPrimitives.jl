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
eltype(PGP.properties(r)[:prop]) == D.bar
PGP.add!(r, e, prop = D.foo())
eltype(PGP.properties(r)[:prop]) == Union{D.bar, D.foo}
PGP.add!(r, t, prop = D.oomp())
eltype(PGP.properties(r)[:prop]) == Union{D.bar, D.foo, D.oomp}

end
