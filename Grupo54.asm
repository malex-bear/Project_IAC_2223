; VERSAO INTERMEDIARIA DO PROJETO: BEYOND MARS

; grupo : 54
; - Martim Auriault : 106676
; - Rodrigo Correia : 106603
; - Maria Medvedeva : 106120

; Descrição: Este programa permite realizar os 
; objetivos delineados para o projeto intermediario. 
; Ele contém portanto a fundação e base que será 
; utilizada para depois completar o jogo. 


;** Constantes***********************************************
;************************************************************

COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

TOCA_SOM      			EQU 	COMANDOS +5AH

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

LINHA_NAVE        		EQU  31        		; linha do boneco (a meio do ecrã))
COLUNA_NAVE			EQU  25        		; coluna do boneco (a meio do ecrã)

LARGURA_NAVE			EQU	15				; largura da nave
LONGURA_NAVE 			EQU 	5

COR_BRANCO			EQU	0FFFFH			; cor dos pixeis (da nave)
COR_VERMELHO			EQU	0FF00H
COR_CINZA				EQU	0FBBBH

COLUNA_CENTRO			EQU  32        		; coluna do boneco (a meio do ecrã)

MIN_COLUNA			EQU  0				; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU  63        		; número da coluna mais à direita que o objeto pode ocupar
MIN_LINHA				EQU  0				; número da linha mais à alta que o objeto pode ocupar
MAX_LINHA				EQU  26        		; número da coluna mais à baixa que o objeto pode ocupar
	

LARGURA_SONDA			EQU	1				; largura da sonda
COR_PIXEL_SONDA		EQU	0FF0FH			; cor do pixel: roxo em ARGB (opaco e vermelho no máximo, verde a 0,  azul no máximo)

LINHA_ASTEROIDE       	EQU  0        		; linha do boneco 
COLUNA_ASTEROIDE		EQU  0        		; coluna do boneco 
LARGURA_ASTEROIDE		EQU	5			; largura do boneco
ALTURA				EQU  5 			; altura do boneco

DISPLAYS   			EQU 0A000H  			; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    			EQU 0C000H  			; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    			EQU 0E000H  			; endereço das colunas do teclado (periférico PIN)
MASCARA    			EQU 000FH   			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
DISPLAY_VALOR			EQU 0100H				; valor  predefenido para os displays 
LINHA_TECLADO 			EQU 8
ZERO					EQU 0
TECLA_4				EQU 4
TECLA_1				EQU 1
TECLA_2				EQU 2

; ***********************************************************
; * Dados 
; ***********************************************************

PLACE	1000H

;Definicao do Asteroide Linha Por Linha:
DEF_LINHA1E5:					; tabela LINHA1
	WORD		LARGURA_ASTEROIDE
	WORD		COR_VERMELHO, 0, COR_VERMELHO, 0, COR_VERMELHO		

DEF_LINHA2E4:					; tabela LINHA2
	WORD		LARGURA_ASTEROIDE
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, 0		
     
DEF_LINHA3:					; tabela LINHA3
	WORD		LARGURA_ASTEROIDE
	WORD		COR_VERMELHO, COR_VERMELHO, 0, COR_VERMELHO, COR_VERMELHO		
DEF_APAGA:
	WORD		LARGURA_ASTEROIDE
	WORD		0, 0, 0, 0, 0


; tabela que define a nave linha por linha (cor, largura, pixels)
DEF_NAVE_0:					
	WORD		LARGURA_NAVE
	WORD		COR_CINZA, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_CINZA; # # #   as cores podem ser diferentes de pixel para pixel
DEF_NAVE_1:
	WORD		LARGURA_NAVE
	WORD		0, COR_CINZA, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_CINZA, 0
DEF_NAVE_2:
	WORD		LARGURA_NAVE
	WORD		0, 0, COR_BRANCO, 0, 0, COR_CINZA, COR_CINZA, COR_BRANCO, COR_CINZA, COR_CINZA, 0, 0, COR_BRANCO, 0, 0
DEF_NAVE_3:
	WORD		LARGURA_NAVE
	WORD		0, 0, COR_VERMELHO, 0, 0, 0, COR_CINZA, COR_BRANCO, COR_CINZA, 0, 0, 0, COR_VERMELHO, 0, 0
DEF_NAVE_4:
	WORD		LARGURA_NAVE
	WORD		0, 0, 0, 0, 0, 0, 0, COR_VERMELHO, 0, 0, 0, 0, 0, 0, 0

DEF_BONECO_SONDA:					; tabela que define a sonda (cor, largura, pixels)
	WORD		LARGURA_SONDA
	WORD		COR_PIXEL_SONDA		

pilha:
	STACK 100H					; espaço reservado para a pilha 
								; (200H bytes, pois são 100H words)
