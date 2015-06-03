

            ; [D,E] += [B,C]
vadd_de_bc  ld a, d
            add b
            ld d, a
            ld a, e
            add c
            ld e, a
            ret

            ; Compare [D,E] to [B,C] and set zero flag accordingly
vcp_de_bc   ld a, d
            cp b
            ret nz
            ld a, e
            cp c
            ret

            ; Iterate over vector grid (0,0)..(B,C) and
            ; call (hl) at each square with coords in (B,C)
iterect     push af
            push bc
            push de
            ld d, b
            jp .nextRow
.iter       ld a, b
            cp a, 0
            jp z, .nextRow
            dec b
            call calli
            jp .iter
.nextRow    ld a, c
            or a
            jp z, .done
            ld b, d
            dec c
            jp .iter
.done       pop de
            pop bc
            pop af
            ret
