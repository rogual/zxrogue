
            ; Lookup table for weird Speccy screen layout
linetab     LUA ALLPASS
                for y=0,191 do
                    offs = 16384
                    offs = offs + _c("("..y.." & %111) << 8)")
                    offs = offs + _c("("..y.." & %111000) << 2)")
                    offs = offs + _c("("..y.." & %11000000) << 5)")
                    sj.add_word(offs)
                end
            ENDLUA


            ; Sets HL to address of pixel line A.
line_addr   push bc
            ld hl, linetab
            ld b, 0
            ld c, a
            add hl, bc
            add hl, bc
            ld bc, (hl)
            ld hl, bc
            pop bc
            ret


            ; Sets HL to address of attribute byte for screen cell (B, C).
attr_addr   ld a,c              ; x position.
            rrca                ; multiply by 32.
            rrca
            rrca
            ld l,a              ; store away in l.
            and 3               ; mask bits for high byte.
            add a,88            ; 88*256=22528, start of attributes.
            ld h,a              ; high byte done.
            ld a,l              ; get x*32 again.
            and 224             ; mask low byte.
            ld l,a              ; put in l.
            ld a,b              ; get y displacement.
            add a,l             ; add to low byte.
            ld l,a              ; hl=address of attributes.
            ld a,(hl)           ; return attribute in a.
            ret


setattr     ; Sets attribute at (B, C) to A
            push hl
            ex af, af'
            call attr_addr
            ex af, af'
            ld (hl), a
            pop hl
            ret


            ; Set all screen attrs to A
cls         ld (23693), a
            jp 3503
