# ALGORITMO EDF

# PARAMETRI: ebp, lines
.section .data

lines: .int 0 # num linee

basePointer: .long 0 # salvo ebp
basePointer_funzione: .long 0 # salvo stack pointer di inizio funzione ( per RET )

min: .int 101 # minimo di EDF
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
    movl %ebp, basePointer_funzione # salvo stack pointer funzione
    # salvo parametri
    movl %ebx, lines

    # imposto nuovo basePointer
    movl %eax, %ebp

    # stampa benvenuto
    movl $4, %eax
    movl $1, %ebx
    leal benvenuto_EDF, %ecx
    movl benvenuto_EDF_len, %edx
    int $0x80

    # INIZIALIZZO IL CONTATORE
    movl lines, %eax
    movl %eax, count

    # NB: LINES VALE 1 IN PIU' DI QUANTO DEVO DECREMENTARE LO STACK
    movl $4, %edx # grandezza di una riga dello stack

    decl %eax # quindi decremento eax (ha valore lines) di 1

    mull %edx # es: se ho 3 linee, e' come se facessi $4 * (3-1) = 8 --> 8(%ebp)

    addl %eax, %ebp # adesso ebp punta alla prima riga che avevo messo sullo stack

    # SALVO EBP CHE PUNTA ALLA PRIMA VARIABILE IN FONDO ALLO STACK 
    movl %ebp, basePointer

    movl lines, %ecx

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

primo_loop_EDF: # RICERCA DEL MINIMO TRA LE RIGHE
    movl %ecx, count
    movl (%ebp), %eax # leggo valore dallo stack

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
    subl $4, %ebp # salgo di stack

    movl count, %ecx
    loop primo_loop_EDF

fine_primo_loop_EDF: # ARRIVATI QUI, IN min HO IL MINIMO TRA LE RIGHE
    # ------------------ DEVO CAPIRE QUANTE RIGHE POSSIEDONO IL MINIMO TROVATO ----------------------
    movl basePointer, %ebp # ripristino stack pointer

    movl lines, %ecx
    movl %ecx, count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

check_min_EDF:
    movl %ecx, count
    movl (%ebp), %eax # leggo valore dallo stack

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_check_min_EDF

    movl $3, %ebx # scelgo SCADENZA
    call revert
    # in eax ho la scadenza
    cmpl min, %eax 
    jne skip_check_min_EDF
    # ho trovato una riga che ha il minimo attuale
    incw countmin # aumento il contatore
    movl %ebp, riga_da_stampare # salvo indirizzo stack

skip_check_min_EDF:
    subl $4, %ebp # salgo di stack

    movl count, %ecx
    loop check_min_EDF

seconda_parte_EDF: # CONTROLLO DELLE PRIORITA' (NEL CASO IL MINIMO E' PIU' DI 1)
    movl basePointer, %ebp # ripristino stack pointer

    # CONTROLLO SE DEVO ESEGUIRE IL SECONDO LOOP O MENO
    movl countmin, %eax
    cmpl $2, %eax
    jl stampa_EDF # se ho solo un minimo vado diretto a stampare

    # --------------------- CASO IN CUI DEVO FARE IL SECONDO CHECK (PRIORITA') ------------------------
    movl lines, %ecx
    movl %ecx, count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

secondo_loop_EDF: # RICERCA DELLA PRIORITA' PIU' ALTA (SOLO DEI MINIMI)
    movl %ecx, count
    movl (%ebp), %eax # leggo valore dallo stack

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
    movl (%ebp), %eax # leggo valore dallo stack
    movl $4, %ebx # scelgo PRIORITA'
    call revert
    # in eax ho la priorita'

    cmpl max2, %eax 
    jge skip_secondo_loop_EDF

    # se eax e' minore di max2, salvo il nuovo max2
    movl %eax, max2
    movl %ebp, riga_da_stampare # salvo riga da stampare 

    # anche se avessi due righe con la stessa priorita', stampo sempre l'ultima che trovo, siccome non ha importanza

skip_secondo_loop_EDF:
    subl $4, %ebp # salgo di stack

    movl count, %ecx
    loop secondo_loop_EDF

stampa_EDF:
    # devo ritornare : riga_da_stampare
    movl riga_da_stampare, %eax
    movl basePointer_funzione, %ebp

    ret 

