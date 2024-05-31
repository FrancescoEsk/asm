# STAMPA MENU SCELTA ALGORITMO (e acquisizione da tastiera)
.section .data

richiesta: .ascii "Select algorithm (0 = exit, 1 = EDF, 2 = HPF) -> "
richiesta_len: .long . - richiesta

print_exit: .ascii "You selected exit\n"
print_exit_len: .long . - print_exit

.section .text
.global menu

.type menu, @function

menu:
    movl $4, %eax                   
    movl $1, %ebx                   
    leal richiesta, %ecx      
    movl richiesta_len, %edx
    int $0x80

inserimento: 
    call scanfd                     # il valore letto va in EAX
    cmpl $0, %eax
    je stampa_zero
    cmpl $1, %eax
    je exit
    cmpl $2, %eax
    je exit

    jmp menu

stampa_zero:
    pushl %eax
    movl $4, %eax                   
    movl $1, %ebx                   
    leal print_exit, %ecx      
    movl print_exit_len, %edx
    int $0x80
    popl %eax
 
exit:
    ret

