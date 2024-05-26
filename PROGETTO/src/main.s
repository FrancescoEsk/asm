# funzione che legge un file

# PARAMETRI
# EBX = file.txt

.section .data

# VARIABILI PER LETTURA FILE
riga: .space 20 # buffer abbastanza grande da contenere una riga (20 caratteri)
index: .int 0 # indice per tenere traccia della posizione in cui scrivere il carattere in 'riga'
buffer: .string ""
fd: .int 0
newline: .byte 10 # valore ascii di '\n'
lines: .int 0 # num linee

# VAR CHE DICE SE DEVO STAMPARE A VIDEO O SCRIVERE SU FILE (0: A VIDEO, 1: SU FILE)
secondfile: .int 0 
# FILE SU CUI SCRIVERE OUTPUT ALGORITMO
file2: .ascii ""

benvenuto_EDF: .ascii "Pianificazione EDF:\n"
benvenuto_EDF_len: .long . - benvenuto_EDF

benvenuto_HPF: .ascii "Pianificazione HPF:\n"
benvenuto_HPF_len: .long . - benvenuto_HPF


# VARIABILI PER ALGORITMO
stackPointer: .long 0 # salvo esp
slottemporali: .int 0


min: .int 0 # minimo di EDF
max2: .int 0 # max di EDF (priorita')

max: .int 0 # massimo di HPF
min2: .int 0 # minimo di HPF (scadenza)

count: .int 0 # quante volte far girare i loop

countmin: .int 0 # conta quanti minimi trova (EDF)
rigaEDF: .long 0 # indirizzo stack della riga da stampare (EDF)

.section .bss


.section .text
    .global _start

_start:
    # CONTROLLO QUANTI PARAMETRI SONO STATI PASSATI PER LINEA DI COMANDO
    movl (%esp), %eax
    cmpl $1, %eax # nessun parametro
    je exit

    cmpl $2, %eax # un file
    je apriFile

    # SE SONO ARRIVATO QUI, HO ALMENO DUE PARAMETRI PASSATI
    incw secondfile # CHECK CHE MI FA SCRIVERE SU FILE
    movl 12(%esp), file2 # SALVO PERCORSO DEL FILE
    cmpl $3, %eax # due file
    je apriFile

    # SE HO PIU' DI DUE PARAMETRI, ERRORE. CHIUDO PROGRAMMA
    jmp exit 

apriFile: # APERTURA FILE
    # apertura file
    movl $5, %eax
    movl 8(%esp), %ebx
    movl $0, %ecx # MODALITA' READ ONLY
    xorl %edx, %edx
    int $0x80

    # controllo errore
    cmpl $0, %eax
    jl algoritmo

    movl %eax, fd # salvo il file descriptor

read_loop: # LETTURA FILE
    # read da file 
    movl $3, %eax 
    movl fd, %ebx
    movl $buffer, %ecx # buffer dove mettere la stringa letto
    movl $1, %edx # lunghezza massima della stringa 
    int $0x80

    # errori o EOF
    cmpl $0, %eax
    jle close_file

    # controllo se sto per avere una nuova riga ('\n)
    movb buffer, %al
    cmpb newline, %al 
    jne next # se non ho finito la riga, salto


    # se ho finito di leggere la riga
    incw lines # incremento contatore linee

    # scrivo lo '\n'
    movl index, %ebx 
    addl $riga, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %al, (%ebx) # scrivo nella posizione del carattere prossimo

    # converto la stringa in num da 32 bit
    leal riga, %eax # passo alla funzione la riga da convertire
    call convert 
    pushl %eax # e poi la carico sullo stack

    # reset indice per la prossima riga
    movl $0, index 

    xorl %eax, %eax

reset_riga: # PULIZIA STRINGA 
    movl $20, %ecx
    movl $riga, %ebx
resetstring_loop:
    movb $0, (%ebx)
    incl %ebx
    loop resetstring_loop

    # end reset stringa
    jmp read_loop # ricomincio a leggere il file

next: # SCRITTURA DA FILE A STRINGA
    # scrivo il carattere (attualmente in AL) letto in "riga" alla posizione corrente
    movl index, %ebx 
    addl $riga, %ebx # riga + offset indice ( punto al carattere prossimo )
    movb %al, (%ebx) # scrivo nella posizione del carattere prossimo

    # incremento l'indice
    addl $1, index

    jmp read_loop # continuo a leggere

close_file: # CHIUSURA FILE
    # chiusura file
    movl $6, %eax
    movl fd, %ebx
    int $0x80

algoritmo:
    # ARRIVATI QUI, LO STACK CONTIENE I VALORI DELLE RIGHE DEL FILE
    # NUMERO RIGHE FILE CONTENUTO IN 'lines' (contatore)

    # ---------------------------- INSERIRE STAMPA MENU' PER SCELTA ALGORITMO ----------------------------
    

EDF: # ALGORITMO EDF
    # stampa benvenuto
    movl $4, %eax
    movl $1, %ebx
    leal benvenuto_EDF, %ecx
    movl benvenuto_EDF_len, %edx

    movl $0, min # azzero

    # INIZIALIZZO IL CONTATORE
    movl lines, %eax
    movl %eax, count

    # SALVO STACK POINTER
    movl %esp, stackPointer

    # NB: LINES VALE 1 IN PIU' DI QUANTO DEVO DECREMENTARE LO STACK
    movl $4, %edx # grandezza di una riga dello stack

    decl %eax # quindi decremento eax (ha valore lines) di 1

    mull %edx # es: se ho 3 linee, e' come se facessi $4 * (3-1) = 8 --> 8(%esp)

    addl %eax, %esp # adesso esp punta alla prima riga che avevo messo sullo stack


    movl lines, %ecx
    movl %ecx, count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

