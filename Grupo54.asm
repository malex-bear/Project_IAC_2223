; VERSAO INTERMEDIARIA DO PROJETO: BEYOND MARS

; grupo : 54
; - Martim Auriault : 106676
; - Rodrigo Correia : 106603
; - Maria Medvedeva : 106120

; Descrição: Este programa contem o jogo 
; completo e funcional "Beyond Mars" 


;** Constantes***********************************************
;************************************************************


; DEFINICAO DE ENDERECOS GERAIS:
;________________________________________________________________________________
COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

TOCA_SOM      			EQU COMANDOS + 5AH
LOOP_VIDEO 				EQU COMANDOS + 5CH
PAD_TRANSICAO 			EQU COMANDOS + 56H

PAUSE_VID 				EQU COMANDOS + 5EH
RESUME_VID 				EQU COMANDOS + 60H
STOP_VID 				EQU COMANDOS + 66H

SELEC_ECRA 				EQU COMANDOS + 04H
ECRA_NAVE 				EQU 6
ECRA_SONDAS 			EQU 0
ECRA_PAINEL 			EQU 5
ECRA_ASTEROIDE_1 		EQU 1
ECRA_ASTEROIDE_2 		EQU 2
ECRA_ASTEROIDE_3 		EQU 3
ECRA_ASTEROIDE_4 		EQU 4

ENTRADA_PIN				EQU 0E000H

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

DECREMENTO_AUTO_ENERG   EQU 3
;________________________________________________________________________________


; DEFINICAO DAS CONSTANTES PARA O DESENHO DA NAVE:
;________________________________________________________________________________
LINHA_NAVE        		EQU  27        		; linha da nave
COLUNA_NAVE				EQU  25        		; coluna do boneco (a meio do ecrã)

LARGURA_NAVE			EQU	 15				; largura da nave
LONGURA_NAVE 			EQU  5
;________________________________________________________________________________

; DEFINICAO DAS CONSTANTES PARA CORES:
;________________________________________________________________________________
COR_BRANCO				EQU	0FFFFH			; cor dos pixeis 
COR_VERMELHO			EQU	0FF00H
COR_CINZA				EQU	0FBBBH	
COR_VERDE 				EQU 0FCF7H
COR_AMARELO 			EQU 0FFF0H
COR_AZUL 				EQU 0F0FFH
;________________________________________________________________________________


; DEFINICAO DAS CONSTANTES PARA AS SONDAS:
;________________________________________________________________________________
; (COORDENADAS)
SONDA_COLUNA_ESQ		EQU  26        		; Coordenadas sonda direita. 
SONDA_LINHA_ESQ			EQU  27 

COLUNA_CENTRO			EQU  32 				; Coordenadas sonda centro.
LINHA_CENTRO			EQU  27 

SONDA_COLUNA_DIR		EQU  37 				; Coordenadas sonda direita.
SONDA_LINHA_DIR			EQU  27 

; (DESENHO)
LARGURA_SONDA			EQU	1				; largura da sonda
COR_PIXEL_SONDA			EQU	0FF0FH			; cor do pixel: roxo em ARGB (opaco e vermelho no máximo, verde a 0,  azul no máximo)
;________________________________________________________________________________


; DEFINICAO DE CONSTANTES PARA OS ASTEROIDES:
;________________________________________________________________________________
LINHA_ASTEROIDE       	EQU  0        			; linha do boneco 
COLUNA_ASTEROIDE		EQU  0        			; coluna do boneco 
LARGURA_ASTEROIDE		EQU	5					; largura do boneco
ALTURA					EQU  5 						; altura do boneco

VEL_ESQUERDA			EQU -1 					;Definicoes das velocidades
VEL_NULA				EQU  0
VEL_DIREITA				EQU  1

MINERAVEL   			EQU  0
NAO_MINERAVEL 			EQU  1

NAO_MINERAVEL_DESTRUIDO	EQU -2					;Vamos usar estas constantes como estados para saber se um asteroide esta a meio da sua animação
MINERAVEL_DESTRUIDO_1	EQU -3
MINERAVEL_DESTRUIDO_2	EQU -4
FIM_ANIMACAO			EQU -5

COLUNA_ASTEROIDE_DIREITA EQU 58
;________________________________________________________________________________


; DEFINICAO DE CONSTANTES PARA O TECLADO:
;________________________________________________________________________________
DISPLAYS   			EQU 0A000H  					; endereço dos displays de 7 segmentos (periférico POUT-1)
DISPLAYS_VALOR		EQU 100H
TEC_LIN    			EQU 0C000H  					; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    			EQU 0E000H  					; endereço das colunas do teclado (periférico PIN)
MASCARA    			EQU 000FH   					; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
LINHA 				EQU 16
ZERO				EQU 0
; def teclas
TECLA_4				EQU 4
TECLA_5				EQU 5
TECLA_6				EQU 6
TECLA_C 			EQU 0CH
TECLA_D 			EQU 0DH
TECLA_E 			EQU 0EH
;________________________________________________________________________________


; DEFINICAO DE CONSTANTES GERAIS:
;________________________________________________________________________________
NULO 				EQU -6				; se uma posicao nao existe

MIN_COLUNA			EQU  0				; número da coluna mais à ESQUERDA que o objeto pode ocupar
MAX_COLUNA			EQU  63        		; número da coluna mais à direita que o objeto pode ocupar

MIN_LINHA			EQU  0				; número da linha mais à alta que o objeto pode ocupar
MAX_LINHA			EQU  32        		; número da coluna mais à baixa que o objeto pode ocupar

TAMANHO_ENDER_PAINEL EQU 24
;________________________________________________________________________________



; ***********************************************************
; * DADOS
; ***********************************************************



PLACE	1000H

; tabela que define a nave linha por linha 
;======================================================================
DESENHO_NAVE:
	WORD		LARGURA_NAVE, LONGURA_NAVE
	WORD		0, 0, 0, 0, 0, 0, 0, COR_VERMELHO, 0, 0, 0, 0, 0, 0, 0
	WORD		0, 0, COR_VERMELHO, 0, 0, 0, COR_CINZA, COR_BRANCO, COR_CINZA, 0, 0, 0, COR_VERMELHO, 0, 0
	WORD		0, 0, COR_BRANCO, 0, 0, COR_CINZA, COR_CINZA, COR_BRANCO, COR_CINZA, COR_CINZA, 0, 0, COR_BRANCO, 0, 0
	WORD		0, COR_CINZA, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_CINZA, 0					
	WORD		COR_CINZA, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_BRANCO, COR_CINZA;
;======================================================================


; tabela que define a sonda (cor, largura, pixels)
;======================================================================
DESENHO_BONECO_SONDA:					
	WORD		LARGURA_SONDA
	WORD		COR_PIXEL_SONDA		
;======================================================================


;Definicao do Asteroide Linha Por Linha incluindo as frames de animacao quando destruido). Os 5os correspondem a longura e largura
;======================================================================
DESENHO_AST_0:
	WORD		5, 5
	WORD		0, COR_VERMELHO,COR_VERMELHO,COR_VERMELHO, 0
	WORD 		COR_VERMELHO, 0, COR_VERMELHO, 0, COR_VERMELHO 
	WORD		COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO
	WORD		0, COR_VERMELHO, 0, COR_VERMELHO, 0 
	WORD		COR_VERMELHO, 0, 0, 0, COR_VERMELHO	

DESENHO_AST_1:
	WORD		5, 5
	WORD		0, COR_AZUL,COR_AZUL,COR_AZUL, 0
	WORD 		COR_AZUL, 0, COR_AZUL, 0, COR_AZUL 
	WORD		COR_AZUL, COR_AZUL, COR_AZUL, COR_AZUL, COR_AZUL
	WORD		0, COR_AZUL, 0, COR_AZUL, 0 
	WORD		COR_AZUL, 0, 0, 0, COR_AZUL
;======================================================================



; tabela que define o asteroide mineravel linha por linha (incluindo as frames de animacao quando destruido)
;======================================================================
DESENHO_AST_MIN_0:
	WORD		5, 5
	WORD		0, 0, COR_VERDE, 0, 0
	WORD 		0, COR_AMARELO, COR_AMARELO, COR_AMARELO, 0 
	WORD		COR_VERDE, COR_AMARELO, COR_AMARELO, COR_AMARELO, COR_VERDE
	WORD		0, COR_AMARELO, COR_AMARELO, COR_AMARELO, 0 
	WORD		0, 0, COR_VERDE, 0, 0		

DESENHO_AST_MIN_1:
	WORD		5, 5
	WORD		0, 0, 0, 0, 0
	WORD 		0, 0, COR_AMARELO, 0, 0 
	WORD		0, COR_AMARELO, COR_AMARELO,COR_AMARELO, 0
	WORD		0, 0, COR_AMARELO, 0, 0 
	WORD		0, 0, 0, 0, 0		

DESENHO_AST_MIN_2:
	WORD		5, 5
	WORD		0, 0, 0, 0, 0
	WORD 		0, 0, 0, 0, 0 
	WORD		0, 0, COR_AMARELO,0, 0
	WORD		0, 0, 0, 0, 0 
	WORD		0, 0, 0, 0, 0				

;======================================================================



;Definicao do Asteroide Linha Por Linha:
;======================================================================
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
;======================================================================


PLACE	1200H

; Definicao da memoria dos pixeis para as sondas:
;======================================================================
DEF_SONDA_CENTRO:		; base de dados para guardar informacao da sonda do centro
	WORD NULO, NULO 	; (posicao do pixel em (x,y) - NULO significa que a sonda nao existe - a coordenada x encontra se em [DEF_SONDA_CENTRO] e y em [DEF_SONDA_CENTRO + 2])
			
DEF_SONDA_DIREITA:		; base de dados para guardar informacao da sonda da direita
	WORD NULO, NULO 		
						
DEF_SONDA_ESQUERDA:		; base de dados para guardar informacao da sonda da esquerda
	WORD NULO, NULO 	  		
;======================================================================

