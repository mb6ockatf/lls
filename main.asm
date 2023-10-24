%include "constants.asm"
%include "functions.asm"
; Get the program arguments from the stack which are (in order):
; number of arguments, program name, arg 1, arg 2, and so on

section .text
global _start

_start:
        pop ecx ; Get the number of arguments
        add ecx,'0'    ; convert to a ascii number
        push ecx        ; push the result into memory using the stack
        mov ecx,esp     ; move the address of the stack pointer to ecx for sys_write
        mov esi,ecx
        call printString

        pop ecx         ; Dump number of args from stack
        call newline    ; Print a newline

                        ; stacks - each 'pop' gives the value of the next item in the stack
                        ;          if there are no more items in the stack, it returns null

nextarg:
        pop ecx ; get pointer to string
                        ; Comment by Frank Kotler:
                        ; we could have kept "argc", and used it as a loop counter
                        ; but args pointers are terminated with zero (dword),
                        ; so if we popped a zero, we're done (environment variables follow this)
        test ecx,ecx    ; or "cmp ecx, 0" - Check if we reached the end of our string
        jz exit
                        ; now we need to find the length of our (zero-terminated) string
        xor edx,edx     ; or "mov edx, 0"  ; Initialize edx to zero
getlen:
        cmp byte [ecx + edx], 0  ; Take each byte and see if it is a terminated string (0x00h) or null
        jz gotlen                ; If the previous instruction found the terminated string, jump out of our loop
        inc edx                  ; Nope, point to the next character or byte
        jmp getlen               ; and check again with getlen procedure
gotlen:
                                ; now ecx -> string, edx = length
        mov esi,ecx
        call printString
        call newline    ; Print a newline charaction by calling our newline function
        jmp nextarg     ; Process the next argument

newline:
                        ; Frank: probably want to print a newline here, "for looks"
                        ; Here is my solution to newline:
        mov edx,10      ; Move 'newline' character into edx
        push edx        ; Put it into the stack
        mov ecx,esp     ; Put the current stack pointer into ecx for sys_write
        mov esi,ecx
        call printString
        pop edx         ; Don't need newline anymore, get rid of it so stack pointer points to what it was before
        ret