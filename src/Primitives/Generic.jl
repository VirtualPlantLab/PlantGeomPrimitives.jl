### This file does NOT contains public API ###

# Create a primitive from affine transformation
function Primitive(trans::AbstractAffineMap, vertices)
    FT = eltype(trans.linear)
    verts = collect(Vec{FT}, vertices(trans))
    Mesh(verts, Vec{FT}[])
end

# Create a primitive from affine transformation and add it in-place to existing mesh
function Primitive!(m::Mesh, trans::AbstractAffineMap, vertices)
    nv = length(m.vertices)
    append!(m.vertices, vertices(trans))
    nothing
end
