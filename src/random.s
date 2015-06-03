

            ; Seed the RNG with BC
srand       push hl
            ld hl, rndseed
            ld (hl), bc
            pop hl
            ret


            ; Sets A to a random byte value
randbyte    push hl
            push bc
            push de

            ld hl, rndseed
            ld bc, (hl)

            ld a, b
            xor c
            ld d, a
            ld a, b
            add c
            ld e, a

            ld hl, bc
            DUP 7
            add hl, de
            EDUP

            ld bc, hl
            ld hl, rndseed
            ld (hl), bc

            ld a, c

            pop de
            pop bc
            pop hl
            ret


            ; Sets A to a random value less than A.
randlt      push bc
            ld b, a
            call randbyte
.iter       sub b
            jp nc, .iter
            add b
            pop bc
            ret

