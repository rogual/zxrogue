            call begin
            db "vadd", 0

            ld de, $0203
            ld bc, $0106
            call vadd_de_bc

            ld a, d
            cp 3
            call nz, fail

            ld a, e
            cp 9
            call nz, fail
