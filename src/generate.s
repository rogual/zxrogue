

            ; generate a world
gen_main    ld b, $3f
	    ld a, (pl_level)
	    ld c, a
            call srand

            call mkperim

            ; no stairs down on level 3
            ld a, (pl_level)
            cp 3
            jp z, .nostair

            ; staircase down
            ld bc, $0808
            ld hl, od_staird
            call obj_inst_at

.nostair

            ; amulet only on level 3
            ld a, (pl_level)
            cp 3
            jp nz, .noamulet

            ; amulet
            ld bc, $0606
            ld hl, od_amulet
            call obj_inst_at
.noamulet

            ; stairs up
            ld bc, $0202
            ld hl, od_stairu
            call obj_inst_at

            ; define rat enemy
	    call gen_enemy
	    call gen_enemy

            ret

gen_enemy
            ld a, board_w
	    dec a
	    call randlt
	    inc a
	    ld b, a
            ld a, board_h
	    dec a
	    call randlt
	    inc a
	    ld c, a
	
            ld hl, od_rat
            call obj_inst_at
	    ret



mkperim     ld b, board_w
            ld c, board_h
            ld hl, .iter
            call iterect
            jp .ok
.iter
            ld a, b
            or a
            jp z, .doit
            cp board_w - 1
            jp z, .doit

            ld a, c
            or a
            jp z, .doit
            cp board_h - 1
            jp z, .doit
            ret
.doit

            call mkwall
            ret
.ok
            ret


mkwall      push hl
            ld hl, od_wall
            call obj_inst_at
            pop hl
            ret
