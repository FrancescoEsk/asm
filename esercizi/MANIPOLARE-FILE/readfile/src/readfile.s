.section .data
filename:
    .ascii "test.txt"    # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor 

buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea (\n) = 10 IN ASCII
lines: .int 0            # Numero di linee (aumento +1 quando trovo il carattere \n, per indicare che ho letto una riga)

.section .bss

.section .text
    .globl _start

# Apre il file
_open:
    mov $5, %eax        # syscall open
    mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # in %eax ho il risultato, può essere di due tipi: 
    # errore, quindi un numero negativo
    # il fd, quindi positivo

    # Se c'è un errore (negativo), esce
    cmp $0, %eax
    jl _exit

    mov %eax, fd      # Salva il file descriptor in ebx

# Legge il file riga per riga
_read_loop:
    mov $3, %eax        # syscall read
    mov fd, %ebx        # File descriptor al posto di 0
    mov $buffer, %ecx   # Buffer di input - quello che leggo lo metto nel buffer
    mov $1, %edx        # Lunghezza massima - un carattere alla volta
    int $0x80           # Interruzione del kernel

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle _close_file     # Se ci sono errori o EOF, chiudo il file
    
    # Controllo se ho una nuova linea
    movb buffer, %al    # copio il carattere dal buffer ad AL
    cmpb newline, %al   # confronto AL con il carattere \n
    jne _print_line     # se sono diversi stampo la linea
    incw lines          # altrimenti, incremento il contatore di linee del file che sto leggendo

_print_line:
    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov $1, %ebx        # File descriptor standard output (stdout)
    mov $buffer, %ecx   # Buffer di output
    int $0x80           # Interruzione del kernel

    jmp _read_loop      # Torna alla lettura del file

# Chiude il file quando ho finito di usarlo
_close_file:
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor (presente in ebx, lo metto in ecx)
    int $0x80           # Interruzione del kernel

_exit:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel

_start:
    jmp _open          # Chiama la funzione per aprire il file

    # Fine programma
    jmp _exit

