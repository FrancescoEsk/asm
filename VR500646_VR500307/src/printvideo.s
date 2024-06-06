# funzione che stampa a video la riga del file fornita

# PARAMETRI
# EAX : indirizzo stack da stampare
# EBX : slottemporali
# ECX : leal stringa su cui scrivere
# EDX : index della stringa su cui scrivere

.section .data

old_temp: .long 0
slot: .int 0
stringa: .long 0
index_temp: .long 0
check: .int 0

temp: .ascii "0000"

.section .text
    .global printvideo
.type printvideo, @function

printvideo:
    # salvo parametri
    movl %ebx, slot
    movl %ecx, stringa

    movl $1, %ebx
    call revert
    # in EAX ho l'id ordine da stampare
    
    jmp conversione

    # stringa scritta con il primo numero
    # index_temp punta alla prossima cifra
redo:
    movl check, %eax # se ho finito di scrivere tutta la stringa, posso fare la return
    cmpl $2, %eax
    je exit

    # altrimenti sono arrivato per la prima volta qui
    # adesso inserisco il carattere ':'
    movl $58, (%esi)
    incl index_temp

    # adesso devo mettere gli slot temporali
    movl slot, %eax

conversione:
    leal temp, %esi # assegno ad esi l'indirizzo di mem della stringa
    addl $3, %esi # faccio puntare esi alla quarta cifra

    movl $10, %edx # divisore
    movl $4, %ecx # loop di 4 (siccome il numero e' al massimo di 4 cifre)

inizioCiclo:
    div %dl # divido per 10

    addb $48, %ah # sommo la cifra da inserire a 48 e ottengo la codifica ascii del numero che voglio stampare 

    movb %ah, (%esi) # inserisco la codifica all'indirizzo di mem puntato da esi
    xorb %ah, %ah # pulisco ah
     
    decl %esi # decremento il puntatore per selezionare la cifra dopo
    loop inizioCiclo # se ecx e' diverso da 0, allora torno a inizio ciclo

    # dopo questo, temp contiene l'intero convertito in ascii.
    # adesso devo inserirlo in stringa, da dopo il primo 0
    leal temp, %eax
    movl stringa, %esi
    addl index_temp, %esi # carico index_temp stringa (aggiungo offset)
    movl $4, %ecx
    jmp scrittura_stringa

skip1:
    incl %eax # avanzo in temp
    decl %ecx # tolgo un giro di loop
    cmpl $1, %ecx
    je loop_scrittura
scrittura_stringa:
    movl (%eax), %ebx
    cmpb $48, %bl # se il carattere di temp e' '0' vado, aspetto a scrivere fino a che non incontro il primo num != da 0
    je skip1

loop_scrittura:
    movl (%eax), %ebx
    movb %bl, (%esi)

    incl %eax
    incl %esi
    incl index_temp

    loop loop_scrittura
    incl check
    jmp redo

exit:
    # adesso inserisco il carattere '\n'
    movl $10, (%esi)
    incl index_temp

    # ritorna la lunghezza della stringa modificata
    movl index_temp, %edx

    # azzero var
    movl $0, index_temp
    movl $0, check
    

    ret

