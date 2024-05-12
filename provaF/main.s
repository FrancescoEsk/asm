# file main

.section .text
    .global _start

_start:
    
    call readf

    jmp exit

exit:
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80


