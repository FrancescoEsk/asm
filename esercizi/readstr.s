# programma che legge da tastiera una stringa di al massimo 50 caratteri
# e la stampa a tastiera

.section .data

.section .bss
    str: .string ""

.section .text
    .global _start

_start:
    movl $3, %eax  # syscall read
    movl $0, %ebx  # uso lo standard da tastiera
    leal str, %ecx # carico in ecx str da memoria
    movl $50, %edx # lunghezza massima della stringa

    int $0x80

    # ora stampo a video
    movl $4, %eax
    movl $0, %ebx
    leal str, %ecx
    movl $50, %edx

    int $0x80

    # eseguo l'exit del programma
    movl $1, %eax
    xorl %ebx, %ebx # azzero il registro

    int $0x80
