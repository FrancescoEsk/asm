# funzione che data una stringa da 32 bit, contenente ogni 8 bit i numeri della stringa, e restituisce uno dei 4 numeri, in base all'offset fornito

# PARAMETRI 
# EAX = numero da 32 bit
# EBX = offset 
# OFFSET: $1 -> primo num della stringa
# OFFSET: $2 -> secondo num della stringa
# OFFSET: $3 -> terzo num della stringa
# OFFSET: $4 -> quarto num della stringa

# REGISTRI USATI = A B C

# RISULTATO IN EAX

.section .text
    .global revert

.type revert, @function

revert:
    jmp start 

redo:
    shrl $8, %eax # altrimenti shifto a destra di 8 bit e passo al prossimo
    addl $1, %ebx # aumento offset
start:
    cmpl $4, %ebx # se voglio il quarto numero, ce l'ho gia' nei primi 8 bit del registro
    jne redo 
    # adesso ho nei primi 8 bit di eax il numero che voglio
    movb %al, %cl # lo sposto in ecx
    xorl %eax, %eax # azzero eax
    movb %cl, %al # lo metto in eax

exit:
    # pulisco registri
    xorl %ebx, %ebx
    xorl %ecx, %ecx
    ret

