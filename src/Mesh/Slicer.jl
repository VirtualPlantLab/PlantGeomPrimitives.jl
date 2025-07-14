# TODO Merge triangles within a voxel

"""
    slice!(mesh::Mesh; X = (), Y = (), Z = ())

Slice a mesh along specified planes in the X, Y, and Z directions. This function modifies
the input mesh in place. The resulting mesh will contain a higher number of triangles which
all constrained to the planes specified. The function will also add a property `:slices` to
the mesh that contains the indices of the planes where each triangle lies.

# Arguments
- `mesh::Mesh`: The mesh to be sliced.
- `X`: A tuple or array of X-coordinates where the mesh should be sliced.
- `Y`: A tuple or array of Y-coordinates where the mesh should be sliced.
- `Z`: A tuple or array of Z-coordinates where the mesh should be sliced.

# Example
```jldoctest
julia> mesh = Rectangle(length = 1.0, width = 1.0);

julia> slice!(mesh, Y = collect(-0.25:0.25:0.5), Z = collect(0.25:0.25:1));
```
"""
function slice!(mesh::Mesh; X = (), Y = (), Z = ())
    # Warn if the mesh has properties other than normals and edges
    any(x -> !(x in (:normals, :edges, :slices)), keys(properties(mesh))) &&
        @warn("The slicer expects meshes to only have :normals, :edges and :slices. Other properties will not be updated after slicing")
    # Make sure that edges are present for each triangle
    update_edges!(mesh)
    # Prepare arrays to keep track of triangles to be removed
    keep_verts = trues(nvertices(mesh))
    keep_tri = trues(ntriangles(mesh))
    # Keep track of the slice where a triangle will fall (3 values, one per type of plane)
    slice = zeros(MVector{3, Int}, ntriangles(mesh))
    # Loop over the cutting planes and triangles
    planes = (X, Y, Z)
    for i in 1:3 # X = 1, Y = 2, Z = 3
        for j in eachindex(planes[i]) # Height of the plane
            h = planes[i][j]
            nt = ntriangles(mesh)
            for t in 1:nt
                # Make sure we do not test for intersection triangles that are marked for deletion
                if keep_tri[t]
                    nit, vi, slindexj, signs = check_intersection(mesh, t, i, h, j)
                    # When a triangle was not intersected update the slice index unless < j
                    # Exception is the first plane that should always assign new code (1 or 2)
                    if nit == 0
                        if slice[t][i] == j || j == 1
                            slice[t][i] = slindexj
                        end
                    end #nit == 0  && (j == 1 || slice[t][i] == j) && (slice[t][i] = slindexj)
                else
                    nit = 0
                end
                # If a triangle is interesected, mark it for deletion
                # and add two or three more triangles to the mesh
                if nit > 0
                    # Set the current triangle for removal
                    i1 = (t - 1)*3 + 1
                    for iv in i1:i1+2 keep_verts[iv] = false end
                    keep_tri[t] = false
                    if nit == 1
                        slindices = one_triangle_intersection!(mesh, t, i, h, vi, slice[t], j, signs)
                        # Update edges
                        update_edges!(mesh)
                        # Keep the new two triangles
                        for _ in 1:6 push!(keep_verts, true) end
                        for _ in 1:2 push!(keep_tri, true) end
                        # Update the slice indices
                        for sli in 1:2 push!(slice, slindices[sli]) end
                    else
                        slindices = two_triangle_intersections!(mesh, t, i, h, vi, slice[t], j, signs)
                        # Update edges
                        update_edges!(mesh)
                        # Keep the new three triangles
                        for _ in 1:9 push!(keep_verts, true) end
                        for _ in 1:3 push!(keep_tri, true) end
                        # Update the slice indices
                        for sli in 1:3 push!(slice, slindices[sli]) end
                    end
                end
            end
        end
    end
    # Add slice indexing as property of the mesh
    add_property!(mesh, :slices, slice)
    # Update normals to include new triangles (other properties don't get updated)
    update_normals!(mesh)
    # Remove marked triangles (also the associated properties)
    mesh.vertices = vertices(mesh)[keep_verts]
    # Remove marked properties
    for k in (:edges, :normals, :slices)
        properties(mesh)[k] = properties(mesh)[k][keep_tri]
    end
    return mesh
end

