# ALGORITMO HPF

# PARAMETRI: ebp, hpf_lines
.section .data

hpf_lines: .int 0 # num linee

hpf_basePointer: .long 0 # salvo ebp
hpf_basePointer_funzione: .long 0 # salvo stack pointer di inizio funzione ( per RET )

max: .int 0 # max di hpf
min2: .int 101 # min di hpf (scadenza)

hpf_count: .int 0 # quante volte far girare i loop
hpf_stmp: .int 0 # tiene conto di quale num variabile devo azzerare

hpf_countmax: .int 0 # conta quanti massimi trova (hpf)

hpf_riga_da_stampare: .long 0 # indirizzo stack della riga da stampare
hpf_toDelete: .int 0

.section .text
    .global hpf 

.type hpf, @function

hpf: 
    movl %ebp, hpf_basePointer_funzione # salvo stack pointer funzione
    # salvo parametri
    movl %ebx, hpf_lines

    # imposto nuovo basePointer
    movl %eax, %ebp

    # INIZIALIZZO IL CONTATORE
    movl hpf_lines, %eax
    movl %eax, hpf_count

    # NB: hpf_lines VALE 1 IN PIU' DI QUANTO DEVO DECREMENTARE LO STACK
    movl $4, %edx # grandezza di una riga dello stack

    decl %eax # quindi decremento eax (ha valore hpf_lines) di 1

    mull %edx # es: se ho 3 linee, e' come se facessi $4 * (3-1) = 8 --> 8(%ebp)

    addl %eax, %ebp # adesso ebp punta alla prima riga che avevo messo sullo stack

    # SALVO EBP CHE PUNTA ALLA PRIMA VARIABILE IN FONDO ALLO STACK 
    movl %ebp, hpf_basePointer

    movl hpf_lines, %ecx

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

primo_loop_hpf: # RICERCA DEL MASSIMO TRA LE RIGHE
    movl %ecx, hpf_count
    movl (%ebp), %eax # leggo valore dallo stack

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_primo_loop_hpf

    movl $4, %ebx # scelgo PRIORITA'
    call revert
    # in eax ho la priorita'
    cmpl max, %eax 
    jle skip_primo_loop_hpf
    # se eax e' maggiore di max, salvo il nuovo max
    movl %eax, max

skip_primo_loop_hpf:
    subl $4, %ebp # salgo di stack

    movl hpf_count, %ecx
    loop primo_loop_hpf

fine_primo_loop_hpf: # ARRIVATI QUI, IN max HO IL MASSIMO TRA LE RIGHE
    # ------------------ DEVO CAPIRE QUANTE RIGHE POSSIEDONO IL MASSIMO TROVATO ----------------------
    movl hpf_basePointer, %ebp # ripristino stack pointer

    movl hpf_lines, %ecx
    movl %ecx, hpf_count

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

check_max_hpf:
    movl %ecx, hpf_count
    movl (%ebp), %eax # leggo valore dallo stack

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_check_max_hpf

    movl $4, %ebx # scelgo PRIORITA'
    call revert
    # in eax ho la priorita'
    cmpl max, %eax 
    jne skip_check_max_hpf
    # ho trovato una riga che ha il massimo attuale
    incw hpf_countmax # aumento il contatore

    movl (%ebp), %eax            
    movl %eax, hpf_riga_da_stampare  # salva il num a 32bit in hpf_riga_da_stampare

    movl hpf_stmp, %eax # salvo il num di variabile
    movl %eax, hpf_toDelete

skip_check_max_hpf:
    subl $4, %ebp # salgo di stack

    incl hpf_stmp
    movl hpf_count, %ecx
    loop check_max_hpf

seconda_parte_hpf: # CONTROLLO DELLE PRIORITA' (NEL CASO IL MASSIMO E' PIU' DI 1)
    movl hpf_basePointer, %ebp # ripristino stack pointer

    # CONTROLLO SE DEVO ESEGUIRE IL SECONDO LOOP O MENO
    movl hpf_countmax, %eax
    cmpl $2, %eax
    jl fine_hpf # se ho solo un massimo vado diretto a stampare

    # --------------------- CASO IN CUI DEVO FARE IL SECONDO CHECK (SCADENZA) ------------------------
    movl hpf_lines, %ecx
    movl %ecx, hpf_count
    movl $0, hpf_stmp # azzero

    # pulisco i registri
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %edx, %edx

secondo_loop_hpf: # RICERCA DELLA SCADENZA PIU' BASSA (SOLO DEI MASSIMI)
    movl %ecx, hpf_count
    movl (%ebp), %eax # leggo valore dallo stack

    # SE LA RIGA CHE STO CONTROLLANDO E' VUOTA, SALTO TALE GIRO DI LOOP
    cmpl $0, %eax
    je skip_secondo_loop_hpf

    # ------------- prima controllo se fa parte dei massimi -------------------
    movl $4, %ebx # scelgo PRIORITA'
    call revert
    # in eax ho la priorita'
    cmpl max, %eax
    jne skip_secondo_loop_hpf # se non e' un massimo, salto diretto

    # ---------------- se fa parte dei massimi, controllo scadenza ----------------
    movl (%ebp), %eax # leggo valore dallo stack
    movl $3, %ebx # scelgo scadenza
    call revert
    # in eax ho la scadenza

    cmpl min2, %eax 
    jge skip_secondo_loop_hpf

    # se eax e' minore di min2, salvo il nuovo min2
    movl %eax, min2
    
    movl (%ebp), %eax            
    movl %eax, hpf_riga_da_stampare  # salva il num a 32bit in hpf_riga_da_stampare

    movl hpf_stmp, %eax # salvo il num di variabile
    movl %eax, hpf_toDelete
    # anche se avessi due righe con la stessa scadenza, stampo sempre l'ultima che trovo, siccome non ha importanza

skip_secondo_loop_hpf:
    subl $4, %ebp # salgo di stack

    incl hpf_stmp
    movl hpf_count, %ecx
    loop secondo_loop_hpf

fine_hpf:
    # prima azzero la riga di stack che devo stampare
    movl hpf_basePointer, %ebp # ripristino stack pointer

    movl hpf_toDelete, %ecx
    cmpl $0, %ecx
    je skip_shift_stack
    # salgo di stack in base a che variabile devo togliere
shift_stack:
    subl $4, %ebp
    loop shift_stack

skip_shift_stack:
    movl $0, (%ebp) # azzero tale area di memoria

    movl hpf_basePointer_funzione, %ebp # ripristino ebp
    movl hpf_riga_da_stampare, %eax # devo ritornare : hpf_riga_da_stampare
    
    # azzero
    movl $0, max
    movl $101, min2
    movl $0, hpf_count
    movl $0, hpf_stmp
    movl $0, hpf_countmax
    movl $0, hpf_riga_da_stampare
    movl $0, hpf_toDelete

    ret 

