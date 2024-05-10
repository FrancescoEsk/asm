# file main

.section .text
    .global _start

_start:
    
    call scanfd # legge stringa da tastiera, lo converte in num e lo mette in eax
    call printfd # converte num in eax in una stringa, e la stampa a video

    jmp exit

exit:
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80


