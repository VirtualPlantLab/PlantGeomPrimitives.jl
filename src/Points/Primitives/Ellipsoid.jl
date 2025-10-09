### This file contains public API ###


# Scaled ellipsoid
function EllipsoidPoints(l::Number, w::Number, h::Number, n::Number)
    @error "Ellipsoid not implemented yet"
end

# Create a ellipsoid from affine transformation
function EllipsoidPoints(trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0)
    @error "Ellipsoid not implemented yet"
end

# Create a ellipsoid from affine transformation and add it in-place to existing point cloud
function Ellipsoid!(p::Points, trans::CT.AbstractAffineMap; n::Int = 20, area::Float64 = 1.0)
    @error "Ellipsoid not implemented yet"
end
