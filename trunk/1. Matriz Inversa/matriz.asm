.data
	newl:			.asciiz "\n"
	tab:			.asciiz "\t"
	m1:				.asciiz "Digite o número de linhas"
	m2:				.asciiz "Digite o número de colunas"
	m3: 			.asciiz "Digite um número da matriz" 
	failure:		.asciiz "You fail"
	notinversible:	.asciiz "Matrix not inversible!"
.text
.globl main
main:
	jal le_matriz
	lw $s0, 0($v0)			#endereço M1
	lw $s1, 4($v0)			#linhas M1
	lw $s2, 8($v0)			#colunas M1
	
	jal le_matriz
	lw $s3, 0($v0)			#endereço M2
	lw $s4, 4($v0)			#linhas M2
	lw $s5, 8($v0)			#colunas M2
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal imprime_matriz
	
	move $a0, $s3
	move $a1, $s4
	move $a2, $s5
	jal imprime_matriz
	
	#jal gauss
	
	subi $sp, $sp, 24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	jal mult_matrizes
	
	move $a0, $sp
	move $a1, $s1
	move $a2, $s5
	jal imprime_matriz
	
	# Sai do programa
	li $v0, 10
	syscall

le_matriz:
	li $v0, 4
	la $a0, m1									#imprime string
	syscall
	li $v0, 5
	syscall										#valor do número de linhas
	add $t0, $v0, $zero							#t0 = nº de linhas
	li $v0, 4
	la $a0, m2									#imprime string
	syscall
	li $v0, 5									#valor do número de colunas
	syscall
	add $t1, $v0, $zero							#t1 = nº de colunas
	mul $t2, $t1, $t0							#t2 = nº de termos
	sll $t3, $t2, 3
	sub $sp, $sp, $t3							#abre na pilha t3 espaços
	move $t6, $sp
	add $t5, $zero, $zero						#t5 = contador (zerando)
loop:
	li $v0, 4
	la $a0, m3									#imprime string
	syscall
	li $v0, 7
	syscall										#valor dos termos
	addi $t5, $t5, 1							#contador = contador + 1
	sdc1 $f0, 0($t6)							#guarda o valor na pilha
	addi $t6, $t6, 8							#incrementa pilha
	bne $t2, $t5, loop							#contador != nº de termos? (1) volte ao loop; (0) continue
	
	move $t6, $sp
	subi $sp, $sp, 12
	sw $t6, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	move $v0, $sp
	jr $ra

	# início da matriz em a0, nro linha em a1 e nro colunas em a2
imprime_matriz:
	move $t0, $a0
	move $t2, $a1
	move $t3, $a2
	add $t5, $zero, $zero						#zera contador primário
	add $t6, $zero, $zero						#zera contador secundário
	mul $t2, $t1, $t2
loop2:
	ldc1 $f12, 0($t0)							#carrega valor em f12
	li $v0, 3									#imprime valor
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	addi $t0, $t0, 8							#incremento para o próximo elemento da pilha
	addi $t5, $t5, 1							#incrementa contador primário
	addi $t6, $t6, 1							#incrementa contador secundário
	bne $t6, $a2, loop2							#cont. secundário != nº colunas?
	add $t6, $zero,$zero						#zera cont. secundário
	li $v0, 4									#carrega string
	la $a0, newl								#Pula linha
	syscall
	bne $t5, $t2, loop2							#cont. primário = nº de termos?

	li $v0, 4									#carrega string
	la $a0, newl								#Pula linha
	syscall
	
	jr $ra

