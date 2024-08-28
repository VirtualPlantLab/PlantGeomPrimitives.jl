### This file contains public API ###
# Scene
# materials
# colors
# mesh
# nvertices
# vertices
# normals

"""
    Scene

A scene is a collection of triangular meshes, colors, and materials. It is used for rendering
and ray tracing. The scene object is a container for the following fields:

- `mesh`: A triangular mesh (object of type `PlantGeomPrimitives.Mesh`).
- `colors`: A vector of colors (any type that inherits from `ColorTypes.Colorant`).
- `material_ids`: A vector of integers that represent the material associated with each
triangle in the mesh.
- `materials`: A vector of materials (object of types that inherit from `PlantGeomPrimitives.Material`).

Several constructors are available to create a scene from scratch or to extend an existing
scene.
"""
struct Scene{VT}
    mesh::Mesh{VT}
    colors::Vector{Colorant}
    material_ids::Vector{Int}
    materials::Vector{Material}
end

# Constructor to avoid concrete types for colors and materials
"""
    Scene(; mesh = Mesh(Float64), colors = Colorant[], materials = Material[])

Create a scene from a triangular mesh and associated colors and materials. This function
should only be used when creating a scene from scratch. To extend an existing scene, use
the function `add!` instead. Also, scenes can be created from `PlantGraphs.Graph` objects
directly.

# Arguments
- `mesh`: A triangular mesh (object of type `PlantGeomPrimitives.Mesh`).

- `colors`: A vector of colors (any type that inherits from `ColorTypes.Colorant`). There
should be one color per triangle in the mesh or a single color (such that all triangles get
the same color). This is an optional argument, but if no colors are provided, it the
resulting scene cannot be visualized (the function `rennder()` will throw an error).

- `materials`: A vector of materials (object of type `PlantRayTracer.Material`). There should
be one material per triangle in the mesh or a single material (such that all triangles get the
same material). This is an optional argument, but if no materials are provided, the resulting
scene cannot be used for ray tracing.

```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> s = Scene(mesh = t);

```
"""
function Scene(;mesh = Mesh(Float64), colors = nothing, materials = nothing)
    @assert mesh isa Mesh
    FT = eltype(eltype(vertices(mesh)))
    sc = Scene(Mesh(FT), Colorant[], Int[], Material[])
    add!(sc, mesh = mesh, colors = colors, materials = materials)
    return sc
end

# Accessor functions
"""
    colors(scene)

Extract the vector of colors stored inside a scene (used for rendering). Note that a scene
will assign one color per vertex (even though we create scenes with one color per triangle
or per mesh).

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> import ColorTypes: RGB

julia> s = Scene(mesh = t, colors = RGB(1.0, 0.0, 0.0));

julia> colors(s);

julia> s = Scene(mesh = t);

julia> colors(s);
```
"""
colors(scene::Scene) = scene.colors

"""
    materials(scene)

Extract the vector of material objects stored inside a scene (used for ray tracing).
Depending on how the scene was created, there may be one material per triangle or one
material per mesh inside the scene.

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```julia
julia> t = Triangle(length = 2.0, width = 2.0);

julia> import PlantRayTracer: Sensor;

julia> s = Scene(mesh = t, materials = Sensor(1));

julia> materials(s);

julia> s = Scene(mesh = t);

julia> materials(s);
```
"""
materials(scene::Scene) = scene.materials

material_ids(scene::Scene) = scene.material_ids

"""
    mesh(scene)

Extract the triangular mesh stored inside a scene (used for ray tracing & rendering).

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> s = Scene(mesh = t);

julia> mesh(s);
```
"""
mesh(scene::Scene) = scene.mesh

"""
    nvertices(scene)

Calculate the number of vertices

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> s = Scene(mesh = t);

julia> nvertices(s);
```
"""
nvertices(scene::Scene) = nvertices(mesh(scene))

"""
    ntriangles(scene)

Calculate the number of vertices

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> s = Scene(mesh = t);

julia> ntriangles(s);
```
"""
ntriangles(scene::Scene) = ntriangles(mesh(scene))