PLACE	1300H
; Definicao da memoria do display da energia:
;======================================================================
V_DISPLAYS:
	WORD 100
;======================================================================
PLACE	1400H

; Definicao da memoria dos asteroides:
;======================================================================
DEF_ASTEROIDE_1:            ; base de dados para guardar informacao dos asteroides
    WORD NULO, NULO, NULO, NULO    ; (posicao dos pixeis em (x,y), e a direcao) - NULO significa que o asteroide nao existe - a coordenada x encontra se em [DEF_ASTEROIDE] e y em [DEF_ASTEROIDE + 2], a velocidade horizontal em [DEF_ASTEROIDE + 4], Mineravel ou Nao [DEF_ASTEROIDE + 6])

DEF_ASTEROIDE_2:            ; base de dados para guardar informacao do asteroide 2
    WORD NULO, NULO, NULO, NULO

DEF_ASTEROIDE_3:            ; base de dados para guardar informacao do asteroide 3
    WORD NULO, NULO, NULO, NULO

DEF_ASTEROIDE_4:             ; base de dados para guardar informacao do asteroide 4
    WORD NULO, NULO, NULO, NULO
;======================================================================



; tabela que define o PAINEL DE INSTRUMENTOS e as suas VARIACOES
;======================================================================
PAINEL_INSTRUMENTOS_1:
	WORD 		5,2
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERDE, 0
	WORD		COR_VERDE, COR_AMARELO, COR_VERMELHO, COR_AMARELO, COR_VERDE
PAINEL_INSTRUMENTOS_2:
	WORD 		5,2
	WORD		0, COR_AMARELO, COR_VERDE, COR_AMARELO,  0
	WORD		COR_AMARELO, COR_VERDE, COR_AZUL, COR_VERMELHO, COR_AZUL

PAINEL_INSTRUMENTOS_3:
	WORD 		5,2
	WORD		0, COR_VERMELHO, COR_AZUL,  COR_VERDE, 0
	WORD		COR_VERMELHO, COR_AMARELO, COR_VERMELHO, COR_AZUL, COR_VERDE

PAINEL_INSTRUMENTOS_4:
	WORD 		5,2
	WORD		0, COR_AZUL, COR_AZUL, COR_AMARELO,  0
	WORD		COR_AMARELO, COR_VERDE, COR_AMARELO, COR_AZUL, COR_VERMELHO

PAINEL_INSTRUMENTOS_5:
	WORD 		5,2
	WORD		0, COR_AMARELO, COR_VERMELHO, COR_VERDE, 0
	WORD		COR_VERDE, COR_AZUL, COR_VERDE, COR_AZUL, COR_AMARELO


DEF_PAINEL: ; Guarda as coordenadas X,Y do painel e o seu estado
	WORD PAINEL_INSTRUMENTOS_1
;======================================================================


; DEFINICAO DA TABELA DE INTERRUPCOES:
;======================================================================
tabInterrupcoes: 	WORD inter_0_Aster
					WORD inter_1_Sonda
					WORD inter_2_Ener
					WORD inter_3_Nave
;======================================================================

PLACE 1550H

I0: WORD 0 						; flag para dar enable/disable as interrupcoes, se 1 entao esta enabled, 0 para disabled
I1: WORD 0  
I2: WORD 0 
I3: WORD 0 


PLACE 1600H

pilha:
	STACK 200H										; espaço reservado para a pilha 
													; (200H bytes, pois são 100H words)
SP_inicial:											; este é o endereço com que o SP deste processo deve ser inicializado 

	STACK 200H										; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:									; este é o endereço com que o SP deste processo deve ser inicializado

PLACE 2000H

tecla_carregada:
	LOCK NULO											; LOCK para o teclado comunicar aos restantes processos que tecla detetou

PLACE 2100H

gameIsPaused:
	WORD 0 			; flag para o jogo em pausa (pela tecla D)

gameDeath:
	WORD 0 			; flag para quando o jogador esta morto.

gameStopped:
	WORD 0 	 		; flag para verificar se o jogo esta a correr ou nao (Interrupcoes ligadas ou nao)
;** Definicao Display  *********************************************************


PLACE	ZERO						; o código tem de começar em 0000H
MOV SP, SP_inicial					; inicializa SP para a palavra a seguir
									; à última da pilha
MOV BTE, tabInterrupcoes

EI0
EI1
EI2
EI3
EI

