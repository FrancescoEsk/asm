# funzione che stampa a video la riga del file fornita

# PARAMETRI
# EAX : indirizzo stack da stampare
# EBX : slottemporali

# ATTUALMENTE SBAGLIATO. PERCHE' SE HO 12, SCRIVE 21 (AL CONTRARIO)


.section .data

slottemporali: .int 0

string_temp: .byte 10
index_string_temp: .int 0
print_temp: .long 0

.section .text
    .global printvideo
.type printvideo, @function

printvideo:
    # salvo indirizzo da stampare 
    movl %eax, print_temp
    movl %ebx, slottemporali

    # -------------- AZZERO VARAIBILI ----------------
    movl $0, index_string_temp 

printvideo_reset_riga: # PULIZIA STRINGA 
    movl $20, %ecx
    movl $string_temp, %ebx
printvideo_resetstring_loop:
    movb $0, (%ebx)
    incl %ebx
    loop printvideo_resetstring_loop
    # end reset stringa

    movl $1, %ebx # ottengo ID
    call revert

    # --- scrivo id sulla stringa da stampare
    movl $10, %ecx # divido per 10

printvideo_loop1:
    divl %ecx # RESTO IN ECX, RISULTATO IN EAX

    # IL RESTO E' IL CARATTERE CHE DEVO STAMPARE
    addb $48, %cl # trasformo in carattere ASCII

    # scrivo sulla stringa
    movl index_string_temp, %ebx 
    addl $string_temp, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %cl, (%ebx) # scrivo nella posizione del carattere prossimo

    # incremento l'indice
    addl $1, index_string_temp

    cmpl $0, %eax # fino a che ho ancora numero da stampare, ciclo
    jl printvideo_loop1

    # scrivo sulla stringa il carattere ':'
    movl index_string_temp, %ebx 
    addl $string_temp, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb $58, (%ebx) # scrivo nella posizione del carattere prossimo

    # incremento l'indice
    addl $1, index_string_temp


    # -------------- STAMPO SLOT TEMPORALI -----------------
    movl slottemporali, %eax
    movl $10, %ecx # divido per 10

printvideo_loop2:
    divl %ecx # RESTO IN ECX, RISULTATO IN EAX

    # IL RESTO E' IL CARATTERE CHE DEVO STAMPARE
    addb $48, %cl # trasformo in carattere ASCII

    # scrivo sulla stringa
    movl index_string_temp, %ebx 
    addl $string_temp, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %cl, (%ebx) # scrivo nella posizione del carattere prossimo

    # incremento l'indice
    addl $1, index_string_temp

    cmpl $0, %eax # fino a che ho ancora numero da stampare, ciclo
    jl printvideo_loop2

    # scrivo sulla stringa il carattere '\n'
    movl index_string_temp, %ebx 
    addl $string_temp, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb $10, (%ebx) # scrivo nella posizione del carattere prossimo

    # -------------- STRINGA SCRITTA -----------------
    leal string_temp, %ecx
    movl index_string_temp, %edx

    ret


