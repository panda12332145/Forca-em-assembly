# arquivo com funcoes para imprimir o boneco na forca #

################################################################################################################################
# SEGMENTO DE TEXTO
################################################################################################################################
.text
################################################################################################################################
# Funcao que imprime situacao do jogo
# a0 - situacao: numero de partes do corpo do boneco (0-6)
################################################################################################################################
.globl imprime_situacao
imprime_situacao:
	blt $a0, 0x00000000, return_ie 	#se $a0 for menor que 0 vai para return_ie
	bgt $a0, 0x00000006, return_ie 	#se $a0  for maior que 6 vai para return_ie
	la $t0, tblCase 		# t0 <- enderecoo da tabela de saltos
	sll $t1, $a0, 0x00000002 	# t1 <- indice do salto
	add $t0, $t0, $t1 
	lw $t2, 0($t0) 			#t2 - enderecoo do salto
	jr $t2
	#### Carrega endereços das partes do boneco
	c0:
	la $a0, s0
	j imprime
	c1:
	la $a0, s1
	j imprime
	c2:
	la $a0, s2
	j imprime
	c3:
	la $a0, s3
	j imprime
	c4:
	la $a0, s4
	j imprime
	c5:
	la $a0, s5
	j imprime
	c6:
	la $a0, s6
	imprime:
	#imprime na tela
	la $v0, 4
	syscall
return_ie:	
jr $ra

################################################################################################################################
# SEGMENTO DE DADOS
################################################################################################################################
.data 
	s0: .asciiz "\n  _____\n  |   |\n  |    \n  |     \n  |\n  |_______\n\n"
	s1: .asciiz "\n  _____\n  |   |\n  |   o\n  |     \n  |\n  |_______\n\n"	
	s2: .asciiz "\n  _____\n  |   |\n  |   o\n  |   |\n  |\n  |_______\n\n"	
	s3: .asciiz "\n  _____\n  |   |\n  |   o\n  |  /|\n  |\n  |_______\n\n"	
	s4: .asciiz "\n  _____\n  |   |\n  |   o\n  |  /|\\\n  |\n  |_______\n\n"	
	s5: .asciiz "\n  _____\n  |   |\n  |   o\n  |  /|\\\n  |  /\n  |_______\n\n"
	s6: .asciiz "\n  _____\n  |   |\n  |   o\n  |  /|\\\n  |  / \\\n  |_______\n\n"
	tblCase: .word c0, c1, c2, c3, c4, c5, c6
