### This file does NOT contains public API ###

# Create a primitive from affine transformation
function Primitive(trans::CT.AbstractAffineMap, vertices)
    FT = eltype(trans.linear)
    verts = collect(Vec{FT}, vertices(trans))
    m = Mesh(verts)
    update_normals!(m)
    return m
end

# Create a primitive from affine transformation and add it in-place to existing mesh
function Primitive!(m::Mesh, trans::CT.AbstractAffineMap, vertices)
    append!(m.vertices, vertices(trans))
    update_normals!(m)
    nothing
end
