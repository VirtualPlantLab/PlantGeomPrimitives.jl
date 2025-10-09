"""
    slice!(segments::Segments; X = (), Y = (), Z = ())

Slice a triangular mesh along specified planes in the X, Y, and Z directions. This function
will create new triangles as needed by slicing the original triangles. This will update the
mesh and some of the properties (but not all, so it is advised to slice the mesh before
adding user-defined properties). The function will add a property `:slices` to the mesh that
contains the indices of the planes where each triangle lies.

# Arguments
- `segments::Segments`: The triangular mesh to be sliced.
- `X`: A tuple or array of X-coordinates where the triangular mesh should be sliced.
- `Y`: A tuple or array of Y-coordinates where the triangular mesh should be sliced.
- `Z`: A tuple or array of Z-coordinates where the triangular mesh should be sliced.

# Example
```jldoctest
julia> mesh = Rectangle(Mesh; length = 1.0, width = 1.0);

julia> slice!(mesh, Y = collect(-0.25:0.25:0.5), Z = collect(0.25:0.25:1));
```
"""
function slice!(segments::Segments; X = (), Y = (), Z = ())
    # Warn if the segment collection has properties other than radius
    any(x -> !(x in (:radius)), keys(properties(segments))) &&
        @warn("The slicer expects segments to only have the property :radius. Other properties will not be updated after slicing")
    # Prepare arrays to keep track of segments to be removed (note that segments will be added
    # during the iterations and some of those new segments may be sliced too)
    keep_verts = trues(nvertices(segments))
    keep_seg = trues(nsegments(segments))
    # Keep track of the voxel where a segment will fall (3 values, one per type of plane)
    slice = zeros(MVector{3, Int}, nsegments(mesh))
    # Loop over the cutting planes and segments
    planes = (X, Y, Z)
    for i in 1:3 # X = 1, Y = 2, Z = 3
        for j in eachindex(planes[i]) # Height of the plane
            h = planes[i][j]
            ns = nsegments(mesh)
            for s in 1:ns
                # Make sure we do not test for intersection segments that are marked for deletion
                if keep_seg[s]
                    intersect, vi, slindexj, signs = check_intersection(segments, s, i, h, j)
                    # When a segment was not intersected update the slice index unless < j
                    # Exception is the first plane that should always assign new code (1 or 2)
                    if !intersect
                        if slice[s][i] == j || j == 1
                            slice[s][i] = slindexj
                        end
                    end
                else
                    intersect = false
                end
                # If a segment is interesected, mark it for deletion
                # and add two more segments to the segment collection
                if intersect
                    verts = vertices(segments)
                    radius = radius(segments)
                    # Set the current triangle for removal
                    i1 = (s - 1)*2 + 1
                    keep_verts[i1] = false
                    keep_verts[i1+1] = false
                    keep_seg[s] = false
                    # Add the two new segments and update all relevant info
                    add_segment!(1, s, i1, vi, keep_verts, keep_seg, verts, radius, slice)
                    add_segment!(2, s, i1, vi, keep_verts, keep_seg, verts, radius, slice)
                end
            end
        end
    end
    # Add slice indexing as property of the segment collection
    add_property!(segments, :slices, slice)
    # Remove marked segments (also the associated properties)
    segments.vertices = vertices(segments)[keep_verts]
    properties(segments)[:radius] = properties(segments)[k][keep_seg]
    return segments
end


#= Check intersection between a segment and a plane
Input
s = index of the segment
i = index of slicing plane (X, Y, Z)
h = height of the slicing plane
j = index of the slicing plane
Returns
intersect= Boolean, whether segment is intersected
vi = Intersection point
slindexj = Either j or j + 1 for segments that are not intersected
signs = Signs attributed to the first and second vertex in the intersection test (for when they are intersected)
=#
function check_intersection(segments::Segments{FT}, s, i, h, j) where FT
    # Extract the vertices
    v1, v2 = get_segment(segments, s)
    # Compute the sign of each segment vertex in the plane equation
    signs = (sign(v1[i] - h), sign(v2[i] - h))
    # No intersection
    if signs[1] == 0
        return false, Vec{FT}(0,0,0), signs[2] > 0 ? j + 1 : j, signs
    elseif signs[2] == 0
        return false, Vec{FT}(0,0,0), signs[1] > 0 ? j + 1 : j, signs
    elseif signs[1] == signs[2]
        return false, Vec{FT}(0,0,0), signs[1] > 0 ? j + 1 : j, signs
    # Intersection
    else
        # Calculate intersection point
        f = (h - v1[i])/(v2[i] - v1[i])
        if i == 1
            vi = Vec{FT}(h, v1[2] + f*(v2[2] - v2[2]), v1[3] + f*(v2[3] - v2[3]))
        elseif i == 2
            vi = Vec{FT}(v1[1] + f*(v2[1] - v2[1]), h, v1[3] + f*(v2[3] - v2[3]))
        else
            vi = Vec{FT}(v1[1] + f*(v2[1] - v2[1]), h, v1[3] + f*(v2[3] - v2[3]))
        end
        return true, vi, j, signs
    end
end

# Add the first or second segment after an intersection
function add_segment!(vindex, s, i1, vi, keep_verts, keep_seg, verts, radius, slice)
    if vindex == 1
        push!(verts, verts[i1])
        push!(verts, vi)
    else
        push!(verts, vi)
        push!(verts, verts[i1+1])
    end
    push!(radius, radius[s])
    push!(keep_verts, true)
    push!(keep_verts, true)
    push!(keep_seg, true)
    push!(slice, signs[vindex] > 0 ? j + 1 : j)
    return nothing
end