# Calculate how many interesection points there are between the plane and the triangle
# and return the vertex index that is relevant to compute the intersection (depends on how
# many intersection points there are). When a triangle is not intersected we return the index
# of the voxel or layer where the triangle lies. When there is an intersection we return -1
# as the voxel indexing will be determined in the intersection function.
function check_intersection(m::Mesh, t::Integer, i::Integer, h::Real, j::Integer)
    @inbounds begin
        # Extract coordinates in the right axes
        vs = get_triangle(m, t)
        c = SVector{3, Float64}(vs[1][i], vs[2][i], vs[3][i])
        # Distance between each vertex and the plane
        δ = 5eps(h)
        Δ = c .- h
        s = sign.(Δ)
        # If all distances have the same sign, then there is no intersection
        # The sign determine on which side of the plane the triangle lies
        if s[1] == s[2] == s[3]
            slindex = s[1] == one(h) ? j + 1 : j
            return 0, 0, slindex, s
        end
        # If two distances are close to zero, there are no intersections
        absΔ = abs.(Δ)
        dzero = absΔ .< δ
        if sum(dzero) == 2
            slindex = s[.!dzero][1] == one(h) ? j + 1 : j
            return 0, 0, slindex, s
        end
        # If one distance is (close to) zero and the others have different signs, there is
        # one intersection, otherwise none (edge case when the plane is tangential to the
        # triangle)
        # For vertex 1
        if dzero[1]
             if s[2] == s[3]
                slindex = s[2] == one(h) ? j + 1 : j
                return 0, 0, slindex, s
            else
                return 1, 1, 0, s
            end
        end
        # For vertex 2
        if dzero[2]
            if s[1] == s[3]
               slindex = s[1] == one(h) ? j + 1 : j
               return 0, 0, slindex, s
            else
               return 1, 2, 0, s
            end
        end
       # For vertex 3
       if dzero[3]
            if s[1] == s[2]
                slindex = s[1] == one(h) ? j + 1 : j
                return 0, 0, slindex, s
            else
                return 1, 3, 0, s
            end
        end
        # If no distances are close to zero, there are two intersections in the edges that share
        # the vertex with a different sign
        d = sum(s) > 0 ? -1 : 1 # Sign of the vertex that would be different
        s[1] == d && (return 2, 1, 0, s)
        s[2] == d && (return 2, 2, 0, s)
        return 2, 3, 0, s
    end
end

# Auxilliary function to help move across all vertices (implements modulo arithmetic 1)
# Note that mod(i, 3) returns 0, 1, 2 hence the +1 at the end, but since i is just a normal
# integer it will always represent the next value
next(i::Integer) = mod(i,3) + 1

# Intersect a triangle with a plane, create new triangles, add them to the mesh
function one_triangle_intersection!(mesh, t, i, h, vi, slindex, j, s)
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
    slindex1 = copy(slindex)
    slindex1[i] = s[vi2] == one(h) ? j + 1 : j
    # Second triangle
    push!(verts, vs[vi1])
    push!(verts, p)
    push!(verts, vs[vi3])
    slindex2 = copy(slindex)
    slindex2[i] = s[vi3] == one(h) ? j + 1 : j
    return slindex1, slindex2
end

# Intersect a triangle with a plane, create new triangles, add them to the mesh
function two_triangle_intersections!(mesh, t, i, h, vi, slindex, j, s)
    vs = get_triangle(mesh, t) # Vertices of triangle
    es = edges(mesh)[t]     # Edges of triangle
    # Compute the two points of intersection in the edges sharing vi
    p1, p2 = two_intersection_points(i, h, vi, es, vs)
    # Choose the three vertices of the triangle in the right order
    vi1 = vi
    vi2 = next(vi1)
    vi3 = next(vi2)
    # On which side of the plane is vi
    side = s[vi] == one(h)
    # First triangle
    verts = vertices(mesh)
    push!(verts, vs[vi1])
    push!(verts, p1)
    push!(verts, p2)
    slindex1 = copy(slindex)
    slindex1[i] = side ? j + 1 : j
    # Second triangle
    push!(verts, p1)
    push!(verts, vs[vi2])
    push!(verts, p2)
    slindex2 = copy(slindex)
    slindex2[i] = side ? j : j + 1
    # Third triangle
    push!(verts, p2)
    push!(verts, vs[vi2])
    push!(verts, vs[vi3])
    slindex3 = copy(slindex)
    slindex3[i] = side ? j : j + 1
    return slindex1, slindex2, slindex3
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
