### This file contains public API ###

# Convert to format used in GeometryBasics
function GLMesh(m::Mesh{VT}) where {VT<:Vec{FT}} where {FT<:AbstractFloat}
    verts = convert(Vector{GeometryBasics.Point{3,FT}}, vertices(m))
    facs = [GeometryBasics.TriangleFace{Int}(i, i+1, i+2) for i in 1:3:length(vertices(m))]
    m = GeometryBasics.Mesh(verts, facs)
end

# Convert from format used in GeometryBasics
function Mesh(m::GeometryBasics.Mesh)
    all_verts = convert(Vector{Vec{Float64}}, GeometryBasics.coordinates(m))
    verts = Vec{Float64}[]
    @inbounds for f in GeometryBasics.faces(m)
        push!(verts, all_verts[f[1]])
        push!(verts, all_verts[f[2]])
        push!(verts, all_verts[f[3]])
    end
    Mesh(verts)
end

"""
    load_mesh(filename, type = Float64)

Import a mesh from a file given by `filename`. Supported formats include stl,
ply, obj and msh. By default, this will generate a `Mesh` object that uses
double floating-point precision. However, a lower precision can be specified by
passing the relevant data type as in `load_mesh(filename, Float32)`.

# Arguments
- `filename`: The path to the file containing the mesh.
- `type`: The floating-point precision type for the mesh data (default is `Float64`).

# Example
```julia
julia> mesh = load_mesh("path/to/mesh.obj");

julia> mesh = load_mesh("path/to/mesh.obj", Float32);
```
"""
function load_mesh(filename, ::Type{FT} = Float64) where {FT}
    check_aply = findfirst(".aply", filename)
    if isnothing(check_aply)
        m = FileIO.load(
            filename,
            pointtype = GeometryBasics.Point{3,FT},
            normaltype = GeometryBasics.Point{3,FT},
        )
    else
        m = FileIO.load(filename, pointtype = GeometryBasics.Point{3,FT})
    end
    Mesh(m)
end

"""
    save_mesh(mesh; fileformat = :STL_BINARY, filename)

Save a mesh into an external file using a variety of formats.

# Arguments
- `mesh`: Object of type `Mesh`.
- `fileformat`: Format to store the mesh as symbol.
- `filename`: Name of the file in which to store the mesh as string.

# Details
The `fileformat` should take one of the following arguments: `:STL_BINARY`,
`:STL_ASCII`, `:PLY_BINARY`, `:PLY_ASCII` or `:OBJ`. Note that these names should
be passed as symnols.

# Example
```julia
julia> v = [Vec(0.0, 0.0, 0.0), Vec(0.0, 1.0, 0.0), Vec(1.0, 0.0, 0.0)];

julia> n = [Vec(0.0, 0.0, 1.0)];

julia> mesh = Mesh(v, n);

julia> save_mesh(mesh, fileformat = :STL_BINARY, filename = "path/to/mesh.bstl");
```
"""
function save_mesh(mesh; fileformat = :STL_BINARY, filename)
    FileIO.save(FileIO.File{FileIO.DataFormat{fileformat}}(filename), GLMesh(mesh))
end
