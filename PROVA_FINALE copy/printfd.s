# converte il contenuto di eax in un ascii intero, e lo stampa
# il numero da stampare deve essere messo in EAX
# EBX contiene il dove stampare (0 = a video, il resto viene inteso con file descriptor)

.section .data
car:
	.byte 0

printfd_fd: .int 0

.section .text
	.global printfd

.type printfd, @function

printfd:
	movl $0, %ecx              # azzera il contatore ECX
	movl %ebx, printfd_fd

continua_a_dividere:

	cmpl $10, %eax
	jge dividi

	pushl %eax
	incl %ecx

	movl %ecx, %ebx
	jmp stampa

dividi:
	movl $0, %edx
	movl $10, %ebx
	divl %ebx

	pushl %edx
	incl %ecx
	jmp continua_a_dividere

stampa:
	cmpl $0, %ebx
	
	je fine_itoa
	popl %eax
	movb %al, car 
	addb $48, car 

	decl %ebx
	pushw %bx

	movl $4, %eax
	movl printfd_fd, %ebx
	leal car, %ecx
	movl $1, %edx
	int $0x80

	popw %bx
	jmp stampa

fine_itoa:
	movb $10, car 

	movl $4, %eax
	movl printfd_fd, %ebx
	leal car, %ecx
	movl $1, %edx
	int $0x80

	ret