## a0 deve ser o início da matriz
## a1 deve ser o número de linhas (o número de colunas tem que ser o de linhas + 1)
gauss:
	sub $sp, $sp, $t3							#volta ao primeiro valor da matriz
	la $s0, 0($sp)								#armazena o endereço do primeiro valor da matriz
	
	# Cria a matriz identidade
	# Carrega o zero em $f0
	add $t5, $zero, $zero
	mtc1 $t5, $f0
	cvt.d.w $f0, $f0
	# Carrega o um em $f2
	addi $t5, $zero, 1
	mtc1 $t5, $f2
	cvt.d.w $f2, $f2
	
	sub $sp, $sp, $t3							#abre na pilha t3 espaços
	la $s1, 0($sp)								#armazena o endereço do primeiro valor da matriz identidade
	add $t4, $zero, $zero						#zero contador da linha
for_ident_r:
	beq $t4, $t0, fim_ident_r
	add $t5, $zero, $zero						#zera contador da coluna
for_ident_c:
	beq $t5, $t0, fim_ident_c
	mov.d $f4, $f2								#carrega 1 em $f4
	beq $t4, $t5, ident_save					#testa se o nro da linha é igual ao da coluna
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
#saindo dessa função temos na memória a matriz original e a matriz identidade de mesma ordem na memória


# INÍCIO DA INVERSA
augmented:
	sub $sp, $sp, $t3							#volta ao primeiro valor da matriz identidade
	sll $t4, $t3, 2
	sub $sp, $sp, $t4							#abre + 2 vezes o tamanho da matriz para a matriz aumentada
	la $s2, 0($sp)								#armazena o endereço do primeiro valor da matriz aumentada
	
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
	beq $t6, $t7, fim_aug2_c					#vai até 2*n
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
	
	#Pivoteamento e troca de linhas
	add $t4, $zero, $zero						#zera contador de loops
for_echelon1:
	sub $t9, $t0, 1
	beq $t4, $t9, fim_echelon1
	add $t5, $zero, $t4							#inicializa contador da linha
for_echelon1_r:
	beq $t5, $t0, fim_echelon1_r
	add $t6, $zero, $t5							#inicializa o testador do pivo
	add $t7, $zero, $t5							#inicializa a coluna atual
for_echelon1_c:
	beq $t7, $t0, fim_echelon1_c
	
	#Carrega o temp
	sll $t8, $t0, 1
	mul $t8, $t6, $t8
	add $t8, $t8, $t4							#elemento = linha*nro_colunas + coluna
	sll $t8, $t8, 3
	add $t8, $s2, $t8
	ldc1 $f0, 0($t8)							#temp
	
	#Carrega o candidato a pivo
	sll $t9, $t0, 1
	mul $t9, $t7, $t9
	add $t9, $t9, $t4							#elemento = linha*nro_colunas + coluna
	sll $t9, $t9, 3
	add $t9, $s2, $t9
	ldc1 $f2, 0($t9)							#m[i][j]
	
	c.lt.d $f0, $f2
	bc1f echelon1_c_cont
	add $t6, $zero, $t7
echelon1_c_cont:
	addi $t7, $t7, 1
	j for_echelon1_c
fim_echelon1_c:
	add $t7, $zero, $zero						#zera o contador da coluna atual
for_swap:
	sll $t8, $t0, 1
	beq $t7, $t8, fim_swap
	
	#Carrega o valor do novo pivo
	sll $t8, $t0, 1
	mul $t8, $t5, $t8
	add $t8, $t8, $t7							#elemento = linha*nro_colunas + coluna
	sll $t8, $t8, 3
	add $t8, $s2, $t8
	ldc1 $f0, 0($t8)							#temp
	
	#Troca o valor da coluna
	sll $t9, $t0, 1
	mul $t9, $t6, $t9
	add $t9, $t9, $t7							#elemento = linha*nro_colunas + coluna
	sll $t9, $t9, 3
	add $t9, $s2, $t9
	ldc1 $f2, 0($t9)							#salva o valor temporariamente
	sdc1 $f2, 0($t8)							#salva o valor da coluna na que era do pivo
	sdc1 $f0, 0($t9)							#salva a coluna do novo pivo nesta
	
	addi $t7, $t7, 1
	j for_swap
