# PlantGeomPrimitives

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://virtualplantlab.com/stable/api/geometry/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://virtualplantlab.com/dev/api/geometry/)
[![CI](https://github.com/VirtualPlantLab/PlantGeomPrimitives.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/VirtualPlantLab/PlantGeomPrimitives.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/VirtualPlantLab/PlantGeomPrimitives.jl/branch/master/graph/badge.svg?token=LCZHPERHUN)](https://codecov.io/gh/VirtualPlantLab/PlantGeomPrimitives.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![ColPrac](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

This package is a component of the VPL ecosystem. It implements algorithms for procedural
generation of plant geometry from graphs, using turtle graphics. This package is a component
of the [Virtual Plant Lab](http://virtualplantlab.com/). Users should install instead the
interface package [VirtualPlantLab.jl](https://github.com/VirtualPlantLab/VirtualPlantLab.jl).

# 1. Installation

You can install the latest stable version of PlantGeomPrimitives.jl with the Julia package manager:

```julia
] add PlantGeomPrimitives
```

Or the development version directly from here:

```julia
import Pkg
Pkg.add(url="https://github.com/VirtualPlantLab/PlantGeomPrimitives.jl", rev = "master")
```
