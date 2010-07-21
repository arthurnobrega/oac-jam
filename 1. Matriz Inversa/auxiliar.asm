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