fim_swap:
	addi $t5, $t5, 1
	j for_echelon1_r
fim_echelon1_r:

	
	
	#REDUCE ECHELON
	add $t5, $zero, $t4							#inicializa o contador da linha
for_reduce_r:
	sub $t6, $t0, 1
	beq $t5, $t6, fim_reduce_r
	
	#Carrega o valor do pivo
	sll $t6, $t0, 1
	mul $t6, $t4, $t6
	add $t6, $t6, $t4							#elemento = linha*nro_colunas + coluna
	sll $t6, $t6, 3
	add $t6, $s2, $t6
	ldc1 $f0, 0($t6)							#m[i][i]
	
	#CHECAR
	#Carrega o valor abaixo do pivo
	sll $t6, $t0, 1
	addi $t9, $t5, 1
	mul $t6, $t9, $t6
	add $t6, $t6, $t4							#elemento = linha*nro_colunas + coluna
	sll $t6, $t6, 3
	add $t6, $s2, $t6
	ldc1 $f2, 0($t6)							#m[i][(cur_row + 1)]
	
	#Calcula o fator
	div.d $f0, $f2, $f0
	add $t6, $zero, $t4							#inicializa o contador da coluna
for_reduce_c:
	sll $t7, $t0, 1
	beq $t6, $t7, fim_reduce_c
	
	#Carrega o valor do elemento da linha
	sll $t7, $t0, 1
	addi $t9, $t5, 1
	mul $t7, $t9, $t7
	add $t7, $t7, $t6							#elemento = linha*nro_colunas + coluna
	sll $t7, $t7, 3
	add $t7, $s2, $t7
	ldc1 $f2, 0($t7)							#m[cur_column][(cur_row + 1)]
	
	#Carrega o valor do elemento
	sll $t8, $t0, 1
	mul $t8, $t4, $t8
	add $t8, $t8, $t6							#elemento = linha*nro_colunas + coluna
	sll $t8, $t8, 3
	add $t8, $s2, $t8
	ldc1 $f4, 0($t8)							#m[cur_column][i]
	
	mul.d $f6, $f0, $f4
	sub.d $f8, $f2, $f6							#calcula L' = Lp*fator + L
	sdc1 $f8, 0($t7)
	
	addi $t6, $t6, 1
	j for_reduce_c
fim_reduce_c:
	addi $t5, $t5, 1
	j for_reduce_r
fim_reduce_r:

	#Testa se a matriz é inversível
	sll $t5, $t0, 1
	mul $t5, $t4, $t5
	add $t5, $t5, $t4							#elemento = linha*nro_colunas + coluna
	sll $t5, $t5, 3
	add $t5, $s2, $t5
	ldc1 $f0, 0($t5)							#m[cur_column][(cur_row + 1)]
	
	mtc1 $zero, $f2
	cvt.d.w $f2, $f2
	c.eq.d $f0, $f2
	bc1t fail2
	
	add $t4, $t4, 1
	j for_echelon1
fim_echelon1:

	
#REVERSE MATRIX
	subi $t4, $t0, 1							#inicializa o contador de loops
for_reverse1:
	beq $t4, $zero, fim_reverse1
	add $t5, $zero, $t4						#inicializa o contador de linhas
for_reverse1_r:
	beq $t5, $zero, fim_reverse1_r
	
	#Carrega o valor do m[i][i]
	sll $t6, $t0, 1
	mul $t6, $t4, $t6
	add $t6, $t6, $t4							#elemento = linha*nro_colunas + coluna
	sll $t6, $t6, 3
	add $t6, $s2, $t6
	ldc1 $f0, 0($t6)							#m[i][i]
	
	#Carrega o valor m[i][(cur_row - 1)]
	sll $t7, $t0, 1
	subi $t9, $t5, 1
	mul $t6, $t9, $t7
	add $t6, $t6, $t4							#elemento = linha*nro_colunas + coluna
	sll $t6, $t6, 3
	add $t6, $s2, $t6
	ldc1 $f2, 0($t6)							#m[i][(cur_row - 1)]
	
	#Calcula o fator
	div.d $f0, $f2, $f0							#f0 = fator
	
	
	add $t6, $zero, $t4							#inicializa o contador da coluna
