# aquivo com procedimentos para gerar palavras para o jogo

.eqv TAM_TXT 10000 # maximo de caracteres do arquivo
.eqv TAM_PAL 100 # maximo de caracteres de cada palavra

################################################################################################################################
# SEGMENTO DE TEXTO
################################################################################################################################
.text
################################################################################################################################
# Funcaoo que le o texto de um arquivo e armazena em um buffer
################################################################################################################################
.globl le_arquivo
le_arquivo:
	la $a0, arquivo
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall # abre o arquivo 
	move $t0, $v0
	move $a0, $t0
	la $a1, buffer
	li $a2, 500
	li $v0, 14
	syscall # armazena o texto no buffer #
	move $a0, $t0
	li $v0, 16
	syscall # fecha o arquivo
	jr $ra
	
################################################################################################################################
# Gera uma palavra aleatoria e remove do buffer
# a0 - ponteiro para a string de palavra
# a1 - ponteiro para a string de dica
################################################################################################################################
.globl gera_palavra
gera_palavra:

	# prologo #
	subiu $sp, $sp, 16
	sw $ra, 12($sp)
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	
	# corpo #
	jal conta_linhas
	move $t3, $v0 # t3 - numero de linhas
	srl $t3, $t3, 1		
	li $a0, 0
	move $a1, $t3
	li $v0, 42   # random
	syscall
	sll $t2, $a0, 1 # indice gerado aleatorio
	sw $t2, 0($sp) # indice colocado na memoria 
	#retorna uma palavra da lista
	lw $a0, 0($sp)
	jal retorna_buffer
	la $a0, tmpBuffer
	lw $a1, 8($sp)
	jal strcpy
	#retira a linha utilizada
	lw $a0, 0($sp)
	jal retira_linha
	#retorna a dica da palavra
	lw $a0, 0($sp)
	jal retorna_buffer
	la $a0, tmpBuffer
	lw $a1, 4($sp)
	jal strcpy
	#retira a linha utilizada
	lw $a0, 0($sp)
	jal retira_linha
	
	# epilogo #
	lw $ra, 12($sp)	
	addiu $sp, $sp, 12
	jr $ra	
	
################################################################################################################################
# Retorna o texto do indice a0 (linha 0-x) para o buffer temporario
# $a0 - indice
################################################################################################################################
retorna_buffer:
	addi $a0, $a0, 1
	la $t0, buffer # t0 <- buffer com as palavras do jogo
	la $t1, tmpBuffer #t1 <- buffer temporario
	li $t2, 1 # t2 - contador
	LOOP_RET:
		lb $t4, 0($t0)
		beq $t4, $zero, END_LOOP_RET
		seq $t3, $a0, $t2 # t3 <-1 se $a0 == contador
		#if
		beq $t4, '\n', RET_INC
		j RET_END_IF
		RET_INC:
			addi $t2, $t2, 1 # incrementa o contador
			addi $t0, $t0, 1 
			j LOOP_RET
		RET_END_IF:
		addi $t0, $t0, 1
		beq $t3, $zero, LOOP_RET
		#aqui a0 == contador
		sb $t4, 0($t1)
		addi $t1, $t1, 1		
		j LOOP_RET	
	END_LOOP_RET:
	sb $zero, ($t1)
	jr $ra
	
################################################################################################################################
# Retira a linha a0 do buffer
# $a0 - indice
################################################################################################################################
retira_linha:
	# prologo #
	subiu $sp, $sp, 4
	sw $ra, 0($sp)
	# corpo do programa #
	la $t0, buffer
	la $t1, auxBuffer
	li $t2, 0 # t2 - contador
	LOOP_RL:
		lb $t3, 0($t0)
		beq $t3, '\n', IC_RL
		j IF_CEI
		IC_RL:
			addi $t2, $t2, 1 # incrementa contador
		IF_CEI:	
		bne $t2, $a0, APPEND_RL
		j INCP_RL	
		APPEND_RL:
			sb $t3, 0($t1)
			addi $t1, $t1, 1
		INCP_RL:
		beq $t3, $zero, END_LOOP_RL	
		#incrementa ponteiros
		addi $t0, $t0, 1
		j LOOP_RL	
	END_LOOP_RL:
	sb $zero, 0($t1) # adiciona zero no ultimo caractere
	la $a0, auxBuffer
	# se o primeiro caractere foi \n incrementa o pointeiro para copiar sem o \n
	lb $t4, 0($a0)
	beq $t4, '\n', IF_BN
	j END_IF_BN
	IF_BN:
	add $a0, $a0, 1
	END_IF_BN:
	la $a1, buffer
	jal strcpy #copia a nova string para a original
	# epilogo #
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
	
################################################################################################################################
# Conta o numero de linhas no buffer
# $v0 - numero de linhas retornado
################################################################################################################################	
.globl conta_linhas
conta_linhas:
	la $t0, buffer # ponteiro da string(buffer)
	li $t1, 0 # t1 - contador
	LOOP_CL:
		lb $t2, 0($t0)
		beq $t2, $zero, END_LOOP_CL
		beq $t2, '\n', INC_CL
		j CONTINUE_LOOP_CL
		INC_CL: # incrementa o contador
			addi $t1, $t1, 1
		CONTINUE_LOOP_CL:
		addi $t0, $t0, 1 # incrementa o ponteiro
		j LOOP_CL	
	END_LOOP_CL:
	move $v0, $t1 # v0 <- contador
	jr $ra # return v0

################################################################################################################################
# SEGMENTO DE DADOS
################################################################################################################################
.data
	arquivo: .asciiz "palavras.txt" # arquivo com as palavras do jogo
	buffer: .space TAM_TXT # buffer com as palavras que ainda nao foram utilizadas
	auxBuffer: .space TAM_TXT # auxiliar para retirar palavra do buffer
	tmpBuffer: .space TAM_PAL # auxiliar para retornar palavra do buffer
	

