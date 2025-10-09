"""
    slice!(points::Points; X = (), Y = (), Z = ())

Slice a point cloud along specified planes in the X, Y, and Z directions. This function
will assign individual points to a different voxel depending on which side of a slicing
plane they lie in. This is achieved by adding a property `:slices` to the point cloud that
contains the indices of the voxels where each point lies.

## Details

The cutting planes are assumed to be stored in increasing order for each axis.

For each dimension, a point is assigned an integer indicating the lowest plane that is
higher than the point. Two special cases: (i) if the point is larger than the highest plane,
it is an index equal to the number of planes plus 1 and (ii) if there are no cutting planes
all points are assign the index 1 for that dimension.

## Arguments
- `points::Points`: The point cloud to be sliced.
- `X`: An array-like of X-coordinates.
- `Y`: An array-like of Y-coordinates.
- `Z`: An array-like of Z-coordinates.

## Example
```jldoctest
julia> points = Rectangle(Points; length = 1.0, width = 1.0);

julia> slice!(points, Y = collect(-0.25:0.25:0.5), Z = collect(0.25:0.25:1));
```
"""
function slice!(points::Points; X = (), Y = (), Z = ())
    # Special case when points are above the highest plane
    max_X = isemtpy(X) ? nothing : maximum(X)
    n_max_X = length(X) + 1
    max_Y = isemtpy(Y) ? nothing : maximum(Y)
    n_max_Y = length(Y) + 1
    max_Z = isemtpy(Z) ? nothing : maximum(Z)
    n_max_Z = length(Z) + 1
    # Compute slice indices for each point by comparing against each plane
    # We loop over points first and then planes, this allows using static vectors
    np = npoints(Points)
    slices = Vector{SVector{3, Int}}(undef, np)
    for i in 1:np
        p = vertices(points)[i]
        slices[i] = SVector(isempty(X) ? 1 : (p[1] > max_X ? n_max_X : findfirst(x -> x > p[1], X)),
                            isempty(Y) ? 1 : (p[2] > max_Y ? n_max_Y : findfirst(y -> y > p[2], Y)),
                            isempty(Z) ? 1 : (p[3] > max_Z ? n_max_Z : findfirst(z -> z > p[3], Z)))
    end
    # Add slice indexing as property of the point cloud
    add_property!(points, :slices, slice)
    return points
end
