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

erroreFile: .ascii "Errore: apertura file fallita\n"
erroreFile_len: .long . - erroreFile

zeroFile: .ascii "Errore: Nessun parametro fornito\n"
zeroFile_len: .long . - zeroFile

troppiFile: .ascii "Errore: Troppi parametri forniti\n"
troppiFile_len: .long . - troppiFile

conclusione: .ascii "Conclusione: "
conclusione_len: .long . - conclusione

badString: .ascii "Penalty: "
badString_len: .long . - badString

# VARIABILI PER ALGORITMO
slottemporali: .int 0
penalty: .long 0
algo: .int 0

giri_algoritmo: .int 0

riga_da_printare: .long 0 # riga da stampare a 32 bit
output_algoritmo: .byte 10

.section .bss

.section .text
    .global _start

_start:
    # CONTROLLO QUANTI PARAMETRI SONO STATI PASSATI PER LINEA DI COMANDO
    movl (%esp), %eax
    cmpl $1, %eax # nessun parametro
    je exit_zeroFile

    cmpl $2, %eax # un file
    je apriFile

    # SE SONO ARRIVATO QUI, HO ALMENO DUE PARAMETRI PASSATI
    incw secondfile # CHECK CHE MI FA SCRIVERE SU FILE
    movl 12(%esp), %ebx # SALVO PERCORSO DEL FILE
    movl %ebx, file2

    cmpl $3, %eax # due file
    je apriFile

    # SE HO PIU' DI DUE PARAMETRI, ERRORE. CHIUDO PROGRAMMA
    jmp exit_troppiFile 

apriFile: # APERTURA FILE
    # apertura file
    movl $5, %eax
    movl 8(%esp), %ebx
    movl $0, %ecx # MODALITA' READ ONLY
    xorl %edx, %edx
    int $0x80

    # controllo errore
    cmpl $0, %eax
    jl exit_erroreFile

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
    jmp read_loop # ricomincio a legkgere il file

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

    # reset indice per la prossima riga (quando rileggero' il file)
    movl $0, index 

    xorl %eax, %eax
reset_riga2: # PULIZIA STRINGA 
    movl $20, %ecx
    movl $riga, %ebx
resetstring_loop2:
    movb $0, (%ebx)
    incl %ebx
    loop resetstring_loop2

stampa_menu:
    # ARRIVATI QUI, LO STACK CONTIENE I VALORI DELLE RIGHE DEL FILE
    # NUMERO RIGHE FILE CONTENUTO IN 'lines' (contatore) -> setto quindi il num giri dell'algoritmo
    movl lines, %eax
    movl %eax, giri_algoritmo

    call menu
    # in eax ho l'input da utente
    cmpl $0, %eax
    je exit
    # se l'utente, quindi, ha inserito 1 o 2 (edf o hpf)
    decl %eax
    movl %eax, algo # decremento e salvo in algo

scelta_algoritmo:
    # scelta algoritmo si basa sulla var. 'algo' che vale 0 se si sceglie edf, e 1 se si sceglie hpf
    movl algo, %eax
    cmpl $0, %eax
    jne algoritmo_hpf

algoritmo_edf:
    # scelta EDF
    movl %esp, %eax # passo esp
    movl lines, %ebx # passo num linee
    call edf
    movl %eax, riga_da_printare # risultato in riga_da_printare

    jmp stampa # FINE EDF

algoritmo_hpf:
    # scelta HPF
    movl %esp, %eax # passo esp
    movl lines, %ebx # passo num linee
    call hpf
    movl %eax, riga_da_printare # risultato in riga_da_printare

    # FINE HPF

