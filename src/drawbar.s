            ; Draws a stat bar, 8 chars wide
            ; B,C Pos to draw at
            ; D/E Ratio
draw_bar
            ld a, CYAN | PAPER_BLUE
            ld (ATTR_T), a

            push bc
            ; 8 chars
            ; 8*8 = 64 bars
            ; how many bars to draw = 64 * d/e
            ld h, 0
            ld l, d
            add hl, hl
            add hl, hl
            add hl, hl
            add hl, hl
            add hl, hl
            add hl, hl    ; hl is now 64 * d
            call div_hl_e ; hl is now 64 * d / e

            ld d, 10

            ; So now we need to draw "hl" many bars. Take off
            ; groups of 8 and draw as full blocks...

            jp .endblock

.nextblock
            ld a, l
            ld b, 8
            cp b
            jp p, .fullblock

            ; Draw part of a block
            ld a, 0
            ld l, 0
            ld a, $8a
            rst 16
            jp .endblock

.fullblock
            DUP 8
            dec l
            EDUP
            ld a, $8f
            rst 16

.endblock
            dec d
            ld a, l
            or a
            jp nz, .nextblock

            ld b, d
            jp .fillnext
.fillspace  ld a, ' '
            rst 16
.fillnext   djnz .fillspace

            pop bc


            ld a, WHITE | PAPER_BLACK
            ld (ATTR_T), a

            ret


