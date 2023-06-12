using VPLGeom
using Documenter

DocMeta.setdocmeta!(VPLGeom, :DocTestSetup, :(using VPLGeom); recursive = true)

makedocs(;
    modules = [VPLGeom],
    authors = "Alejandro Morales Sierra <alejandro.moralessierra@wur.nl> and contributors",
    repo = "https://github.com/AleMorales/VPLGeom.jl/blob/{commit}{path}#{line}",
    sitename = "VPLGeom.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "master",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)
