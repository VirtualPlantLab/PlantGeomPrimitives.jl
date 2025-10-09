import PlantGeomPrimitives as G
using Test


let

e = G.Ellipse(;length = 1.0, width = 1.0, n = 20);
@test !(:edges in keys(G.properties(e)))
G.update_edges!(e)
@test :edges in keys(G.properties(e))
eds = G.edges(e)
@test length(eds) == G.ntriangles(e)
@test length(eds[1]) == 3
@test length(eds[1][1]) == 3

end
