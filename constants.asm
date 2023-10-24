SYS_WRITE               equ 4
SYS_EXIT                equ 1
SYS_STDOUT              equ 1
ZERO_EXIT_CODE          equ 0

section .data
        nullstr         db '(null)',0
        abobastr        db 'aboba',0

section .text