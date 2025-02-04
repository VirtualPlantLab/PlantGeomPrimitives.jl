# 0. A mesh that is going to be sliced should not have any properties except perhaps normals and edges (raise warning if it does)
# 1. A new property is defined with the edges of the triangles (this could be used for barycentric coordinates later on)
# 2. Loop over the triangles and check if the plane intersects the triangle
# If yes
    # 3. Calculate the intersection point(s)
    # 4. Create new triangles with the intersection points and add them to the mesh
    # 5. Mark triangles for removal
# 6. At the end, go through all the triangles and removed the marked ones (also associated properties)
# 7. Run update normals and update edges to create the normals and edges for new triangles
# 8. Run update layers to assign each triangle to a layer (or do it while adding triangles?)
# Future work: Perform all of this in a single pass?


function slice!(mesh::Mesh; planes = (X = (), Y = (), Z = ()))
    # Warn if the mesh has properties other than normals and edges
    any(x -> !(x in (:normals, :edges)), keys(properties(mesh))) &&
        warning("The slicer expects meshes to only have :normals and :edges properties. Other properties will not be updated after slicing")
    # Make sure that edges are present for each triangle
    update_edges!(mesh)
    # Keep track of old triangles to be removed
    keep_verts = trues(nvertices(mesh))
    keep_tri = trues(ntriangles(mesh))
    # Loop over the cutting planes and triangles
    for i in 1:3 # X = 1, Y = 2, Z = 3
        for h in planes[i] # Height of the plane
            nt = ntriangles(mesh)
            for t in 1:nt
                if keep_tri[t]
                    nit, vi = check_intersection(mesh, t, i, h) # # intersections, vertex index
                    # If an triangle is interesected, mark it for deletion
                    # and add two or three more triangles to the mesh (at the end)
                else
                    nit = 0
                end
                if nit > 0
                    # Set the current triangle for removal
                    i1 = (t - 1)*3 + 1
                    for iv in i1:i1+2 keep_verts[iv] = false end
                    keep_tri[t] = false
                    if nit == 1
                        one_triangle_intersection!(mesh, t, i, h, vi)
                        # Update edges
                        update_edges!(mesh)
                        # Keep the new two triangles
                        for _ in 1:6 push!(keep_verts, true) end
                        for _ in 1:2 push!(keep_tri, true) end
                    else
                        two_triangle_intersections!(mesh, t, i, h, vi)
                        # Update edges
                        update_edges!(mesh)
                        # Keep the new three triangles
                        for _ in 1:9 push!(keep_verts, true) end
                        for _ in 1:3 push!(keep_tri, true) end
                    end
                end
            end
        end
    end
    # Update normals to include new triangles (other properties don't get updated)
    update_normals!(mesh)
    # Remove marked triangles (also the associated properties)
    mesh.vertices = vertices(mesh)[keep_verts]
    # Remove marked properties
    for k in (:edges, :normals)
        properties(mesh)[k] = properties(mesh)[k][keep_tri]
    end
    return mesh
end

# Calculate how many interesection points there are between the plane and the triangle
# and return the vertex index that is relevant to compute the intersection (depends on how
# many intersection points there are)
function check_intersection(m::Mesh, t::Integer, i::Integer, h::Real)
    @inbounds begin
        # Extract coordinates in the right axes
        vs = get_triangle(m, t)
        c = SVector{3, Float64}(vs[1][i], vs[2][i], vs[3][i])
        # Distance between each vertex and the plane
        δ = 5eps(h)
        Δ = c .- h
        s = sign.(Δ)
        # If all distances have the same sign, then there is no intersection
        s[1] == s[2] == s[3] && (return 0, 0)
        # If two distances are close to zero, there are no intersections
        absΔ = abs.(Δ)
        dzero = absΔ .< δ
        sum(dzero) == 2 && (return 0, 0)
        # If one distance is (close to) zero and the others have different signs, there is
        # one intersection, otherwise none (edge case when the plane is tangential to the
        # triangle)
        dzero[1] && (s[2] == s[3] ? (return 0, 0) : (return 1, 1))
        dzero[2] && (s[1] == s[3] ? (return 0, 0) : (return 1, 2))
        dzero[3] && (s[1] == s[2] ? (return 0, 0) : (return 1, 3))
        # If no distances are close to zero, there are two intersections in the edges that share
        # the vertex with a different sign
        d = sum(s) > 0 ? -1 : 1 # Sign of the vertex that would be different
        s[1] == d && (return 2, 1)
        s[2] == d && (return 2, 2)
        return 2, 3
    end
