# MENU SCELTA ALGORITMO 

.section .data

richiesta:
    .ascii "Select algorithm (0 = exit, 1 = EDF, 2 = HPF) -> "
richiesta_len:
    .long . - richiesta

print_exit:
    .ascii "You selected exit\n"
print_exit_len:
    .long . - print_exit

print_alg1:
    .ascii "You selected EDF algorithm\n"
print_alg1_len:
    .long . - print_alg1

print_alg2:
    .ascii "You selected HPF algorithm\n"
print_alg2_len:
    .long . - print_alg2
    

.section .text
.global menu

.type menu, @function

menu:
    movl $4, %eax                   # chiamo la WRITE per scrivere "Select algorithm" contenuto nell'etichetta richiesta
    movl $1, %ebx                   # esco dalla syscall
    leal richiesta, %ecx      
    movl richiesta_len, %edx
    int $0x80

inserimento:
    #scanf
    
    call scanfd                     # il valore letto va in EAX
    cmpl $0, %eax
    je stampa_zero
    cmpl $1, %eax
    je stampa_uno
    cmpl $2, %eax
    je stampa_due

    jmp menu

stampa_zero:
    pushl %eax
    movl $4, %eax                   # chiamo la WRITE per scrivere "You selected EDF algorithm" contenuto nell'etichetta richiesta
    movl $1, %ebx                   # esco dalla syscall
    leal print_exit, %ecx      
    movl print_exit_len, %edx
    int $0x80
    jmp exit

stampa_uno:
    pushl %eax
    movl $4, %eax                   # chiamo la WRITE per scrivere "You selected EDF algorithm" contenuto nell'etichetta richiesta
    movl $1, %ebx                   # esco dalla syscall
    leal print_alg1, %ecx      
    movl print_alg1_len, %edx
    int $0x80
    jmp exit

stampa_due:
    pushl %eax
    movl $4, %eax                   # chiamo la WRITE per scrivere "You selected HPF algorithm" contenuto nell'etichetta richiesta
    movl $1, %ebx                   # esco dalla syscall
    leal print_alg2, %ecx      
    movl print_alg2_len, %edx
    int $0x80
 
exit:
    popl %eax
    
    ret

