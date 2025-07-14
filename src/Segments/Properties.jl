
#################################### AREAS #################################################

# TODO: Write documentation for calculate_areas!()
function calculate_areas!(m::Segments{FT}) where {FT<:AbstractFloat}
    # We need the lengths to compute the areas
    if has_lengths(m) && length(lengths(m)) == nsegments(m)
        lvec = lengths(m)
    else
        lvec = calculate_lengths(m)
    end
    # We need the radius to compute the areas (this should always be available!)
    rvec = radius(m)
    # Compute the surface of the segment
    output = Vec{FT}[]
    for i in 1:nsegments(m)
        area = 2pi*rvec[i]*lvec[i]
        push!(output, area)
    end
    return output
end

# TODO: Write documentation for update_areas!()
function update_areas!(m::Segments{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :areas and if not create it
    if !haskey(properties(m), :areas)
        properties(m)[:areas] = Vec{FT}[]
    end
    # 2. We need lengths and radius
    update_lengths!(m)
    lvec = lengths(m)
    rvec = radius(m)
    # 3. If the property :areas is empty, compute the areas for all vertices
    if isempty(areas(m))
        for i in 1:nsegments(n)
            area = 2pi*rvec[i]*lvec[i]
            push!(areas(m), area)
        end
    else
    # 3. If the property :areas is not empty, compute the areas for the remaining vertices
        ln = length(areas(m))
        for i in ln:nsegments(m)
            area = 2pi*rvec[i]*lvec[i]
            push!(areas(m), area)
        end
    end
    return nothing
end

################################### VOLUMES ################################################

# TODO: Write documentation for calculate_volumes!()
function calculate_volumes!(m::Segments{FT}) where {FT<:AbstractFloat}
    # We need the lengths to compute the volumes
    if has_lengths(m) && length(lengths(m)) == nsegments(m)
        lvec = lengths(m)
    else
        lvec = calculate_lengths(m)
    end
    # We need the radius to compute the volumes (this should always be available!)
    rvec = radius(m)
    # Compute the volume of the segment
    output = Vec{FT}[]
    for i in 1:nsegments(m)
        volume = pi*rvec[i]^2*lvec[i]
        push!(output, volume)
    end
    return output
end

# TODO: Write documentation for update_volumes!()
function update_volumes!(m::Segments{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :volumes and if not create it
    if !haskey(properties(m), :volumes)
        properties(m)[:volumes] = Vec{FT}[]
    end
    # 2. We need lengths and radius
    update_lengths!(m)
    lvec = lengths(m)
    rvec = radius(m)
    # 3. If the property :volumes is empty, compute the volumes for all vertices
    if isempty(volumes(m))
        for i in 1:nsegments(n)
            volume = pi*rvec[i]^2*lvec[i]
            push!(volumes(m), volume)
        end
    else
    # 4. If the property :volumes is not empty, compute the volumes for the remaining vertices
        ln = length(volumes(m))
        for i in ln:nsegments(m)
            volume = pi*rvec[i]^2*lvec[i]
            push!(volumes(m), volume)
        end
    end
    return nothing
end

################################### LENGTHS ################################################

# TODO: Write documentation for calculate_lengths!()
function calculate_lengths!(m::Segments{FT}) where {FT<:AbstractFloat}
    vs = vertices(m)
    output = Vec{FT}[]
    for i in 1:2:nvertices(m)
        l = norm(vs[i] .- vs[i+1])
        push!(output, l)
    end
    return output
end

# TODO: Write documentation for update_lengths!()
function update_lengths!(m::Segments{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :lengths and if not create it
    if !haskey(properties(m), :lengths)
        properties(m)[:lengths] = Vec{FT}[]
    end
    # 2. If the property :lengths is empty, compute the lengths for all vertices
    vs = vertices(m)
    if isempty(lengths(m))
        for i in 1:2:nvertices(m)
            l = norm(vs[i] .- vs[i+1])
            push!(lengths(m), l)
        end
    else
    # 3. If the property :lengths is not empty, compute the lengths for the remaining vertices
        ln = length(lengths(m))
        for i in 2ln:2:nvertices(m)
            l = norm(vs[i] .- vs[i+1])
            push!(lengths(m), l)
        end
    end
    return nothing
end


################################### INCLINATIONS ############################################

# TODO: Write documentation for calculate_inclinations!()
function calculate_inclinations!(m::Segments{FT}) where {FT<:AbstractFloat}
    vs = vertices(m)
    output = Vec{FT}[]
    for i in 1:2:nvertices(m)
        v = vs[i+1] .- vs[i]
        push!(output, asin(v[3]/norm(v)))
    end
    return output
end

# TODO: Write documentation for update_inclinations!()
function update_inclinations!(m::Segments{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :inclinations and if not create it
    if !haskey(properties(m), :inclinations)
        properties(m)[:inclinations] = Vec{FT}[]
    end
    # 2. If the property :inclinations is empty, compute the inclinations for all vertices
    vs = vertices(m)
    if isempty(inclinations(m))
        for i in 1:2:nvertices(m)
            v = vs[i+1] .- vs[i]
            push!(inclinations(m), asin(v[3]/norm(v)))
        end
    else
    # 3. If the property :inclinations is not empty, compute the inclinations for the remaining vertices
        ln = length(inclinations(m))
        for i in 2ln:2:nvertices(m)
            v = vs[i+1] .- vs[i]
            push!(inclinations(m), asin(v[3]/norm(v)))
        end
    end
    return nothing
end


################################### ORIENTATIONS ###########################################

# TODO: Write documentation for calculate_orientations!()
function calculate_orientations!(m::Segments{FT}) where {FT<:AbstractFloat}
    vs = vertices(m)
    output = Vec{FT}[]
    for i in 1:2:nvertices(m)
        v = vs[i+1] .- vs[i]
        push!(output, atan(v[2]/v[1]))
    end
    return output
end

# TODO: Write documentation for update_orientations!()
function update_orientations!(m::Segments{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :orientations and if not create it
    if !haskey(properties(m), :orientations)
        properties(m)[:orientations] = Vec{FT}[]
    end
    # 2. If the property :orientations is empty, compute the orientations for all vertices
    vs = vertices(m)
    if isempty(orientations(m))
        for i in 1:2:nvertices(m)
            v = vs[i+1] .- vs[i]
            push!(orientations(m), atan(v[2]/v[1]))
        end
    else
    # 3. If the property :orientations is not empty, compute the orientations for the remaining vertices
        ln = length(orientations(m))
        for i in 2ln:2:nvertices(m)
            v = vs[i+1] .- vs[i]
            push!(orientations(m), atan(v[2]/v[1]))
        end
    end
    return nothing
end