inicializacaoDisplay:
	MOV  [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0							; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo


; **************************************************************************************
; * Código teclado
; **************************************************************************************

displayBgStart:
	CALL muda_bg_Start
	loop_wait_C_press:
		CALL teclado	 			; Call ao teclado
		MOV R0, [tecla_carregada] 	
		MOV R1, TECLA_C
		CMP R0, R1 					; verificamos se a tecla premida e o C
		JNZ loop_wait_C_press  		; se a tecla premida nao for C, queremos repetir o processo.

	init_jogo: 						; so corremos isto da primeira vez que lancamos o programa 
		CALL muda_bg_main
		CALL spawn_inicial_nave
		MOV R0, NULO
		MOV [tecla_carregada], R0	
		CALL enable_int_todas
		CALL som_inicio_jogo


loop_teclado:
;-------------------------------------------------------------------------------
loop_teclado_init:
	loop_esperanaotecla:
		CALL espera_nao_tecla
		SHR R11, 1
		JNZ loop_esperanaotecla
		
	CALL teclado	 				; Call ao teclado
	MOV R0, [tecla_carregada] 		; esperamos pela proxima tecla
	MOV R11, 0
loop_teclado_controlo:
	MOV R1, TECLA_C
	CMP R0, R1
	JZ tecla_C_carregada

	MOV R2, TECLA_D
	CMP R0, R2
	JZ tecla_D_carregada

	MOV R3, TECLA_E
	CMP R0, R3
	JZ tecla_E_carregada

loop_teclado_sonda:
	MOV R10, [gameStopped]
	CMP R10, R11					; verificamos se o jogo esta parado
	JNZ loop_teclado_main_fim 		; se sim, entao vamos para o final, senao vemos o input para as naves

	sonda_para_direita:
		MOV R6, TECLA_6
		CMP R0, R6								; tecla 6 para mexer a sonda para a direita
		JNZ sonda_para_centro
		CALL sonda_spawn_direita
		
	sonda_para_centro:
		MOV R5, TECLA_5
		CMP R0, R5								; tecla 5 para mexer a sonda em frente
		JNZ sonda_para_esquerda
		CALL sonda_spawn_centro
		
	sonda_para_esquerda:
		MOV R4, TECLA_4
		CMP R0, R4 								; tecla 4 para mexer a sonda para a esquerda
		JNZ loop_teclado_main_fim
		CALL sonda_spawn_esquerda

loop_teclado_main_fim:
	MOV R11, NULO
	MOV [tecla_carregada], R11
	JMP loop_teclado_init
;-------------------------------------------------------------------------------


; ROTINAS PARA CADA TECLA

tecla_C_carregada: 			; tecla para reiniciar o jogo quando morto
;-------------------------------------------------------------------------------
	MOV R8, gameDeath
	MOV R9, [R8]
	MOV R11, 0
	CMP R9, R11
	JZ loop_teclado_main_fim 	; se a flag ja estiver a 0, entao o jogador nao esta morto e nao precisamos de reiniciar o jogo
	MOV [R8], R11 				; pomos a flag "death" a 0 (o jogador ja nao esta morto)
	MOV [gameStopped], R11
	MOV [gameDeath], R11
	CALL som_inicio_jogo
	CALL muda_bg_main
	CALL enable_int_todas
	CALL spawn_inicial_nave
	JMP loop_teclado_main_fim
;-------------------------------------------------------------------------------


tecla_D_carregada: 			; tecla para terminar o jogo quando vivo
;-------------------------------------------------------------------------------
	MOV R8, gameDeath
	MOV R9, [R8]
	CMP R9, 0
	JNZ loop_teclado_main_fim 	; se o jogador ja esta morto, entao nao queremos fazer nada
	MOV R11, 1
	MOV [gameDeath], R11 		; terminar = matar o jogo
	MOV [gameStopped], R11 		; paramos o jogo
	CALL disable_int_todas
	CALL som_menu_click
	CALL muda_bg_gameTerminated
	CALL reset_memoria
	CALL delete_display
	JMP loop_teclado_main_fim 	
;-------------------------------------------------------------------------------

tecla_E_carregada: 			; tecla para pausar o jogo quando vivo
;-------------------------------------------------------------------------------
	MOV R8, gameDeath
	MOV R9, [R8]
	CMP R9, 1
	JZ loop_teclado_main_fim 			; se o jogador ja esta morto, nao pausamos e saimos

	MOV R8, gameIsPaused
	MOV R9, [R8]
	MOV R11, 0
	MOV R10, 1
	CALL som_menu_click
	CMP R9, R11 						; se a flag gameIsPaused estiver a 0, entao o jogo nao esta em pausa e queremos por lo em pausa
	JZ poePausa

	retiraPausa: 	; se o jogo estiver em pausa, queremos retirar lo da pausa
		CALL muda_bg_main
		CALL enable_int_todas
		MOV [gameIsPaused], R11 			; retiramos o jogo da pausa
		MOV [gameStopped], R11				; retiramos o jogo do stop
		JMP loop_teclado_main_fim

	poePausa: 		; poe o jogo em pausa
		CALL muda_bg_pause
		CALL disable_int_todas
		MOV [gameIsPaused], R10 			; pomos o jogo em pausa
		MOV [gameStopped], R10				; pomos o jogo em stop
		JMP loop_teclado_main_fim	
;-------------------------------------------------------------------------------	


; **************************************************************************************
; * Código teclado
; **************************************************************************************
	

;***************************************************************************************
; Processo teclado - processo que trata da leitura das teclas 
; **************************************************************************************

PROCESS SP_inicial_teclado

teclado:
espera_tecla:
	MOV R6, ZERO									; contador geral (multi-usos)
	MOV R4, LINHA									; inicializo o contador das linhas
	
percorrer_teclas:
	SHR R4, 1
	JZ espera_tecla									; se for a primeira linha, volto ao inicio
	
	MOV  R1, R4										; indico a linha a ser testada
	CALL leitura_teclado							; chamo a rotina que verifica se está premida uma tecla
	CMP  R0, ZERO									; há tecla premida?
	JNZ tecla_premida				
	JMP percorrer_teclas							; se não houver, passo para a linha anterior
	
	CALL tecla_premida

ha_tecla:
	YIELD											; este ciclo é potencialmente bloqueante, pelo que tem de
													; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	MOV R1, R4 										; inicializo a linha a ser testada
    CALL leitura_teclado							; chamo a rotina que verifica se está premida uma tecla
    CMP  R0, ZERO									; há tecla premida?
    JNZ  ha_tecla									; se ainda houver uma tecla premida, espera até não haver
	JMP percorrer_teclas


;***************************************************************************************
; leitura_teclado : R1 - linha do teclado que vai percorrer
;					R0 - devolve a coluna lida 
	
leitura_teclado:
	PUSH R2
	PUSH R3
	PUSH R5
	MOV  R2, TEC_LIN								; endereço do periférico das linhas
	MOV  R3, TEC_COL								; endereço do periférico das colunas
	MOV  R5, MASCARA								; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB  [R2], R1									; escrever no periférico de entrada( linhas)
	MOVB  R0, [R3]									; ler do periférico de saída (colunas)
	AND  R0, R5										; isolar os últimos 4 bits
	POP R5
	POP R3
	POP R2
	RET

;***************************************************************************************
; espera_nao_tecla : R1 - linha do teclado a testar
; Rotina que espera até mais nenhuma tecla ser premida

espera_nao_tecla:
    
    espera_nao_tecla_ciclo:
	MOV R1, R11
	CALL leitura_teclado			           ; leitura às teclas
	CMP	R0, 0                          			; verifica se há alguma tecla a ser primida
	JNZ	espera_nao_tecla_ciclo	       			; espera enquanto houver tecla uma tecla carregada
    
    RET


;***************************************************************************************
; tecla_premida : R1, R0 - linha e coluna lida, respetivamente
;				  R1 - tecla premida

tecla_premida:
	PUSH R6
	MOV R6, ZERO									; inicializo o contador
	converte_linha:
		ADD R6,1
		SHR R1,1									; conta-se o numero de ciclos que é preciso para a linha ficar a 0
		JNZ converte_linha
		SUB R6, 1									; porque as lihas vão de 1-4 e precisamos de 0-3
	
	MOV R1, R6										; converte a linha para 0-3
	MOV R6, ZERO									; reinicializo o contador para as colunas
	
	converte_coluna:
		ADD R6, 1									; conta-se o numero de ciclos que é preciso para a coluna ficar a 0
		SHR R0, 1
		JNZ converte_coluna
		SUB R6, 1									; subtrai 1 pq as colunas vao de 0-3 em vez de 1-4
	
	MOV R0, R6										; converte a coluna para 0-3
	
	MOV R6, 4
	MUL R1, R6										; 4*LINHA
	ADD R1, R0										; linha + coluna
	
	MOV [tecla_carregada], R1						; atualiza a tecla carregada
	POP R6
	RET

;***************************************************************************************
; decresce_sonda : R7 - valor hexadecimal da energia
;				   R5 - valor decimal da energia da sonda decrementada
; Trata-se de uma rotina que decrementa a energia por cada sonda lançada e espera até que
; nenhuma tecla dessa linha seja premida para continuar

decresce_sonda:
	PUSH R0
	PUSH R1
	PUSH R6
	MOV R0, 5
	MOV R7, [V_DISPLAYS]
	SUB R7, R0									; subtrai 5 à energia da nave
	MOV R6, R7									; guardo o valor em hexadecimal para executar as operações no hexadecimal e não no decimal
	CALL decimal
	MOV [DISPLAYS], R5							; atualizo os displays com o valor em decimal
	MOV R7, R6									; volto a guardar na minha variável de energia o valor em hexadecimal para que continue 
	MOV [V_DISPLAYS], R7
	POP R6
	POP R1
	POP R0
	RET
	
;***************************************************************************************
; energia_asteroide_min: R7 - valor hexadecimal da energia
;				   		 R5 - valor decimal da energia da sonda incrementada
; Trata-se de uma rotina que incrementa a energia por cada asteroide minerável atingido e espera até que
; nenhuma tecla dessa linha seja premida para continuar

energia_asteroide_min:
	PUSH R0
	PUSH R1
	PUSH R6
	MOV R0, 25
	MOV R7, [V_DISPLAYS]
	ADD R7, R0
	MOV R6, R7									; guardo o valor em hexadecimal para executar as operações no hexadecimal e não no decimal
	CALL decimal
	MOV R7, R6									; volto a guardar na minha variável de energia o valor em hexadecimal para que continue 
	MOV [V_DISPLAYS], R7
	MOV [DISPLAYS], R5							; atualizo os displays com o valor em decimal
	POP R6
	POP R1
	POP R0
	RET

;***************************************************************************************
; verifica_energia: R7 - valor hexadecimal dos DISPLAYS
;	Trata-se de uma rotina que verifica se a energia da nave chegou a 0 e caso chegar,
; altera o flag para 1 (orrespondente ao fim do jogo por falta de energia)

verificar_energia:
	PUSH R0
	CMP R7, 0000H
	JGT fim_decresce							; se for maior do que 0, sai da rotina
	
	CALL som_morte
	MOV R0, 1
	MOV [gameDeath], R0							; atualizo o flag 
	MOV [gameStopped], R0						; atualizo o flag 
	CALL disable_int_todas 						; damos disable as interrupcoes
	CALL muda_bg_deadEnergy 					; mudamos o background
	CALL reset_memoria 							; damos reset a memoria
	CALL delete_display							; apagamos os ecras		
	
	fim_decresce:
	POP R0
	RET

;***************************************************************************************
; decimal: R7 - valor que queremos converter
;		   R5 - valor convertido para notação decimal

decimal: 
	PUSH R0
	PUSH R4
	PUSH R2


	MOV R0, 1000									; FATOR
	MOV R5, 0										; RESULTADO
	MOV R2, 10								
	ciclo1:
		MOD R7, R0									; número: o valor a converter nesta iteração
													; fator: uma potência de 1000 (para obter os dígitos)
		DIV R0, R2									; prepara o próximo fator de divisão
		CMP R0, 1
		JLT fim_ciclo1
		MOV R4, R7									; mais um dígito do valor decimal (0 a 9)
		DIV R4, R0
		
		SHL R5, 4
		OR R5, R4									; vai compondo o resultado
		JMP ciclo1
		
	
	fim_ciclo1:


		POP R2
		POP R4
		POP R0
		RET







reiniciar_tudo:
	PUSH R1


;************************************************************************************
;*************************** Rotina mexer sondas ************************************
;************************************************************************************

sonda_main: 					; rotina principal para todas as sondas na memorias ativas (!= NULO), elimina estas, mexe a sonda e redesenha.
;-------------------------------------------------------------------------------
	PUSH R0
	PUSH R1
	CALL switch_ecra_sondas
	CALL sonda_centro
	CALL sonda_esquerda
	CALL sonda_direita
	POP R1
	POP R0
	RET
;-------------------------------------------------------------------------------


; Funcoes auxiliares para as sondas
;-------------------------------------------------------------------------------

sonda_desenha_memoria:		; desenha os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e muda os seus valores
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R11
	MOV R11, R10
	ADD R11, 2 				; coordenada de y
	MOV R9, DESENHO_BONECO_SONDA		; endereço da largura da sonda
	ADD R9, 2 				; para termos o endereco da cor da sonda
	MOV R6, [R9]
	MOV R7, [R11] 				; load linha
	MOV  [DEFINE_LINHA], R7		; seleciona a linha 
	MOV R8, [R10] 				; load coluna
	MOV  [DEFINE_COLUNA], R8		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R6	; altera a cor do pixel na linha e coluna selecionadas
	POP R11
	POP R9
	POP R8
	POP R7
	POP R6
	RET

sonda_apaga_memoria:			; apagas os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e e muda os seus valores
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R11
	MOV R9, 0					; load 0 (cor para apagar pixel)
	MOV R11, R10
	ADD R11, 2 				; coordenada de y
	MOV R7, [R11] 				; load linha
	MOV  [DEFINE_LINHA], R7		; seleciona a linha 
	MOV R8, [R10] 				; load coluna
	MOV  [DEFINE_COLUNA], R8		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R9		; altera a cor do pixel na linha e coluna selecionadas
	POP R11
	POP R9
	POP R8
	POP R7
	RET

sonda_remeter_nulo: 		; elimina uma sonda, poe as suas coordenadas a NULO. (recebe argumento do endereco das coordenadas de x (R10) e muda os seus valores)
	PUSH R9
	PUSH R11
	MOV R9, NULO
	MOV R11, R10 
	ADD R11, 2 			; coordenada de y
	MOV [R11], R9			; mete a coordenada x a NULO
	MOV [R10], R9			; mete a coordenada y a NULO
	POP R11
	POP R9
	RET
;-------------------------------------------------------------------------------





;** Rotina mexer sonda centro *******************************
;************************************************************


sonda_centro: 					; verifica se a sonda esta ativa e se sim, entao chama as funcoes auxiliares.
;-------------------------------------------------------------------------------
sonda_centro_verifica: 			; seccao para tornar mais rapida a rotina de interrupcao quando a sonda nao estiver activa
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, NULO
	MOV R10, DEF_SONDA_CENTRO	; R10 guarda o endereco da coordenada x da sonda do centro
	MOV R8, [R10] 				; load do valor x para R8
	CMP R8, R9 	 			; verificar que x != NULO
	JZ sonda_centro_fim 
sonda_centro_main:
	CALL sonda_apaga_memoria 	; apagas os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
	CALL sonda_incrementa_centro 	; incrementa os valores na memoria das coordenadas da sonda do centro, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
	CALL sonda_desenha_memoria 	; desenha os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
sonda_centro_fim:
	POP R10
	POP R9
	POP R8
	RET
;-------------------------------------------------------------------------------



sonda_incrementa_centro:			; recebe argumento do endereco das coordenadas de x (R10), altera os valores na memoria da sonda do centro 
							; verifica se esta vai sair do ecra e se sim repoe o seu valor para (NULO, NULO)
;-------------------------------------------------------------------------------
sonda_incrementa_centro_inicio:
	PUSH R7
	PUSH R8
	PUSH R11
	MOV R7, MIN_LINHA
	MOV R11, R10
	ADD R11, 2 				; definicao de y
sonda_incrementa_centro_main:
	MOV R8, [R11] 
	SUB R8, 1 		
	MOV [R11], R8				; substraimos 1 para a sonda subir de 1 em y (ADD [R11], 1)
	CMP R8, R7	 			; se y chegar a cima do ecra, queremos remover a sonda
	JGE  sonda_incrementa_centro_final	
	CALL sonda_remeter_nulo 		; funcao para remeter as coordenadas da sonda a NULO
sonda_incrementa_centro_final:
	POP R11
	POP R8
	POP R7
	RET
;-------------------------------------------------------------------------------



;** Rotina mexer sonda esquerda *****************************
;************************************************************


sonda_esquerda: 				; verifica se a sonda esta ativa e se sim, entao chama as funcoes auxiliares.
;-------------------------------------------------------------------------------
sonda_esquerda_verifica: 			; seccao para tornar mais rapida a rotina de interrupcao quando a sonda nao estiver activa
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, NULO
	MOV R10, DEF_SONDA_ESQUERDA		; R10 guarda o endereco da coordenada x da sonda da esquerda
	MOV R8, [R10] 					; load do valor x para R8
	CMP R8, R9 	 				; verificar que x != NULO
	JZ sonda_esquerda_fim 
sonda_esquerda_main:
	CALL sonda_apaga_memoria 		; apagas os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
	CALL sonda_incrementa_esquerda 	; incrementa os valores na memoria das coordenadas da sonda do esquerda, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
	CALL sonda_desenha_memoria 		; desenha os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
sonda_esquerda_fim:
	POP R10
	POP R9
	POP R8
	RET
;-------------------------------------------------------------------------------


sonda_incrementa_esquerda:		; recebe argumento do endereco das coordenadas de x (R10) e y (R11), altera os valores na memoria da sonda da esquerda 
							; verifica se esta vai sair do ecra e se sim repoe o seu valor para (NULO, NULO)
;-------------------------------------------------------------------------------
sonda_incrementa_esquerda_inicio:
 	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R11
	MOV R7, MIN_LINHA
	MOV R5, MIN_COLUNA
	MOV R11, R10
	ADD R11, 2 				; definicao de y
sonda_incrementa_esquerda_main:
	MOV R8, [R11] 
	SUB R8, 1 		
	MOV [R11], R8				; substraimos 1 para a sonda subir de 1 em y (SUB [R11], 1)

	MOV R6, [R10]
	SUB R6, 1
	MOV [R10], R6 				; substraimos 1 para a sonda ir para a esquerda de 1 em x (SUB [R10], 1)

	CMP R8, R7	 			; se y chegar a cima do ecra, queremos remover a sonda
	JLT sonda_incrementa_esquerda_nulo
	CMP R6, R5 				; se x chegar ao limite da esquerda do ecra, queremos remover a sonda
	JLT sonda_incrementa_esquerda_nulo
sonda_incrementa_esquerda_final:
	POP R11
	POP R8
	POP R7
	POP R6
	POP R5
	RET
sonda_incrementa_esquerda_nulo:
	CALL sonda_remeter_nulo 		; funcao para remeter as coordenadas da sonda a NULO
	JMP sonda_incrementa_esquerda_final
;-------------------------------------------------------------------------------




;** Rotina mexer sonda direita *****************************
;************************************************************


sonda_direita: 					; verifica se a sonda esta ativa e se sim, entao chama as funcoes auxiliares.
;-------------------------------------------------------------------------------
sonda_direita_verifica: 			; seccao para tornar mais rapida a rotina de interrupcao quando a sonda nao estiver activa
	PUSH R8
	PUSH R9
	PUSH R10
	MOV R9, NULO
	MOV R10, DEF_SONDA_DIREITA	; R10 guarda o endereco da coordenada x da sonda da direita
	MOV R8, [R10] 				; load do valor x para R8
	CMP R8, R9 	 			; verificar que x != NULO
	JZ sonda_direita_fim 
sonda_direita_main:
	CALL sonda_apaga_memoria 	; apagas os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
	CALL sonda_incrementa_direita ; incrementa os valores na memoria das coordenadas da sonda do direita, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
	CALL sonda_desenha_memoria 	; desenha os pixeis de uma sonda na memoria, recebe argumento do endereco das coordenadas de x (R10) e y (R11)
sonda_direita_fim:
	POP R10
	POP R9
	POP R8
	RET
;-------------------------------------------------------------------------------


sonda_incrementa_direita:		; recebe argumento do endereco das coordenadas de x (R10) e y (R11), altera os valores na memoria da sonda da direita 
							; verifica se esta vai sair do ecra e se sim repoe o seu valor para (NULO, NULO)
;-------------------------------------------------------------------------------
sonda_incrementa_direita_inicio:
 	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R11
	MOV R7, MIN_LINHA
	MOV R5, MAX_COLUNA
	MOV R11, R10
	ADD R11, 2 				; definicao de y
sonda_incrementa_direita_main:
	MOV R8, [R11] 
	SUB R8, 1 		
	MOV [R11], R8				; substraimos 1 para a sonda subir de 1 em y (SUB [R11], 1)

	MOV R6, [R10]
	ADD R6, 1
	MOV [R10], R6 				; adicionamos 1 para a sonda se deslocar para a direita de 1 em x (ADD [R10], 1)

	CMP R8, R7	 			; se y chegar a cima do ecra, queremos remover a sonda
	JLT sonda_incrementa_direita_nulo
	CMP R6, R5 				; se x chegar ao limite da direita do ecra, queremos remover a sonda
	JGT sonda_incrementa_direita_nulo
sonda_incrementa_direita_final:
	POP R11
	POP R8
	POP R7
	POP R6
	POP R5
	RET
sonda_incrementa_direita_nulo:
	CALL sonda_remeter_nulo 		; funcao para remeter as coordenadas da sonda a NULO
	JMP sonda_incrementa_direita_final
;-------------------------------------------------------------------------------


;************************************************************************************
;*************************** Rotina spawn das sondas ********************************
;************************************************************************************


sonda_spawn_centro:				; actualiza as coordenadas na memoria da sonda do centro
;-------------------------------------------------------------------------------
sonda_spawn_centro_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7

	MOV R1, COLUNA_CENTRO		; coordenada em x inicial para a sonda
	MOV R2, LINHA_CENTRO		; coordenada em y inicial para a sonda
	MOV R5, DEF_SONDA_CENTRO		; endereco da memoria da sonda (corresponde a x)
	MOV R3, [R5] 				; guardamos a coordenada x

sonda_spawn_centro_verifica:	
	CMP R3, NULO				; verificamos se x ja tem valor (nao temos de verificar a coordenada y)
	JNZ sonda_spawn_centro_fim	; se essa coordenada ja tiver valor entao nao temos de spawnar a sonda e o programa acaba.

sonda_spawn_centro_altera:
	MOV [R5], R1 				; alteramos o valor de x para o inicial
	ADD R5, 2 				; endereco de memoria de y
	MOV [R5], R2				; alteramos o valor de y para o inicial
	CALL som_sonda 			; se a sonda for criada com sucesso queremos por o som
	CALL decresce_sonda							; a energia decresce 5 por cada sonda lançada


sonda_spawn_centro_fim:	
	POP R7
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;-------------------------------------------------------------------------------



sonda_spawn_esquerda:			; actualiza as coordenadas na memoria da sonda da esquerda
;-------------------------------------------------------------------------------
sonda_spawn_esquerda_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7

	MOV R1, SONDA_COLUNA_ESQ		; coordenada em x inicial para a sonda
	MOV R2, SONDA_LINHA_ESQ		; coordenada em y inicial para a sonda
	MOV R5, DEF_SONDA_ESQUERDA	; endereco da memoria da sonda (corresponde a x)
	MOV R3, [R5] 				; guardamos a coordenada x

sonda_spawn_esquerda_verifica:	
	CMP R3, NULO				; verificamos se x ja tem valor (nao temos de verificar a coordenada y)
	JNZ sonda_spawn_esquerda_fim	; se essa coordenada ja tiver valor entao nao temos de spawnar a sonda e o programa acaba.

sonda_spawn_esquerda_altera:
	MOV [R5], R1 				; alteramos o valor de x para o inicial
	ADD R5, 2 				; endereco de memoria de y
	MOV [R5], R2				; alteramos o valor de y para o inicial
	CALL som_sonda 			; se a sonda for criada com sucesso queremos por o som
	CALL decresce_sonda							; a energia decresce 5 por cada sonda lançada

sonda_spawn_esquerda_fim:
	POP R7	
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;-------------------------------------------------------------------------------



sonda_spawn_direita:			; actualiza as coordenadas na memoria da sonda da direita
;-------------------------------------------------------------------------------
sonda_spawn_direita_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7

	MOV R1, SONDA_COLUNA_DIR		; coordenada em x inicial para a sonda
	MOV R2, SONDA_LINHA_DIR		; coordenada em y inicial para a sonda
	MOV R5, DEF_SONDA_DIREITA	; endereco da memoria da sonda (corresponde a x)
	MOV R3, [R5] 				; guardamos a coordenada x

sonda_spawn_direita_verifica:	
	CMP R3, NULO				; verificamos se x ja tem valor (nao temos de verificar a coordenada y)
	JNZ sonda_spawn_direita_fim	; se essa coordenada ja tiver valor entao nao temos de spawnar a sonda e o programa acaba.

sonda_spawn_direita_altera:
	MOV [R5], R1 				; alteramos o valor de x para o inicial
	ADD R5, 2 				; endereco de memoria de y
	MOV [R5], R2				; alteramos o valor de y para o inicial
	CALL som_sonda 			; se a sonda for criada com sucesso queremos por o som
	CALL decresce_sonda							; a energia decresce 5 por cada sonda lançada

sonda_spawn_direita_fim:
	POP R7	
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;-------------------------------------------------------------------------------










;************************************************************************************
;*************************** Rotinas asteroides *************************************
;************************************************************************************


;--------------------------------------------------------------------------------
asteroide_main:
asteroide_main_inicio: ; Loop que permite de percorrer todos os asteroides e se estiverem fora do ecrã então criamos um novo
	PUSH R1
	PUSH R9
	PUSH R10
	PUSH R11

asteroide_loop:
	inicializacao:
		MOV R1,1 						;inicializar contador R1 a 1
		MOV R9, DEF_ASTEROIDE_1			;inicializar Asteroide
		MOV R11,8 						;incrementacao memoria para passar de um asteroide para o proximo
	loop_interno:
		CMP R1,5 						;Verificar fim quando R1 chega a 5
		JZ asteroide_main_fim		;Acabar loop 

		CALL asteroide_spawnar ; Vai verificar se existe o asteroide e se nao entao vai criar um novo.
		CALL asteroide_eliminar
		CALL asteroide_incrementar
		CALL asteroide_desenhar
		ADD R9,R11  						;Passar para o proximo asteroide
		ADD R1,1 						;Incrementar de 1 o contador
		JMP loop_interno 				;Repetir Loop

asteroide_main_fim:
	POP R11
	POP R10
	POP R9
	POP R1
	RET

;--------------------------------------------------------------------------------



asteroide_spawn_esquerda: 					; rotina principal para todas as sondas na memorias ativas (!= NULO), elimina estas, mexe a sonda e redesenha.
;-------------------------------------------------------------------------------
asteroide_spawn_esquerda_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R3,R9
	MOV R1, MIN_COLUNA-1	; coordenada em x inicial para a sonda
	MOV R2, MIN_LINHA-1		; coordenada em y inicial para a sonda
	MOV R4, VEL_DIREITA

asteroide_spawn_esquerda_altera:
	MOV [R3], R1 				; alteramos o valor de x para o inicial
	ADD R3, 2 				; endereco de memoria de y
	MOV [R3], R2 				; alteramos o valor de y para o inicial
	ADD R3, 2
	MOV [R3], R4				;queremos alterar a velocidade lateral do asteroide
	ADD R3, 2
	MOV [R3], R7

asteroide_spawn_esquerda_fim:	
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;--------------------------------------------------------------------------------



asteroide_spawn_centro: 					; rotina principal para todas as sondas na memorias ativas (!= NULO), elimina estas, mexe a sonda e redesenha.
;-------------------------------------------------------------------------------
asteroide_spawn_centro_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R3,R9
	MOV R1, COLUNA_CENTRO-2	; coordenada em x inicial para a asteroide
	MOV R2, MIN_LINHA-1		; coordenada em y inicial para a asteroide
asteroide_spawn_centro_velocidade:  ;Verificamos a partir do par coluna/velocidade qual a velocidade do asteroide.
	CMP R5, 1 		;R5 é onde guardamos o resto portanto usamos para saber qual é a direção do asteroide
	JNZ skip1							
	MOV R4, VEL_ESQUERDA
	JMP asteroide_spawn_centro_altera

	skip1:
	CMP R5,2
	JNZ skip2
	MOV R4, VEL_NULA
	JMP asteroide_spawn_centro_altera

	skip2:
	CMP R5,3
	JNZ skip3
	MOV R4, VEL_DIREITA
	JMP asteroide_spawn_centro_altera

	skip3:

asteroide_spawn_centro_altera:
	MOV [R3], R1 				; alteramos o valor de x para o inicial
	ADD R3, 2 				; endereco de memoria de y
	MOV [R3], R2 				; alteramos o valor de y para o inicial
	ADD R3, 2
	MOV [R3], R4				;queremos alterar a velocidade lateral do asteroide
	ADD R3, 2
	MOV [R3], R7
	; falta som

asteroide_spawn_centro_fim:	
	POP R4
	POP R3
	POP R2
	POP R1
	RET

asteroide_spawn_direita: 					; rotina principal para todas as sondas na memorias ativas (!= NULO), elimina estas, mexe a sonda e redesenha.
;-------------------------------------------------------------------------------
asteroide_spawn_direita_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R3,R9
	MOV R1, MAX_COLUNA-3	; coordenada em x inicial para a sonda
	MOV R2, MIN_LINHA-1	; coordenada em y inicial para a sonda
	MOV R4, VEL_ESQUERDA
asteroide_spawn_direita_altera:
	MOV [R3], R1 				; alteramos o valor de x para o inicial
	ADD R3, 2 				; endereco de memoria de y
	MOV [R3], R2 				; alteramos o valor de y para o inicial
	ADD R3, 2
	MOV [R3], R4				;queremos alterar a velocidade lateral do asteroide
	ADD R3, 2
	MOV [R3], R7

asteroide_spawn_direita_fim:	
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;--------------------------------------------------------------------------------



asteroide_spawn_picker:; Permite de saber o par coluna-direção e portanto onde vai spawnar o asteroide
;--------------------------------------------------------------------------------
asteroide_spawn_picker_inicio: 
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
	PUSH R7
	CALL numero_aleatorio_spawn ;Vai guardar resto em R2
	CALL condicao_mineravel ;Vai guardar MINERAVEL ou NAO_MINERAVEL em R7
	CMP R5,0 				;Observamos o resto da rotina numero_aleatorio_spawn
	JZ asteroide_pick0		;As funcoes asteroide_pick escolhem o asteroide dependente do resto.
	CMP R5,3
	JLE asteroide_pick123
	CMP R5,4
	JZ asteroide_pick4



asteroide_spawn_picker_fim:
	POP R7
	POP R5
	POP R3
	POP R2
	POP R1
	RET

asteroide_pick0: ; Se o resto foi 0 entao vai spawnar na esquerda
	CALL asteroide_spawn_esquerda
	JMP asteroide_spawn_picker_fim

asteroide_pick123:
	CALL asteroide_spawn_centro
	JMP asteroide_spawn_picker_fim

asteroide_pick4:
	CALL asteroide_spawn_direita
	JMP asteroide_spawn_picker_fim






;--------------------------------------------------------------------------------
asteroide_spawnar:
asteroide_verifica_existe: ;Recebe argumento R9 que é o asteroide
	asteroide_verifica_existe_inicio:
		PUSH R1

		MOV R1,[R9]
		CMP R1,NULO 						;Verificamos se o asteroide existe
		JNZ asteroide_verifica_existe_fim
		CALL asteroide_spawn_picker 		;Se nao existir vamos dar spawn a um novo asteroide
	asteroide_verifica_existe_fim:
		POP R1
		RET
;--------------------------------------------------------------------------------


asteroide_remover:
;--------------------------------------------------------------------------------
    PUSH R10
    PUSH R11

    MOV R10, NULO
    MOV R11, 2             ; coordenada de y
    MOV [R9], R10        ; mete a coordenada x a NULO
    MOV [R9+R11], R10            ; mete a coordenada y a NULO

    POP R11
    POP R10
    RET
;--------------------------------------------------------------------------------






;--------------------------------------------------------------------------------


asteroide_desenhar: ; Esta funcao recebe como argumento R9 que é o asteroide e desenha-o.
;--------------------------------------------------------------------------------
asteroide_desenhar_inicio:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R7
	PUSH R8
	PUSH R10
	PUSH R11

	MOV R2,6 ;Offset para ver o estado do asteroide
	MOV R11, [R9+R2] ;R11 guarda o estado do asteroide

	CMP R11,NAO_MINERAVEL
	JZ asteroide_desenha_nao_mineravel
	CMP R11,NAO_MINERAVEL_DESTRUIDO
	JZ asteroide_desenha_nao_mineravel_destruido

	CMP R11,MINERAVEL
	JZ asteroide_desenha_mineravel
	CMP R11,MINERAVEL_DESTRUIDO_1
	JZ asteroide_desenha_mineravel_destruido_1
	CMP R11,MINERAVEL_DESTRUIDO_2
	JZ asteroide_desenha_mineravel_destruido_2

	JMP asteroide_acabou_animacao

asteroide_desenha_mineravel:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_MIN_0
	MOV R7, [R9]
	MOV R8, [R9+2]
	CALL draw_object
	JMP asteroide_desenhar_fim

asteroide_desenha_nao_mineravel:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_0
	MOV R7, [R9]
	MOV R8, [R9+2]
	CALL draw_object
	JMP asteroide_desenhar_fim
asteroide_desenha_nao_mineravel_destruido:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_1
	MOV R7, [R9]
	MOV R8, [R9+2]	
	CALL draw_object
	JMP asteroide_fim_animacao
asteroide_desenha_mineravel_destruido_1:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_MIN_1
	MOV R7, [R9]
	MOV R8, [R9+2]	
	CALL draw_object
	MOV R11,  MINERAVEL_DESTRUIDO_2
	MOV [R9+R2], R11
	JMP asteroide_desenhar_fim
asteroide_desenha_mineravel_destruido_2:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_MIN_2
	MOV R7, [R9]
	MOV R8, [R9+2]	
	CALL draw_object
	CALL energia_asteroide_min
	CALL som_asteroide_minerado
	JMP asteroide_fim_animacao

asteroide_fim_animacao:
	MOV R11,  FIM_ANIMACAO
	MOV [R9+R2],R11 ;Declaramos que acabou a animacao do asteroide
	JMP asteroide_desenhar_fim

asteroide_acabou_animacao:
	MOV R10, NULO
	MOV R11, 2 			; coordenada de y
	MOV [R9], R10		; mete a coordenada x a NULO
	MOV [R9+R11], R10			; mete a coordenada y a NULO
	JMP asteroide_desenhar_fim

asteroide_desenhar_fim:
	POP R11
	POP R10
	POP R8
	POP R7
	POP R5
	POP R2
	POP R1
	POP R0
	RET


;--------------------------------------------------------------------------------

asteroide_eliminar: ;Esta funcao recebe o asteroide em R9 e elimina-o.
;--------------------------------------------------------------------------------
asteroide_eliminar_inicio:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R7
	PUSH R8
	PUSH R11

	MOV R2,6 ;Offset para ver o estado do asteroide
	MOV R11, [R9+R2] 	;R11 guarda o estado do asteroide
	CMP R11,NAO_MINERAVEL
	JZ asteroide_eliminar_nao_mineravel
	CMP R11,NAO_MINERAVEL_DESTRUIDO
	JZ asteroide_eliminar_nao_mineravel_destruido

	CMP R11,MINERAVEL
	JZ asteroide_eliminar_mineravel
	CMP R11,MINERAVEL_DESTRUIDO_1
	JZ asteroide_eliminar_mineravel_destruido_1
	CMP R11,MINERAVEL_DESTRUIDO_2
	JZ asteroide_eliminar_mineravel_destruido_2

asteroide_eliminar_mineravel:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_MIN_0
	MOV R7, [R9]
	MOV R8, [R9+2]
	CALL delete_object
	JMP asteroide_eliminar_fim

asteroide_eliminar_nao_mineravel:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_0
	MOV R7, [R9]
	MOV R8, [R9+2]
	CALL delete_object
	JMP asteroide_eliminar_fim
asteroide_eliminar_nao_mineravel_destruido:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_1
	MOV R7, [R9]
	MOV R8, [R9+2]	
	CALL delete_object
	JMP asteroide_eliminar_fim
asteroide_eliminar_mineravel_destruido_1:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_MIN_1
	MOV R7, [R9]
	MOV R8, [R9+2]	
	CALL delete_object
	JMP asteroide_eliminar_fim
asteroide_eliminar_mineravel_destruido_2:
	CALL asteroide_ecra ;Tem output R1 com o digito do ecra mas queremos o digito em R0
	MOV R0,R1
	MOV R1, DESENHO_AST_MIN_2
	MOV R7, [R9]
	MOV R8, [R9+2]	
	CALL delete_object
	JMP asteroide_eliminar_fim


	
asteroide_eliminar_fim:
	POP R11
	POP R8
	POP R7
	POP R2
	POP R1
	POP R0
	RET






;--------------------------------------------------------------------------------

numero_aleatorio_mineravel_generator:;Vamos ter 4 possibilidades equiprovaveis, vamos ter restos de 0,1,2,3. Com eles podemos por exemplo dizer que quando o resto é 0, o asteroide vai ser mineravel
	MOV R1, ENTRADA_PIN
	MOVB R6,[R1]
	SHR R6,4
	MOV R3,4
	MOD R6,R3
	RET

condicao_mineravel:
	CALL numero_aleatorio_mineravel_generator
	CMP R6,0
	JZ e_mineravel
	MOV R7, NAO_MINERAVEL
	JMP condicao_mineravel_fim
	e_mineravel:
	MOV R7, MINERAVEL

	condicao_mineravel_fim:
	RET

;--------------------------------------------------------------------------------





asteroide_incrementar:;  R9 VAI SER ARGUMENTO OBJETO, altera os valores na memoria do asteroide
							; verifica se esta vai sair do ecra e se sim repoe o seu valor para (NULO, NULO)
;-------------------------------------------------------------------------------
	
asteroide_incrementar_inicio:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
 	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R10
	PUSH R11
	MOV R7, MAX_LINHA
	MOV R5, MAX_COLUNA+5
	MOV R2, MIN_COLUNA-5 			;Limite x da esquerda
	MOV R4, [R9+6]  					;Observamos o estado
	CMP R4,0
	JLT asteroide_incrementar_final


asteroide_incrementar_init:
	MOV R3, 2 				; Offset para ler coordenadas y
	MOV R8, [R9+R3] 			;R8 guarda coordenada y

	MOV R1, 4
	MOV R6, [R9+R1]			;R6 obtém a velocidade do asteroide

asteroide_incrementar_verifica:
	CMP R8, R7	 			; se y chegar a baixo do ecra, queremos remover o asteroide
	JGE asteroide_remeter_nulo
	MOV R4,[R9]
	CMP R4, R5 				; se x chegar ao limite da direita do ecra, queremos remover o asteroide
	JGT asteroide_remeter_nulo
	CMP R4,R2
	JLT asteroide_remeter_nulo
	
asteroide_incrementar_main:
	ADD R8, 1 		
	MOV [R9+R3], R8				; adicionamos 1 para ao asteroide descer de 1 em y

	MOV R4,[R9]					; Atualizamos coordenada do asteroide



	MOV R4,[R9] 				;Obtemos x
	ADD R4,R6 				;Adicionar velocidade
	MOV [R9], R4			; Atualizamos o valor
	JMP asteroide_incrementar_final
	

asteroide_remeter_nulo: 		; elimina um asteroide, poe as suas coordenadas a NULO. Recebe R9 como argumento
	CALL asteroide_eliminar
	MOV R10, NULO
	MOV R11, 2 			; coordenada de y
	MOV [R9], R10		; mete a coordenada x a NULO
	MOV [R9+R11], R10			; mete a coordenada y a NULO


asteroide_incrementar_final:
	POP R11
	POP R10
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET




;--------------------------------------------------------------------------------
asteroide_ecra:;Recebe argumento R9 o asteroide e R1 que vai ser o output
	PUSH R10	;R10 vai ser onde percorremos os Asteroides
	PUSH R11
asteroide_loop_ecra:
	inicializacao_loop_ecra:
		MOV R1,1 						;inicializar contador R1 a 1
		MOV R11, DEF_ASTEROIDE_1			;inicializar Asteroide
		MOV R10,8 						;incrementacao memoria para passar de um asteroide para o proximo
	loop_interno_ecra:
		CMP R1,5						;Verificar fim quando R1 chega a 5
		JZ asteroide_ecra_fim		;Acabar loop e o spawn dos asteroides

		CMP R11,R9
		JZ asteroide_ecra_fim
		ADD R11,R10  						;Passar para o proximo asteroide
		ADD R1,1 						;Incrementar de 1 o contador
		JMP loop_interno_ecra				;Repetir Loop

	asteroide_ecra_fim:
		POP R11
		POP R10
		RET

	
;--------------------------------------------------------------------------------
numero_aleatorio_spawn:
	MOV R1, ENTRADA_PIN ;ler inputs do PIN 
	MOVB R5,[R1]
	SHR R5,4
	MOV R3,5
	MOD R5,R3 ;Vamos ter restos de 0,1,2,3,4. Isto da 5 possibilidades equiprovaveis
	RET





;************************************************************************************
;************************** Rotinas detecao de colisao ******************************
;************************************************************************************

colisao_detecta_sonda_ast: 				; verifica uma colisao entre um asteroide no registro R9 e uma sonda no registro R10, se encontrar uma colisao, elimina a sonda e o asteroide
;-------------------------------------------------------------------------------
colisao_detecta_start:
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	MOV R3, [R10]  			; coordenada x da sonda
	MOV R4, [R10+2] 			; coordenada y da sonda
	MOV R5, [R9] 				; coordenada x inicio asteroide
	MOV R6, R5
	ADD R6, LARGURA_ASTEROIDE  	; coordenada x final asteroide
	MOV R7, [R9+2] 			; coordenada y inicio asteroide
	MOV R8, R7
	ADD R8, LARGURA_ASTEROIDE 	; coordenada y final asteroide

	CMP R5, NULO
	JZ cdf
colisao_detecta_main:
	colisao_detecta_x:			; detectamos se a sonda se encontra entre o inicio e final do asteroide em x
		CMP R3, R5
		JLT cdf  				; se nao, saltamos para o final pois nao ha colisao
		CMP R3, R6
		JGT cdf
	colisao_detecta_y: 			; detectamos se a sonda se encontra entre o inicio e final do asteroide em y
		CMP R4,R8
		JGT cdf
		CMP R4, R7
		JLT cdf
colisao_detecta_true:
	CALL switch_ecra_sondas 	; remover sonda	
	CALL sonda_apaga_memoria	
	CALL sonda_remeter_nulo 	


transforma_estado_colisao:
	MOV R2,[R9+6] 				;Observamos o estado
	CMP R2, NAO_MINERAVEL
	JZ transforma_estado_nao_mineravel
	CMP R2, MINERAVEL
	JZ transforma_estado_mineravel
	JMP cdf

transforma_estado_mineravel:
	MOV R2, MINERAVEL_DESTRUIDO_1
	MOV [R9+6], R2
	JMP cdf

transforma_estado_nao_mineravel:
	MOV R2, NAO_MINERAVEL_DESTRUIDO
	MOV [R9+6], R2
	CALL som_asteroide  		; som asteroide destruido 
	JMP cdf

cdf:
colisao_detecta_fim:	
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3 
	POP R2
	RET
;-------------------------------------------------------------------------------




colisao_sonda: 						; chama a funcao de detecao de colisao para todas as permutacoes de sondas e asteroides.
;-------------------------------------------------------------------------------
colisao_call_inicial:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R9
	PUSH R10
colisao_call_loop:

	col_inicializacao:
		MOV R1, 0           		; Inicializa contador externo (R1) como 0
		MOV R9, DEF_ASTEROIDE_1		; inicializa a R9 o endereco com as coordenadas dos asteroide
		MOV R4,8 					;Offset de 8 para passar para o proximo asteroide

	col_loopExterno: 	; loop dos asteroides
	    	CMP R1, 4       			; Compara contador externo com 4 (pois temos 4 asteroides)
	    	JZ col_feito                      ; Se for igual, pula para 'feito' (loop externo completo)
	    	MOV R2, 0         			; Inicializa contador interno (R2) como 0
	    	MOV R10, DEF_SONDA_CENTRO 	; inicializa a R10 o endereco com as coordenadas das sondas

	col_loopInterno: 	; loop das sondas

	 	CMP R2, 3        			; Compara contador interno com 3 (pois temos 3 sondas)
		JZ col_loopInternoConcluido       ; Se for igual, pula para 'loopInternoConcluido' (loop interno completo)

		CALL colisao_detecta_sonda_ast

		ADD R10, 4 				; adiciona 4 ao endereco das sondas para passar a proxima sonda
	   	ADD R2, 1            		; Incrementa contador interno
		JMP col_loopInterno               ; Pula para o início do loop interno

	col_loopInternoConcluido:
	    ADD R1, 1           			; Incrementa contador externo
	    ADD R9, R4					; passamos para o proximo endereco da coordenada do asteroide (must update to 8 after change)
	    JMP col_loopExterno                ; Pula para o início do loop externo

	col_feito:                            	; Loop externo completo
colisao_call_fim:
	POP R10
	POP R9
	
	POP R4
	POP R3
	POP R2
	POP R1
	RET
;-------------------------------------------------------------------------------




colisao_asteroide_nave: 						; chama a funcao de detecao de colisao um asteroide. recebe a coordenada do asteroide (R9)
;-------------------------------------------------------------------------------
colisao_asteroide_nave_inicio:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R10
	PUSH R11
	PUSH R0
colisao_asteroide_nave_verifica:
	MOV R1, [gameDeath]
	MOV R2, 1
	CMP R1, R2
	JZ colisao_asteroide_nave_fim 			; se ja houve colisao (perdemos jogo) , entao nao precisamos de verificar colisao
colisao_asteroide_nave_init:
	MOV R5, [R9] 							; coordenada x inicio asteroide
	MOV R6, R5
	ADD R6, LARGURA_ASTEROIDE  				; coordenada x final asteroide
	MOV R7, [R9+2] 							; coordenada y inicio asteroide
	MOV R8, R7
	ADD R8, LARGURA_ASTEROIDE 				; coordenada y final asteroide

	MOV R10, COLUNA_NAVE - 2				; coordenada x inicio nave
	MOV R11, LINHA_NAVE	- 2					; coordenada y inicio nave
	MOV R1, COLUNA_NAVE + LARGURA_NAVE - 2	; coordenada x final nave
	MOV R2, LINHA_NAVE + LONGURA_NAVE - 2	; coordenada y final nave

colisao_asteroide_nave_main:
	colisao_nave_detecta_x:					; detectamos se a nave se encontra entre o inicio e final do asteroide em x
		CMP R6, R10
		JLT colisao_asteroide_nave_fim 		; se nao, saltamos para o final pois nao ha colisao
		CMP R5, R1
		JGT colisao_asteroide_nave_fim
	colisao_nave_detecta_y: 				; detectamos se a nave se encontra entre o inicio e final do asteroide em y
		CMP R8,R2
		JLT colisao_asteroide_nave_fim
		CMP R7, R11
		JGT colisao_asteroide_nave_fim

colisao_asterodie_nave_ha_colisao: 			; se houver colisao
	CALL asteroide_eliminar
	CALL asteroide_remover
	CALL som_morte
	
	CALL disable_int_todas
	MOV R0, 1
	MOV [gameDeath], R0							; atualizo o flag 
	MOV [gameStopped], R0						; atualizo o flag 
	CALL muda_bg_deadExplosion					; mudamos o background
	CALL delete_display 						; apagamos os ecras
	CALL reset_memoria 							; damos reset a memoria		

colisao_asteroide_nave_fim:
	POP R0
	POP R11
	POP R10
	POP R8
	POP R7
	POP R6
	POP R5 
	POP R2
	POP R1
	RET
;-------------------------------------------------------------------------------



colisoes_nave: 						; chama a funcao de detecao de colisao um asteroide.
;-------------------------------------------------------------------------------
colisoes_nave_inicio:
PUSH R0
PUSH R9
PUSH R10
PUSH R11

MOV R9, DEF_ASTEROIDE_1 ; init R9 ao primeiro asteroide
colisoes_nave_main:
	MOV R10, 4 			; numero de asteroides para o loop
	MOV R11, 8  		; step para passar ao proximo asteroide
	MOV R0, 0 			; contador
	colisoes_nave_loop:
		CMP R0, R10 	; se ja verificamos os 4 asteroides entao acaba o loop
		JZ colisoes_nave_fim

		CALL colisao_asteroide_nave
 		
 		ADD R0, 1 		; incrementamos o contador
 		ADD R9, R11  	; passamos ao proximo asteroide
 		JMP colisoes_nave_loop
colisoes_nave_fim:
POP R11
POP R10
POP R9
POP R0
RET
;-------------------------------------------------------------------------------



;************************************************************
;** FUNCOES MUDAR ECRA **************************************
;************************************************************


;-------------------------------------------------------------------------------
switch_ecra_sondas:
	PUSH R1
	MOV R1, ECRA_SONDAS
	MOV [SELEC_ECRA], R1
	POP R1
	RET
;-------------------------------------------------------------------------------
switch_ecra_nave:
	PUSH R1
	MOV R1, ECRA_NAVE
	MOV [SELEC_ECRA], R1
	POP R1
	RET
;-------------------------------------------------------------------------------
switch_ecra_ast1:
	PUSH R1
	MOV R1, ECRA_ASTEROIDE_1
	MOV [SELEC_ECRA], R1
	POP R1
	RET
;-------------------------------------------------------------------------------
switch_ecra_ast2:
	PUSH R1
	MOV R1, ECRA_ASTEROIDE_1
	MOV [SELEC_ECRA], R1
	POP R1
	RET
;-------------------------------------------------------------------------------
switch_ecra_ast3:
	PUSH R1
	MOV R1, ECRA_ASTEROIDE_1
	MOV [SELEC_ECRA], R1
	POP R1
	RET
;-------------------------------------------------------------------------------
switch_ecra_ast4:
	PUSH R1
	MOV R1, ECRA_ASTEROIDE_1
	MOV [SELEC_ECRA], R1
	POP R1
	RET
;-------------------------------------------------------------------------------



;************************************************************
;** rotina de desenho ***************************************
;************************************************************


draw_object:  	 					; recebe: ecra: R0, endereco objeto: R1, posicao x: R7, posicao y: R8 e desenha esse objeto.
;-------------------------------------------------------------------------------
draw_object_inicio:
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5 	
	PUSH R6
	PUSH R11

	MOV R2, [R1] 					; R2 fica com o valor da largura (LINHA)
	ADD R1, 2 			
	MOV R3, [R1] 					; R3 fica com o valor da longura (COLUNA)

	MOV [SELEC_ECRA], R0 			; seleciona o ecra para desenhar
draw_object_loop:

	draw_inicializacao:
		MOV R0, 0           		; Inicializa contador externo (R0) como 0
		ADD R1, 2 				; Inicializa o endereco do objeto a primeira cor do objeto

		MOV R11, R7 				; faz uma copia da coordenada x para podermos voltar para esta em cada loop

	draw_loopExterno: 	; loop das colunas
	    	CMP R0, R3         			; Compara contador externo com R3 (pois temos R3 colunas)
	    	JZ draw_feito                 ; Se for igual, pula para 'feito' (loop externo completo)
	    	MOV R5, 0         			; Inicializa contador interno (R5) como 0

	    	MOV R7, R11 				; reinicializamos o valor de x para o seu inicial (primeiro valor da linha)

	draw_loopInterno: 	; loop das linhas
	 	CMP R5, R2      			; Compara contador interno com R2 (pois temos R2 linhas)
		JZ draw_loopInternoConcluido  ; Se for igual, pula para 'loopInternoConcluido' (loop interno completo)

		; desenhar o pixel da cor [R1] na posicao (R7,R8)
		MOV [DEFINE_COLUNA], R7
		MOV [DEFINE_LINHA], R8
		MOV R4, [R1]
		MOV [DEFINE_PIXEL], R4	

		ADD R7, 1 				; Incrementamos de 1 o valor em x para o objeto mexer para a frente na linha
	   	ADD R5, 1            		; Incrementa contador interno

	   	ADD R1, 2 				; Incrementamos o endereco para passar a proxima cor.

		JMP draw_loopInterno          ; Pula para o início do loop interno

	draw_loopInternoConcluido:
	    ADD R0, 1           			; Incrementa contador externo
	    ADD R8, 1 					; Incrementamos de 1 o valor em y para o objeto descer de linha
	    JMP draw_loopExterno           ; Pula para o início do loop externo

	draw_feito:                         ; Loop externo completo
draw_object_fim:	
	POP R11
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	RET
;-------------------------------------------------------------------------------


delete_object:  	 					; recebe: ecra: R0, endereco objeto: R1, posicao x: R7, posicao y: R8 e apaga esse objeto.
;-------------------------------------------------------------------------------
delete_object_inicio:
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5 	
	PUSH R6
	PUSH R11

	MOV R2, [R1] 					; R2 fica com o valor da largura (LINHA)
	ADD R1, 2 			
	MOV R3, [R1] 					; R3 fica com o valor da longura (COLUNA)

	MOV [SELEC_ECRA], R0 			; seleciona o ecra para desenhar
delete_object_loop:

	delete_inicializacao:
		MOV R0, 0           		; Inicializa contador externo (R0) como 0
		MOV R11, R7 				; faz uma copia da coordenada x para podermos voltar para esta em cada loop

	delete_loopExterno: 	; loop das colunas
	    	CMP R0, R3         			; Compara contador externo com R3 (pois temos R3 colunas)
	    	JZ delete_feito               ; Se for igual, pula para 'feito' (loop externo completo)
	    	MOV R5, 0         			; Inicializa contador interno (R5) como 0

	    	MOV R7, R11 				; reinicializamos o valor de x para o seu inicial (primeiro valor da linha)

	delete_loopInterno: 	; loop das linhas
	 	CMP R5, R2      			; Compara contador interno com R2 (pois temos R2 linhas)
		JZ delete_loopInternoConcluido; Se for igual, pula para 'loopInternoConcluido' (loop interno completo)

		; apagar o pixel usando a cor 0 na posicao (R7,R8)
		MOV [DEFINE_COLUNA], R7
		MOV [DEFINE_LINHA], R8
		MOV R4, 0
		MOV [DEFINE_PIXEL], R4	

		ADD R7, 1 				; Incrementamos de 1 o valor em x para o objeto mexer para a frente na linha
	   	ADD R5, 1            		; Incrementa contador interno

		JMP delete_loopInterno        ; Pula para o início do loop interno

	delete_loopInternoConcluido:
	    ADD R0, 1           			; Incrementa contador externo
	    ADD R8, 1 					; Incrementamos de 1 o valor em y para o objeto descer de linha
	    JMP delete_loopExterno         ; Pula para o início do loop externo

	delete_feito:                      ; Loop externo completo
delete_object_fim:	
	POP R11
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	RET
;-------------------------------------------------------------------------------


;** Spawn Inicial da Nave *********************************************************

spawn_inicial_nave: 		; rotina para spawnar a nave
	PUSH R0
	PUSH R1
	PUSH R7
	PUSH R8
	MOV R0, ECRA_NAVE
	MOV R1, DESENHO_NAVE
	MOV R7, COLUNA_NAVE
	MOV R8, LINHA_NAVE
	CALL draw_object
	POP R8
	POP R7
	POP R1
	POP R0 
	RET


;************************************************************
;******************* ROTINAS DE MEDIA  **********************
;************************************************************

;** Rotinas mudar fundos de ecra ****************************
;************************************************************

;-------------------------------------------------------------------------------
muda_bg_deadExplosion:
	PUSH R1
	MOV	R1, 0					; cenário de fundo número 0
	CALL pause_bg
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    POP R1
    RET

muda_bg_deadEnergy:
	PUSH R1
	MOV	R1, 1					; cenário de fundo número 1
	CALL pause_bg
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    POP R1
    RET

muda_bg_pause:
	PUSH R1
	MOV	R1, 2					; cenário de fundo número 2
	CALL pause_bg
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    POP R1
    RET

muda_bg_Start:
	PUSH R1
	MOV	R1, 3					; cenário de fundo número 3
	CALL pause_bg
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    POP R1
    RET

muda_bg_gameTerminated:
	PUSH R1
	MOV	R1, 4					; cenário de fundo número 4
	CALL pause_bg
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    POP R1
    RET

muda_bg_main:
	PUSH R1
	MOV	R1, 0					; VIDEO de fundo número 2
    MOV  [LOOP_VIDEO], R1	; seleciona o cenário de fundo
    POP R1
    RET

pause_bg:
	PUSH R1
	MOV R1, 0
	MOV [PAUSE_VID], R1
	MOV [STOP_VID], R1
	POP R1
	RET

delete_display: 			;funcao apagar ecras
	PUSH R0
	MOV R0, 0
	MOV [APAGA_ECRÃ], R0 		; valor de R0 nao interessa, apaga todos os ecras
	POP R9
	RET
;-------------------------------------------------------------------------------



;** Rotina play sound effects *******************************
;************************************************************

;-------------------------------------------------------------------------------
som_asteroide:
    PUSH R9
    MOV R9,1
    MOV [TOCA_SOM], R9
    POP R9
    RET

som_sonda:
    PUSH R9
    MOV R9,2
    MOV [TOCA_SOM], R9
    POP R9
    RET

som_asteroide_minerado:
	PUSH R9
    MOV R9,3
    MOV [TOCA_SOM], R9
    POP R9
    RET

som_morte:
	PUSH R9
    MOV R9,4
    MOV [TOCA_SOM], R9
    POP R9
    RET

som_menu_click:
	PUSH R9
    MOV R9,5
    MOV [TOCA_SOM], R9
    POP R9
    RET

som_inicio_jogo:
	PUSH R9
    MOV R9,6
    MOV [TOCA_SOM], R9
    POP R9
    RET
;-------------------------------------------------------------------------------

painel_atualiza:
;-------------------------------------------------------------------------------
painel_inicio:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R7
    PUSH R8
    PUSH R10
    PUSH R11

    MOV R0, ECRA_PAINEL
    MOV R2, DEF_PAINEL
    MOV R7, 30						; Coordenadas x do painel
    MOV R8, 30        				; Coordenadas y do painel
    MOV R1,[R2]         			; Objeto do painel
    MOV R10, PAINEL_INSTRUMENTOS_5
    CMP R1,R10
    JZ painel_reiniciar
    JMP painel_proximo_estado

painel_reiniciar:
    MOV R11,PAINEL_INSTRUMENTOS_1
    MOV [R2],R11
    CALL draw_object
    JMP painel_fim

painel_proximo_estado:
    MOV R3, TAMANHO_ENDER_PAINEL
    MOV R11, R1
    ADD R11,R3
    MOV [R2], R11
    CALL draw_object
    JMP painel_fim

painel_fim:
    POP R11
    POP R10
    POP R8
    POP R7
    POP R3
    POP R2
    POP R1
    POP R0
    RET
;-------------------------------------------------------------------------------





;************************************************************
;** rotina limpar memoria ***********************************
;************************************************************

reset_memoria: 		; elimina a informacao das posicoes das sondas
;-------------------------------------------------------------------------------
reinicializar_dados_inicio:;Reinicia todos os dados
    PUSH R1
    PUSH R2
    PUSH R10
    PUSH R11    ;R11 vai ser onde percorremos os Asteroides
	asteroide_dados_loop:
	    MOV R2, NULO
	    inicializacao_loop_dados_asteroide:
	        MOV R1,1                         ;inicializar contador R1 a 1
	        MOV R11, DEF_ASTEROIDE_1            ;inicializar Asteroide
	        MOV R10,8                         ;incrementacao memoria para passar de um asteroide para o proximo
	    loop_interno_asteroide_dados:
	        CMP R1,5                        ;Verificar fim quando R1 chega a 5
	        JZ asteroide_dados_fim        ;Acabar loop e o spawn dos asteroides

	        MOV [R11],R2
	        MOV [R11+2],R2
	        MOV [R11+4],R2
	        MOV [R11+6],R2
	        ADD R11,R10                          ;Passar para o proximo asteroide
	        ADD R1,1                         ;Incrementar de 1 o contador
	        JMP loop_interno_asteroide_dados                ;Repetir Loop
	    asteroide_dados_fim:

sonda_dados_loop:
    inicializacao_loop_dados_sonda:
        MOV R1,1                         ;inicializar contador R1 a 1
        MOV R11, DEF_SONDA_CENTRO            ;inicializar Asteroide
        MOV R10,4                         ;incrementacao memoria para passar de um asteroide para o proximo
    loop_interno_sonda_dados:
        CMP R1,4                        ;Verificar fim quando R1 chega a 5
        JZ sonda_dados_fim        ;Acabar loop e o spawn dos asteroides

        MOV [R11],R2
        MOV [R11+2],R2
        ADD R11,R10                          ;Passar para o proximo asteroide
        ADD R1,1                         ;Incrementar de 1 o contador
        JMP loop_interno_sonda_dados                ;Repetir Loop
    sonda_dados_fim:

reiniciar_energia:
    MOV R1, V_DISPLAYS
    MOV R2, 100
    MOV [R1],R2

reinicializar_dados_fim:
    POP R11
    POP R10
    POP R2
    POP R1
    RET
;-------------------------------------------------------------------------------


;************************************************************
;** rotinas de interrupcoes *********************************
;************************************************************

enable_int_todas: 	; activamos as interrupcoes
	PUSH R0
 	MOV R0, 1
	MOV [I0], R0
	MOV [I1], R0
	MOV [I2], R0
	MOV [I3], R0
	POP R0
	RET

disable_int_todas:  ; desactivamos as interrupcoes
	PUSH R0
 	MOV R0, 0
	MOV [I0], R0
	MOV [I1], R0
	MOV [I2], R0
	MOV [I3], R0
	POP R0
	RET

;-------------------------------------------------------------------------------
inter_1_Sonda:
	PUSH R0
	PUSH R1

	MOV R1, I1
	MOV R0, [R1]
	CMP R0, 0
	JZ ret_inter_1

	CALL sonda_main
	CALL colisao_sonda

	ret_inter_1:
	POP R1
	POP R0
	RFE




inter_2_Ener:
	PUSH R0
	PUSH R1
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8

	MOV R1, I2
	MOV R0, [R1]
	CMP R0, 0
	JZ ret_inter_2

	MOV R8, DECREMENTO_AUTO_ENERG
	MOV R7, [V_DISPLAYS]
	SUB R7, R8
	MOV R6, R7								; guardo o valor em hexadecimal noutra variável 										
	CALL decimal
	MOV [DISPLAYS], R5						; atualizo com o valor em decimal
	MOV R7, R6								; para depois ir decrementando o valor em hexadecimal 
											; pq se decrementar o valor já convertido, irá dar um valor muito superior
	MOV [V_DISPLAYS],R7
	CALL verificar_energia

	ret_inter_2:
	POP R8
	POP R7
	POP R6
	POP R5
	POP R1
	POP R0
	RFE


inter_0_Aster:
	PUSH R0
	PUSH R1
	MOV R1, I0
	MOV R0, [R1]
	CMP R0, 0
	JZ ret_inter_0

	CALL asteroide_main
	CALL colisoes_nave
	ret_inter_0:
	POP R1
	POP R0
	RFE

inter_3_Nave:
	PUSH R0
	PUSH R1
	MOV R1, I3
	MOV R0, [R1]
	CMP R0, 0
	JZ ret_inter_3
	CALL painel_atualiza
	ret_inter_3:
	POP R1
	POP R0
	RFE
;-------------------------------------------------------------------------------
