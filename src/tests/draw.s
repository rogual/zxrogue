
            call begin
            db "dirty", 0

            ld hl, dirtytab
            ld a, (hl)
            bit 7, a
            call z, fail
            bit 6, a
            call nz, fail

            ld bc, $0304
            call dirty_cell
            ld bc, $0506
            call dirty_cell

            MACRO expect byte
                ld a, (hl)
                cp byte
                call nz, fail
                inc hl
            ENDM

            expect 3
            expect 4
            expect 5
            expect 6

            ld a, (hl)
            bit 7, a
            call z, fail

