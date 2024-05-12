# FUNZIONE CHE LEGGERE IL FILE FORNITO DA RIGA DI COMANDO
.section .data

strError:
    .ascii "Errore --> file non fornito o troppi file forniti\n"
strError_len:
    .long . - strError

.section .text
.global readf

.type readf, @function

readf:
    popl %eax # num parametri passato da riga di comando

    cmpl $2, %eax # se ha passato solo il file degli ordini
    je leggiFile

    cmpl $3, %eax # se ha passato anche il file bonus
    je bonus

    jmp errore # non sono stati passati file oppure sono stati passati troppi file

leggiFile: # lettura file ordini
    
    jmp fine

bonus:

    jmp fine

errore:
    movl $4, %eax
	movl $1, %ebx
	leal strError, %ecx
	movl strError_len, %edx
	int $0x80

fine:

    ret
