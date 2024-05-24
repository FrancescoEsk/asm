# funzione che legge un file

# PARAMETRI
# EBX = file.txt

.section .data

file:
    .ascii "Ordini.txt"

riga: .space 100 # buffer abbastanza grande da contenere una riga (100 caratteri)
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

    # controllo se ho nuova linea
    movb buffer, %al
    cmpb newline, %al 
    jne next
    incw lines # incremento contatore linee

next:
    # scrivo il carattere letto in "riga" alla posizione corrente
    movb buffer, %al
    movl index, %ebx
    addl riga, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %al, (%ebx) # scrivo nella posizione del carattere prossimo

    # incrementa l'indice
    addl $1, index

    jmp read_loop # continuo a leggere

close_file:
    pushl %eax
    
    # chiusura file
    movl $6, %eax
    movl fd, %ebx
    int $0x80

    popl %eax
    
    ret

exit:
    # movl $404, %eax # CODICE ERRORE - 404

    ret
