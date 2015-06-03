obj_init
            ; Set all objects to free
            ld a, 0
            ld (obj_free0), a
            ld (obj_count), a

            ld a, 255
            ld (obj_used0), a

            ; Make each object point to its next
            ld hl, objects
            ld de, obj_t
            ld b, 254
            ld c, 0
            ld a, 1
.loop
            push hl
            pop ix
            ld (ix + obj_t.next), a
            inc a
            ld (ix + obj_t.flags), c
            add hl, de
            djnz .loop

            ret


            ; set HL=addr of object A
            ; preserves A
obj_addr
            push bc
            push de
            ld b, a
            ld hl, objects
            or a
            jp z, .done
            ld de, obj_t
.loop
            add hl, de
            djnz .loop
.done
            pop de
            pop bc
            ret


            ; Like obj_add_at except inits the object with the
            ; objdef at (HL)
obj_inst_at push hl
            call obj_add_at
            pop hl
            ld a, (hl)                ; Copy object flags
            or OF_ACTIVE              ; but always keep active flag
            ld (ix + obj_t.flags), a  ; set
            inc hl
            ld a, (hl)                ; Copy glyph
            ld (ix + obj_t.glyph), a
            inc hl
            ld a, (hl)                ; Copy attr byte
            ld (ix + obj_t.attr), a
            inc hl
            ld a, (hl)                ; Copy HP
            ld (ix + obj_t.hp), a
            inc hl
            push bc                   ; Copy event handler
            ld bc, (hl)
            ld (ix + obj_t.eventh), bc
            pop bc
            push ix                   ; Set HL to obj addr for compat
            pop hl                    ; with obj_add_at
            ret


            ; Create an object at B,C and sets its pos member.
            ; Returns:
            ; A: Object ID
            ; HL: Cell address
            ; IX: Object address
obj_add_at  call obj_add
            push hl
            pop ix
            ld (ix + obj_t.pos), b
            ld (ix + obj_t.pos + 1), c
            push af
            call cell_ins
            pop af
            ret


            ; Create an object. Returns:
            ; A: Object ID
            ; HL: Object address
            ; IX: Object address
obj_add     push bc
            ld a, (obj_count)         ; Ensure there is space
            cp a, 254                 ; for the new object.
            jp nz, .body
            ld hl, etoomany
            jp panic

.body       ld a, (obj_free0)         ; Find first free object
            push af
            call obj_addr             ; and set IX to it.
            push hl
            pop ix
            ld a, (ix + obj_t.next)   ; Update "first free" ptr
            ld (obj_free0), a         ; to the object after it
            set 0, (ix + obj_t.flags) ; Set it to used
            ld a, (obj_used0)         ; Set our object's next-ptr to first
            ld (ix + obj_t.next), a   ; used object
            ld a, 255                 ; Set cnext to 255 (empty)
            ld (ix + obj_t.cnext), a  ;
            pop af                    ; Set first used object to our new
            ld (obj_used0), a         ; object
            ld hl, obj_count          ; increment object count
            inc (hl)
            push ix                   ; Return object's address in hl
            pop hl
            pop bc
            ret


            ; Delete object A
obj_del     push hl
            call obj_addr
            DUP obj_t.flags
            inc hl
            EDUP
            res 0, (hl)             ; Set inactive
            bit 3, (hl)             ; Is this a tile?
            jp nz, .done
.fat        push bc                 ; If not, remove from its cell
            call obj_pos            ; obj_pos preserves a. BC=pos.
            call cell_rem           ; Remove A from cell BC
            pop bc
.done       pop hl
            ret


            ; Iterate over all used objects
            ; calling (hl) with
            ; A = object ID
            ; IX = object ptr
obj_iter
            ld a, (obj_used0)
.iter       cp a, 255
            jp z, .done
            push hl                 ; Save callback addr
            call obj_addr           ; Get object addr
            push hl                 ; Transfer into IX
            pop ix                  ; as HL = callback addr
            pop hl                  ;

            ex af, af'
            ld a, (ix + obj_t.flags) ; If obj is inactive
            and OF_ACTIVE            ; then skip it
            jr z, .inactive
            jp .visit

.inactive   ex af, af'
            jp .next

.visit      ex af, af'
            call calli              ; Call callback
.next       ld a, (ix + obj_t.next) ; Get next object
            jp .iter                ; Loop
.done       ret



            ; Move object A to cell B,C
obj_move    push ix
            push de

            ; get old cell pos to de
            push bc
            push af
            call obj_addr
            push hl
            pop ix
            ld d, (ix + obj_t.pos)
            ld e, (ix + obj_t.pos + 1)
            pop af
            pop bc

            ; remove from old cell
            push bc
            push af
            ld bc, de
            call cell_rem
            pop af
            pop bc
            pop de

            ; add to new
            call cell_ins

            ; update pos
            ld (ix + obj_t.pos), b
            ld (ix + obj_t.pos + 1), c

            ; fire stepped event
            ld d, OE_STEPPED_ON
            call cell_event

.done       pop ix
            ret


            ; “Attack walk”
            ; Like obj_walk except fights if blocked
            ; by a fightable thing
obj_awalk   push af
            call obj_walk
            or a
            jp z, .done

.blocked    ld a, 255               ; We're blocked, so try to find
            ld (.objid), a          ; a fightable obj in the new square
            ld bc, de
            ld hl, .iter
            call cell_objs
            ld a, (.objid)          ; Did we find one?
            cp 255
            jp z, .done             ; No such luck

.fight      pop af                  ; Get fighter into A and fightee into B
            push af                 ; then call fight proc
            push bc

            push af
            ld a, (.objid)
            ld b, a
            pop af

            call fight

            pop bc
            jp .done

.iter       push af
            ld a, (ix + obj_t.flags) ; Is this object FIGHT?
            and OF_FIGHT
            jp z, .iterend
            pop af                   ; Object is FIGHT!
            push af
            ld (.objid), a
.iterend    pop af
            ret

.objid      db 128

.done       pop af
            ret


            ; Move A by B, C if way is clear
            ; Return A=1 if blocked, else 0
            ; Return DE=new pos
obj_walk    push hl
            push bc

            push af

            push bc                 ; Get obj pos into DE
            call obj_pos
            ld de, bc
            pop bc

            call vadd_de_bc         ; Add to offset and store
            ld bc, de               ; in BC

            call cell_solid         ; Check solidity
            or a
            jp nz, .cantmove

.canmove    pop af                  ; Retrieve obj ID
            call obj_move           ; Move object to BC
            ld a, 0                 ; Signal not-blocked
            jp .done

.cantmove   pop af
            ld a, 1                 ; Signal blocked

.done
            pop bc
            pop hl
            ret

            ; BC = pos of object a
            ; preserves A
obj_pos     push hl
            call obj_addr           ; This preserves A
            DUP obj_t.pos
            inc hl
            EDUP
            ld b, (hl)
            inc hl
            ld c, (hl)
            pop hl
            ret

            ; Send event D(E) to obj A
            ; Calls object's event handler with:
            ; D(E) Event
            ; IX Object pointer
            ; A Object ID
obj_event
            push hl
            push de
            push af
            call obj_addr
            push hl
            pop ix

            DUP obj_t.eventh
            inc hl
            EDUP
            ld bc, (hl)
            ld hl, bc
            pop af
            pop de
            call calli
            pop hl
            ret

            ; Object error messages
etoomany     db "Too many objects", 0
