################################## INCLINATION #############################################

# TODO: Write documentation for calculate_inclinations!()
function calculate_inclinations!(m::Points{FT}) where {FT<:AbstractFloat}
    # We need the normal vectors to compute the angles
    if has_normals(m) && length(normals(m)) == npoints(m)
        nvec = normals(m)
    else
        error("Cannot compute inclinations for point clouds without normals")
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
function update_inclinations!(m::Points{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :inclinations and if not create it
    if !haskey(properties(m), :inclinations)
        properties(m)[:inclinations] = Vec{Vec{FT}}[]
    end
    # 2. If the property :inclinations is empty, compute the inclinations for all points
    if isempty(inclinations(m))
        !has_normals(m) && error("Cannot compute inclinations for point clouds without normals")
        for n in normals(m)
            push!(inclinations(m), acos(n[3]/norm(n)))
        end
    else
    # 3. If the property :inclinations is not empty, compute the inclinations for the remaining points (if any)
        ln = length(inclinations(m))
        if has_normals(m) && length(normals(m)) == npoints(m)
            for i in ln:npoints(m)
                n = normals(m)[i]
                push!(inclinations(m), acos(n[3]/norm(n)))
            end
        else
            error("Cannot compute inclinations for point clouds without normals")
        end
    end
end


################################## ORIENTATION #############################################

# TODO: Write documentation for calculate_orientations!()
function calculate_orientations!(m::Points{FT}) where {FT<:AbstractFloat}
    # We need the normal vectors to compute the angles
    if has_normals(m) && length(normals(m)) == npoints(m)
        nvec = normals(m)
    else
        error("Cannot compute orientations for point clouds without normals")
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
function update_orientations!(m::Points{FT}) where {FT<:AbstractFloat}
    # 1. Check if there is a property called :orientations and if not create it
    if !haskey(properties(m), :orientations)
        properties(m)[:orientations] = Vec{Vec{FT}}[]
    end
    # 2. If the property :orientations is empty, compute the orientations for all vertices
    if isempty(orientations(m))
        !has_normals(m) && error("Cannot compute orientations for point clouds without normals")
        for n in normals(m)
            push!(orientations(m), atan(n[2]/n[1]))
        end
    else
    # 3. If the property :orientations is not empty, compute the orientations for the remaining vertices (if any)
        ln = length(orientations(m))
        if has_normals(m) && length(normals(m)) == npoints(m)
            for i in ln:npoints(m)
                n = normals(m)[i]
                push!(orientations(m), atan(n[2]/n[1]))
            end
        else
            error("Cannot compute orientations for point clouds without normals")
        end
    end
end
