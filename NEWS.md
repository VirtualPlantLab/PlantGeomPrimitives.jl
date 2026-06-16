# PlantGeomPrimitives release notes

We started keeping track of changes in the `NEWS.md` file after version 0.1.0.

# PlantGeomPrimitives 1.0.1 (2026-06-16)

Implement `Ellipsoid` as a primitive discretize into rectangular patches defined by fixed longitude and 
latitude increments. The user specifies the number of longitude and latitude increments rather than the
total number of triangles.

# PlantGeomPrimitives 1.0.1 (2026-06-11)

The rotation functions were still expecting angles in radians rather than degrees. The
documentation and internal implementation have been updated and tests improve (this error
went undetected!). This affects code where manual rotation of geometry was being used.

Functions affected: `rotatex!`, `rotatey!`, `rotatez!`.

# PlantGeomPrimitives 1.0.0 (2026-06-10)

No actual changes. We move to version 1.0.0 because:

- The tool is being used extensively by the community and it has become more stable.

- Julia treats any change as breaking change when < 1.0.0

# PlantGeomPrimitives 0.1.1 (2026-01-14)

* Add documentation (docstrings) to many of the functions in the package

* Update dependencies and ensure it works on Julia 1.12
