# file main

.section .data

file:
    .ascii "Ordini.txt"

.section .text
    .global _start

_start:
    movl $1, %eax
    movl $file, %ebx 
    movl $1, %ecx
    
    call readfile
    call printfd

    jmp exit

exit:
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80


