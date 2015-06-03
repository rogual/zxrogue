OE_STEPPED_ON   equ 1

oeh_noop    ret

oeh_staird  call next_level
            ret

oeh_stairu  call prev_level
            ret

oeh_amulet  call obj_del

            ld a, 4
            out (254), a
            halt
            ld a, 0
            out (254), a

            ld a, 1
            ld (pl_amulet), a
            ret
