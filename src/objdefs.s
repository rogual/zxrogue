
            ; Object prototype structure
            struct def_t
flags       byte
glyph       byte
attr        byte
hp          byte 255
eventh      word oeh_noop
            ends


                ; Flags               Gl   Attr                  HP   EvtHand
od_player   def_t OF_SOLID,           '@', WHITE | BRIGHT
od_wall     def_t OF_SOLID | OF_TILE, '#', PAPER_BLACK | WHITE
od_staird   def_t OF_TILE,            '>', PAPER_BLACK | YELLOW, 255, oeh_staird
od_stairu   def_t OF_TILE,            '<', PAPER_BLACK | YELLOW, 255, oeh_stairu

od_amulet   def_t 0, 90h, YELLOW | BRIGHT, 255, oeh_amulet


            ; Enemies
OF_ENEMY    equ OF_SOLID | OF_AI | OF_FIGHT
od_rat      def_t OF_ENEMY, 'r', PAPER_BLACK | MAGENTA | BRIGHT, 2
