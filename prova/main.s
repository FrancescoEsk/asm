# namefile: prova.s


.section .data

richiesta:
.ascii "Inserire numero:"
richiesta_len:
.long . - richiesta



num_str:   # variabile STRINGA per numero letto da tastiera
.ascii "0000"
num_str_len:
.long . - num_str

.section .text
.global _start

_start:

stampa_richiesta:
  movl $4, %eax             # chiamo la WRITE per scrivere "Inserire numero" contenuto nell'etichetta richiesta
  movl $1, %ebx             # esco dalla syscall
  leal richiesta, %ecx      
  movl richiesta_len, %edx
  int $0x80

inserimento:
  #scanf
  movl $3, %eax             # chiamo la READ per leggere
  movl $1, %ebx
  leal num_str, %ecx
  movl num_str_len, %edx
  incl %edx                 # incrementa di uno per farci stare anche il /n (quando dichiaro una dimensione per array di char nella dimensione e' incluso il /n [dim 50 = max 49 char])
  int $0x80

atoi_num:  				

  leal num_str, %esi 		# metto indirizzo della stringa in esi 


  xorl %eax,%eax			# Azzero registri General Purpose
  xorl %ebx,%ebx           
  xorl %ecx,%ecx           
  xorl %edx,%edx
  


ripeti:
  movb (%ecx,%esi,1), %bl   # prende cio' a cui punta il contenuto nelle parentesi

  cmp $10, %bl              # vedo se e' stato letto il carattere '\n'
  je stampa_intero

  subb $48, %bl             # converte il codice ASCII della cifra nel numero corrisp.
  movl $10, %edx            # sposta il valore 10 nel registro EDX
  mulb %dl                  # EBX = EBX * 10 (mul = eax * il registro che passo)
  addl %ebx, %eax           # somma a EAX il valore contenuto in EBX (quindi EAX alla fine conterra' il numero convertito dalla stringa)

  inc %ecx
  jmp ripeti


# stampa il valore in eax
stampa_intero:
  


  call printfd



exit:
  movl $1,%eax
  movl $0,%ebx
  int $0x080