for_reverse1_c:
	sll $t7, $t0, 1
	beq $t6, $t7, fim_reverse1_c
	
	#Carrega o valor do elemento da linha
	sll $t7, $t0, 1
	subi $t9, $t5, 1
	mul $t8, $t9, $t7
	add $t8, $t8, $t6							#elemento = linha*nro_colunas + coluna
	sll $t8, $t8, 3
	add $t8, $s2, $t8
	ldc1 $f2, 0($t8)							#m[cur_column][(cur_row - 1)]
	
	#Carrega o valor do elemento
	sll $t9, $t0, 1
	mul $t9, $t4, $t9
	add $t9, $t9, $t6							#elemento = linha*nro_colunas + coluna
	sll $t9, $t9, 3
	add $t9, $s2, $t9
	ldc1 $f4, 0($t9)							#m[cur_column][i]
	
	mul.d $f6, $f0, $f4
	sub.d $f8, $f2, $f6							#calcula
	sdc1 $f8, 0($t8)
	
	addi $t6, $t6, 1
	j for_reverse1_c
fim_reverse1_c:
	subi $t5, $t5, 1
	j for_reverse1_r
fim_reverse1_r:
	subi $t4, $t4, 1
	j for_reverse1
fim_reverse1:


	
	

#CANONICAL MATRIX
	add $t4, $zero, $zero						#inicializa o contador de linhas
for_canonical_r:
	beq $t4, $t0, fim_canonical_r
	
	#Carrega o valor do fator
	sll $t5, $t0, 1
	mul $t5, $t4, $t5
	add $t5, $t5, $t4							#elemento = linha*nro_colunas + coluna
	sll $t5, $t5, 3
	add $t5, $s2, $t5
	ldc1 $f0, 0($t5)
	
	add $t5, $zero, $t4							#inicializa o contador de colunas
for_canonical_c:
	sll $t6, $t0, 1
	beq $t5, $t6, fim_canonical_c
	
	#Carrega o valor do elemento
	sll $t6, $t0, 1
	mul $t6, $t4, $t6
	add $t6, $t6, $t5							#elemento = linha*nro_colunas + coluna
	sll $t6, $t6, 3
	add $t6, $s2, $t6
	ldc1 $f2, 0($t6)
	
	div.d $f4, $f2, $f0
	sdc1 $f4, 0($t6)							#armazena o valor do elemento/fator
	
	addi $t5, $t5, 1
	j for_canonical_c
fim_canonical_c:
	addi $t4, $t4, 1
	j for_canonical_r
fim_canonical_r:




#MATRIZ INVERSA
	#Abre espaço para a matriz inversa e salva em $s3
	move $sp, $s2
	sub $sp, $sp, $t3
	add $s3, $sp, $zero
	
	add $t4, $zero, $zero
for_inverse_r:
	beq $t4, $t0, fim_inverse_r
	add $t5, $zero, $zero
for_inverse_c:
	beq $t5, $t0, fim_inverse_c
	
	#Carrega o valor do elemento
	sll $t7, $t0, 1
	mul $t6, $t4, $t7
	add $t6, $t6, $t5							#elemento = linha*nro_colunas + coluna
	add $t6, $t6, $t0							#soma número de colunas
	sll $t6, $t6, 3
	add $t6, $s2, $t6
	ldc1 $f0, 0($t6)
	
	#Salva o valor na matriz inversa
	mul $t6, $t4, $t0
	add $t6, $t6, $t5							#elemento = linha*nro_colunas + coluna
	sll $t6, $t6, 3
	add $t6, $s3, $t6
	sdc1 $f0, 0($t6)
	
	addi $t5, $t5, 1
	j for_inverse_c
