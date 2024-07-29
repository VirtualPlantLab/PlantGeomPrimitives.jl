### This file contains public API ###
# Scene
# materials
# colors
# mesh
# nvertices
# vertices
# normals

# Structure that contains the information gathered by a turtle
struct Scene{VT}
    mesh::Mesh{VT}
    colors::Vector{Colorant}
    material_ids::Vector{Int}
    materials::Vector{Material}
end

# Constructor to avoid concrete types for colors and materials
"""
    Scene(; mesh = Mesh(Float64), colors = Colorant[], material_ids = Int[], materials = Material[])

Create a `Scene` object from a triangular mesh (`mesh`), a vector of colors (`colors`, any
type that inherits from `Colorant` from the ColorTypes package), a vector of material IDs
(`material_ids` that link indivudal triangles to material objects) and a vector of materials
(`materials`, any object that inherits from `Material`). See packages PlantViz and
PlantRayTracer for more details on materials and colors.

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
    colors(scene::Scene)

Extract the vector of `Colorant` objects stored inside a scene (used for rendering)
"""
colors(scene::Scene) = scene.colors
"""
    materials(scene::Scene)

Extract the vector of `Material` objects stored inside a scene (used for ray tracing)
"""
materials(scene::Scene) = scene.materials
material_ids(scene::Scene) = scene.material_ids
"""
    mesh(scene::Scene)

Extract the triangular mesh stored inside a scene (used for ray tracing & rendering)
"""
mesh(scene::Scene) = scene.mesh
nvertices(scene::Scene) = nvertices(mesh(scene))
vertices(scene::Scene) = vertices(mesh(scene))
normals(scene::Scene) = normals(mesh(scene))

"""
    Scene(scenes)

Merge multiple `Scene` objects into one.
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
    add!(scene; mesh, color = nothing, material = nothing)

Manually add a 3D mesh to an existing `Scene` object (`scene`) with optional
colors and materials
"""
function add!(scene; mesh, colors = nothing, materials = nothing)
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


# Add material(s) associated to a primitive
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
