# main
.section .data
s1:
    .ascii "1,2,3,4\n"

num:
    .long 

.section .text
    .global _start

_start:
    leal s1, %eax
    call convert
    movl %eax, num
    movl $4, %ecx

    movl num, %eax
    movl $1, %ebx
    call revert
    call printfd

    movl num, %eax
    movl $2, %ebx
    call revert
    call printfd

    movl num, %eax
    movl $3, %ebx
    call revert
    call printfd

    movl num, %eax
    movl $4, %ebx
    call revert
    call printfd

exit:
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80

