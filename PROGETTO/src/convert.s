# funzione che data una stringa contenente 4 numeri (separati da ','), ne forma uno singolo da 32 bit, contenente ogni 8 bit i numeri della stringa

# PARAMETRI 
# EAX = leal della stringa da convertire

# REGISTRI USATI: A B C D

# RISULTATO IN EAX

.section .data
count:
    .int 1

.section .bss
temp:
    .ascii

.section .text
    .global convert

.type convert, @function

convert:
    # salvo la stringa nello stack
    movl %eax, temp
    xorl %edx, %edx
    movl $4, %ecx

redo:
    pushl %ecx
    sall $8, %edx # shift del numero a sx di 8 posizioni, per fare spazio al prossimo

    pushl %edx # salvo edx
    movl temp, %eax # ricarico la stringa
    movl count, %ebx # impost offset
    call readl

    popl %edx # riottengo il numero
    addl %eax, %edx # aggiungo il numero
    
    incl count # aumento offset
    popl %ecx
    loop redo 

exit:
    movl %edx, %eax
    xorl %ebx, %ebx
    xorl %ecx, %ecx
    xorl %edx, %edx
    ret