end

# Auxilliary function to help move across all vertices (implements modulo arithmetic 1)
# Note that mod(i, 3) returns 0, 1, 2 hence the +1 at the end, but since i is just a normal
# integer it will always represent the next value
next(i::Integer) = mod(i,3) + 1

# Intersect a triangle with a plane, create new triangles, add them to the mesh
function one_triangle_intersection!(mesh, t, i, h, vi)
    # Extract the relevant vertices and edges
    vs = get_triangle(mesh, t) # Vertices of triangle
    es = edges(mesh)[t]     # Edges of triangle
    # Compute the point of intersection in the edge opposite to vi
    p = one_intersection_point(i, h, vi, es, vs)
    # Choose the three vertices of the triangle in the right order
    vi1 = vi
    vi2 = next(vi1)
    vi3 = next(vi2)
    # First triangle
    verts = vertices(mesh)
    push!(verts, vs[vi1])
    push!(verts, vs[vi2])
    push!(verts, p)
    # Second triangle
    push!(verts, vs[vi1])
    push!(verts, p)
    push!(verts, vs[vi3])
    return nothing
end

# Intersect a triangle with a plane, create new triangles, add them to the mesh
function two_triangle_intersections!(mesh, t, i, h, vi)
    vs = get_triangle(mesh, t) # Vertices of triangle
    es = edges(mesh)[t]     # Edges of triangle
    # Compute the two points of intersection in the edges sharing vi
    p1, p2 = two_intersection_points(i, h, vi, es, vs)
    # Choose the three vertices of the triangle in the right order
    vi1 = vi
    vi2 = next(vi1)
    vi3 = next(vi2)
    # First triangle
    verts = vertices(mesh)
    push!(verts, vs[vi1])
    push!(verts, p1)
    push!(verts, p2)
    # Second triangle
    push!(verts, p1)
    push!(verts, vs[vi2])
    push!(verts, p2)
    # Third triangle
    push!(verts, p2)
    push!(verts, vs[vi2])
    push!(verts, vs[vi3])
    return nothing
end

# Compute the intersection between the plane and the opposite edge of the vertex
function one_intersection_point(i, h, vi, es, vs)
    @inbounds begin
        # Choose barycentric coordinate system (just one axis)
        vi == 1 && begin vr, e = (vs[2], .-es[3]) end
        vi == 2 && begin vr, e = (vs[3], .-es[2]) end
        vi == 3 && begin vr, e = (vs[1],   es[1]) end
        # Calculate the barycentric coordinate on the axis
        d = (h - vr[i])/e[i]
        # Compute the 3D coordinate of intersection point
        return vr .+ d*e
    end
end

# Compute the intersections between the plane and the two edges that share the vertex
function two_intersection_points(i, h, vi, es, vs)
    @inbounds begin
        # Choose barycentric coordinate system
        vi == 1 && begin vr, e1, e2 = (vs[1],   es[1],   es[2]) end
        vi == 2 && begin vr, e1, e2 = (vs[2], .-es[3], .-es[1]) end
        vi == 3 && begin vr, e1, e2 = (vs[3],  .-es[2] , es[3]) end
        # Calculate the barycentric coordinate on each axis
        # and from that the 3D coordinate of intersection point
        d = (h - vr[i])/e1[i]
        p1 = vr .+ d.*e1
        d = (h - vr[i])/e2[i]
        p2 = vr .+ d.*e2
        return p1, p2
    end
end
