# ###################
# filename: itoa.s
# ###################
.section .data
car:
  .byte 0
.section .text

.global itoa

.type itoa, @function 
# dichiarazione della funzione itoa
# la funzione converte un intero in una stringa
# il numero da convertire deve essere
# stato caricato nel registro eax

itoa:
    mov   $0, %ecx # carica il numero 0 in ecx

continua_a_dividere:
    cmp   $10, %eax # confronta 10 con il conenuto in eax
    jge   dividi # salta a dividi se eax e' maggiore o uguale a 10
    pushl %eax 
    inc   %ecx
    mov   %ecx, %ebx
    jmp   stampa

dividi:
    movl  $0, %edx   # carica 0 in edx
    movl  $10, %ebx  # carica 10 in ebx
    divl %ebx

    # divide per ebx (10) il numero ottenuto
    # concatenando il contenuto di dx e ax (notare che # in questo caso dx=0)
    # il quoziente viene messo in eax, il resto in dx # salva il resto nello stack
    # incrementa il contatore delle cifre da stampare
    pushl %edx
    inc   %ecx
    jmp   continua_a_dividere

stampa:
    cmp   $0, %ebx
    je    fine_itoa
    popl  %eax
    movb  %al, car
    addb  $48, car
    dec   %ebx
    # controlla se ci sono (ancora) caratteri da
    # stampare
    # se ebx=0 ho stampato tutto, quindi salto alla fine # preleva l'elemento da stampare dallo stack
    # memorizza nella variabile car il valore contenuto # negli 8 bit meno significativi del registro eax
    # gli altri bit del registro non ci interessano
    # visto che una cifra decimale e' contenuta in
    # un solo byte
    # somma al valore car il codice ascii del carattere # '0' (zero)
    # decrementa di 1 il numero di cifre da stampare
    pushw %bx
    # salviamo il valore di bx nello stack poiché # per effettuare la stampa dobbiamo modificare # i valori dei registri come richiesto
    # dalla funzione del sistema operativo WRITE
    movl  $4, %eax  # codice della funzione write
    movl  $1, %ebx
    leal  car, %ecx
    mov $1, %edx
    int   $0x80
    popw   %bx
    jmp stampa
    
fine_itoa:
    movb  $10, car
    movl  $4, %eax
    movl  $1, %ebx
    leal  car, %ecx
    mov   $1, %edx
    int   $0x80
    ret

# la write scrive nello standard output
# identificato dal file descriptor 1
# il puntatore della stringa da stampare deve
# essere caricato in ecx
# l'istruzione lea carica l'indirizzo della
# locazione di memoria indicata dall’etichetta car, # nel registro ecx
# la lunghezza della stringa da stampare deve
# essere caricata in edx
# chiamata all'interrupt 0x80 per la stampa di car # recupera il contatore dei caratteri da stampare
# salvato nello stack prima della chiamata alla
# funzione write
# ritorna all'etichetta stampa per stampare il
# prossimo carattere. Notare che il blocco di
# istruzioni compreso tra l'etichetta stampa
# e l'istruzione jmp stampa e' un classico
# esempio di come creare un ciclo while in assembly
# copia il codice ascii del carattere line feed
# (per andare a capo riga) nella variabile car
# solito blocco di istruzioni per la stampa
# fine della funzione itoa
# l'esecuzione riprende dall'istruzione sucessiva # alla call che ha invocato itoa