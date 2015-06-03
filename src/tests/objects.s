
            ; ensure obj_addr(0) == objects
            call begin
            db "obj-addr-0", 0

            ld a, 0
            call obj_addr
            ld bc, objects
            or a
            sbc hl, bc
            call nz, fail

            ; ensure obj_addr(1) == objects + sz
            call begin
            db "obj-addr-1", 0

            ld a, 1
            call obj_addr
            ld bc, objects + obj_t
            or a
            sbc hl, bc
            call nz, fail


            ; ensure obj_addr(42) == objects + 42 * sz
            call begin
            db "obj-addr-42",0

            ld a, 42
            call obj_addr
            ld bc, objects + 42 * obj_t
            or a
            sbc hl, bc
            call nz, fail


            ; Test obj-add
_objadd     call begin
            db "obj-add",0

            call obj_add            ; Add 1st object
            ld bc, objects          ; Check address
            or a
            sbc hl, bc
            call nz, fail
            ld a, (obj_count)       ; Count should be 1
            cp 1
            call nz, fail

            call obj_add            ; Add 2nd object
            ld bc, objects + obj_t  ; Check address
            or a
            sbc hl, bc

            call nz, fail

            ld a, (obj_count)       ; Count should be 2
            cp 2
            call nz, fail


            ; Test obj-iter
_objiter    call begin
            db "obj-iter",0

            call obj_add
            call obj_add

            ld hl, .iter
            call obj_iter
            jp .done
.iter       push hl                 ; Callback:
            ld hl, .tmp             ; just increment (.tmp)
            inc (hl)
            pop hl
            ret
.tmp        db 0
.done       ld a, (.tmp)
            call print_a

            cp 2
            call nz, fail