SP_inicial:						; este é o endereço (1200H) com que o SP deve ser 
								; inicializado. O 1.º end. de retorno será 
								; armazenado em 11FEH (1200H-2)

; *********************************************************************************
; * Código spawn da Nave e Asteroide
; *********************************************************************************

PLACE	ZERO				; o código tem de começar em 0000H

inicializacaoDisplay:
	MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo


;** Spawn Inicial da Nave *********************************************************

inicio_spawn_nave:
     MOV R8, LINHA_NAVE
     SUB R8, LONGURA_NAVE 		; ponho no registro R8 o equivalente a linha final da nave, se chegarmos a esta linha entao acabamos de desenhar
     
posicao_inicial:
     MOV  R1, LINHA_NAVE		; linha do boneco
     MOV  R2, COLUNA_NAVE	; coluna do boneco

desenha_nave_0:       		; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_0		; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R1	; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto

proxima_linha:
	MOV R2, COLUNA_NAVE 	; reset da coluna para inicio
	SUB R1, 1 			; proxima linha 

verifica_linha:
	CMP R1,R8				; verificar se ja acabou a ultima linha da nave
	JZ inicioAsteroide
	MOV R9,30
	CMP R1,R9
	JZ desenha_nave_1   	; verificar em que linha estamos
	MOV R9,29
	CMP R1,R9
	JZ desenha_nave_2
	MOV R9,28
	CMP R1,R9
	JZ desenha_nave_3
	MOV R9,27
	CMP R1,R9
	JZ desenha_nave_4

desenha_nave_1:       		; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_1		; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_pixels
desenha_nave_2:       		; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_2		; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_pixels
desenha_nave_3:       		; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_3		; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_pixels
desenha_nave_4:       		; desenha o boneco a partir da tabela
	MOV	R4, DEF_NAVE_4		; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_pixels




;** Spawn Inicial Asteroide *******************************************************


inicioAsteroide:
     MOV R7,ALTURA				;R7 é o contador de altura
     
posição_inicial:
     MOV  R9, LINHA_ASTEROIDE			; linha do boneco
     MOV  R10, COLUNA_ASTEROIDE		; coluna do boneco

desenha_linha1E5:
	MOV R4, DEF_LINHA1E5		; endereço da tabela que define o boneco
	MOV R5,[R4]				; obtém a largura do boneco
	MOV R1, R10				;copia coluna
	MOV R2, R9 				;copia linha
	ADD R4,2 					; endereço da cor do 1º pixel (2 porque a largura é uma word)

		
desenha_linha:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R2	; seleciona a linha
	MOV  [DEFINE_COLUNA], R1	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R1, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  desenha_linha        ; continua até percorrer toda a largura do objeto
     ADD R9,1 				;Descer de 1 a linha
     SUB R7,1 				;Diminuir de 1 a altura


 verifica_fim: ;Verifica em que linha estamos, R7 é o contador da altura
 	CMP R7,1
 	JZ desenha_linha1E5
 	CMP R7,5
 	JZ desenha_linha1E5
 	CMP R7,2
 	JZ desenha_linha2E4
 	CMP R7,4
 	JZ desenha_linha2E4
 	CMP R7,3
 	JZ desenha_linha3
 	SUB R9, LARGURA_ASTEROIDE; adicionar R1 de volta ao ponto original
 	MOV R7,ALTURA ;reinicializar R7
 	JMP fim_spawnAsteroide

desenha_linha2E4:
	MOV R4, DEF_LINHA2E4		; endereço da tabela que define o boneco
	MOV R5,[R4]				; obtém a largura do boneco
	MOV R1, R10				;copia coluna
	MOV R2, R9 				;copia linha
	ADD R4,2 					; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_linha

desenha_linha3:
	MOV R4, DEF_LINHA3		; endereço da tabela que define o boneco
	MOV R5,[R4]				; obtém a largura do boneco
	MOV R1, R10				;copia coluna
	MOV R2, R9				;copia linha
	ADD R4,2 					; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_linha

fim_spawnAsteroide:



; *********************************************************************************
; * Código spawn sonda
; *********************************************************************************

spawn_posicao_sonda:
     MOV  R1, COLUNA_CENTRO	; registro temporal para guardar coluna do boneco
     MOV  R11, MAX_LINHA		; registro PERMANENTE para guardar linha do boneco

spawn_desenha_sonda:       	; desenha o boneco a partir da tabela
	MOV	R4, DEF_BONECO_SONDA; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)

spawn_desenha_pixels:       	; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R11	; seleciona a linha
	MOV  [DEFINE_COLUNA], R1	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R6, 1               ; próxima linha
     SUB  R5, 1			; menos uma linha para tratar
     JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto


; *********************************************************************************
; * Código teclado
; *********************************************************************************


