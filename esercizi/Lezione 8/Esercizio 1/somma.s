# Scrivere un programma Assembly che sommi i numeri 100, 33 e 68 e metta il risultato in 
# una variabile chiamata “somma”. Stampare a monitor il risultato

.section .data

titolo: # titolo programma
    .ascii "Programma che calcola la somma dei numeri 100, 33 e 68\n"
titolo_len:
    .long . - titolo

# 3 numeri da sommare
n1:
    .long 100

n2:
    .long 33

n3: 
    .long 68

somma: # var risultante
    .ascii "000\n"

# codice
.section .text
    .global _start

_start:
    # scrivo a video il titolo
    movl $4, %eax
    movl $1, %ebx # standard output
    leal titolo, %ecx # stringa da stampare
    movl titolo_len, %edx # lunghezza stringa
    int $0x80 

    movl n1, %eax
    addl n2, %eax
    addl n3, %eax

    leal somma, %esi # puntatore alla prima cifra della stringa somma
    addl $2, %esi # faccio puntare esi alla terza cifra di numAuto

    movl $10, %ebx # divisore 10
    movl $3, %ecx # num di volte che voglio eseguire il loop1

loop1:
    div %bl
    addb $48, %ah

    movb %ah, (%esi)
    xorb %ah, %ah # pulisco ah

    decl %esi
    loop loop1

    # scrivo a video il risultato
    movl $4, %eax
    movl $1, %ebx # standard output
    leal somma, %ecx # stringa da stampare
    movl $4, %edx # lunghezza stringa
    int $0x80

    jmp exit

exit:
    mov $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80

