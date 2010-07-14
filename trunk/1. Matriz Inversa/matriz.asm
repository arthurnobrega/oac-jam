.data
	newl:		.asciiz "\n"
	tab:		.asciiz "\t"
	m1:			.asciiz "Digite o n�mero de linhas"
	m2:			.asciiz "Digite o n�mero de colunas"
	m3: 		.asciiz "Digite um n�mero da matriz" 
	failure:	.asciiz "You fail"
.text

escreve_matriz:
	li $v0, 4
	la $a0, m1									#imprime string
	syscall
	li $v0, 5
	syscall										#valor do n�mero de linhas
	add $t0, $v0, $zero							#t0 = n� de linhas
	li $v0, 4
	la $a0, m2									#imprime string
	syscall
	li $v0, 5									#valor do n�mero de colunas
	syscall
	add $t1, $v0, $zero							#t1 = n� de colunas
	mul $t2, $t1, $t0							#t2 = n� de termos
	add $t3, $t2, $t2
	add $t3, $t3, $t3							#t3 = 4*t2 (utilizado para abrir espa�o na pilha)
	add $t3, $t3, $t3							#t3 = 8*t2
	sub $sp, $sp, $t3							#abre na pilha t3 espa�os
	add $t5, $zero, $zero						#t5 = contador (zerando)
loop:
	li $v0, 4
	la $a0, m3									#imprime string
	syscall
	li $v0, 7
	syscall										#valor dos termos
	addi $t5, $t5, 1							#contador = contador + 1
	sdc1 $f0, 0($sp)							#guarda o valor na pilha
	addi $sp, $sp, 8							#incrementa pilha
	bne $t2, $t5, loop							#contador != n� de termos? (1) volte ao loop; (0) continue

imprime_matriz:
	add $t5, $zero, $zero						#zera contador prim�rio
	add $t6, $zero, $zero						#zera contador secund�rio
	sub $sp, $sp, $t3							#volta ao primeiro valor da pilha
loop2:
	ldc1 $f12, 0($sp)							#carrega valor em f12
	li $v0, 3									#imprime valor
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	addi $sp, $sp, 8							#incremento para o pr�ximo elemento da pilha
	addi $t5, $t5, 1							#incrementa contador prim�rio
	addi $t6, $t6, 1							#incrementa contador secund�rio
	bne $t6, $t1, loop2							#cont. secund�rio != n� colunas?
	add $t6, $zero,$zero						#zera cont. secund�rio
	li $v0, 4									#carrega string
	la $a0, newl								#Pula linha
	syscall
	bne $t5, $t2, loop2							#cont. prim�rio = n� de termos?

	li $v0, 4									#carrega string
	la $a0, newl								#Pula linha
	syscall

det_matriz:
	add $t5, $zero, $zero						#contador = 0
	add $t6, $zero, $zero						#cont. linha inicial = 0
	add $t8, $t1, $zero							#cont. qual linha
	div $t7, $t3, $t1							#termos em uma linha
	add $t9, $zero, $zero						#checar se excedeu o n�mero de linhas
	sub $sp, $sp, $t7							#volta ao come�o da matriz
	mtc1 $t8, $f2								#move int pra double
	cvt.d.w $f2, $f2							#converte n� para double
	controle: ldc1 $f6, 0($sp)					#carrega o termo da pilha
	c.eq.d 1,$f6, $f8							#checa se o termo = 0 e armazena na flag 1
	bc1t 1, troca								#chega se flag 1 = 0
	j go_on										#pulo para continuar m�todo
	troca: add $sp, $sp, $t7					#vai para a pr�xima linha da pilha
	addi $t6, $t6, 1							#contador da linha = linha +1
	slt $t9, $t0, $t6							#n�mero de linhas excedido?
	beq $t9, $zero, fail						#primeira linha feita de zeros -> det = 0
	j controle									#teste a pr�xima linha

go_on:
	beq $t6, $t8, primeira_linha

primeira_linha: 

inverte_matriz:
	sub $sp, $sp, $t3							#come�o da matriz
	sub $sp, $sp, $t3							#abre t2 mais termos na matriz
	add $t5, $zero, $zero						#zera cont.1 (n� de termos)
	addi $t6, $zero, 0							#zera cont.2 (qual elemento da linha?)
	addi $t7, $zero, 0							#zera cont.3 (qual elemento da coluna?)
	add $t8, $zero, $zero						#zera cont.4
	addi $t8, $t8, 1							#1 em cont.4(para passar 1 pro float)
	mtc1 $t8, $f2								#move int pra double
	cvt.d.w $f2, $f2							#converte n� para double
	mtc1 $t5, $f4								#move int pra double
	cvt.d.w $f4, $f4							#converte n� para double
