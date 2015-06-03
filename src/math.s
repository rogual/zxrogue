
div_hl_e:   xor a                          ; clearing the upper 8 bits of AHL
            ld b,16                        ; the length of the dividend (16 bits)
.loop:      add hl,hl                      ; advancing a bit
            rla
            cp e                           ; checking if the divisor divides the digits chosen (in A)
            jp c, .next                    ; if not, advancing without subtraction
            sub e                          ; subtracting the divisor
            inc l                          ; and setting the next digit of the quotient
.next:      djnz .loop
            ret
