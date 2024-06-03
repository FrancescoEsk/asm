# funzione che data una variabile di tipo stringa
# e un parametro che funge da offset, traduce l'ascii in numero, 
# e lo mette nel registro eax

# PARAMETRI
# EAX = leal della variabile ascii
# EBX = offset della stringa (quale parametro voglio)
# OFFSET: $1 -> primi 3 num
# OFFSET: $2 -> secondi 2 num
# OFFSET: $3 -> terzi 3 num
# OFFSET: $4 -> ultimo num

# ESEMPIO DI ASCII CHE TRADUCE QUESTA FUNZIONE
# str:
#   .ascii "10,9,80,2\n"

.section .text
.global readl

.type readl, @function

readl:
    movl %eax, %esi # carico indirizzo della stringa da leggere
    movl %ebx, %ecx

    xorl %edi, %edi
    xorl %ebx,%ebx                
    xorl %edx,%edx

clean:
    xorl %eax, %eax

ripeti:
    movb (%edi,%esi,1), %bl

    cmpb $44, %bl             # vedo se e' stato letto il carattere ','
    je fine_atoi
    cmpb $10, %bl             # vedo se e' stato letto il carattere '\n'
    je fine_atoi

    subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
    movl $10, %edx
    mulb %dl                # EBX = EBX * 10
    addl %ebx, %eax

    incl %edi

    jmp ripeti

fine_atoi: # EAX contiene il numero letto

    incl %edi # incremento il puntatore della stringa per saltare la ','

    loop clean # loop se non ho il numero scelto dall'offset
    
    ret # EAX contiene il numero
