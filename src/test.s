failed      db 0
failmsg     db " -- FAIL -- ",0

test_run
            include tests/vector.s
            include tests/cells.s
            include tests/objects.s
            include tests/draw.s
            jp done

begin       ld hl, 0
            add hl, sp
            ld e, (hl)
            inc hl
            ld d, (hl)
            ex de, hl
            call newline
            call print
            ld a, ' '
            rst 16
            inc hl
            ld bc, hl

            ld hl, 0
            add hl, sp
            ld (hl), c
            inc hl
            ld (hl), b

            call init

            ret

fail        ld hl, failed
            inc (hl)
            ld hl, failmsg
            call print
            ret

done        ld a, (failed)
            or a
            ret z
            jp $

