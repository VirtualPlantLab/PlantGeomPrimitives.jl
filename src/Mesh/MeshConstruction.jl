### This file does NOT contains public API ###

# Construction a mesh from a series of vertices
function construct_mesh(vertices)
    norms = [normal(get_triangle(vertices, i)...) for i in 1:length(vertices)/3]
    Mesh(vertices, norms)
end


# Compute the normal of a triangle given three vertices
# This defines implicitly our orientation convention
function normal(v1, v2, v3)
    e1 = v2 .- v1
    e2 = v3 .- v1
    normalize(e1 × e2)
end
