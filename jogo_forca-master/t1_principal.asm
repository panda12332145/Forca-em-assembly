.eqv TAM_PAL 100

################################################################################################################################
# MACROS
################################################################################################################################

# le um caractere
.macro read_char()
	li $v0, 12 	# parametro de leitura de char
	syscall
.end_macro

#imprime uma string
#%x endereco da string
.macro print_str(%x)
	li $v0, 4	# parametro de imprimir string
	add $a0, $zero, %x
	syscall
.end_macro

#imprime um caractere \n
.macro endl()
	li $v0, 11	# parametro de imprimir char
	li $a0, '\n'
	syscall
.end_macro

.macro sleep()
	li $v0, 32 # servicoo sleeep
	li $a0, 3000 # 3 sec
	syscall
.end_macro

################################################################################################################################
# SEGMENTO DE TEXTO
################################################################################################################################	
.text

################################################################################################################################
# Funcaoo principal do programa
################################################################################################################################
.globl main
main:
	# le o arquivo e gera a primeira palavra	
	jal le_arquivo			#Funcao que le o texto de um arquivo
	jal conta_linhas		#Conta o numero de linhas no buffer
	srl $s3, $v0, 1			#$s3 <- $v0 e desloca para a direita
	INICIO:
	li $s0, 0  			# s0 - situacao
	li $s1, 0 			# s1 - score
	# s2 - tamanho da palavra
	la $a0, palavra			#$a0 <- endereco palavra
	la $a1, dica			#$a1 <- endereco dica
	jal gera_palavra		#Funcao Gera uma palavra aleatoria
	
	la $a0, palavra			#$a0 <- endereco palavra
	jal strlen 			#Funcao que retorna o numero de caracteres de uma string
	move $s2, $v0			#$s2 <- $v0 tamanho da palavra
	la $a0, palavra			#$a0 <- endereco palavra
	la $a1, pdesc			#$a0 <- endereco palavra a ser revelada
	jal preenche_ul			#Funcao que preenche uma string com _
	# testa se tem espaco
	la $a0, palavra			#$a0 <- endereco palavra
	la $a1, pdesc			#$a1 <- endereco palavra a ser revelada
	li $a2, ' '
	jal revela_letra 		# tenta revelar um espaco
	add $s1, $s1, $v0
	GAME_LOOP:
		move $a0, $s0		#$a0 <- $s0 - numero de partes que deve ser revelada
		jal imprime_situacao	#Funcao que imprime situacao do jogo "BONECO"
		bgt $s0, 5, PERDEU	#Se o valor de $s0 for maior que 5 vai para "PERDEU"
		la $a0, dica		#$a0 <- endereco da dica
		print_str($a0)		#Imprime a dica
		endl()			#quebra de linha
		la $a0, pdesc		#$a0 <- endereco palavra a ser revelada
		jal imprime_separado	#Funcao que imprime uma string com espaço entre cada caractere
		la $t0, prompt		#$t0 <- endereco de frase "Informe o char.."
		print_str($t0)		#imprime o valor $t0
		read_char()		#le o char
		move $a0, $v0		#a0 <- $v0 valor lido
		jal to_upper		#Funcao que deixa tudo maiusculo
		move $a2, $v0		#$a2 <- retorno de $v0
		la $a0, palavra		#$a0 <- endereco da palavra
		la $a1, pdesc		#$a1 <- edenreço da palavra gerado
		jal revela_letra	#Funcao revela uma letra da string
		beq $v0, $zero, INC_CNT #se o reotorno for igual a zero vai para "INC_CNT"
		add $s1, $s1, $v0	#incrementa o numero de acertos
		beq $s1, $s2, VENCEU	#testa se o numero de acertos e igual ao numero de letras, se for vai para "VENCEU"
		j CONTINUE_GAME
		INC_CNT:
			add $s0, $s0, 1 #incrementa a situaco
		CONTINUE_GAME:	
		j GAME_LOOP	
	VENCEU:
		endl()			#quebra de linha
		la $t0, pdesc		#endereco da palavra a ser revelada
		print_str($t0)		#imprimi a palavra
		endl()			#quebra de linha
		la $t0, game_win	#$t0 <- Endereco da frase de "venceu"
		print_str($t0)		#imprime a msg
		sleep()			#sleep 3seg
		sub $s3, $s3, 1		#
		bgt $s3, $zero, INICIO 	#se $s3 for maior que 0, chama "INICIO"
		la $t0, game_end	#endereco da msg que "acertou todas as palavras"
		print_str($t0)		#imprime a msg
		j PROMPT
	PERDEU:
		la $t0, game_over	#$t0 <- endereco msg de game over
		print_str($t0)		#imprime o valor de $t0
		sleep()			#sleep 3seg
		j PROMPT
	PROMPT:
		la $t0, game_reset	#endereco da pergunta de restart game
		print_str($t0)		#imprime o valor $t0
		read_char()		#ler a opcao do usuario
		move $a0, $v0		#$a0 <- $v0 - opcao escolhida
		jal to_upper		#Funcao que deixa maisculo
		move $t1, $v0		#$t1 <- $v0 
		beq $t1, 'S', RESET	#se $t1 == S vai para 'reset' - restart
		bne $t1, 'N', ERRO_C	#se $t1 != N vai para char invalido
		j EXIT
		ERRO_C:
			la $t2, error_char	#$t2 <- endereco da frase de char invalido
			print_str($t2)		#imprime o conteudo de $t2
			j PROMPT
		RESET:
			jal le_arquivo		#Funcao de le o arquivo
			jal conta_linhas	#Funcao que conta as linhas
			srl $s3, $v0, 1		#guarda o n de linhas
			j INICIO
################################################################################################################################
# Encerra o programa
################################################################################################################################
EXIT:	
	li $a0, 0
	li $v0, 17	#finaliza o programa
	syscall

################################################################################################################################
# SEGMENTO DE DADOS
################################################################################################################################			
.data
	palavra: .space TAM_PAL # resposta correta da palavra #
	dica: .space TAM_PAL # dica da palavra #
	pdesc: .space TAM_PAL # palavra a ser revelada durante o jogo #
	prompt: .asciiz "\nInforme o caractere: "
	# mensagens que o jogo mostra durante o jogo #
	game_over: .asciiz "GAME OVER!"
	game_win: .asciiz "PARABENS!"
	game_end: .asciiz "\nVOCE ACERTOU TODAS AS PALAVRAS!"
	game_reset: .asciiz "\nReiniciar o jogo (S/N)?\n"
	error_char:	.asciiz "Caractere invalido!\n"
