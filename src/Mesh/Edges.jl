# Calculate the edges of a mesh and add them as properties (deals with partially computed normals)
function update_edges!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :edges and if not create it
    if !haskey(properties(m), :edges)
        properties(m)[:edges] = Vec{Vec{FT}}[]
    end
    vs = vertices(m)
    lv = length(vs)
    # 2. If the property :edges is empty, compute the edges for all vertices
    if isempty(edges(m))
        for i in 1:3:lv
            push_edges!(vs, m, i)
        end
    else
    # 3. If the property :edges is not empty, compute the edges for the remaining vertices
        ln = length(edges(m))
        for i in 3ln:3:(lv - 3)
            push_edges!(vs, m, i + 1)
        end
    end
end

# Create the three edges stored as a vector of vectors
function push_edges!(vs, m, i0)
    @inbounds v1, v2, v3 = vs[i0], vs[i0+1], vs[i0+2]
    e1 = L.normalize(v2 .- v1)
    e2 = L.normalize(v3 .- v1)
    e3 = L.normalize(v2 .- v3)
    push!(edges(m), Vec(e1, e2, e3))
    return nothing
end
