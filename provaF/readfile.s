# funzione che legge un file

# PARAMETRI
# EAX = riga da leggere (da 1 a 10)
# EBX = file.txt
# ECX = valore da leggere (offset)

# OFFSET: $1 -> primi 3 num
# OFFSET: $2 -> secondi 2 num
# OFFSET: $3 -> terzi 3 num
# OFFSET: $4 -> ultimo num

.section .data

riga: .space 100 # buffer abbastanza grande da contenere una riga (100 caratteri)
index: .int 0 # indice per tenere traccia della posizione in cui scrivere il carattere in 'riga'

buffer: .string ""

fd: .int 0
newline: .byte 10 # valore ascii di '\n'

lines: .int 0 # num linee
lineToRead: .int 0

offset:
    .int 0

.section .text
    .global readfile

.type readfile, @function

readfile:
    movl %eax, lineToRead  # salvo riga da leggere
    movl %ecx, offset # salvo offset 

    xorl %edi, %edi  # pulisco registro

    # apertura file
    movl $5, %eax
    # file gia' presente in ebx
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
    movl buffer, %ecx # buffer dove mettere la stringa letto
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
    movl lineToRead, %edi
    # guardo se sono alla riga che voglio leggere
    cmpl lines, %edi
    jne read_loop

    # controllo se ho nuova linea
    movb buffer, %al
    cmpb newline, %al 
    je close_file

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
    movl offset, %ebx
    call readl
    
    ret

exit:
    # movl $404, %eax # CODICE ERRORE - 404

    ret
