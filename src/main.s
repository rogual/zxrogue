            org $8000
            output build/main.bin

main        call init
            call test_run
            call init
            call game_start
            ret

init        call obj_init
            call cell_init
            call draw_init
            ret

            ; Helpers
            include misc.s
            include math.s
            include random.s
            include stdout.s
            include vector.s

            ; Speccy stuff
            include system.s
            include attr.s
            include screen.s

            ; Game stuff
            include input.s
            include constants.s
            include objdefs.s
            include objevents.s
            include dir.s
            include cells.s
            include objects.s
            include generate.s
            include draw.s
            include drawbar.s
            include fight.s
            include ai.s
            include game.s
            include graphics.s

            ; Testing stuff
            include test.s


            ; Mapping Area
            ; No more code after this point
vars        display "Code size is ", /a, ($ - $8000)

            ; Now we can use the MAP pseudo-op to define some memory blocks
            ; for our game data, without actually putting any bytes into the
            ; executable.
            map $
            include vars.s

            ; Make sure we didn't define any data by mistake
            assert $ == vars

            ; End of vars
end         field 0

            display "Objects are at ", /a, objects
            display "Cells are at ", /a, cells
            display "Binary size is ", /a, (vars - $8000)
            display "Vars end at ", /a, end

            assert end < $c000
