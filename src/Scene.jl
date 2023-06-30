### This file contains public API ###
# Scene
# materials
# colors
# mesh
# nvertices
# vertices
# normals
# faces

# Structure that contains the information gathered by a turtle
struct Scene{FT}
    mesh::Mesh{FT}
    colors::Vector{Colorant}
    material_ids::Vector{Int}
    materials::Vector{Material}
end

# Constructor to avoid concrete types for colors and materials
function Scene(;
    mesh = Mesh(Float64),
    colors = Colorant[],
    material_ids = Int[],
    materials = Material[],
)
    scene = Scene(mesh, Colorant[], Int[], Material[])
    if colors isa Colorant
        push!(scene.colors, colors)
    else
        append!(scene.colors, colors)
    end
    if material_ids isa Number
        push!(scene.material_ids, material_ids)
    else
        append!(scene.material_ids, material_ids)
    end
    if materials isa Material
        push!(scene.materials, materials)
    else
        append!(scene.materials, materials)
    end
    return scene
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
faces(scene::Scene) = faces(mesh(scene))

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
function add!(scene; mesh, color = nothing, material = nothing)
    # Add triangles to scene by adjusting face indices
    nv = nvertices(scene)
    append!(vertices(scene), vertices(mesh))
    append!(normals(scene), normals(mesh))
    append!(faces(scene), (nv .+ face for face in faces(mesh)))
    # Add colors if available
    update_color!(scene, color, nvertices(mesh))
    # Add material if available
    update_material!(scene, material, ntriangles(mesh))
    return nothing
end
