            ;;  Copy our graphics to 65368 (UDG area)
            ;;  so they can be printed by ROM print routines
gfx_init    ld hl, gfx_start
            ld de, 65368
            ld bc, gfx_end - gfx_start
            ldir
            ret

gfx_start   db %00011100
            db %00100010
            db %00100010
            db %00011100
            db %00001000
            db %00111110
            db %00001000
            db %00001000

gfx_end     equ $
