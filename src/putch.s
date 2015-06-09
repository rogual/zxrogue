
            ; Draws ASCII char in A register to screen pos (B, C)
            ; ROM routine to do this is slow and can't use whole screen
putch       push de
            push bc
            push hl

            ; Get row start addr
            push af
            ld a, c
            rlca
            rlca
            rlca
            ld c, a
            call line_addr
            pop af

            ; Add X pos
            push bc
            ld c, b
            ld b, 0
            add hl, bc
            pop bc

            ex de, hl

            ; Get source. If bit 7 is set, fetch graphic.
            push bc
            bit 7, a
            jp z, .src_rom
            ld hl, gfx_start-(90h*8)
            jp .src_end
.src_rom    ld hl, 15616+256-(8*'A')+8
.src_end    ld b, 0
            ld c, a
            DUP 8
            add hl, bc
            EDUP
            pop bc

.line

            ; Draw line
            ld a, (hl)
            ld (de), a

            ; See if we're done
            inc c
            ld a, c
            and 7
            jp z, .done

            ; Next line
            inc d
            inc hl
            jp .line

.done
            pop hl
            pop bc
            pop de
            ret


