
prev_level
            ld hl, pl_level
            dec (hl)
            ld a, (hl)
            or a
            jp z, exit_cave
            jp apply_level
next_level
            ld hl, pl_level
            inc (hl)
apply_level
            ld a, WHITE
            call cls
            call dirty_all
            call obj_init
            call cell_init
            call mk_player
            call gen_main
            ret

m_win       db "         W I N N E R           ",13,13
            db "You escaped the Cave of",13
            db "Vociferocity with the Amulet",13
            db "of Spazmodeus!",13,13
            db "You sell it and retire to ",13
            db "Spain.",0

m_quit      db "You leave the cave. You may not",13
            db "have found the fabled Amulet of",13
            db "Spazmodeus but who needs that",13
            db "anyway. ",13,13
            db "You drift around for a bit ",13
            db "and eventually die.",0

m_died      db "     D    E    A   T    H       ",13,13
            db "You got yourself killed!",0

gameover
            call cls
            ld a, RED
            ld (ATTR_T), a
            ld hl, m_died
            call print
            call in_get
            ld a, 1
            ld (quitflag), a
            ret

exit_cave
            ld a, WHITE
            call cls
            ld bc, 0

            ld a, (pl_amulet)
            or a
            jp z, .noamulet
            ld hl, m_win
            jp .done
.noamulet   ld hl, m_quit
.done       call print
            call in_get
            ld a, 1
            ld (quitflag), a
            ret

game_start
            ; cls
            ld a, WHITE
            call cls
            ld a, 0
            out (254), a

            ld a, 0
            ld (quitflag), a

            ; init stats
            ld a, 2
            ld (pl_strength), a
            ld a, 5
            ld (pl_armour), a
            ld a, 1
            ld (pl_level), a
            ld a, 10
            ld (pl_max_hp), a
            ld a, 8
            ld (pl_hp), a

            call dirty_all
            call mk_player
            call gen_main

.loop

            ; update hp from player object
            ld a, 0
            call obj_addr
            push hl
            pop ix
            ld a, (ix + obj_t.hp)
            ld (pl_hp), a

            call draw
            call in_get
            call mv_player
            call ai

            ld a, (quitflag)
            or a
            jp z, .loop
            ret


mk_player   push hl
            ld bc, $0303
            ld hl, od_player
            call obj_inst_at
            ld a, (pl_hp)
            ld (ix + obj_t.hp), a
            pop hl
            ret

mv_player   ld a, 0
            ld bc, (in_dir)
            call obj_awalk
            or a
            jp nz, blocked
            ret

blocked     ld a, 1
            out (254), a
            halt
            ld a, 0
            out (254), a
            ret
