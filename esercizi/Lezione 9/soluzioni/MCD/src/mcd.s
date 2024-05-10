.section .data

richiesta1:
.ascii "Inserire primo numero:"
richiesta1_len:
.long . - richiesta1


richiesta2:
.ascii "Inserire secondo numero:"
richiesta2_len:
.long . - richiesta2


num1_str:		# variabile STRINGA per num1 (a)
.ascii "000000"
num1_str_len:
.long . - num1_str

num2_str:		# variabile STRINGA per num2 (b)
.ascii "000000"
num2_str_len:
.long . - num2_str



num1_int:		# variabile INTERA per num1 (a).
.long 0 		# Il valore di num1 viene salvato qui dopo averne fatto la conversione da stringa a intero.

num2_int:		# variabile INTERA per num2 (b)
.long 0 		# Il valore di num2 viene salvato qui dopo averne fatto la conversione da stringa a intero.

.section .text
.global _start



_start:
#-----------------------------------
#-----------------------------------
# LETTURA VALORI DA TERMINALE
#-----------------------------------
#-----------------------------------
stampa_richiesta1:
  movl $4, %eax
  movl $1, %ebx
  leal richiesta1, %ecx
  movl richiesta1_len, %edx
  int $0x80

inserimento1:
  #scanf
  movl $3, %eax
  movl $1, %ebx
  leal num1_str, %ecx
  movl num1_str_len, %edx
  incl %edx
  int $0x80


stampa_richiesta2:
  movl $4, %eax
  movl $1, %ebx
  leal richiesta2, %ecx
  movl richiesta2_len, %edx
  int $0x80


inserimento2:
  #scanf
  movl $3, %eax
  movl $1, %ebx
  leal num2_str, %ecx
  movl num2_str_len, %edx
  incl %edx
  int $0x80


#-----------------------------------
#-----------------------------------
# CONVERSIONE STRINGA INTERO
#-----------------------------------
#-----------------------------------

#----------------------
# Conversione num1 
# Da Stringa a Intero!
#----------------------

atoi_num1:  				

  leal num1_str, %esi 		# metto indirizzo della stringa in esi 


  xorl %eax,%eax			# Azzero registri General Purpose
  xorl %ebx,%ebx           
  xorl %ecx,%ecx           
  xorl %edx,%edx
  


ripeti1:

  movb (%ecx,%esi,1), %bl

  cmp $10, %bl             # vedo se e' stato letto il carattere '\n'
  je fine_atoi1

  subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
  movl $10, %edx
  mulb %dl                # EBX = EBX * 10
  addl %ebx, %eax

  inc %ecx
  jmp ripeti1


fine_atoi1:
		
	movl %eax,num1_int	#salvo il valore nella variabile num1_int

#----------------------
# Conversione num2 
# Da Stringa a Intero!
#----------------------


atoi_num2:  				

  leal num2_str, %esi 		# metto indirizzo della stringa in esi 


  xorl %eax,%eax			# Azzero registri General Purpose
  xorl %ebx,%ebx           
  xorl %ecx,%ecx           
  xorl %edx,%edx


ripeti2:

  movb (%ecx,%esi,1), %bl

  cmp $10, %bl             # vedo se e' stato letto il carattere '\n'
  je fine_atoi2

  subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
  movl $10, %edx
  mulb %dl                 # EBX = EBX * 10
  addl %ebx, %eax

  inc %ecx
  jmp ripeti2


fine_atoi2:
		
	movl %eax,num2_int	# salvo il valore nella variabile num2_int


#-----------------------------------
#-----------------------------------
# MCD
#-----------------------------------
#-----------------------------------


MCD:				# i valori sono salvati rispettivamente su eax ed ebx

	movl num1_int,%eax
	movl num2_int,%ebx
	
	cmpl $0,%eax		# prima parte primo if (a==0)
	jne primo_else 		# se a!=0 vai all'else
		cmpl $0,%ebx	# se a==0 allora  procedi con la seconda parte (b==0)
	jne primo_else		# se b!=0 allora vai all'else
		movl $1,%ebx	# se a==0 e b==0 allora b=1
		jmp fine		# vai direttamente alla fine (return b)


	primo_else:
		cmpl $0,%ebx		# if b==0
		jne secondo_else	# se b!=0 vai al relativo else
		movl %eax,%ebx		# se b==0 --> b=a
		jmp fine			# salta direttamente alla fine 
	
	
	secondo_else:			# else if (a!=0)
		cmpl $0,%eax		# if a!=0
		je fine 			# se a==0 vai direttamente alla fine
	
		ciclo:
			cmpl %eax,%ebx	# while(a!=b)
			je fine
			cmpl %ebx,%eax  # if (a<b)
			jge terzo_else		
				subl %eax,%ebx
	
			jmp ciclo		#chiusura ciclo while
			
			terzo_else:		#   a>=b
				subl %ebx,%eax
				jmp ciclo		# chiusura ciclo while



fine:
	movl %eax,%ecx 	# salvo il risultato. per testarlo e vedere il risultato usate gdb
					# fissate un breakpoint qui, lanciate step e poi info registers.
	movl $1,%eax	
	xorl %ebx,%ebx
	int $0x80
