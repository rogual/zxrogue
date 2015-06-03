            ; Call subroutine at (hl)
calli       jp (hl)


            ; Print message at (hl) and hang.
panic       call cur00
            push hl
            ld a, $10   ; white ink
            rst 16
            ld a, WHITE
            rst 16
            ld a, $11   ; red paper
            rst 16
            ld a, RED
            rst 16
            pop hl
            call print  ; go for it
            jp $


            ; invert A and update flags
nota        or a
            jp z, .zero
.nz         ld a, 0
            or a
            ret
.zero       ld a, 1
            or a
            ret
