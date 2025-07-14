
################################### NORMALS ################################################

# TODO: Write documentation for calculate_normals!()
function calculate_normals!(m::Mesh{FT}) where {FT<:AbstractFloat}
    vs = vertices(m)
    lv = length(vs)
    output = Vec{FT}[]
    for i in 1:3:lv
        @inbounds v1, v2, v3 = vs[i], vs[i+1], vs[i+2]
        n = L.normalize(L.cross(v2 .- v1, v3 .- v1))
        push!(output, n)
    end
    return output
end

# TODO: Write documentation for update_normals!()
function update_normals!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :normals and if not create it
    if !haskey(properties(m), :normals)
        properties(m)[:normals] = Vec{FT}[]
    end
    vs = vertices(m)
    lv = length(vs)
    # 2. If the property :normals is empty, compute the normals for all vertices
    if isempty(normals(m))
        for i in 1:3:lv
            @inbounds v1, v2, v3 = vs[i], vs[i+1], vs[i+2]
            n = L.normalize(L.cross(v2 .- v1, v3 .- v1))
            push!(normals(m), n)
        end
    else
    # 3. If the property :normals is not empty, compute the normals for the remaining vertices
        ln = length(normals(m))
        for i in 3ln:3:(lv - 3)
            @inbounds v1, v2, v3 = vs[i + 1], vs[i + 2], vs[i + 3]
            n = L.normalize(L.cross(v2 .- v1, v3 .- v1))
            push!(normals(m), n)
        end
    end
    return nothing
end

##################################### AREAS ################################################

# Area of a triangle given its vertices
function area_triangle(v1::Vec{FT}, v2::Vec{FT}, v3::Vec{FT})::FT where {FT<:AbstractFloat}
    e1 = v2 .- v1
    e2 = v3 .- v1
    FT(0.5) * L.norm(L.cross(e1, e2))
end

# TODO: Write documentation for calculate_areas!()
function calculate_areas!(m::Mesh{FT}) where {FT<:AbstractFloat}
    vs = vertices(m)
    lv = length(vs)
    output = FT[]
    for i in 1:3:lv
        @inbounds v1, v2, v3 = vs[i], vs[i+1], vs[i+2]
        area = area_triangle(v1, v2, v3)
        push!(output, area)
    end
    return output
end

# TODO: Write documentation for update_areas!()
function update_areas!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :areas and if not create it
    if !haskey(properties(m), :areas)
        properties(m)[:areas] = Vec{FT}[]
    end
    vs = vertices(m)
    lv = length(vs)
    # 2. If the property :areas is empty, compute the areas for all vertices
    if isempty(areas(m))
        for i in 1:3:lv
            @inbounds v1, v2, v3 = vs[i], vs[i+1], vs[i+2]
            area = area_triangle(v1, v2, v3)
            push!(areas(m), area)
        end
    else
    # 3. If the property :areas is not empty, compute the areas for the remaining vertices
        ln = length(areas(m))
        for i in 3ln:3:(lv - 3)
            @inbounds v1, v2, v3 = vs[i + 1], vs[i + 2], vs[i + 3]
            area = area_triangle(v1, v2, v3)
            push!(areas(m), area)
        end
    end
    return nothing
end


##################################### EDGES ################################################

# TODO: Write documentation for calculate_edges!()
function calculate_edges!(m::Mesh{FT}) where {FT<:AbstractFloat}
    vs = vertices(m)
    lv = length(vs)
    output = FT[]
    for i in 1:3:lv
        @inbounds v1, v2, v3 = vs[i], vs[i+1], vs[i+2]
        e1 = L.normalize(v2 .- v1)
        e2 = L.normalize(v3 .- v1)
        e3 = L.normalize(v2 .- v3)
        push!(output, Vec(e1, e2, e3))
    end
    return output
end

# TODO: Write documentation for update_edges!()
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


################################## INCLINATION #############################################

# TODO: Write documentation for calculate_inclinations!()
function calculate_inclinations!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # We need the normal vectors to compute the angles
    if has_normals(m) && length(normals(m)) == ntriangles(m)
        nvec = normals(m)
    else
        nvec = calculate_normals(m)
    end
    # For each normal vector compute the angel wrt horizontal plane
    output = FT[]
    for n in nvec
        push!(output, acos(n[3]/norm(n)))
    end
    return output
end

# TODO: Write documentation for update_inclinations!()
# Creates normals as a side effect
function update_inclinations!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :inclinations and if not create it
    if !haskey(properties(m), :inclinations)
        properties(m)[:inclinations] = Vec{Vec{FT}}[]
    end
    # 2. We need the normal vectors to compute the angles
    update_normals!(m)
    # 3. If the property :inclinations is empty, compute the inclinations for all vertices
    if isempty(inclinations(m))
        for n in normals(m)
            push!(inclinations(m), acos(n[3]/norm(n)))
        end
    else
    # 4. If the property :inclinations is not empty, compute the inclinations for the remaining vertices (if any)
        ln = length(inclinations(m))
        for i in ln:ntriangles(m)
            n = normals(m)[i]
            push!(inclinations(m), acos(n[3]/norm(n)))
        end
    end
end


################################## ORIENTATION #############################################

# TODO: Write documentation for calculate_orientations!()
function calculate_orientations!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # We need the normal vectors to compute the angles
    if has_normals(m) && length(normals(m)) == ntriangles(m)
        nvec = normals(m)
    else
        nvec = calculate_normals(m)
    end
    # For each normal vector compute the angel wrt horizontal plane
    output = FT[]
    for n in nvec
        push!(output, atan(n[2]/n[1]))
    end
    return output
end

# TODO: Write documentation for update_orientations!()
# Creates normals as a side effect
function update_orientations!(m::Mesh{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :orientations and if not create it
    if !haskey(properties(m), :orientations)
        properties(m)[:orientations] = Vec{Vec{FT}}[]
    end
    # 2. We need the normal vectors to compute the angles
    update_normals!(m)
    # 3. If the property :orientations is empty, compute the orientations for all vertices
    if isempty(orientations(m))
        for n in normals(m)
            push!(orientations(m), atan(n[2]/n[1]))
        end
    else
    # 4. If the property :orientations is not empty, compute the orientations for the remaining vertices (if any)
        ln = length(orientations(m))
        for i in ln:ntriangles(m)
            n = normals(m)[i]
            push!(orientations(m), atan(n[2]/n[1]))
        end
    end
end
