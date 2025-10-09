# PlantGeomPrimitives v1.0.0 release notes

- Intoduce Segments and Points: There is now an underlying data structure (`Geom`) that can
represent triangles, segments and points plus properties.

- Refactor how properties are stored: they are now stored in a named tuple of vectors. All
the properties and their element types must be defined at the moment of creating the `Geom`
object. This makes the system less dynamic but growing existing geometries (e.g., through
turtle algorithm or similar) becomes much faster and the types of properties are now inferred.
This breaks existing public API.
