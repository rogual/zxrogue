
_celladdr0  ; cell_addr(0, 0) = cells
            call begin
            db "cell-addr-0", 0

            ld bc, 0
            call cell_addr
            ld bc, cells
            or a
            sbc hl, bc
            call nz, fail


            ; cell_addr(5, 4) = cells + 5 * w + 4
_celladdr   call begin
            db "cell-addr",0

            ld bc, $0504
            call cell_addr

            ld bc, cells + (cell_t * (5 + (board_w * 4)))
            or a
            sbc hl, bc
            call nz, fail


            ; ensure iter_cell calls callback w*h times
_celliter   call begin
            db "cell-iter",0
            ld hl, .iter
            call cell_iter

            ld hl, board_w * board_h
            ld bc, (.tmp)
            or a
            sbc hl, bc
            call nz, fail

            jp .done
.iter
            push hl
            ld hl, (.tmp)
            inc hl
            ld (.tmp), hl
            pop hl
            ret
.tmp
            dw 0
.done


            ; test cell-ins
_cellins    call begin
            db "cell-ins", 0

            ld bc, $0303
            call cell_addr
            push hl
            pop ix

            ld a, (ix + cell_t.obj0)
            cp 255
            call nz, fail

            call obj_add            ; Create an obj
            ld bc, $0303            ; Add it to 3,3
            call cell_ins

            ld bc, $0303            ; Get addr of 3,3
            call cell_addr
            push hl
            pop ix

            ld a, (ix + cell_t.obj0) ; Check obj0 is 0
            cp 0
            call nz, fail


_cellobjs0  call begin
            db "cell-objs-0", 0

            ld hl, .iter
            ld bc, $0303
            call cell_objs
            jp .done

.iter       push hl
            ld hl, (.tmp)
            inc (hl)
            pop hl
            ret

.tmp        db 0

.done       ld a, (.tmp)
            cp 0
            call nz, fail


_cellrem    call begin
            db "cell-rem", 0

            call obj_add
            push af
            push af
            ld bc, $0303
            call cell_ins
            pop af
            ld bc, $0303
            call cell_rem
            ld hl, .iter
            ld bc, $0303
            call cell_objs
            pop af

            call obj_addr
            DUP obj_t.cnext
            inc hl
            EDUP
            ld a, (hl)
            cp 255
            call nz, fail

            jp .done

.iter
            ld a, 1
            ld (.tmp), a
            ret
.tmp
            db 0
.done
            ld a, (.tmp)
            call print_a
            cp 0
            call nz, fail


            ; test cell-objs
_cellobjs   call begin
            db "cell-objs", 0

            call obj_add
            ld bc, $0303            ; Add 2 objs to 3,3
            call cell_ins
            call obj_add
            ld bc, $0303            ; Add 2 objs to 3,3
            call cell_ins

            ld bc, .tmp             ; Init callback vars
            ld hl, .tmpi            ; tmpi = write pos
            ld (hl), bc             ; tmp = buffer

            ld hl, .iter
            ld bc, $0303
            call cell_objs


            jp .done

.tmpi       dw 0                    ; Vars for callback
.tmp        db 128, 128

.iter       push hl                 ; Write A to buffer

            ld hl, (.tmpi)
            ld (hl), a
            inc hl
            ld (.tmpi), hl
            pop hl

            ret

.done       ld hl, .tmp

            ld a, (hl)
            cp 1
            call nz, fail

            inc hl
            ld a, (hl)
            cp 0
            call nz, fail


            ; test cell-ib
_cellib     call begin
            db "cell-ib", 0

            ; ib

            ld bc, $0000
            call cell_ib
            cp 0
            call z, fail

            ld bc, $0304
            call cell_ib
            cp 0
            call z, fail

            ld b, board_w - 1
            ld c, board_h - 1
            call cell_ib
            cp 0
            call z, fail

            ; oob

            ld b, board_w
            ld c, board_h
            call cell_ib
            cp 0
            call nz, fail

            ld bc, $8080
            call cell_ib
            cp 0
            call nz, fail

            ld bc, $ffff
            call cell_ib
            cp 0
            call nz, fail
