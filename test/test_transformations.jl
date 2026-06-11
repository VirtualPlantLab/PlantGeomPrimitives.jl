import PlantGeomPrimitives as G
using Test

let
    # Default Rectangle() lies in the x=0 plane:
    #   y ∈ {-0.5, 0.5},  z ∈ {0, 1}
    # Vertex list (two triangles, winding 1→2→3 and 1→3→4):
    #   v1=(0, 0.5,1), v2=(0,-0.5,1), v3=(0,-0.5,0), v1, v3, v4=(0, 0.5,0)
    # Normal for both faces: (1, 0, 0)  (face points in +x direction)
    # Area: width 1 × length 1 = 1

    m = G.Rectangle()
    verts0 = copy(G.vertices(m))
    norms0 = copy(G.normals(m))
    area0  = G.area(m)

    # Helpers for per-axis coordinate extraction
    xs(m) = getindex.(G.vertices(m), 1)
    ys(m) = getindex.(G.vertices(m), 2)
    zs(m) = getindex.(G.vertices(m), 3)

    atol = sqrt(eps(Float64))

    # ── Baseline: verify the default geometry ────────────────────────────────
    @test all(verts0 .≈ [G.Vec(0.0,  0.5, 1.0),
                         G.Vec(0.0, -0.5, 1.0),
                         G.Vec(0.0, -0.5, 0.0),
                         G.Vec(0.0,  0.5, 1.0),
                         G.Vec(0.0, -0.5, 0.0),
                         G.Vec(0.0,  0.5, 0.0)])
    @test all(n ≈ G.Vec(1.0, 0.0, 0.0) for n in norms0)
    @test area0 ≈ 1.0

    # ── rotatex!(90°)  Rx(90°): (x,y,z) → (x, -z, y) ───────────────────────
    # x is the rotation axis → x-coordinates are invariant.
    # Normal (1,0,0) lies on the rotation axis → must stay (1,0,0).
    m1 = deepcopy(m)
    G.rotatex!(m1, 90.0)
    @test all(isapprox.(xs(m1),  getindex.(verts0, 1), atol = atol))  # x unchanged
    @test all(isapprox.(ys(m1), -getindex.(verts0, 3), atol = atol))  # y ← −z_orig
    @test all(isapprox.(zs(m1),  getindex.(verts0, 2), atol = atol))  # z ←  y_orig
    @test all(n ≈ G.Vec(1.0, 0.0, 0.0) for n in G.normals(m1))
    @test G.area(m1) ≈ area0               # rotation preserves area

    # ── rotatey!(90°)  Ry(90°): (x,y,z) → (z, y, -x) ───────────────────────
    # y is the rotation axis → y-coordinates are invariant.
    # Normal (1,0,0) → (0,0,-1) under Ry(90°).
    m2 = deepcopy(m)
    G.rotatey!(m2, 90.0)
    @test all(isapprox.(xs(m2),  getindex.(verts0, 3), atol = atol))  # x ←  z_orig
    @test all(isapprox.(ys(m2),  getindex.(verts0, 2), atol = atol))  # y unchanged
    @test all(isapprox.(zs(m2), -getindex.(verts0, 1), atol = atol))  # z ← −x_orig  (all 0 here)
    @test all(n ≈ G.Vec(0.0, 0.0, -1.0) for n in G.normals(m2))
    @test G.area(m2) ≈ area0

    # ── rotatez!(90°)  Rz(90°): (x,y,z) → (-y, x, z) ───────────────────────
    # z is the rotation axis → z-coordinates are invariant.
    # Normal (1,0,0) → (0,1,0) under Rz(90°).
    m3 = deepcopy(m)
    G.rotatez!(m3, 90.0)
    @test all(isapprox.(xs(m3), -getindex.(verts0, 2), atol = atol))  # x ← −y_orig
    @test all(isapprox.(ys(m3),  getindex.(verts0, 1), atol = atol))  # y ←  x_orig  (all 0 here)
    @test all(isapprox.(zs(m3),  getindex.(verts0, 3), atol = atol))  # z unchanged
    @test all(n ≈ G.Vec(0.0, 1.0, 0.0) for n in G.normals(m3))
    @test G.area(m3) ≈ area0

    # ── rotatex!(180°)  Rx(180°): (x,y,z) → (x, -y, -z) ────────────────────
    # (1,0,0) is still on the rotation axis → normal unchanged.
    m4 = deepcopy(m)
    G.rotatex!(m4, 180.0)
    @test all(isapprox.(xs(m4),  getindex.(verts0, 1), atol = atol))
    @test all(isapprox.(ys(m4), -getindex.(verts0, 2), atol = atol))
    @test all(isapprox.(zs(m4), -getindex.(verts0, 3), atol = atol))
    @test all(n ≈ G.Vec(1.0, 0.0, 0.0) for n in G.normals(m4))

    # ── rotatez!(180°)  Rz(180°): (x,y,z) → (-x, -y, z) ────────────────────
    # Normal (1,0,0) → (-1,0,0): the face now points in the -x direction.
    m5 = deepcopy(m)
    G.rotatez!(m5, 180.0)
    @test all(isapprox.(xs(m5), -getindex.(verts0, 1), atol = atol))  # all 0 here, but sign matters
    @test all(isapprox.(ys(m5), -getindex.(verts0, 2), atol = atol))
    @test all(isapprox.(zs(m5),  getindex.(verts0, 3), atol = atol))
    @test all(n ≈ G.Vec(-1.0, 0.0, 0.0) for n in G.normals(m5))

    # ── Composition: Ry(90°) then Rz(90°) ───────────────────────────────────
    # (0,y,z) →[Ry]→ (z, y, 0) →[Rz]→ (-y, z, 0)
    # Normal: (1,0,0) →[Ry]→ (0,0,-1) →[Rz]→ (0, 0, -1)  (Rz maps (-y,x,z): (0,0,-1) stays)
    m6 = deepcopy(m)
    G.rotatey!(m6, 90.0)
    G.rotatez!(m6, 90.0)
    @test all(isapprox.(xs(m6), -getindex.(verts0, 2), atol = atol))  # x ← −y_orig
    @test all(isapprox.(ys(m6),  getindex.(verts0, 3), atol = atol))  # y ←  z_orig
    @test all(isapprox.(zs(m6), -getindex.(verts0, 1), atol = atol))  # z ← −x_orig  (all 0)
    @test all(n ≈ G.Vec(0.0, 0.0, -1.0) for n in G.normals(m6))

    # ── Invertibility (arbitrary angles) ─────────────────────────────────────
    # Rotating by θ then −θ must restore the original mesh exactly.
    for (fn, θ) in [(G.rotatex!, 37.5), (G.rotatey!, -53.2), (G.rotatez!, 123.4)]
        m_inv = deepcopy(m)
        fn(m_inv, θ)
        fn(m_inv, -θ)
        @test all(G.vertices(m_inv) .≈ verts0)
        @test all(G.normals(m_inv) .≈ norms0)
    end

    # ── rotate! with custom axes ─────────────────────────────────────────────
    # Cyclic permutation x→ŷ, y→ẑ, z→x̂ builds the column-major matrix
    #   col1=(0,1,0), col2=(0,0,1), col3=(1,0,0)
    # which maps (x,y,z) → (z, x, y).
    # For (0,y,z): new coords are (z, 0, y).
    # Normal (1,0,0): mat*(1,0,0) = first column of mat = (0,1,0).
    m7 = deepcopy(m)
    G.rotate!(m7, x = G.Vec(0.0, 1.0, 0.0), y = G.Vec(0.0, 0.0, 1.0), z = G.Vec(1.0, 0.0, 0.0))
    @test all(isapprox.(xs(m7),  getindex.(verts0, 3), atol = atol))  # new x = orig z
    @test all(isapprox.(ys(m7),  getindex.(verts0, 1), atol = atol))  # new y = orig x  (all 0)
    @test all(isapprox.(zs(m7),  getindex.(verts0, 2), atol = atol))  # new z = orig y
    @test all(n ≈ G.Vec(0.0, 1.0, 0.0) for n in G.normals(m7))

    # Identity rotation (x→x̂, y→ŷ, z→ẑ) must leave the mesh unchanged.
    m7b = deepcopy(m)
    G.rotate!(m7b, x = G.X(), y = G.Y(), z = G.Z())
    @test all(G.vertices(m7b) .≈ verts0)
    @test all(G.normals(m7b) .≈ norms0)

    # ── translate! ────────────────────────────────────────────────────────────
    # Each vertex must shift by exactly d; normals are unaffected.
    m8 = deepcopy(m)
    d = G.Vec(1.0, 2.0, 3.0)
    G.translate!(m8, d)
    @test all(G.vertices(m8) .≈ verts0 .+ Ref(d))
    @test all(G.normals(m8) .≈ norms0)
    G.translate!(m8, -d)
    @test all(G.vertices(m8) .≈ verts0)   # reversible

    # ── scale! ────────────────────────────────────────────────────────────────
    # scale!(m, Vec(sx,sy,sz)) multiplies vertex coords component-wise.
    m9 = deepcopy(m)
    G.scale!(m9, G.Vec(2.0, 3.0, 0.5))
    @test all(isapprox.(xs(m9), 2.0 .* getindex.(verts0, 1), atol = atol))
    @test all(isapprox.(ys(m9), 3.0 .* getindex.(verts0, 2), atol = atol))
    @test all(isapprox.(zs(m9), 0.5 .* getindex.(verts0, 3), atol = atol))

    # Area of the rectangle (in the x=0 plane) scales with sy*sz.
    m10 = deepcopy(m)
    G.scale!(m10, G.Vec(1.0, 2.0, 3.0))
    @test G.area(m10) ≈ 6.0 * area0

    # Scaling along x (perpendicular to the face) does not change the area.
    m11 = deepcopy(m)
    G.scale!(m11, G.Vec(5.0, 1.0, 1.0))
    @test G.area(m11) ≈ area0
    # But it does move vertices' x-coordinates.
    @test all(isapprox.(xs(m11), 5.0 .* getindex.(verts0, 1), atol = atol))

    # Scaling along x: normal direction (1,0,0) under (S⁻¹)ᵀ = diag(1/sx,1,1)
    # → (1/sx, 0, 0) which normalises back to (1,0,0).
    @test all(n ≈ G.Vec(1.0, 0.0, 0.0) for n in G.normals(m11))

end
