### This file does NOT contains public API ###

# Create a primitive from affine transformation
function Primitive(trans::CT.AbstractAffineMap, generate_vertices)
    FT = eltype(trans.linear)
    verts = collect(Vec{FT}, generate_vertices(trans))
    m = Mesh(verts)
    update_normals!(m)
    return m
end

# Create a primitive from affine transformation and add it in-place to existing mesh
function Primitive!(m::Mesh, trans::CT.AbstractAffineMap, generate_vertices)
    append!(vertices(m), generate_vertices(trans))
    update_normals!(m)
    nothing
end
