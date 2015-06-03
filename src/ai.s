

ai
            ld hl, ai_do_obj
            call obj_iter
            ret


ai_do_obj   push af
            ld a, (ix + obj_t.flags)
            and OF_AI
            jp z, .done

            pop af
            push af

            push bc
            push af
            call rand_dir
            pop af
            call obj_walk
            pop bc


.done       pop af
            ret
