
print       ld a, (hl)
            or a
            ret z
            rst 16
            inc hl
            jp print


            ; Move cursor to B, C
setcur      ld a, 22
            rst 16
            ld a, c
            rst 16
            ld a, b
            rst 16
            ret


            ; Move cursor to 0, 0
cur00       push bc
            ld bc, 0
            call setcur
            pop bc
            ret


newline     ld a, 13
            rst 16
            ret

            ; Print BC to stdout for BC <= 9999
            ; Preserves AF
print_bc    push bc
            push af
            push de
            push hl
            push ix

            call 11563
            call 11747

            pop ix
            pop hl
            pop de
            pop af
            pop bc
            ret

            ; Print A to stdout
            ; Preserves AF
print_a     push bc
            push af

            ld b, 0
            ld c, a
            call print_bc

            pop af
            pop bc
            ret

            ; Print [B, C] to stdout
print_b_c   push bc
            push hl
            push de
            ld a, '['
            rst 16

            push bc
            ld c, b
            ld b, 0
            call print_bc
            pop bc

            ld a, ','
            rst 16

            push bc
            ld b, 0
            call print_bc
            pop bc

            ld a, ']'
            rst 16
            pop de
            pop hl
            pop bc
            ret