loop3:
	sdc1 $f4, 0($sp)							#armazena 0 no termo
	addi $t5, $t5, 1							#incrementa cont. 1
	beq $t6, $t7, arruma						# i = j? vai pro m�todo arruma
	continua: 									
	addi $sp, $sp, 8							#incrementa pilha
	addi $t6, $t6, 1							#incrementa cont. 2
	bne $t6, $t1, loop3							#elemento linha = �ltimo?
	add $t6, $zero, $zero 						#zera contador termo linha
	addi $t7, $t7, 1							#pr�xima linha
	bne $t5, $t2, loop3							#cont. = �ltimo termo?
	j parte2									#avan�a para o m�todo seguinte de invers�o
	arruma: sdc1 $f2, 0($sp)					#armazena 1 no termo (ao �nves do antigo 0 )
	j continua									#volta para o m�todo continua

parte2: 									#imprime a identidade da ordem equivalente da matriz inicial
	add $t5, $zero, $zero						#zera contador prim�rio
	add $t6, $zero, $zero						#zera contador secund�rio
	sub $sp, $sp, $t3							#volta ao primeiro valor da pilha
loop4:
	ldc1 $f12, 0($sp)							#carrega valor em f12
	li $v0, 3									#imprime valor
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	addi $sp, $sp, 8							#incremento para o pr�ximo elemento da pilha
	addi $t5, $t5, 1							#incrementa contador prim�rio
	addi $t6, $t6, 1							#incrementa contador secund�rio
	bne $t6, $t1, loop4							#cont. secund�rio != n� colunas?
	add $t6, $zero,$zero						#zera cont. secund�rio
	li $v0, 4									#carrega string
	la $a0, newl								#Pula linha
	syscall
	bne $t5, $t2, loop4							#cont. prim�rio = n� de termos?

	li $v0, 4									#carrega string
	la $a0, newl								#Pula linha
	syscall

	add $t5, $zero, $zero						#cont. prim�rio = 0
	add $t6, $zero, $zero						#linha = 0
	add $t7, $zero, $zero						#coluna = 0
	add $t8, $zero, $zero						#cont. secund�rio = 0
	add $t9, $zero, $zero						#n�o sei, mas vai usar com certeza = 0

## a0 deve ser o in�cio da matriz
## a1 deve ser o n�mero de linhas (o n�mero de colunas tem que ser o de linhas + 1)
gauss:
	j fim #n�o entrando aqui por enquanto
	add $t4, $zero, $zero						#contador da linha

## a0 deve ser o in�cio da matriz
## a1 deve ser o n�mero de linhas (o n�mero de colunas tem que ser o de linhas + 1)
## a2 deve ser a linha do piv� candidato (come�ando de zero)
verifica_pivo:
	addi $s0, $a1, 1							#armazena o n�mero de colunas (linhas + 1)
	mul $s1, $a1, $s0							#linhas*colunas = n�mero de termos
	sub $a0, $a0, $s1							#volta ao primeiro valor da pilha
	add $t5, $zero, $a2							#seta nova linha para a linha do pivo
	addi $t6, $t5, 1							#seta o in�cio dos testes para uma linha abaixo da do piv�
	
	mul $t8, $t5, $s0
	add $t8, $t8, $a2							#pega o candidato a piv�
	sll $t8, $t8, 3								#multiplica por 8
	add $t8, $a0, $t8							#pega o endere�o do valor
	ldc1 $f0, 0($t8)							#pega o valor
	
pivo_for:
	sub $t7, $a1, $t6							#subtrai o n�mero de linhas do n�mero da linha
	slti $t7, $t7, 1							#verifica se o resultado acima � menor que 1
	bne $t7, $zero, pivo_fim
	
	mul $t8, $t6, $s0
	add $t8, $t8, $a2							#pega o candidato a piv�
	sll $t8, $t8, 3								#multiplica por 8
	add $t8, $a0, $t8							#pega o endere�o do valor
	ldc1 $f2, 0($t8)							#pega o valor
	
	c.lt.d 0, $f0, $f2
	bc1f 0, pivo_continua						#verifica se o valor � maior que o do piv� candidato
	add $t5, $zero, $t6							#troca a linha do piv�
pivo_continua:
	addi $t6, $t6, 1							#incrementa o contador
	j pivo_for
	
pivo_fim:
	#TESTAR SE O NOVO PIVO � DIFERENTE DE $a2

pivo_return:
	jr $ra

## a0 deve ser o in�cio da matriz
## a1 deve ser o n�mero de linhas (o n�mero de colunas tem que ser o de linhas + 1)
## a2 deve ser a linha1
## a3 deve ser a linha2
troca_linhas:
	

fail: 
	li $v0, 4
	la $a0, failure								#imprime string
	syscall

fim: 
