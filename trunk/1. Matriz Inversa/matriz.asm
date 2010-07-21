.data
	newl:		.asciiz "\n"
	tab:		.asciiz "\t"
	m1:			.asciiz "Digite o n�mero de linhas"
	m2:			.asciiz "Digite o n�mero de colunas"
	m3: 		.asciiz "Digite um n�mero da matriz" 
	failure:	.asciiz "You fail"
.text
.globl main
main:
	jal escreve_matriz
	
	jal imprime_matriz
	
	jal gauss
	
	# Sai do programa
	li $v0, 10
	syscall

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
	jr $ra

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
	
	jr $ra

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
	sub $sp, $sp, $t3							#volta ao primeiro valor da matriz
	la $s0, 0($sp)								#armazena o endere�o do primeiro valor da matriz
	
	# Cria a matriz identidade
	# Carrega o zero em $f0
	add $t5, $zero, $zero
	mtc1 $t5, $f0
	cvt.d.w $f0, $f0
	# Carrega o um em $f2
	addi $t5, $zero, 1
	mtc1 $t5, $f2
	cvt.d.w $f2, $f2
	
	sub $sp, $sp, $t3							#abre na pilha t3 espa�os
	la $s1, 0($sp)								#armazena o endere�o do primeiro valor da matriz identidade
	add $t4, $zero, $zero						#zero contador da linha
for_ident_r:
	beq $t4, $t0, fim_ident_r
	add $t5, $zero, $zero						#zera contador da coluna
for_ident_c:
	beq $t5, $t0, fim_ident_c
	mov.d $f4, $f2								#carrega 1 em $f4
	beq $t4, $t5, ident_save					#testa se o nro da linha � igual ao da coluna
	mov.d $f4, $f0								#carrega 0 em $f4
ident_save:
	sdc1 $f4, 0($sp)							#guarda o valor na pilha
	addi $sp, $sp, 8							#incrementa pilha
	addi $t5, $t5, 1							#coluna = coluna + 1
	j for_ident_c
fim_ident_c:
	addi $t4, $t4, 1							#linha = linha + 1
	j for_ident_r
fim_ident_r:
	#jr $ra
	#j imprime_matriz
#saindo dessa fun��o temos na mem�ria a matriz original e a matriz identidade de mesma ordem na mem�ria
	
augmented:
	sub $sp, $sp, $t3							#volta ao primeiro valor da matriz identidade
	sll $t4, $t3, 2
	sub $sp, $sp, $t4							#abre + 2 vezes o tamanho da matriz para a matriz aumentada
	la $s2, 0($sp)								#armazena o endere�o do primeiro valor da matriz aumentada
	
	#Parte 1 para carregar a matriz aumentada
	add $t4, $zero, $zero						#zera o contador auxiliar
	add $t5, $zero, $zero						#zera o contador da linha
for_aug1_r:
	beq $t5, $t0, fim_aug1_r
	add $t6, $zero, $zero						#zera o contador da coluna
for_aug1_c:
	beq $t6, $t0, fim_aug1_c
	mul $t7, $t5, $t0
	add $t7, $t7, $t6							#elemento = linha*nro_colunas + coluna
	sll $t7, $t7, 3
	add $t7, $s0, $t7
	ldc1 $f0, 0($t7)							#carrega valor da matriz em f0
	add $t7, $t4, $t6
	sll $t7, $t7, 3
	add $t7, $s2, $t7
	sdc1 $f0, 0($t7)
	addi $t6, $t6, 1
	j for_aug1_c
fim_aug1_c:
	addi $t5, $t5, 1
	sll $t7, $t0, 1
	add $t4, $t4, $t7							#pula n elementos
	j for_aug1_r
fim_aug1_r:
	#jr $ra
	
	# ldc1 $f12, 0($sp)							#carrega valor em f12
	# li $v0, 3									#imprime valor
	# syscall
	# li $v0, 4									#carrega string
	# la $a0, newl								#Pula linha
	# syscall
	#Parte 2 para carregar a matriz aumentada
	add $t4, $zero, $zero						#zera o contador auxiliar
	add $t5, $zero, $zero						#zera o contador da linha
for_aug2_r:
	beq $t5, $t0, fim_aug2_r
	add $t6, $zero, $t0							#zera o contador da coluna
for_aug2_c:
	sll $t7, $t0, 1
	beq $t6, $t7, fim_aug2_c					#vai at� 2*n
	mul $t7, $t5, $t0
	add $t7, $t7, $t6							#elemento = linha*nro_colunas + coluna
	sub $t7, $t7, $t0
	sll $t7, $t7, 3
	add $t7, $s1, $t7
	ldc1 $f0, 0($t7)							#carrega valor da matriz em f0
	add $t7, $t4, $t6
	sll $t7, $t7, 3
	add $t7, $s2, $t7
	sdc1 $f0, 0($t7)
	addi $t6, $t6, 1
	j for_aug2_c
fim_aug2_c:
	addi $t5, $t5, 1
	sll $t7, $t0, 1
	add $t4, $t4, $t7							#pula n elementos
	j for_aug2_r
fim_aug2_r:
	#jr $ra
	add $t4, $zero, $zero
for_x_r:
	beq $t4, $t0, fim_x_r
	add $t5, $zero, $zero
for_x_c:
	sll $t6, $t0, 1
	beq $t5, $t6, fim_x_c
	mul $t7, $t4, $t6
	add $t7, $t7, $t5							#elemento = linha*nro_colunas + coluna
	sll $t7, $t7, 3
	add $t7, $s2, $t7
	ldc1 $f12, 0($t7)							#carrega valor da matriz em f0
	li $v0, 3
	syscall
	addi $t5, $t5, 1
	j for_x_c
fim_x_c:
	addi $t4, $t4, 1
	#mov.d $f12, $f0
	#li $v0, 3									#imprime valor
	#syscall
	#li $v0, 4									#carrega string
	#la $a0, newl								#Pula linha
	#syscall
	li $v0, 4
	la $a0, newl
	syscall
	j for_x_r
fim_x_r:
	jr $ra
	

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
