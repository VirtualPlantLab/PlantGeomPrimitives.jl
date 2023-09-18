var documenterSearchIndex = {"docs":
[{"location":"#Geometry","page":"Home","title":"Geometry","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = PlantGeomPrimitives","category":"page"},{"location":"#Scenes","page":"Home","title":"Scenes","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Scene\nadd!","category":"page"},{"location":"#PlantGeomPrimitives.Scene","page":"Home","title":"PlantGeomPrimitives.Scene","text":"Scene(; mesh = Mesh(Float64), colors = Colorant[], material_ids = Int[], materials = Material[])\n\nCreate a Scene object from a triangular mesh (mesh), a vector of colors (colors, any type that inherits from Colorant from the ColorTypes package), a vector of material IDs (material_ids that link indivudal triangles to material objects) and a vector of materials (materials, any object that inherits from Material). See packages PlantViz and PlantRayTracer for more details on materials and colors.\n\njulia> t = Triangle(length = 2.0, width = 2.0);\n\njulia> s = Scene(mesh = t);\n\n\n\n\n\n\nScene(scenes)\n\nMerge multiple Scene objects into one.\n\n\n\n\n\n","category":"type"},{"location":"#PlantGeomPrimitives.add!","page":"Home","title":"PlantGeomPrimitives.add!","text":"add!(scene; mesh, color = nothing, material = nothing)\n\nManually add a 3D mesh to an existing Scene object (scene) with optional colors and materials\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"colors(scene::Scene)\nmesh(scene::Scene)\nmaterials(scene::Scene)","category":"page"},{"location":"#PlantGeomPrimitives.colors-Tuple{Scene}","page":"Home","title":"PlantGeomPrimitives.colors","text":"colors(scene::Scene)\n\nExtract the vector of Colorant objects stored inside a scene (used for rendering)\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.mesh-Tuple{Scene}","page":"Home","title":"PlantGeomPrimitives.mesh","text":"mesh(scene::Scene)\n\nExtract the triangular mesh stored inside a scene (used for ray tracing & rendering)\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.materials-Tuple{Scene}","page":"Home","title":"PlantGeomPrimitives.materials","text":"materials(scene::Scene)\n\nExtract the vector of Material objects stored inside a scene (used for ray tracing)\n\n\n\n\n\n","category":"method"},{"location":"#D-vectors","page":"Home","title":"3D vectors","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Vec\nO(::Type{FT} = Float64) where FT\nX(::Type{FT} = Float64) where FT\nY(::Type{FT} = Float64) where FT\nZ(::Type{FT} = Float64) where FT\nX(s::FT) where FT\nY(s::FT) where FT\nZ(s::FT) where FT","category":"page"},{"location":"#PlantGeomPrimitives.Vec","page":"Home","title":"PlantGeomPrimitives.Vec","text":"Vec(x, y, z)\n\n3D vector or point with coordinates x, y and z.\n\njulia> v = Vec(0.0, 0.0, 0.0);\n\njulia> v = Vec(0f0, 0f0, 0f0);\n\n\n\n\n\n","category":"type"},{"location":"#PlantGeomPrimitives.O-Union{Tuple{}, Tuple{Type{FT}}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.O","text":"O()\n\nReturns the origin of the 3D coordinate system as a Vec object. By default, the coordinates will be in double floating precision (Float64) but it is possible to generate a version with lower floating precision as in O(Float32).\n\njulia>  O();\n\njulia>  O(Float32);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.X-Union{Tuple{}, Tuple{Type{FT}}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.X","text":"X()\n\nReturns an unit vector in the direction of the X axis as a Vec object. By default, the coordinates will be in double floating precision (Float64) but it is possible to generate a version with lower floating precision as in X(Float32).\n\njulia>  X();\n\njulia>  X(Float32);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.Y-Union{Tuple{}, Tuple{Type{FT}}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.Y","text":"Y()\n\nReturns an unit vector in the direction of the Y axis as a Vec object. By default, the coordinates will be in double floating precision (Float64) but it is possible to generate a version with lower floating precision as in Y(Float32).\n\njulia>  Y();\n\njulia>  Y(Float32);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.Z-Union{Tuple{}, Tuple{Type{FT}}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.Z","text":"Z()\n\nReturns an unit vector in the direction of the Z axis as a Vec object. By default, the coordinates will be in double floating precision (Float64) but it is possible to generate a version with lower floating precision as in Z(Float32).\n\njulia>  Z();\n\njulia>  Z(Float32);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.X-Tuple{FT} where FT","page":"Home","title":"PlantGeomPrimitives.X","text":"X(s)\n\nReturns scaled vector in the direction of the X axis with length s as a Vec object using the same floating point precision as s.\n\njulia>  X(1.0);\n\njulia>  X(1f0) ;\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.Y-Tuple{FT} where FT","page":"Home","title":"PlantGeomPrimitives.Y","text":"Y(s)\n\nReturns scaled vector in the direction of the Y axis with length s as a Vec object using the same floating point precision as s.\n\njulia>  Y(1.0);\n\njulia>  Y(1f0);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.Z-Tuple{FT} where FT","page":"Home","title":"PlantGeomPrimitives.Z","text":"Z(s)\n\nReturns scaled vector in the direction of the Z axis with length s as a Vec object using the same floating point precision as s.\n\njulia>  Z(1.0);\n\njulia>  Z(1f0);\n\n\n\n\n\n","category":"method"},{"location":"#Geometry-primitives","page":"Home","title":"Geometry primitives","text":"","category":"section"},{"location":"#Triangle","page":"Home","title":"Triangle","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Triangle(;length::FT = 1.0, width::FT = 1.0) where FT","category":"page"},{"location":"#PlantGeomPrimitives.Triangle-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.Triangle","text":"Triangle(;length = 1.0, width = 1.0)\n\nCreate a triangle with dimensions given by length and width, standard location and orientation.\n\nExamples\n\njulia> Triangle(;length = 1.0, width = 1.0);\n\n\n\n\n\n","category":"method"},{"location":"#Rectangle","page":"Home","title":"Rectangle","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Rectangle(;length::FT = 1.0, width::FT = 1.0) where FT","category":"page"},{"location":"#PlantGeomPrimitives.Rectangle-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.Rectangle","text":"Rectangle(;length = 1.0, width = 1.0)\n\nCreate a rectangle with dimensions given by length and width, standard location and orientation.\n\nExamples\n\njulia> Rectangle(;length = 1.0, width = 1.0);\n\n\n\n\n\n","category":"method"},{"location":"#Trapezoid","page":"Home","title":"Trapezoid","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Trapezoid(;length::FT = 1.0, width::FT = 1.0, ratio::FT = 1.0) where FT","category":"page"},{"location":"#PlantGeomPrimitives.Trapezoid-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.Trapezoid","text":"Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0)\n\nCreate a trapezoid with dimensions given by length and the larger width and the ratio between the smaller and larger widths. The trapezoid is generted at the standard location and orientation.\n\nExamples\n\njulia> Trapezoid(;length = 1.0, width = 1.0, ratio = 1.0);\n\n\n\n\n\n","category":"method"},{"location":"#Ellipse","page":"Home","title":"Ellipse","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Ellipse(;length::FT = 1.0, width::FT = 1.0 , n::Int = 20) where FT","category":"page"},{"location":"#PlantGeomPrimitives.Ellipse-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.Ellipse","text":"Ellipse(;length = 1.0, width = 1.0, n = 20)\n\nCreate an  ellipse with dimensions given by length and width, discretized into n triangles (must be even) and standard location and orientation.\n\nExamples\n\njulia> Ellipse(;length = 1.0, width = 1.0, n = 20);\n\n\n\n\n\n","category":"method"},{"location":"#Hollow-cylinder","page":"Home","title":"Hollow cylinder","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"HollowCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 40) where FT\nSolidCylinder(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 80) where FT","category":"page"},{"location":"#PlantGeomPrimitives.HollowCylinder-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.HollowCylinder","text":"HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40)\n\nCreate a hollow cylinder with dimensions given by length, width and height, discretized into n triangles (must be even) and standard location and orientation.\n\nExamples\n\njulia> HollowCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 40);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.SolidCylinder-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.SolidCylinder","text":"SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 80)\n\nCreate a solid cylinder with dimensions given by length, width and height, discretized into n triangles (must be even) and standard location and orientation.\n\nExamples\n\njulia> SolidCylinder(;length = 1.0, width = 1.0, height = 1.0, n = 80);\n\n\n\n\n\n","category":"method"},{"location":"#Hollow-cone","page":"Home","title":"Hollow cone","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"HollowCone(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 20) where FT\nSolidCone(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, n::Int = 40) where FT","category":"page"},{"location":"#PlantGeomPrimitives.HollowCone-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.HollowCone","text":"HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 20)\n\nCreate a hollow cone with dimensions given by length, width and height, discretized into n triangles (must be even) and standard location and orientation.\n\nExamples\n\njulia> HollowCone(;length = 1.0, width = 1.0, height = 1.0, n = 20);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.SolidCone-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.SolidCone","text":"SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 40)\n\nCreate a solid cone with dimensions given by length, width and height, discretized into n triangles (must be even) and standard location and orientation.\n\nExamples\n\njulia> SolidCone(;length = 1.0, width = 1.0, height = 1.0, n = 40);\n\n\n\n\n\n","category":"method"},{"location":"#Cube","page":"Home","title":"Cube","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"SolidCube(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where FT\nHollowCube(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0) where FT","category":"page"},{"location":"#PlantGeomPrimitives.SolidCube-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.SolidCube","text":"SolidCube(;length = 1.0, width = 1.0, height = 1.0)\n\nCreate a solid cube with dimensions given by length, width and height, standard location and orientation.\n\nExamples\n\njulia> SolidCube(;length = 1.0, width = 1.0, height = 1.0);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.HollowCube-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.HollowCube","text":"HollowCube(;length = 1.0, width = 1.0, height = 1.0)\n\nCreate a hollow cube with dimensions given by length, width and height, standard location and orientation.\n\nExamples\n\njulia> HollowCube(;length = 1.0, width = 1.0, height = 1.0);\n\n\n\n\n\n","category":"method"},{"location":"#Solid-frustum","page":"Home","title":"Solid frustum","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"SolidFrustum(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, ratio::FT = 1.0, n::Int = 80) where FT\nHollowFrustum(;length::FT = 1.0, width::FT = 1.0, height::FT = 1.0, ratio::FT = 1.0, n::Int = 40) where FT","category":"page"},{"location":"#PlantGeomPrimitives.SolidFrustum-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.SolidFrustum","text":"SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40)\n\nCreate a solid frustum with dimensions given by length, width and height, discretized into n triangles and standard location and orientation.\n\nExamples\n\njulia> SolidFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40);\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.HollowFrustum-Union{Tuple{}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.HollowFrustum","text":"HollowFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40)\n\nCreate a hollow frustum with dimensions given by length, width and height, discretized into n triangles (must be even) and standard location and orientation.\n\nExamples\n\njulia> HollowFrustum(;length = 1.0, width = 1.0, height = 1.0, n = 40);\n\n\n\n\n\n","category":"method"},{"location":"#Bounding-box","page":"Home","title":"Bounding box","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"BBox(m::Mesh{VT}) where VT <: Vec{FT} where FT\nBBox(pmin::Vec{FT}, pmax::Vec{FT}) where FT","category":"page"},{"location":"#PlantGeomPrimitives.BBox-Union{Tuple{Mesh{VT}}, Tuple{VT}, Tuple{FT}} where {FT, VT<:StaticArraysCore.SVector{3, FT}}","page":"Home","title":"PlantGeomPrimitives.BBox","text":"BBox(m::Mesh)\n\nBuild a tight axis-aligned bounding box around a Mesh object.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.BBox-Union{Tuple{FT}, Tuple{StaticArraysCore.SVector{3, FT}, StaticArraysCore.SVector{3, FT}}} where FT","page":"Home","title":"PlantGeomPrimitives.BBox","text":"BBox(pmin::Vec, pmax::Vec)\n\nBuild an axis-aligned bounding box given the vector of minimum (pmin) and maximum (pmax) coordinates.\n\nExamples\n\njulia> p0 = Vec(0.0, 0.0, 0.0);\n\njulia> p1 = Vec(1.0, 1.0, 1.0);\n\njulia> box = BBox(p0, p1);\n\n\n\n\n\n","category":"method"},{"location":"#Rotations,-scaling-and-translations","page":"Home","title":"Rotations, scaling and translations","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"scale!(m::Mesh, vec::Vec)\nrotatex!(m::Mesh, θ)\nrotatey!(m::Mesh, θ)\nrotatez!(m::Mesh, θ)\nrotate!(m::Mesh; x::Vec{FT}, y::Vec{FT}, z::Vec{FT}) where FT\ntranslate!(m::Mesh, v::Vec)","category":"page"},{"location":"#PlantGeomPrimitives.scale!-Tuple{Mesh, StaticArraysCore.SVector{3}}","page":"Home","title":"PlantGeomPrimitives.scale!","text":"scale!(m::Mesh, Vec)\n\nScale a mesh m along the three axes provided by vec\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.rotatex!-Tuple{Mesh, Any}","page":"Home","title":"PlantGeomPrimitives.rotatex!","text":"rotatex!(m::Mesh, θ)\n\nRotate a mesh m around the x axis by θ rad.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.rotatey!-Tuple{Mesh, Any}","page":"Home","title":"PlantGeomPrimitives.rotatey!","text":"rotatey!(m::Mesh, θ)\n\nRotate a mesh m around the y axis by θ rad.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.rotatez!-Tuple{Mesh, Any}","page":"Home","title":"PlantGeomPrimitives.rotatez!","text":"rotatez!(m::Mesh, θ)\n\nRotate a mesh m around the z axis by θ rad.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.rotate!-Union{Tuple{Mesh}, Tuple{FT}} where FT","page":"Home","title":"PlantGeomPrimitives.rotate!","text":"rotate!(m::Mesh; x::Vec, y::Vec, z::Vec)\n\nRotate a mesh m to a new coordinate system given by x, y and z\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.translate!-Tuple{Mesh, StaticArraysCore.SVector{3}}","page":"Home","title":"PlantGeomPrimitives.translate!","text":"translate!(m::Mesh, v::Vec)\n\nTranslate the mesh m by vector v\n\n\n\n\n\n","category":"method"},{"location":"#Other-mesh-related-methods","page":"Home","title":"Other mesh-related methods","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Mesh(::Type{FT} = Float64)  where FT <: AbstractFloat\nMesh(nt, nv = nt*3, ::Type{FT} = Float64) where FT <: AbstractFloat\nntriangles(mesh::Mesh)\nnvertices(mesh::Mesh)\narea(m::Mesh)\nareas(m::Mesh)\nloadmesh(filename)\nsavemesh(mesh; fileformat = STL_BINARY, filename)","category":"page"},{"location":"#PlantGeomPrimitives.Mesh-Union{Tuple{}, Tuple{Type{FT}}, Tuple{FT}} where FT<:AbstractFloat","page":"Home","title":"PlantGeomPrimitives.Mesh","text":"Mesh()\n\nGenerate an empty triangular dense mesh that represents a primitive or 3D scene.  By default a Mesh object will only accept coordinates in double floating  precision (Float64) but a lower precision can be generated by specifying the  corresponding data type as in Mesh(Float32).\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.Mesh-Union{Tuple{Any}, Tuple{FT}, Tuple{Any, Any}, Tuple{Any, Any, Type{FT}}} where FT<:AbstractFloat","page":"Home","title":"PlantGeomPrimitives.Mesh","text":"Mesh(nt, nv = nt*3)\n\nGenerate a triangular dense mesh with enough memory allocated to store nt  triangles and nv vertices. The behaviour is equivalent to generating an empty  mesh but may be computationally more efficient when appending a large number of  primitives. If a lower floating precision is required, this may be specified as an optional third argument as in Mesh(10, 30, Float32).\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.ntriangles-Tuple{Mesh}","page":"Home","title":"PlantGeomPrimitives.ntriangles","text":"ntriangles(mesh)\n\nExtract the number of triangles in a mesh.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.nvertices-Tuple{Mesh}","page":"Home","title":"PlantGeomPrimitives.nvertices","text":"nvertices(mesh)\n\nThe number of vertices in a mesh.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.area-Tuple{Mesh}","page":"Home","title":"PlantGeomPrimitives.area","text":"area(m::Mesh)\n\nTotal surface area of a mesh (as the sum of areas of individual triangles).\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.areas-Tuple{Mesh}","page":"Home","title":"PlantGeomPrimitives.areas","text":"areas(m::Mesh)\n\nA vector with the areas of the different triangles that form a mesh.\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.loadmesh-Tuple{Any}","page":"Home","title":"PlantGeomPrimitives.loadmesh","text":"loadmesh(filename)\n\nImport a mesh from a file given by filename. Supported formats include stl, ply, obj and msh. By default, this will generate a Mesh object that uses double floating-point precision. However, a lower precision can be specified by passing the relevant data type as in loadmesh(filename, Float32).\n\n\n\n\n\n","category":"method"},{"location":"#PlantGeomPrimitives.savemesh-Tuple{Any}","page":"Home","title":"PlantGeomPrimitives.savemesh","text":"savemesh(mesh; fileformat = STL_BINARY, filename)\n\nSave a mesh into an external file using a variety of formats.\n\nArguments\n\nmesh: Object of type Mesh.\nfileformat: Format to store the mesh. This is a keyword argument.\nfilename: Name of the file in which to store the mesh.\n\nDetails\n\nThe fileformat should take one of the following arguments: STL_BINARY, STL_ASCII, PLY_BINARY, PLY_ASCII or OBJ. Note that these names should not be quoted as strings.\n\nReturn\n\nThis function does not return anything, it is executed for its side effect.\n\n\n\n\n\n","category":"method"}]
}