"""
    vertices(scene)

Extract the vertices of the triangular mesh stored inside a scene.

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> s = Scene(mesh = t);

julia> vertices(s);
```
"""
vertices(scene::Scene) = vertices(mesh(scene))

"""
    normals(scene)

Extract the normals of the triangular mesh stored inside a scene.

# Arguments
- `scene`: A scene object (object of type `Scene`).

# Example
```jldoctest
julia> t = Triangle(length = 2.0, width = 2.0);

julia> s = Scene(mesh = t);

julia> normals(s);
```
"""
normals(scene::Scene) = normals(mesh(scene))

"""
    Scene(scenes)

Merge multiple scenes into a single one.

# Arguments
- `scenes`: A vector of scene objects (object of type `Scene`).

# Example
```jldoctest
julia> t1 = Triangle(length = 1.0, width = 1.0);

julia> t2 = Rectangle(length = 5.0, width = 0.5);

julia> s1 = Scene(mesh = t1);

julia> s2 = Scene(mesh = t2);

julia> s = Scene([s1, s2]);
"""
function Scene(scenes::Vector{<:Scene})
    allmesh = Mesh(mesh.(scenes))
    allcolors = vcat(colors.(scenes)...)
    allmaterials = vcat(materials.(scenes)...)
    @inbounds allmaterial_ids = scenes[1].material_ids
    if length(scenes) > 1
        for i = 2:length(scenes)
            @inbounds append!(
                allmaterial_ids,
                allmaterial_ids[end] .+ scenes[i].material_ids,
            )
        end
    end
    Scene(allmesh, allcolors, allmaterial_ids, allmaterials)
end


"""
    add!(scene; mesh, colors = nothing, materials = nothing)

Manually add a mesh to an existing scene with optional colors and materials. Make sure to
be consistent with the optional arguments. That is, if the scene was created with colors,
then you should provide colors for the new mesh as well (the same applies to materials).
Otherwise, the scene will not be usable for rendering or ray tracing.

# Arguments
- `scene`: A scene object.
- `mesh`: A triangular mesh.
- `colors`: A vector of colors. See documentation of `Scene` for more information.
- `materials`: A vector of materials. See documentation of `Scene` for more information.

# Example
```jldoctest
julia> t1 = Triangle(length = 1.0, width = 1.0);

julia> t2 = Rectangle(length = 5.0, width = 0.5);

julia> s1 = Scene(mesh = t1);

julia> add!(s1, mesh = t2);

julia> ntriangles(s1);
"""
function add!(scene; mesh, colors = nothing, materials = nothing)
    # Make sure the mesh contains normals
    update_normals!(mesh)
    # Add triangles to scene by adjusting face indices
    nv = nvertices(scene)
    append!(vertices(scene), vertices(mesh))
    append!(normals(scene), normals(mesh))
    # Add colors if available
    update_color!(scene, colors, ntriangles(mesh))
    # Add material if available
    update_material!(scene, materials, ntriangles(mesh))
    return nothing
end


# Add material(s) associated to a primitive, making sure they are consistent with the number
# of triangles
function update_material!(scene, material, nt)
    if !isnothing(material)
        matid = length(materials(scene)) + 1
        # All triangles shared the same material
        if material isa Material
            push!(materials(scene), material)
            for _ = 1:nt
                push!(material_ids(scene), matid)
            end
            # Each triangle has its own material
        elseif length(material) == nt
            append!(materials(scene), material)
            for i = 0:nt-1
                push!(material_ids(scene), matid + i)
            end
        else
            error("Provided either a material or a vector of materials of length $(nt)")
        end
    end
    return nothing
end

# Add color(s) associated to a primitive (one color per vertex as required by the renderer)
function update_color!(scene, color, ntriangles)
    if !isnothing(color)
        # All triangles share the same color
        if color isa Colorant
            for _ = 1:ntriangles
                for _ = 1:3
                    push!(colors(scene), color)
                end
            end
        # Each triangle has its own color
        elseif length(color) == ntriangles
            for i = 1:ntriangles
                for _ = 1:3
                    push!(colors(scene), color[i])
                end
            end
        else
            error("Provided either a color or a vector of colors of length $(ntriangles)")
        end
    end
    return nothing
end
