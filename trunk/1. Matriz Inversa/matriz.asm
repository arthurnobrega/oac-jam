.data
newl: .asciiz "\n"
tab: .asciiz "\t"
m1: .asciiz "Digite o número de linhas"
m2: .asciiz "Digite o número de colunas"
m3: .asciiz "Digite um número da matriz" 
failure: .asciiz "You fail"
.text

escreve_matriz:
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
add $t3, $t2, $t2
add $t3, $t3, $t3							#t3 = 4*t2 (utilizado para abrir espaço na pilha)
add $t3, $t3, $t3							#t3 = 8*t2
sub $sp, $sp, $t3							#abre na pilha t3 espaços
add $t5, $zero, $zero						#t5 = contador (zerando)
loop:
li $v0, 4
la $a0, m3									#imprime string
syscall
li $v0, 7
syscall										#valor dos termos
addi $t5, $t5, 1							#contador = contador + 1
sdc1 $f0 , 0($sp)							#guarda o valor na pilha
addi $sp, $sp, 8							#incrementa pilha
bne $t2, $t5, loop							#contador != nº de termos? (1) volte ao loop; (0) continue

imprime_matriz:
add $t5, $zero, $zero						#zera contador primário
add $t6, $zero, $zero						#zera contador secundário
sub $sp, $sp, $t3							#volta ao primeiro valor da pilha
loop2: ldc1 $f12, 0($sp)					#carrega valor em f12
li $v0, 3									#imprime valor
syscall
li $v0, 4									#carrega string
la $a0, tab									#tab
syscall
li $v0, 4									#carrega string
la $a0, tab									#tab
syscall
addi $sp, $sp, 8							#incremento para o próximo elemento da pilha
addi $t5, $t5, 1							#incrementa contador primário
addi $t6, $t6, 1							#incrementa contador secundário
bne $t6, $t1, loop2							#cont. secundário != nº colunas?
add $t6, $zero,$zero						#zera cont. secundário
li $v0, 4									#carrega string
la $a0, newl								#Pula linha
syscall
bne $t5, $t2, loop2							#cont. primário = nº de termos?

li $v0, 4									#carrega string
la $a0, newl								#Pula linha
syscall

det_matriz:
add $t5, $zero, $zero						#contador = 0
add $t6, $zero, $zero						#cont. linha inicial = 0
add $t8, $t1, $zero							#cont. qual linha
div $t7, $t3, $t1							#termos em uma linha
add $t9, $zero, $zero						#checar se excedeu o número de linhas
sub $sp, $sp, $t7							#volta ao começo da matriz
mtc1 $t8, $f2								#move int pra double
cvt.d.w $f2, $f2							#converte nº para double
controle: ldc1 $f6, 0($sp)					#carrega o termo da pilha
c.eq.d 1,$f6, $f8							#checa se o termo = 0 e armazena na flag 1
bc1t 1, troca								#chega se flag 1 = 0
j go_on										#pulo para continuar método
troca: add $sp, $sp, $t7					#vai para a próxima linha da pilha
addi $t6, $t6, 1							#contador da linha = linha +1
slt $t9, $t0, $t6							#número de linhas excedido?
beq $t9, $zero, fail						#primeira linha feita de zeros -> det = 0
j controle									#teste a próxima linha

go_on: beq $t6, $t8, primeira_linha

primeira_linha: 

inverte_matriz:
sub $sp, $sp, $t3							#começo da matriz
sub $sp, $sp, $t3							#abre t2 mais termos na matriz
add $t5, $zero, $zero						#zera cont.1 (nº de termos)
addi $t6, $zero, 0							#zera cont.2 (qual elemento da linha?)
addi $t7, $zero, 0							#zera cont.3 (qual elemento da coluna?)
add $t8, $zero, $zero						#zera cont.4
addi $t8, $t8, 1							#1 em cont.4(para passar 1 pro float)
mtc1 $t8, $f2								#move int pra double
cvt.d.w $f2, $f2							#converte nº para double
mtc1 $t5, $f4								#move int pra double
cvt.d.w $f4, $f4							#converte nº para double
loop3: sdc1 $f4, 0($sp)						#armazena 0 no termo
addi $t5, $t5, 1							#incrementa cont. 1
beq $t6, $t7, arruma						# i = j? vai pro método arruma
continua: 									
addi $sp, $sp, 8							#incrementa pilha
addi $t6, $t6, 1							#incrementa cont. 2
bne $t6, $t1, loop3							#elemento linha = último?
add $t6, $zero, $zero 						#zera contador termo linha
addi $t7, $t7, 1							#próxima linha
bne $t5, $t2, loop3							#cont. = último termo?
j parte2									#avança para o método seguinte de inversão
arruma: sdc1 $f2, 0($sp)					#armazena 1 no termo (ao ínves do antigo 0 )
j continua									#volta para o método continua

parte2: 									#imprime a identidade da ordem equivalente da matriz inicial
add $t5, $zero, $zero						#zera contador primário
add $t6, $zero, $zero						#zera contador secundário
sub $sp, $sp, $t3							#volta ao primeiro valor da pilha
loop4: ldc1 $f12, 0($sp)					#carrega valor em f12
li $v0, 3									#imprime valor
syscall
li $v0, 4									#carrega string
la $a0, tab									#tab
syscall
li $v0, 4									#carrega string
la $a0, tab									#tab
syscall
addi $sp, $sp, 8							#incremento para o próximo elemento da pilha
addi $t5, $t5, 1							#incrementa contador primário
addi $t6, $t6, 1							#incrementa contador secundário
bne $t6, $t1, loop4							#cont. secundário != nº colunas?
add $t6, $zero,$zero						#zera cont. secundário
li $v0, 4									#carrega string
la $a0, newl								#Pula linha
syscall
bne $t5, $t2, loop4							#cont. primário = nº de termos?

li $v0, 4									#carrega string
la $a0, newl								#Pula linha
syscall

add $t5, $zero, $zero						#cont. primário = 0
add $t6, $zero, $zero						#linha = 0
add $t7, $zero, $zero						#coluna = 0
add $t8, $zero, $zero						#cont. secundário = 0
add $t9, $zero, $zero						#não sei, mas vai usar com certeza = 0

gauss:
ldc1 $f6, 0($sp)
#beq $f6, $f4, troca_Linha

#div.d $f6, $f6, $f6

troca_Linha: 

j fim

fail: 
li $v0, 4
la $a0, failure								#imprime string
syscall

fim: 