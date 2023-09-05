using PlantGeomPrimitives
using Documenter

DocMeta.setdocmeta!(PlantGeomPrimitives, :DocTestSetup, :(using PlantGeomPrimitives); recursive = true)

makedocs(;
    modules = [PlantGeomPrimitives],
    authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
    repo = "https://github.com/AleMorales/PlantGeomPrimitives.jl/blob/{commit}{path}#{line}",
    sitename = "PlantGeomPrimitives.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "master",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)