inicio_teclado:				;inicializacoes
	MOV SP, SP_inicial			;inicializa SP para a palavra a seguir
							;à última da pilha

	MOV R2, TEC_LIN			;endereco do periférico das linhas
	MOV R3, TEC_COL			;endereco do periférico das colunas
	MOV R4, DISPLAYS			;endereco do periférico dos displays
	MOV R5, MASCARA			;para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV R1,DISPLAY_VALOR
	MOV [R4], R1
	MOV R8, DISPLAY_VALOR		;crio uma variável que vai ser atualizada 
							;sempre que houver alterações nos displays

ciclo:
	MOV R6, LINHA_TECLADO		;contador das linhas já percorridas				

espera_tecla:					;espera até uma tecla ser premida
	MOV R7, ZERO				;contador para conversao das linhas e colunas
	MOV R1, R6				;inicializo a linha a ser testada
	MOVB [R2], R1				;redireciona a linha para o periférico de linhas
	MOVB R0,[R3]				;lê a coluna lida
	AND R0, R5				;isola os 4 bits de menor peso
	CMP R0,ZERO
	JNZ tecla_premida			;se houver uma tecla premida, 
								;passa para a parte de alterar os displays
	JMP ha_tecla

tecla_premida:
	CALL converte_linha 
	SUB R7, 1						;subtrai 1 pq as linhas vao de 0-3 em vez de 1-4
	MOV R1, R7					;converte a linha para 0-3
	MOV R7, ZERO					;reinicializo o contador para as colunas
	CALL converte_coluna
	SUB R7, 1						;subtrai 1 pq as colunas vao de 0-3 em vez de 1-4
	MOV R0, R7					;converte a coluna para 0-3
	
	;processo de conversão para hexadecimal
	MOV R7, TECLA_4
	MUL R1, R7					;4* linha	
	OR R1,R0						;linha + coluna
	
	tecla_4:
		CMP R1,R7 				;correspondente à tecla '4' 
		JZ incrementa_display
	
	tecla_8:
		MOV R7, LINHA_TECLADO
		CMP R1,R7            		;correspondente à tecla '8'
		JZ decrementa_display
	
	tecla_1:
		MOV R7, TECLA_1			;correspondente à tecla '1'
		CMP R1,R7
		JNZ tecla_2 				;ignoramos o call do move da sonda se a tecla nao foi pressionada
		CALL moveSonda_inicio		;iniciamos a funcao para mexer a sonda
		CALL som_sonda
	
	tecla_2:
		MOV R7, TECLA_2			;correspondente à tecla '2'
		CMP R1, R7
		JNZ ha_tecla
		CALL moveAsteroide_inicio
		CALL som_asteroide

ha_tecla:						;verifica se existem mais alguma tecla a ser premida
	MOV R1, R6				;inicializo a linha a ser testada
	MOVB [R2], R1				;redireciona a linha para o periférico de linhas
	MOVB R0,[R3]				;lê a coluna lida
	AND R0, R5				;isola os 4 bits
	CMP R0,ZERO				;verifica se existe uma tecla premida
	JNZ ha_tecla				; se exitir, repete o ciclo até não houver
	SHR  R6,1					;para passar para a linha anterior
	CMP	 R6, ZERO				;verifica se é a primeira linha
    	JNZ  espera_tecla   		;se não for a primeira linha, continua a percorrer o teclado
	JMP ciclo

incrementa_display:
	INC R8					; incrementa o valor do display

    ; Atualiza o valor do display
    MOV [R4], R8

    JMP  ha_tecla           		; volta ao início do ciclo

decrementa_display:
	DEC R8					; decrementa o valor do display

    ; Atualiza o valor do display
    MOV [R4], R8

    JMP  ha_tecla           		; volta ao início do ciclo



; ************************************************************	
; * R O T I N A S 
; ************************************************************


converte_linha:
	ADD R7,1
	SHR R1,1					; conta-se o numero de ciclos que é preciso para a linha ficar a 0
	JNZ converte_linha
	RET

converte_coluna:
	ADD R7, 1					; conta-se o numero de ciclos que é preciso para a coluna ficar a 0
	SHR R0, 1
	JNZ converte_coluna
	RET



;** Rotina mexer Asteroide **********************************
;************************************************************

moveAsteroide_inicio:
	PUSH R1
	PUSH R2 
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7

	MOV R7, ALTURA ; registro temporario para altura

apaga_Asteroide:                 	; desenha o boneco a partir da tabela
     MOV  R4, DEF_APAGA     		; endereço da tabela que define o boneco
     MOV R1, R10				;copia coluna
	MOV R2, R9				;copia linha
     MOV  R5, [R4]            	; obtém a largura do boneco


