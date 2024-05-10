# calcolare quante auto mi servono per trasportare un certo numero di persone

.section .data

titolo:
    .ascii "Programma per calcolare quante auto servono\n\n"
    
titolo_len:
    .long . - titolo

testo:
    .ascii "Totale auto richieste: "
testo_len:
    .long . - testo

numPersone: # numero max persone: 255 --> 8 bit  (sarebbe input ma per questa volta lo mettiamo come costante)
    .long 152

persPerAuto: # quante persone ci stanno per auto?
    .long 5

numAuto: # variabile tipo ascii che conterra' il numero da stampare
    .ascii "000\n"
    

.section .text
    .global _start

_start:

    movl numPersone, %eax # dividendo (deve essere MAX 8 bit)
    # AL contiene il numPersone, ovvero il valore su cui fare la divisione

    movl persPerAuto, %ebx # divisore
    # BL contene persPerAuto, quindi il divisore

    div %bl # fa la divisione AL / BL -- risultato in AL e resto in AH

    # prendo gli 8 bit meno significativi di ebx (perchè devo dividere per 8 bit e non di piu')
    # --> 152 / 5 = 30 resto 2
    # divisione in assembly. la funzione DIV prende il registro AX (come operando) e inserisce in AL il quoziente e in AH il resto

    cmpb $0, %ah # controllo il resto con 0 (ovvero se sono rimaste persone senza auto)
    je skip # se è 0 salto questo
    
    incb %al # aumento il risultato di 1 per aggiungere l'auto mancante

    xorb %ah, %ah # pulisco AH eseguendo uno xor con se stesso (siccome tutti i bit sono uguali, lo xor da 0 su ogni bit)

skip: # procedo normalmente
    # gestisco la conversione da numeri binari a stringhe in base 10
    # utilizzo il trucco di dividere per 10 e prendere il resto (come eseguire i%10 su c per prendere ogni cifra)

    # voglio scrivere ogni cifra di numAuto con il risultato effettivo, in base 10
    leal numAuto, %esi # assegno ad esi l'indirizzo di mem di numAuto

    addl $2, %esi # faccio puntare esi alla terza cifra di numAuto

    movl $10, %ebx # calcolo il divisore in %ebx

    movl $3, %ecx # la loop usa ecx con contatore, lo decrementa e riparte fino a che non vale 0
# '8' = 48 (0) + 8 
inizioCiclo:
    # numAuto %eax = 31 
    div %bl # divido per 10
    # dopo la divisione -> AL = 3 , AH 1
    addb $48, %ah # ascii di 0 = 48. sommo la cifra da inserire a 48 e ottengo la codifica ascii del numero che voglio stampare 
    # AH = 49 (codice ASCII per stampare il carattere '1')
    movb %ah, (%esi) # inserisco la codifica all'indirizzo di mem puntato da esi
    xorb %ah, %ah # pulisco ah
     
    decl %esi # decremento il puntatore per selezionare la cifra dopo
    loop inizioCiclo # se ecx e' diverso da 0, allora torno a inizio ciclo

# adesso dobbiamo solo stampare

    movl $4, %eax # syscall WIRTE
    movl $1, %ebx # stampa su standard output
    leal titolo, %ecx # stampo il titolo
    movl titolo_len, %edx # quanto devo stampare
    int $0x80 # interrupt 

    movl $4, %eax
    movl $1, %ebx
    leal testo, %ecx # stampo il testo
    movl testo_len, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    leal numAuto, %ecx # stampo il numero auto
    movl $4, %edx # so che e' 4 caratteri
    int $0x80

    # termino il programma senza errori
    movl $1, %eax # termino
    movl $0, %ebx # con 0 errori
    int $0x80

    # END
