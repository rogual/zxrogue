            ; error messages
ecnext      db "obj already in cell",0
erem        db "error removing obj",0


            ; init
cell_init   ld hl, cells
            ld a, 255
            DUP board_w * board_h
            ld (hl), a
            inc hl
            EDUP
            ret

            ; A=!0 if B,C is in bounds
cell_ib     ld a, board_w
            sub b
            jp z, .no
            jp c, .no
            ld a, board_h
            sub c
            jp z, .no
            jp c, .no
.yes        ld a, 1
            ret
.no         ld a, 0
            ret


            ; A!=0 if B,C is out-of-bounds
cell_oob    call cell_ib
            jp nota


            ; call (hl) for each cell with bc=coords
cell_iter   push bc
            ld b, board_w 
.x
            push bc
            ld c, b
            ld b, board_h 
.y
            dec b
            dec c
            call calli
            inc c
            inc b

            djnz .y
            pop bc
            djnz .x
            pop bc
            ret


            ; get address in hl of cell at bc
cell_addr   ld hl, cells

            push de

            ; Get Y pos
            push bc
            ld b, c
            ld de, board_w * cell_t

            inc b
            jp .nrow
.row
            add hl, de
.nrow
            djnz .row
            pop bc

            ; Add X pos
            push bc
            ld c, b
            ld b, 0
            DUP cell_t
            add hl, bc
            EDUP
            pop bc

            pop de
            ret


            ; add object a to cell at bc
            ; preserves af
cell_ins    push de
            push af
            push hl
            ld d, a                   ; remember obj id
            call obj_addr             ; get obj to ix
            push hl
            pop ix
            ld a, (ix + obj_t.cnext)  ; ensure cnext is empty
            cp 255
            jp z, .body
            ld hl, ecnext
            jp panic

.body       call cell_addr            ; get cell addr
            ld a, (hl)                ; obj.cnext = cell.obj0
            ld (ix + obj_t.cnext), a
            ld a, d                   ; recall obj id
            ld (hl), a                ; cell.obj0 = obj.id
            pop hl
            pop af
            pop de
            jp dirty_cell             ; mark cell dirty


            ; remove object a from cell bc
            ; preserves af
cell_rem    push af
            ld (.objid), a

            call obj_addr           ; store our object's cnext
            DUP obj_t.cnext         ; then set it to 255
            inc hl
            EDUP
            ld a, (hl)              ; (255 = no cnext)
            ld (.next), a
            ld a, 255
            ld (hl), a

            push bc
            call cell_addr          ; if this is the first
            ld a, (.objid)
            ld b, a                 ; object in the cell,
            ld a, (hl)              ; set cell's first to
            cp b                    ; our next and
            pop bc                  ; return
            jp nz, .notfirst
            ld a, (.next)
            ld (hl), a
            jp .ok

.notfirst   ld a, 0                 ; not the first object so
            ld (.found), a          ; must update predecessor

            ld hl, .iter            ; search objects for the
            call cell_objs          ; one before ours

            ld a, (.found)            ; check that we found
            cp 1                      ; exactly 1 obj
            jp z, .ok
            ld hl, erem
            jp panic
.ok         pop af
            jp dirty_cell           ; mark cell dirty
.objid      db 0
.next       db 0
.found      db 0
.iter
            push bc
            ld a, (.objid)            ; check if this object is
            ld b, (ix + obj_t.cnext)  ; the one before ours.
            cp b
            jp nz, .iterend           ; if it is,

            ld a, (.next)             ; set its cnext to our
            ld (ix + obj_t.cnext), a  ; cnext

            ld hl, .found             ; remember that we found
            inc (hl)                  ; it

.iterend
            pop bc
            ret


            ; call (hl) for each obj in cell (B, C) with
            ; A: Object ID
            ; IX: Object addr
cell_objs   push de
            push hl
            call cell_addr
            ld de, hl
            pop hl

            ld a, (de)

.next       cp 255

            jp z, .done

            push hl
            call obj_addr                       ; get obj addr
            push hl                             ; to ix
            pop ix
            pop hl

            call calli                          ; call callback
            ld a, (ix + obj_t.cnext)            ; next obj

            jp .next

.done       pop de
            ret


            ; A!=0 if any object in cell (B, C) is solid.
cell_solid  call cell_oob
            ret nz

            push ix
            push hl

            ld hl, .iter
            ld a, 0
            ld (.result), a
            call cell_objs
            ld a, (.result)
            jp .done
.iter       ld a, (ix + obj_t.flags)
            and 2
            push hl
            ld hl, .result
            or (hl)
            ld (hl), a
            pop hl
            ret
.result     db 0
.done       pop hl
            pop ix
            ld a, (.result)
            ret


            ; Send evt D(E) to all objs in cell B,C
cell_event  ld a, d
            ld (.evtid), a
            ld a, e
            ld (.evtarg), a
            push hl
            push bc
            ld hl, .iter
            call cell_objs
            pop bc
            pop hl
            ret
.iter       push hl
            ld hl, (ix + obj_t.eventh)

            ex af, af'
            ld a, (.evtid)
            ld d, a
            ld a, (.evtarg)
            ld e, a
            ex af, af'
            call obj_event
.iterend    pop hl
            ret
.evtid      db 0
.evtarg     db 0
