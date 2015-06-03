
            ; Object A attacks object B
            ; Preserves AF
fight       push af
            push bc

            ld a, RED
            out (254), a
            halt
            halt

            ld a, 0
            out (254), a

            push bc
            call damage
            pop bc
            ld a, b
            call damage

            pop bc
            pop af
            ret

            ; Damage object A
damage
            ld b, a
            push bc
            call obj_addr
            push hl
            pop ix
            pop bc

            dec (ix + obj_t.hp)
            jp z, .kill
            ret
.kill       ld a, b
            jp kill


            ; Kill object A
kill
            or a
            jp z, gameover
            jp obj_del