stampa: # STAMPA RIGA SCELTA DA ALGORITMO
    # controllo se devo stampare a video o su file
    movl secondfile, %eax
    cmpl $1, %eax
    je stampa_file

    # ----------------- STAMPA A VIDEO -----------------
    # stampa identificativo
    movl riga_da_printare, %eax
    movl slottemporali, %ebx
    leal output_algoritmo, %ecx
    call printvideo
    # output_algoritmo da stampare lenght in edx (stringa gia' modificata da funzione)
    movl $4, %eax
    movl $1, %ebx
    leal output_algoritmo, %ecx
    int $0x80

    #  AUMENTO SLOT TEMPORALI
    movl riga_da_printare, %eax
    movl $2, %ebx
    call revert # HO LA DURATA IN EAX
    addl slottemporali, %eax
    movl %eax, slottemporali

    # --------------- CALCOLO PENALITA' ---------------
    movl riga_da_printare, %eax  # 32bit riga stampata
    movl $3, %ebx # prendo scadenza
    call revert  # scadenza in eax
    movl slottemporali, %edx 
    subl %edx, %eax # slot temporali - scadenza -> risultato in eax
    cmpl $0, %eax 
    # se il risultato e' positivo quelli sono i giorni di ritardo passati
    jle skip_penalty # se non sono in ritardo, salto calcolo penalita'
                     # se eax e' minore o uguale di zero salta

    # quindi li moltiplico per la priorita'

    movl %eax, %edx # uso edx (siccome non lo usa revert)
    # sposto i giorni di ritardo in edx
    movl riga_da_printare, %eax
    movl $4, %ebx # prendo priorita'
    call revert

    mulb %dl # moltiplico il tempo di ritardo per la penalita'
    # priorita' * edx (giorni di ritardo) -> risultato in eax
    
    # lo sommo alla penalita' totale
    addl penalty, %eax
    movl %eax, penalty
    # e lo aggiorno in memoria

skip_penalty:
    # DECREMENTO IL NUM DI GIRI ALGORITMO (PERCHE' HO 'TOLTO' UNA LINEA DA CONTROLLARE)
    decw giri_algoritmo

    jmp ricomincia

stampa_file: # STAMPA RIGA SU FILE DA ALGORITMO EDF
    

ricomincia:
    # pulisco stringa di output

reset_output_algoritmo: # PULIZIA STRINGA 
    movl $10, %ecx
    movl $output_algoritmo, %ebx
resetoutput_algoritmo_loop:
    movb $0, (%ebx)
    incl %ebx
    loop resetoutput_algoritmo_loop

    # se ci sono ancora righe da stampare 
    movl giri_algoritmo, %eax
    cmpl $0, %eax
    jne scelta_algoritmo

    # altrimenti restarto l'algoritmo, dopo la stampa delle ultime righe
    # stampa Conclusione:
    movl $4, %eax 
    movl $0, %ebx
    leal conclusione, %ecx
    movl conclusione_len, %edx
    int $0x80

    movl slottemporali, %eax
    call printfd

    # stampa Penalty: 
    movl $4, %eax 
    movl $0, %ebx
    leal badString, %ecx
    movl badString_len, %edx
    int $0x80

    movl penalty, %eax
    call printfd

# restart_algoritmo:
    # DEVO PULIRE LO STACK DALLE LINEE CHE AVEVO INSERITO
    movl lines, %ecx

pulisci_stack:
    popl %eax
    loop pulisci_stack

    # azzero le var per ricominciare
    movl $0, lines
    movl $0, slottemporali
    movl $0, penalty

    jmp apriFile # ricomincio rileggendo il file

exit_erroreFile: # MESSAGGI DI ERRORE
    movl $4, %eax
    movl $1, %ebx
    leal erroreFile, %ecx
    movl erroreFile_len, %edx
    int $0x80
    jmp exit

exit_zeroFile: 
    movl $4, %eax
    movl $1, %ebx
    leal zeroFile, %ecx
    movl zeroFile_len, %edx
    int $0x80
    jmp exit

exit_troppiFile:
    movl $4, %eax
    movl $1, %ebx
    leal troppiFile, %ecx
    movl troppiFile_len, %edx
    int $0x80

exit: # CHIUSURA PROGRAMMA
    movl $1, %eax 
    xorl %ebx, %ebx # codice di uscita (0)
    int $0x80

