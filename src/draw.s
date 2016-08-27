
; Dirtytab entries
; 16bits
;
; Flags  a=no entry here,  b=sentinel (last entry)
; /\
; ab000000 00000000
;   |----|   |----|
;    X pos    Y pos


draw_init   ld hl, dirtyend
            ld (hl), %11000000
            inc hl
            ld (hl), $ff
            ld hl, dirtytab
            ld (hl), %10000000
            inc hl
            ld (hl), $ff
            ret


dirty_all   ld hl, drawflag         ; set flag to say whole
            set 0, (hl)             ; screen is dirty
            ld hl, dirtytab         ; remove all cells from
            ld (hl), %10000000      ; dirtytab
            ret


            ; Mark the cell at B,C dirty.
dirty_cell  push hl
            push bc

            ld hl, drawflag         ; return if screen already dirty
            bit 0, (hl)
            jp nz, .skip

            ld hl, dirtytab         ; prepare to read table

.iter       ld b, (hl)              ; read entry
            bit 6, b                ; if this is the sentinel
            jp nz, .overflow        ; go to overflow

            bit 7, b                ; if this slot is empty
            jp nz, .found           ; go to found

            inc hl                  ; next slot
            inc hl
            jp .iter

.overflow   call dirty_all          ; overflow -- mark whole
.skip       pop bc                  ; screen dirty
            pop hl
            ret

.found      pop bc                  ; found -- set this entry
            ld (hl), b              ; to the cell we're
            inc hl                  ; trying to make dirty
            ld (hl), c
            inc hl                  ; mark the next item
            set 7, (hl)             ; empty
            pop hl
            ret


            ; draw whatever needs drawing
draw        push hl
            push bc

            call draw_hud

            ld hl, drawflag         ; draw whole screen
            bit 0, (hl)             ; if that flag is set
            jp z, .dirty
.all        call draw_cells
            jp .done

.dirty      ld hl, dirtytab         ; draw only dirty cells
.iter       ld b, (hl)              ; read entry from table
            inc hl
            ld c, (hl)
            inc hl
            bit 7, b                ; stop if we're done
            jp nz, .iterend
            call draw_cell          ; draw this cell
            jp .iter                ; next
.iterend    ld hl, dirtytab         ; empty the table
            set 7, (hl)
.done       pop bc
            pop hl
            ret


            ; draw all cells
draw_cells  ld hl, drawflag         ; reset dirty flag
            res 0, (hl)
            ld hl, draw_cell        ; draw each cell
            call cell_iter
            ret


            ; draw the cell at b,c
draw_cell   push hl
            push bc
            ld a, '.'
            call putch
            ld a, BLUE
            call setattr

            ld a, b
            ld (.x), a
            ld a, c
            ld (.y), a

            ld hl, .drawobj
            call cell_objs
            jp .done

.drawobj
            push bc
            ld a, (.x)
            ld b, a
            ld a, (.y)
            ld c, a
            ld a, (ix + obj_t.glyph)
            call putch
            ld a, (ix + obj_t.attr)
            call setattr
            pop bc
            ret

.x          db 0
.y          db 0

.done
            pop bc
            pop hl
            ret


draw_hud    push bc

            ld b, 23
            ld c, 0

            ; Draw HP
            call setcur
            ld hl, m_hp
            call print
            ld a, (pl_hp)
            ld d, a
            call print_a
            ld a, '/'
            rst 16
            ld a, (pl_max_hp)
            ld e, a
            call print_a

            inc c
            call setcur
            call draw_bar

            ; Draw amulet
            ld a, (pl_amulet)
            or a
            jp z, .noamulet
            inc c
            call setcur
            ld hl, m_amulet
            call print
            jp .endamulet

.noamulet
            inc c
            call setcur
.endamulet

            ; Draw level
            inc c
            call setcur
            ld hl, m_level
            call print

            ld a, (pl_level)
            call print_a

            pop bc
            ret

m_amulet    db 90h," Amulet",0
m_hp        db "HP:",0
m_level     db "Level ",0

