            ; Game-related constants
board_w     equ 22
board_h     equ 22

            ; Constants for object flags
OF_ACTIVE   equ 1       ; Object exists
OF_SOLID    equ 2       ; Can't move through using obj_walk
OF_AI       equ 4       ; To be processed by ai
OF_TILE     equ 8       ; Is a tile (one per cell)
OF_FIGHT    equ 16      ; Can be attacked

            ; Object structure
            struct obj_t
next        byte ; ID of next object or 255 if last
cnext       byte ; ID of next object in same cell (or 255)
flags       byte ; Bitmask of OF_ flags
hp          byte ; Hit points
glyph       byte ; Character graphic
attr        byte ; Display attributes
pos         word ; Screen pos or $ffff if tile
eventh      word ; Event handler address or 0
            ends

            ; Cell structure
            struct cell_t
obj0        byte ; ID of first object or 255 if none
            ends
