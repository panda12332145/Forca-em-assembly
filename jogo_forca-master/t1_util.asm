# Arquivo com funcoes utilitarias #
    
################################################################################################################################
# SEGMENTO DE TEXTO 
################################################################################################################################
.text
################################################################################################################################
# Funcao que retorna o numero de caracteres de uma string
# a0 - ponteiro para a string
################################################################################################################################	
.globl strlen
strlen:
	move $t0, $a0 # t0 <- ponteiro para a string
	li $t1, 0 # t1 <- contador
	LOOP_SL:
		lb $t3, 0($t0)
		beq $t3, $zero, END_LOOP_SL
		add $t0, $t0, 1 #incrementa o ponteiro
		add $t1, $t1, 1 #incrementa o contador
		j LOOP_SL
	END_LOOP_SL:	
	move $v0, $t1
	jr $ra

################################################################################################################################
# Funcao que copia uma string
# a0 - ponteiro para a string a ser copiada
# a1 - ponteiro para a copia 
################################################################################################################################	
.globl strcpy
strcpy:
	move $t0, $a0 # t0 <- ponteiro para a primeira string
	move $t1, $a1 # t1 <- ponteiro para cópia
	LOOP_SC:
		lb $t2, 0($t0)
		lb $t3, 0($t1)
		sb $t2, 0($t1) # *(t1) = *(t0)
		beq $t2, $zero, END_LOOP_SC
		addi $t0, $t0, 1 # t0++
		addi $t1, $t1, 1 # t1++
		j LOOP_SC
	END_LOOP_SC:
	jr $ra
			
################################################################################################################################
# Preenche uma string com _
# a0 - ponteiro para string original
# a1 - ponteiro para a string com _
################################################################################################################################
.globl preenche_ul
 preenche_ul:
	LOOP_PUL: 
		lb $t1, 0($a1)
		li $t1, '_'
		sb $t1, 0($a1)	# *a1 <- '_'																
		lb $t0, 0($a0) 			
		beq $t0, $zero, END_LOOP_PUL
		addi $a0, $a0, 1 # a0++
		addi $a1, $a1, 1 # a1++
		j LOOP_PUL
	END_LOOP_PUL:
	sb $zero, 0($a1)
	jr $ra
	
################################################################################################################################
# Imprime uma string com espacoo entre cada caractere
# a0 - ponteiro para string
################################################################################################################################
.globl imprime_separado
 imprime_separado:
 	move $t0, $a0 # t0 - ponteiro
 	la $a0, divisor
	li $v0, 4
	syscall # imprime divisor
	LOOP_ISEP:
		lb $t1, 0($t0)
		beq $t1, $zero, END_LOOP_ISEP
		move $a0, $t1
		li $v0, 11
		syscall # inprime caractere
		lw $a0, space
		li $v0, 11
		syscall # imprime espaco
		add $t0, $t0, 1 # incrementa ponteiro
		j LOOP_ISEP
	END_LOOP_ISEP:
	la $a0, newLine
	li $v0, 4
	syscall # imprime \n
	jr $ra

################################################################################################################################
# Revela uma letra da string
# a0 - ponteiro para string 1
# a1 - ponteiro para string a ser revelada
# a2 - caractere a ser revelado
# v0 - retorna o numero de caracteres revelados
################################################################################################################################
.globl revela_letra
revela_letra:
	move $t0, $a0 # ponteiro para a string 1
	move $t1, $a1 # ponteiro para a string 2
	move $t2, $a2 # caractere
	li $t3, 0 # contador de caracteres revelados
	LOOP_RP:	
		lb $t4, 0($t0)
		beq $t4, $zero, END_LOOP_RP
		bne $t4, $t2, INCP_RP
		lb $t5, 0($t1)
		bne $t5, '_', INCP_RP
			sb $t4, 0($t1)
			addi $t3, $t3, 1 # incrementa o contador
		INCP_RP: # incrementa os ponteiros
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j LOOP_RP
	END_LOOP_RP:
	move $v0, $t3
	jr $ra
	
################################################################################################################################
# Funcao que converte um caractere para maiusculo
# a0 - byte de entrada
# v0 - byte de saida
################################################################################################################################
.globl to_upper
to_upper:
	blt $a0, 97, NOT_LC # se menor q 97(a) retornar a0
	bgt $a0, 122, NOT_LC # se maior q 122(z) retornar a0
	subi $v0, $a0, 32
	j END_TU
	NOT_LC:
		move $v0, $a0
	END_TU:
	jr $ra

################################################################################################################################
# SEGMENTO DE DADOS
################################################################################################################################
.data
	newLine: .asciiz "\n"
	space: .word ' '
	divisor: .asciiz "Resposta: "
  