apaga_linhaAsteroide:              ; desenha os pixels do boneco a partir da tabela
     MOV  R3, 0               	; para apagar, a cor do pixel é sempre 0
     MOV  [DEFINE_LINHA], R2  	; seleciona a linha
     MOV  [DEFINE_COLUNA], R1 	; seleciona a coluna
     MOV  [DEFINE_PIXEL], R3  	; altera a cor do pixel na linha e coluna selecionadas
     ADD  R1, 1               	; próxima coluna
     SUB  R5, 1               	; menos uma coluna para tratar
     JNZ  apaga_linhaAsteroide     ; continua até percorrer toda a largura do objeto


controlo_apaga_linhaAsteroide:
	MOV R5, [R4] 				; obtem largura
     ADD R2,1    				; proxima linha
     MOV R1,R10	    			; Voltamos a primeira coluna
     SUB R7,1     				; contador de altura desce de um
     CMP R7,0     				; verificamos se acabamos
     JNZ apaga_linhaAsteroide
 	MOV R7,ALTURA 				; reinicializar R7
 	ADD R9,1      				; esta linha e a proxima servem para ir 1 em diagonal para a direita
 	ADD R10,1

 	MOV R6, MAX_LINHA
 	CMP R10 ,R6

desenha_Novalinha1E5:
	MOV R4, DEF_LINHA1E5		; endereço da tabela que define o boneco
	MOV R5,[R4]				; obtém a largura do boneco
	MOV R1, R10				;copia coluna
	MOV R2, R9				;copia linha
	ADD R4,2 					; endereço da cor do 1º pixel (2 porque a largura é uma word)

		
desenha_Novalinha:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]				; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R2		; seleciona a linha
	MOV  [DEFINE_COLUNA], R1		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2				; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R1, 1               	; próxima coluna
     SUB  R5, 1				; menos uma coluna para tratar
     JNZ  desenha_Novalinha        ; continua até percorrer toda a largura do objeto
     ADD R9,1 					; descer de 1 a linha
     SUB R7,1 					; diminuir de 1 a altura


 Novoverifica_fim: ;Verifica em que linha estamos, R7 é o contador da altura
 	CMP R7,1
 	JZ desenha_Novalinha1E5
 	CMP R7,5
 	JZ desenha_Novalinha1E5
 	CMP R7,2
 	JZ desenha_Novalinha2E4
 	CMP R7,4
 	JZ desenha_Novalinha2E4
 	CMP R7,3
 	JZ desenha_Novalinha3
 	SUB R9, LARGURA_ASTEROIDE	; adicionar R1 de volta ao ponto original
 	MOV R7,ALTURA 				; reinicializar R7
 	JMP moveAsteroide_fim

desenha_Novalinha2E4:
	MOV R4, DEF_LINHA2E4		; endereço da tabela que define o boneco
	MOV R5,[R4]				; obtém a largura do boneco
	MOV R1, R10				; copia coluna
	MOV R2, R9 				; copia linha
	ADD R4,2 					; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_Novalinha

desenha_Novalinha3:
	MOV R4, DEF_LINHA3			; endereço da tabela que define o boneco
	MOV R5,[R4]				; obtém a largura do boneco
	MOV R1, R10				;copia coluna
	MOV R2, R9 				;copia linha
	ADD R4,2 					; endereço da cor do 1º pixel (2 porque a largura é uma word)
	JMP desenha_Novalinha

moveAsteroide_fim:
	POP R7
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET


;** Rotina play sound effects *******************************
;************************************************************

som_sonda:
     PUSH R9
     MOV R9,1
     MOV [TOCA_SOM], R9
     POP R9
     RET

som_asteroide:
     PUSH R9
     MOV R9,0
     MOV [TOCA_SOM], R9
     POP R9
     RET


;** Rotina mexer sonda **************************************
;************************************************************


moveSonda_inicio:			;funcao para mexer a sonda de um pixel
	PUSH R1
	PUSH R2 
	PUSH R3
	PUSH R4
	PUSH R5 
	PUSH R6
     MOV  R1, COLUNA_CENTRO	; registro temporal para guardar coluna do boneco

moveSonda_load_sonda:       	; desenha o boneco a partir da tabela
	MOV	R4, DEF_BONECO_SONDA; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)

moveSonda_apaga_pixels:       ; apaga os pixels do boneco a partir da tabela
	MOV	R3, 0			; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R11	; seleciona a linha
	MOV  [DEFINE_COLUNA], R1	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas

moveSonda_desenha_pixels:     ; desenha os pixels do boneco a partir da tabela
	SUB  R11, 1 			; retiramos 1 a linha para fazer a sonda subir de 1 linha.
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R11	; seleciona a linha
	MOV  [DEFINE_COLUNA], R1	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas

moveSonda_return:
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