fim_inverse_c:
	addi $t4, $t4, 1
	j for_inverse_r
fim_inverse_r:
	
#MOSTRA A MATRIZ INVERTIDA
	add $t4, $zero, $zero
for_x_r:
	beq $t4, $t0, fim_x_r
	add $t5, $zero, $zero
for_x_c:
	beq $t5, $t0, fim_x_c
	mul $t7, $t4, $t0
	add $t7, $t7, $t5							#elemento = linha*nro_colunas + coluna
	sll $t7, $t7, 3
	add $t7, $s3, $t7
	ldc1 $f12, 0($t7)							#carrega valor da matriz em f0
	li $v0, 3
	syscall
	li $v0, 4									#carrega string
	la $a0, tab									#tab
	syscall
	addi $t5, $t5, 1
	j for_x_c
fim_x_c:
	addi $t4, $t4, 1
	li $v0, 4
	la $a0, newl
	syscall
	j for_x_r
fim_x_r:
	jr $ra
	

# Recebe o endereço da primeira matriz, seu número de linhas e número de colunas na pilha
# O endereço da segunda matriz, seu número de linhas e número de colunas na pilha
#MULTIPLICAÇÃO DE MATRIZES
mult_matrizes:
	lw $s0, 0($sp)	#M1
	lw $s1, 4($sp)	#L1
	lw $s2, 8($sp)	#C1
	lw $s3, 12($sp)	#M2
	lw $s4, 16($sp)	#L2
	lw $s5, 20($sp)	#C2
	
	mul $t0, $s1, $s5
	sll $t0, $t0, 3
	sub $sp, $sp, $t0
	
	move $t0, $zero
for_mult_r:
	slt $t1, $t0, $s1
	beq $t1, $zero, fim_mult_r
	move $t1, $zero
for_mult_c:
	slt $t2, $t1, $s5
	beq $t2, $zero, fim_mult_c
	
	# Pega o M3[i][j]
	mul $t4, $t0, $s5
	add $t4, $t4, $t1
	sll $t4, $t4, 3
	add $t4, $t4, $sp
	move $t9, $zero
	mtc1 $t9, $f12
	cvt.d.w $f12, $f12
	sdc1 $f12, 0($t4)						# M3[i][j] = 0
	
	move $t2, $zero
for_mult_m:
	slt $t3, $t2, $s2
	beq $t3, $zero, fim_mult_m
	
	# Pega o M1[i][k]
	mul $t5, $t0, $s2
	add $t5, $t5, $t2
	sll $t5, $t5, 3
	add $t5, $t5, $s0
	ldc1 $f2, 0($t5)						# M1[i][k] = f2
	
	# Pega o M2[k][j]
	mul $t5, $t2, $s5
	add $t5, $t5, $t1
	sll $t5, $t5, 3
	add $t5, $t5, $s3
	ldc1 $f4, 0($t5)						# M1[k][j] = f4
	
	mul.d $f6, $f2, $f4
	
	# Pega o M3[i][j]
	mul $t4, $t0, $s5
	add $t4, $t4, $t1
	sll $t4, $t4, 3
	add $t4, $t4, $sp
	ldc1 $f0, 0($t4)						# M3[i][j] = f0
	
	add.d $f8, $f0, $f6
	sdc1 $f8, 0($t4)
	
	addi $t2, $t2, 1
	j for_mult_m
fim_mult_m:
	addi $t1, $t1, 1
	j for_mult_c
fim_mult_c:
	addi $t0, $t0, 1
	j for_mult_r
fim_mult_r:
	move $v0, $sp
	jr $ra
	
	
	
	
	
	
	
	
	
	
	
	
fail: 
	li $v0, 4
	la $a0, failure								#imprime string
	syscall

fail2:
	li $v0, 4
	la $a0, notinversible						#imprime string
	syscall