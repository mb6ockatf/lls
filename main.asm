extern printf
extern exit
extern fopen
extern fclose
; to EAX (syscalls)
SYS_EXIT                equ 1
SYS_FORK                equ 2
SYS_READ                equ 3
SYS_WRITE               equ 4
SYS_OPEN                equ 5
SYS_CLOSE               equ 6
; to EBX (arguments)
SYS_STDOUT              equ 1   ; to EBX
ZERO_EXIT_CODE          equ 0   ; to EBX
; filename to read goes to ebx, too
; 

section .data
        nullstr         db '(null)',0
        abobastr        dd 'aboba',0
        fmt             db "%s",10,0

section .text

global main
main:
        push abobastr
        push fmt
        call printf
        push 0
        call exit