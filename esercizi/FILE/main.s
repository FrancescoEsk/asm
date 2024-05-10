# ###################
# filename: main.s
# ###################
.section .text
    .global _start

_start:
    movl $100, %eax # metto il numero da stampare in EAX

    call  itoa # chiamata alla funzione itoa

    xorl  %eax, %eax # azzera eax
    inc   %eax # incr. eax di 1 (1 e' il codice della exit)
    xorl  %ebx, %ebx # azzera ebx (alla exit viene passato 0)
    int   $0x80 # invoca la funzione exit
    
    