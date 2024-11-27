### This file contains public API ###

"""
    BBox(m::Mesh)

Build a tight axis-aligned bounding box around a `Mesh` object.

# Arguments
- `m`: The mesh to build the bounding box around.

# Examples
```jldoctest
julia> m = Rectangle();

julia> box = BBox(m);
```
"""
function BBox(m::Mesh{FT}) where {FT<:AbstractFloat}
    @inbounds xmin, ymin, zmin = vertices(m)[1]
    xmax, ymax, zmax = xmin, ymin, zmin
    for v in m.vertices
        x, y, z = v
        xmax = max(x, xmax)
        ymax = max(y, ymax)
        zmax = max(z, zmax)
        xmin = min(x, xmin)
        ymin = min(y, ymin)
        zmin = min(z, zmin)
    end
    pmin = Vec{FT}(xmin, ymin, zmin)
    pmax = Vec{FT}(xmax, ymax, zmax)

    BBox(pmin, pmax)

end

"""
    BBox(pmin::Vec, pmax::Vec)

Build an axis-aligned bounding box given the vector of minimum (`pmin`) and
maximum (`pmax`) coordinates.

# Arguments
- `pmin`: The minimum coordinates of the bounding box.
- `pmax`: The maximum coordinates of the bounding box.

# Examples
```jldoctest
julia> p0 = Vec(0.0, 0.0, 0.0);

julia> p1 = Vec(1.0, 1.0, 1.0);

julia> box = BBox(p0, p1);
```
"""
function BBox(pmin::Vec{FT}, pmax::Vec{FT}) where {FT}
    @inbounds begin
        h = pmax[1] - pmin[1] + eps(FT)
        w = pmax[2] - pmin[2] + eps(FT)
        l = pmax[3] - pmin[3] + eps(FT)
        v2 = pmin .+ Vec{FT}(0, w, 0)
        v3 = v2 .+ Vec{FT}(h, 0, 0)
        v4 = v3 .+ Vec{FT}(0, -w, 0)
        v5 = pmin .+ Vec{FT}(0, 0, l)
        v6 = v5 .+ Vec{FT}(0, w, 0)
        v8 = pmax .+ Vec{FT}(0, -w, 0)
        BBox(pmin, v2, v3, v4, v5, v6, pmax, v8)
    end
end

# Create the mesh associated to a bbox
function BBox(v1, v2, v3, v4, v5, v6, v7, v8)
    vertices = [
        v1, v4, v3,
        v1, v3, v2,
        v1, v5, v8,
        v1, v8, v4,
        v4, v8, v7,
        v4, v7, v3,
        v3, v7, v6,
        v3, v6, v2,
        v2, v6, v5,
        v2, v5, v1,
        v5, v6, v7,
        v5, v7, v8
        ]
    Mesh(vertices)
end
