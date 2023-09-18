using Documenter, PlantGeomPrimitives

makedocs(;
         doctest = false,
         modules = [PlantGeomPrimitives],
         format = Documenter.HTML(;
            prettyurls = get(ENV, "CI", "false") == "true",
            edit_link = "master",
            assets = String[],
         ),
         authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
         repo = "https://github.com/VirtualPlantLab/PlantGeomPrimitives.jl/blob/{commit}{path}#{line}",
         sitename = "PlantGeomPrimitives.jl",
         pages = [
             "Home" => "index.md",
         ])

deploydocs(;
         repo="github.com/VirtualPlantLab/PlantGeomPrimitives.jl.git",
         devbranch="master"
)
