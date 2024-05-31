# ALGORITMO EDF

# PARAMETRI: ebp, edf_lines
.section .data

edf_lines: .int 0 # num linee

edf_basePointer: .long 0 # salvo ebp
edf_basePointer_funzione: .long 0 # salvo stack pointer di inizio funzione ( per RET )

min: .int 101 # minimo di EDF
max2: .int 0 # max di EDF (priorita')

edf_count: .int 0 # quante volte far girare i loop
edf_stmp: .int 0 # tiene conto di quale num variabile devo azzerare

edf_countmin: .int 0 # conta quanti minimi trova (EDF)

edf_riga_da_stampare: .long 0 # indirizzo stack della riga da stampare
edf_toDelete: .int 0

.section .text
    .global edf 

.type edf, @function

edf: 
    movl %ebp, edf_basePointer_funzione # salvo stack pointer funzione
    # salvo parametri
    movl %ebx, edf_lines

    # imposto nuovo basePointer
    movl %eax, %ebp

    # INIZIALIZZO IL CONTATORE
    movl edf_lines, %eax
    movl %eax, edf_count

    # NB: edf_lines VALE 1 IN PIU' DI QUANTO DEVO DECREMENTARE LO STACK
    movl $4, %edx # grandezza di una riga dello stack

    decl %eax # quindi decremento eax (ha valore edf_lines) di 1

    mull %edx # es: se ho 3 linee, e' come se facessi $4 * (3-1) = 8 --> 8(%ebp)

    addl %eax, %ebp # adesso ebp punta alla prima riga che avevo messo sullo stack

    # SALVO EBP CHE PUNTA ALLA PRIMA VARIABILE IN FONDO ALLO STACK 
    movl %ebp, edf_basePointer

    movl edf_lines, %ecx

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

primo_loop_EDF: # RICERCA DEL MINIMO TRA LE RIGHE
    movl %ecx, edf_count
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

    movl edf_count, %ecx
    loop primo_loop_EDF

fine_primo_loop_EDF: # ARRIVATI QUI, IN min HO IL MINIMO TRA LE RIGHE
    # ------------------ DEVO CAPIRE QUANTE RIGHE POSSIEDONO IL MINIMO TROVATO ----------------------
    movl edf_basePointer, %ebp # ripristino stack pointer

    movl edf_lines, %ecx
    movl %ecx, edf_count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

check_min_EDF:
    movl %ecx, edf_count
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
    incw edf_countmin # aumento il contatore

    movl (%ebp), %eax            
    movl %eax, edf_riga_da_stampare  # salva il num a 32bit in edf_riga_da_stampare

    movl edf_stmp, %eax # salvo il num di variabile
    movl %eax, edf_toDelete

skip_check_min_EDF:
    subl $4, %ebp # salgo di stack

    incl edf_stmp
    movl edf_count, %ecx
    loop check_min_EDF

seconda_parte_EDF: # CONTROLLO DELLE PRIORITA' (NEL CASO IL MINIMO E' PIU' DI 1)
    movl edf_basePointer, %ebp # ripristino stack pointer

    # CONTROLLO SE DEVO ESEGUIRE IL SECONDO LOOP O MENO
    movl edf_countmin, %eax
    cmpl $2, %eax
    jl fine_EDF # se ho solo un minimo vado diretto a stampare

    # --------------------- CASO IN CUI DEVO FARE IL SECONDO CHECK (PRIORITA') ------------------------
    movl edf_lines, %ecx
    movl %ecx, edf_count
    movl $0, edf_stmp # azzero

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

secondo_loop_EDF: # RICERCA DELLA PRIORITA' PIU' ALTA (SOLO DEI MINIMI)
    movl %ecx, edf_count
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
    jle skip_secondo_loop_EDF

    # se eax e' minore di max2, salvo il nuovo max2
    movl %eax, max2
    
    movl (%ebp), %eax            
    movl %eax, edf_riga_da_stampare  # salva il num a 32bit in edf_riga_da_stampare

    movl edf_stmp, %eax # salvo il num di variabile
    movl %eax, edf_toDelete
    # anche se avessi due righe con la stessa priorita', stampo sempre l'ultima che trovo, siccome non ha importanza

skip_secondo_loop_EDF:
    subl $4, %ebp # salgo di stack

    incl edf_stmp
    movl edf_count, %ecx
    loop secondo_loop_EDF

fine_EDF:
    # prima azzero la riga di stack che devo stampare
    movl edf_basePointer, %ebp # ripristino stack pointer

    movl edf_toDelete, %ecx
    cmpl $0, %ecx
    je skip_shift_stack
    # salgo di stack in base a che variabile devo togliere
shift_stack:
    subl $4, %ebp
    loop shift_stack

skip_shift_stack:
    movl $0, (%ebp) # azzero tale area di memoria

    movl edf_basePointer_funzione, %ebp # ripristino ebp
    movl edf_riga_da_stampare, %eax # devo ritornare : edf_riga_da_stampare
    
    # azzero
    movl $101, min
    movl $0, max2
    movl $0, edf_count
    movl $0, edf_stmp
    movl $0, edf_countmin
    movl $0, edf_riga_da_stampare
    movl $0, edf_toDelete

    ret 

