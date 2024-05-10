# Scrivere il programma Assembly equivalente al seguente algoritmo C per il calcolo del 
# massimo comune divisore (MCD) di due numeri naturali. Si assuma che i parametri a e 
# b siano nei registri EAX ed EBX, mentre il valore di ritorno deve essere memorizzato in 
# ECX. Verificarne il funzionamento con il debugger

.section .data


.section .text
    .global _start

_start:
    movl $4, %eax
    movl $7, %ebx

    cmpl $0, %eax # controllo che A e B siano uguali a 0, altrimenti salto sotto
    jne not_ab
    cmpl $0, %ebx
    jne not_ab
    # se sono entrambi uguali a zero, risultato = 1
    movl $1, %ecx

    jmp after
not_ab: # primo else
    cmpl $0, %ebx
    jne not_b 
    # se b uguale a 0, risultato = A
    movl %eax, %ecx
    
    jmp after

not_b: # secondo else
    cmpl $0, %eax  # se A non e' diverso da 0, esco dall'IF
    je after
    # altrimenti entro nel while
while:
    cmpl %ebx, %eax
    je after # se A e' uguale a B, non faccio il while
    
    jl else4 # if(a<b)
    subl %eax, %ebx # b = b - a
    movl %ebx, %ecx # metto b in ECX
    jmp fine_while
else4:
    subl %ebx, %eax # a = a - b

fine_while:
    jmp while # ricomincia il while

after: # fine IF

    jmp exit

exit:
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80

