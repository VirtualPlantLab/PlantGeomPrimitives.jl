### This file does NOT contains public API ###

# Create a primitive from affine transformation
function Primitive(trans::AbstractAffineMap, vertices, normals)
    FT = eltype(trans.linear)
    verts = collect(Vec{FT}, vertices(trans))
    norm_trans = transpose(inv(trans.linear))
    norms = collect(Vec{FT}, normals(norm_trans))
    Mesh(verts, norms)
end

# Create a primitive from affine transformation and add it in-place to existing mesh
function Primitive!(m::Mesh, trans::AbstractAffineMap, vertices, normals)
    nv = length(m.vertices)
    norm_trans = transpose(inv(trans.linear))
    append!(m.vertices, vertices(trans))
    append!(m.normals, normals(norm_trans))
    nothing
end
