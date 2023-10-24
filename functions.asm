exit:
        mov eax,SYS_EXIT
        mov ebx,ZERO_EXIT_CODE
        int 80h
        ret

printString:
        pusha
        test esi,esi
        jne .J0
        mov esi,nullstr
        .J0:
                mov eax,SYS_WRITE
                mov ebx,SYS_STDOUT
                mov ecx,esi
                xor edx,edx                ; count bytes to send
        .J1:
                cmp byte [esi],0           ; look for the terminating null
                je .J2
                add edx,1
                add esi,1
                jmp .J1
        .J2:
                int 80h
                popa
                ret

convertEAXtoDEC:                ; ARG: EAX integer, EDI pointer to string buffer
        push ebx
        push ecx
        push edx
        mov ebx, 10             ; Divisor = 10
        xor ecx, ecx            ; ECX=0 (digit counter)
        .J1:                    ; First Loop: store the remainders
                xor edx, edx            ; Don't forget it!
                div ebx                 ; EDX:EAX / EBX = EAX remainder EDX
                push dx                 ; Push the digit in DL (LIFO)
                add cl, 1               ; = inc cl (digit counter)
                or eax, eax             ; AX == 0?
                jnz .J1                     ; No: once more
                mov ebx, ecx                ; Store count of digits
        .J2:                        ; Second loop: load the remainders in reversed order
                pop ax                      ; get back pushed digits
                or al, 00110000b            ; to ASCII
                mov [edi], al               ; Store AL to [EDI] (EDI is a pointer to a buffer)
                add edi, 1                  ; = inc edi
        loop .J2                    ; until there are no digits left
        mov byte [edi], 0           ; ASCIIZ terminator (0)
        mov eax, ebx                ; Restore Count of digits
        pop edx
        pop ecx
        pop ebx
        ret                         ; RET: EAX length of string (w/o last null)