# file main
.section .data

stackI:
    .long 0

.section .text
    .global _start

_start:
    movl $1, %eax
    movl $2, %ebx
    movl $3, %ecx
    pushl %eax
    pushl %ebx
    pushl %ecx

    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %ecx, %ecx

    movl %esp, stackI # salvo lo stack pointer, ma lo alzo di 1 altrimenti salterei l'elemento in cima allo stack
    subl $4, stackI

    # POP e PUSH dall'altro in basso
    popl %eax
    call printfd
    pushl %eax
    addl $4, %esp

    popl %eax
    call printfd
    pushl %eax
    addl $4, %esp

    popl %eax
    call printfd
    pushl %eax
    addl $4, %esp

    # jmp while

exit:
    movl stackI, %esp # rimetto lo stack pointer originale
    
    popl %eax
    call printfd
    popl %eax
    call printfd
    popl %eax
    call printfd

    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80


