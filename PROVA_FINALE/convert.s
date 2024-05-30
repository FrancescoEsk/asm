# funzione che data una stringa contenente 4 numeri (separati da ','), ne forma uno singolo da 32 bit, contenente ogni 8 bit i numeri della stringa

# PARAMETRI 
# EAX = leal della stringa da convertire

# REGISTRI USATI: A B C D

# RISULTATO IN EAX

.section .data

count: .int 1
temp: .space 20

.section .text
    .global convert

.type convert, @function

convert:
    # salvo la stringa nella memoria
    movl %eax, temp
    xorl %edx, %edx # pulisco edx
    movl $4, %ecx # imposto quante volte eseguire il ciclo

redo:
    pushl %ecx

    sall $8, %edx # shift del numero a sx di 8 posizioni, per fare spazio al prossimo
    pushl %edx # salvo edx

    # leggo dalla stringa il numero
    movl temp, %eax # ricarico la stringa
    movl count, %ebx # impost offset
    call readl

    popl %edx # riottengo il numero
    addl %eax, %edx # aggiungo il numero
    
    incl count # aumento offset

    popl %ecx
    loop redo # loop in base a ecx

exit: 
    movl %edx, %eax # metto il risultato in eax

    # pulisco i registri usati
    xorl %ebx, %ebx
    xorl %ecx, %ecx
    xorl %edx, %edx

    # azzero anche le variabili in memoria
    movl $1, count

    ret