primo_loop_EDF: # RICERCA DEL MINIMO TRA LE RIGHE

    # DA AGGIUNGERE CHE SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP

    movl %ecx, count

    movl (%esp), %eax # leggo valore dallo stack
    movl $3, %ebx # scelgo SCADENZA
    call revert
    # in eax ho la scadenza
    cmpl min, %eax 
    jge skip_primo_loop_EDF
    # se eax e' maggiore di min, salvo il nuovo min
    movl %eax, min

skip_primo_loop_EDF:
    subl $4, %esp # salgo di stack

    movl count, %ecx
    loop primo_loop_EDF

fine_primo_loop_EDF: # ARRIVATI QUI, IN min HO IL MINIMO TRA LE RIGHE
    # ------------------ DEVO CAPIRE QUANTE RIGHE POSSIEDONO IL MINIMO TROVATO ----------------------

    movl $0, countmin # azzero

    movl stackPointer, %esp # ripristino stack pointer

    # INIZIALIZZO IL CONTATORE
    movl lines, %eax
    movl %eax, count

    # NB: LINES VALE 1 IN PIU' DI QUANTO DEVO DECREMENTARE LO STACK
    movl $4, %edx # grandezza di una riga dello stack

    decl %eax # quindi decremento eax (ha valore lines) di 1

    mull %edx # es: se ho 3 linee, e' come se facessi $4 * (3-1) = 8 --> 8(%esp)

    addl %eax, %esp # adesso esp punta alla prima riga che avevo messo sullo stack

    movl lines, %ecx
    movl %ecx, count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

check_min_EDF:
    movl %ecx, count

    movl (%esp), %eax # leggo valore dallo stack
    movl $3, %ebx # scelgo SCADENZA
    call revert
    # in eax ho la scadenza
    cmpl min, %eax 
    jne skip_primo_loop_EDF
    # ho trovato una riga che ha il minimo attuale
    incw countmin # aumento il contatore
    movl %esp, stampa_EDF # salvo indirizzo stack

skip_check_min_EDF:
    subl $4, %esp # salgo di stack

    movl count, %ecx
    loop check_min_EDF

seconda_parte_EDF: # CONTROLLO DELLE PRIORITA' (NEL CASO IL MINIMO E' PIU' DI 1)
    movl $0, max2 # azzero

    movl stackPointer, %esp # ripristino stack pointer

    # CONTROLLO SE DEVO ESEGUIRE IL SECONDO LOOP O MENO
    movl countmin, %eax
    cmpl $2, eax
    jl stampa_EDF # se ho solo un minimo vado diretto a stampare

    # --------------------- CASO IN CUI DEVO FARE IL SECONDO CHECK (PRIORITA') ------------------------
    # INIZIALIZZO IL CONTATORE
    movl lines, %eax
    movl %eax, count

    # NB: LINES VALE 1 IN PIU' DI QUANTO DEVO DECREMENTARE LO STACK
    movl $4, %edx # grandezza di una riga dello stack

    decl %eax # quindi decremento eax (ha valore lines) di 1

    mull %edx # es: se ho 3 linee, e' come se facessi $4 * (3-1) = 8 --> 8(%esp)

    addl %eax, %esp # adesso esp punta alla prima riga che avevo messo sullo stack

    movl lines, %ecx
    movl %ecx, count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

secondo_loop_EDF: # RICERCA DELLA PRIORITA' PIU' ALTA (SOLO DEI MINIMI)
    movl %ecx, count

    # ------------- prima controllo se fa parte dei minimi -------------------
    movl (%esp), %eax # leggo valore dallo stack
    movl $3, %ebx # scelgo SCADENZA
    call revert
    # in eax ho la scadenza
    cmpl min, %eax
    jne skip_secondo_loop_EDF # se non e' un minimo, salto diretto

    # ---------------- se fa parte dei minimi, controllo priorita' ----------------
    movl (%esp), %eax # leggo valore dallo stack
    movl $4, %ebx # scelgo PRIORITA'
    call revert
    # in eax ho la priorita'

    cmpl max2, %eax 
    jge skip_secondo_loop_EDF

    # se eax e' minore di max2, salvo il nuovo max2
    movl %eax, max2
    movl %esp, stampa_EDF # salvo riga da stampare 

    # anche se avessi due righe con la stessa priorita', stampo sempre l'ultima che trovo, siccome non ha importanza

skip_secondo_loop_EDF:
    subl $4, %esp # salgo di stack

    movl count, %ecx
    loop secondo_loop_EDF

stampa_EDF: # STAMPA RIGA SCELTA DA ALGORITMO EDF

    # controllo se devo stampare a video o su file
    movl secondfile, %eax
    cmpl $1, %eax
    je stampa_file_EDF

    # ----------------- STAMPA A VIDEO -----------------
    # stampa identificativo
    movl (stampa_EDF), %eax
    call printvideo
    # stringa da stampare: string_temp 
    movl $4, %eax
    movl $1, %ebx
    leal string_temp, %ecx
    movl index_string_temp, %edx

    #  AUMENTO SLOT TEMPORALI
    movl (stampa_EDF), %eax
    movl $2, %ebx
    call revert # HO LA DURATA IN EAX
    addl slottemporali, %eax
    movl %eax, slottemporali

    # --------------- CALCOLO PENALITA' ---------------
    

stampa_file_EDF: # STAMPA RIGA SU FILE DA ALGORITMO EDF


exit: # CHIUSURA PROGRAMMA
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80

