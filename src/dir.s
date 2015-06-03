
dirtab      db -1,  0
            db  1,  0
            db  0, -1
            db  0,  1


            ; Random NESW dir into BC
rand_dir    call randbyte
            push hl
            and 3
            ld b, 0
            ld c, a
            ld hl, dirtab
            add hl, bc
            add hl, bc
            ld b, (hl)
            inc hl
            ld c, (hl)
            pop hl
            ret
