# Scrivere un programma Assembly che confronti 2 numeri caricati nei registri EAX ed EBX 
# e stampi una stringa che indichi quale sia il maggiore ed il minore oppure indichi che i 
# due numeri sono uguali

.section .data

maggA:
    .ascii "Maggiore EAX\n"
maggA_len:
    .long . - maggA

maggB:
    .ascii "Maggiore EBX\n"
maggB_len:
    .long . - maggB

eq:
    .ascii "Uguali\n"
eq_len:
    .long . - eq

.section .text
    .global _start

_start: 
    movl $9, %eax
    movl $8, %ebx

    cmpl %ebx, %eax
    je equals
    jg greater # eax < ebx

    # leal carica asci, movl carica long
    # la stampa, prende sempre il contenuto di ecx
    # la lunghezza della stringa e' sempre in edx

    leal maggB, %ecx
    movl maggB_len, %edx
    
    jmp after
    
greater: # eax > ebx
    leal maggA, %ecx
    movl maggA_len, %edx
    
    jmp after
    
equals: # eax = ebx 
    leal eq, %ecx
    movl eq_len, %edx

    after:
    movl $4, %eax # carico la write
    movl $1, %ebx 
    int $0x80
    mov

    jmp exit

exit:
    mov $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80

