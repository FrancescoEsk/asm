# funzione che legge un file

# PARAMETRI
# EBX = file.txt

.section .data

file: .ascii "Ordini.txt"

riga: .space 20 # buffer abbastanza grande da contenere una riga (20 caratteri)
index: .int 0 # indice per tenere traccia della posizione in cui scrivere il carattere in 'riga'

buffer: .string ""

fd: .int 0
newline: .byte 10 # valore ascii di '\n'

lines: .int 0 # num linee

.section .text
    .global _start

_start:
    # apertura file
    movl $5, %eax
    movl $file, %ebx
    movl $0, %ecx # MODALITA' READ ONLY
    xorl %edx, %edx
    int $0x80

    # controllo errore
    cmpl $0, %eax
    jl exit

    movl %eax, fd # salvo il file descriptor

read_loop:
    # read da file 
    movl $3, %eax 
    movl fd, %ebx
    movl $buffer, %ecx # buffer dove mettere la stringa letto
    movl $1, %edx # lunghezza massima della stringa 
    int $0x80

    # errori o EOF
    cmpl $0, %eax
    jle close_file

    # controllo se sto per avere una nuova riga ('\n)
    movb buffer, %al
    cmpb newline, %al 
    jne next # se non ho finito la riga, salto


    # se ho finito di leggere la riga
    incw lines # incremento contatore linee

    # scrivo lo '\n'
    movl index, %ebx 
    addl riga, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %al, (%ebx) # scrivo nella posizione del carattere prossimo

    # converto la stringa in num da 32 bit
    leal riga, %eax # passo alla funzione la riga da convertire
    call convert 
    pushl %eax # e poi la carico sullo stack

    # reset indice per la prossima riga
    movl $0, index 

reset_riga: # pulisco tutta la riga
    movl $0, %ebx
reset_loop:
    cmpl $20, %ebx
    je end_reset
    addl riga, %ebx
    movb $0, (%ebx)
    addl $1, %ebx
    jmp reset_loop
end_reset:
    jmp read_loop # ricomincio a leggere il file

next:
    # scrivo il carattere (attualmente in AL) letto in "riga" alla posizione corrente
    movl index, %ebx 
    addl riga, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %al, (%ebx) # scrivo nella posizione del carattere prossimo

    # incrementa l'indice
    addl $1, index

    jmp read_loop # continuo a leggere

close_file:
    pushl %eax
    pushl %ebx
    
    # chiusura file
    movl $6, %eax
    movl fd, %ebx
    int $0x80

    popl %ebx
    popl %eax
    
    ret

exit:
    # movl $404, %eax # CODICE ERRORE - 404

    ret
