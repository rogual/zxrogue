            ; random
rndseed     field 2

quitflag    field 1

            ; draw
            ; Bit 0 -- whole board dirty
drawflag    field 1
dirtytab    field 2 * 16
dirtyend    field 2

            ; cells
cells       field (board_w * board_h * cell_t)

            ; objects
objects     field (254 * obj_t)     ; 254 objects
obj_used0   field 1                 ; ID of first used obj
obj_free0   field 1                 ; ID of first free obj
obj_count   field 1                 ; Num of used objs

            ; game
pl_addr     field 2
pl_strength field 1
pl_armour   field 1
pl_level    field 1
pl_amulet   field 1
pl_hp       field 1
pl_max_hp   field 1
