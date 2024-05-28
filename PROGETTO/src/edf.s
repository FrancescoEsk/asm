# ALGORITMO EDF

# PARAMETRI: ESP, lines
.section .data

lines: .int 0 # num linee

stackPointer: .long 0 # salvo esp
stackPointer_funzione: .long 0 # salvo stack pointer di inizio funzione ( per RET )

min: .int 0 # minimo di EDF
max2: .int 0 # max di EDF (priorita')

count: .int 0 # quante volte far girare i loop

countmin: .int 0 # conta quanti minimi trova (EDF)

benvenuto_EDF: .ascii "Pianificazione EDF:\n"
benvenuto_EDF_len: .long . - benvenuto_EDF

riga_da_stampare: .long 0 # indirizzo stack della riga da stampare


.section .text
    .global edf 

.type edf, @function

edf: 
    movl %esp, stackPointer_funzione # salvo stack pointer funzione
    # salvo parametri
    movl %eax, stackPointer
    movl %ebx, lines

    # imposto nuovo stackPointer
    movl %eax, %esp

    # stampa benvenuto
    movl $4, %eax
    movl $1, %ebx
    leal benvenuto_EDF, %ecx
    movl benvenuto_EDF_len, %edx

    movl $0, min # azzero

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

primo_loop_EDF: # RICERCA DEL MINIMO TRA LE RIGHE
    movl %ecx, count
    movl (%esp), %eax # leggo valore dallo stack

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_primo_loop_EDF


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

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_check_min_EDF

    movl $3, %ebx # scelgo SCADENZA
    call revert
    # in eax ho la scadenza
    cmpl min, %eax 
    jne skip_primo_loop_EDF
    # ho trovato una riga che ha il minimo attuale
    incw countmin # aumento il contatore
    movl %esp, riga_da_stampare # salvo indirizzo stack

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
    movl (%esp), %eax # leggo valore dallo stack

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_secondo_loop_EDF

    # ------------- prima controllo se fa parte dei minimi -------------------
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
    movl %esp, riga_da_stampare # salvo riga da stampare 

    # anche se avessi due righe con la stessa priorita', stampo sempre l'ultima che trovo, siccome non ha importanza

skip_secondo_loop_EDF:
    subl $4, %esp # salgo di stack

    movl count, %ecx
    loop secondo_loop_EDF

    # devo ritornare : riga_da_stampare
    movl riga_da_stampare, %eax
    movl stackPointer_funzione, %esp

    ret 


