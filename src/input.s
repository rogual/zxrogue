in_dir      db 0, 0
in_flags    db 0 ;   X   Y  Flags
in_tab      db 'h',  0, -1, 0
            db 'j',  1,  0, 0
            db 'k', -1,  0, 0
            db 'l',  0,  1, 0
            db 0

in_get      ; Blocks until a key is pressed, then
            ; returns it in A.
            push hl
            push bc
.wait
            halt
            ld hl, FLAGS
            ld a, (hl)
            bit 5, a
            jp z, .wait

            ; Reset the new-key flag
            and %11011111
            ld (hl), a

            ; Reset flags
            ld a, 0
            ld (in_dir), a
            ld (in_dir+1), a
            ld (in_flags), a

            ; Get key code into A
            ld hl, LASTK
            ld a, (hl)

            ; Interpret this key
            ld hl, in_tab
            ld c, a
.loop
            ld b, (hl)
            ld a, 0
            cp b
            jp z, .done
            ld a, c
            cp b
            jp z, .found

            inc hl
            inc hl
            inc hl
            inc hl
            jp .loop
.found
            inc hl
            ld a, (hl)
            ld (in_dir), a
            inc hl
            ld a, (hl)
            ld (in_dir+1), a
            inc hl
            ld a, (hl)
            ld (in_flags), a
.done
            pop bc
            pop hl
            ret
