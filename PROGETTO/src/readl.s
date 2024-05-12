# funzione che data una variabile di tipo stringa
# e un parametro che funge da offset, traduce l'ascii in numero, 
# e lo mette nel registro eax

# PARAMETRI
# EAX = leal della variabile ascii
# EBX = offset della stringa
# OFFSET: $0 -> primi 3 num
# OFFSET: $4 -> secondi 2 num
# OFFSET: $7 -> terzi 3 num
# OFFSET: $11 -> ultimo num

# ESEMPIO DI ASCII CHE TRADUCE QUESTA FUNZIONE
# str:
#   .ascii "010.09.121.2\n"

.section .text
.global readl

.type readl, @function

readl:
    addl %ebx, %eax # sommo offset della stringa per saltare al numero da convertire

    movl %eax, %esi

    xorl %eax,%eax			# Azzero registri General Purpose
    xorl %ebx,%ebx           
    xorl %ecx,%ecx           
    xorl %edx,%edx

ripeti:
    movb (%ecx,%esi,1), %bl

    cmpb $46, %bl             # vedo se e' stato letto il carattere '.'
    je fine_atoi
    cmpb $10, %bl             # vedo se e' stato letto il carattere '\n'
    je fine_atoi

    subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
    movl $10, %edx
    mulb %dl                # EBX = EBX * 10
    addl %ebx, %eax

    incl %ecx
    jmp ripeti

fine_atoi:
    # EAX contiene il numero letto
    ret

