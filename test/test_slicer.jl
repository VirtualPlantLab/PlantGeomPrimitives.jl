import PlantGeomPrimitives as G
using Test
using StaticArrays
using LinearAlgebra: normalize
#import PlantViz as V
#import ColorTypes: RGB
#import GLMakie

let

#######################
##### Test slicer #####
#######################

# Create a mesh and a copy
r = G.HollowCylinder(length = 2.0, width = 0.1, height = 0.1)
G.rotatex!(r, pi/4)
r2 = deepcopy(r)

# Intersection of by a horizontal and vertical plane
# Heights of intersection
Ycuts = collect(-1:0.25:1)
Zcuts = collect(0:0.25:2)
G.slice!(r2, planes = (X = (), Y = Ycuts, Z = Zcuts))

end
