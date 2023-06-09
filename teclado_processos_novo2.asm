;** Constantes***********************************************
;************************************************************

DISPLAYS   			EQU 0A000H  					; endereço dos displays de 7 segmentos (periférico POUT-1)
V_DISPLAYS			EQU 100
DISPLAYS_VALOR		EQU 100H
TEC_LIN    			EQU 0C000H  					; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    			EQU 0E000H  					; endereço das colunas do teclado (periférico PIN)
MASCARA    			EQU 000FH   					; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
LINHA 				EQU 16
ZERO				EQU 0
TECLA_4				EQU 4
TECLA_5				EQU 5
TECLA_6				EQU 6
COMANDOS				EQU	6000H					; endereço de base dos comandos do MediaCenter
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H			; endereço do comando para selecionar uma imagem de fundo


;*************************************************************

	PLACE 1000H
	
	
tabInterrupcoes:
	WORD 0
	WORD 0
	WORD inter_2_ener
	WORD 0

; Reserva do espaço para as pilhas dos processos
	STACK 100H										; espaço reservado para a pilha do processo "programa principal"
SP_inicial:											; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H										; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:									; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H										; espaço reservado para a pilha do processo "teclado"
SP_inicial_controlo:								; este é o endereço com que o SP deste processo deve ser inicializado



tecla_carregada:
	LOCK 0											; LOCK para o teclado comunicar aos restantes processos que tecla detetou

comeco_jogo:
	WORD 1											; flag que indica se j+a começou o jogo ou não
	
fim_jogo:
	WORD 0											; flag que indica se o jogo acabou ou não 
													;(1 para falta de energia, 2 para colisao e 3 para ação voluntária)
pausa_jogo:
	WORD 0											; flag que indica se o jogo está em pausa

;*************************************************************

PLACE ZERO

inicio_teclado:
	MOV SP, SP_inicial
	MOV R0, DISPLAYS_VALOR

	MOV [DISPLAYS], R0								; inicializo os displays
	MOV R7, V_DISPLAYS								; R7- vai ser o registo onde vou atualizando os displays

	
	MOV BTE, tabInterrupcoes

	
	ciclo_teclado:
	CALL teclado									; crio o processo do teclado
	
	CALL controlo								; crio o processo para as teclas de controlo
	
		;MOV R0, [tecla_carregada]					; leio a tecla que foi posta no LOCK
	
		jogo_pausa:
			MOV R2, [pausa_jogo]
			MOV R1, 1								
			CMP R2, R1								; verifico se o jogo está em pausa
			JNZ fim									; se não, verifico se o jogo já terminou
		
			;CALL fun_tecla_pausa					; chamo a função que vai alterar o cenário de fundo na pausa
			
			MOV R2, [fim_jogo]						
			MOV R1, 3
			CMP R2, R1								; verifico se foi clicada a tecla para terminar o jogo
			JNZ ciclo_teclado						; desta maneira, se o jogo estiver em pausa, só vai poder continuar o jogo ou terminá-lo

			;JMP ciclo_teclado						; se ele está em pausa, então vai ter de continuar tar na pausa até for premida a tecla D de novo
			
	
		fim:
			MOV R2, [fim_jogo]						
			MOV R1, 0
			CMP R2, R1								; verifico se o jogo terminou
			JZ inicio								; se ainda não, volto ao inicio 
			
			DI2										; desativo as interrupções
			DI										
			
			MOV R3, 1
			CMP R2, R3								; verifico se o jogo terminou por falta de energia
			JZ falta_energia
			
			MOV R3, 2
			CMP R2, R3								; verifico se o jogo terminou devido a uma colisão
			JZ f_colisao
			
			MOV R3, 3
			CMP R2, R3								; verifico se foi fim voluntário
			JZ f_voluntario
		
		inicio:
			MOV R2, [comeco_jogo]
			MOV R1, 1
			CMP R2, R1								; verifico se o jogo já começou
			JZ  ciclo_teclado						; se ainda não, volto ao inicio (porque se ele ainda n começou não pode premir outras teclas)
	
			;CALL fun_tecla_start					; chamo a função que inicializa tudo para o início do jogo
			
			JMP ver_teclas
		
	
ver_teclas:

	
	sonda_para_direita:
		CMP R0, TECLA_4								; tecla 4 para mexer a sonda para a direita
		JNZ sonda_para_centro
		;CALL sonda_spawn_direita
		CALL decresce_sonda							; a energia decresce 5 por cada sonda lançada
		
	sonda_para_centro:
		CMP R0, TECLA_5								; tecla 5 para mexer a sonda em frente
		JNZ sonda_para_esquerda
		;CALL sonda_spawn_centro
		CALL decresce_sonda							; a energia decresce 5 por cada sonda lançada
		
	sonda_para_esquerda:
		MOV R2, TECLA_6								; tecla 9 para mexer a sonda para a esquerda
		CMP R0, R2
		JNZ ciclo_teclado
		;CALL sonda_spawn_esquerda
		CALL decresce_sonda							; a energia decresce 5 por cada sonda lançada
	JMP ciclo_teclado
	

falta_energia:
	JMP inicio

f_colisao:
	JMP inicio

f_voluntario:
	JMP inicio

;************************************************************
; Processos   ***********************************************

PROCESS SP_inicial_teclado
teclado:

espera_tecla:
	WAIT										; ciclo potencialmente bloqueante
	MOV R6, ZERO								; contador geral (multi-usos)
	MOV R4, LINHA								; inicializo o contador das linhas
	
	percorrer_teclas:
	SHR R4, 1
	JZ espera_tecla								; se for a primeira linha, volto ao inicio
	
	MOV  R1, R4									; indico a linha a ser testada
	CALL leitura_teclado						; chamo a rotina que verifica se está premida uma tecla
	CMP  R0, ZERO								; há tecla premida?
	JNZ tecla_premida				
	JMP percorrer_teclas
	
	CALL tecla_premida

ha_tecla:
	YIELD										; este ciclo é potencialmente bloqueante, pelo que tem de
												; ter um ponto de fuga (aqui pode comutar para outro processo)
	
	MOV R1, R4 									; inicializo a linha a ser testada
    CALL leitura_teclado						; chamo a rotina que verifica se está premida uma tecla
    CMP  R0, ZERO								; há tecla premida?
    JNZ  ha_tecla								; se ainda houver uma tecla premida, espera até não haver
	JMP percorrer_teclas

;Rotinas *******************************************************************************
controlo:
	PUSH R1
	PUSH R2
	
	MOV R0, [tecla_carregada]
	
	start:	
		MOV R1, 0CH
		CMP R0, R1								; verifico se foi premida a tecla C - começo
		JNZ pausa
		MOV R1, 0
		MOV [comeco_jogo], R1					; altero o flag a indicar que já começou o jogo
		EI2										; ativo as interrupções
		EI
		;CALL fun_tecla_start
	
	pausa:
		MOV R1, 0EH
		CMP R0, R1								; verifico se foi premida a tecla D - pausa
		JNZ fim_voluntario
		condicao_pausa:
			MOV R2, [pausa_jogo]				; verifico se já o jogo já estava em pausa
			CMP R2, 1
			JNZ atualiza_flag					; se não, atualizo o flag para indicar que foi para pausa
			MOV R1, 0
			MOV [pausa_jogo], R1				; como foi premida tecla D de novo, atualizo o flag para sair da pausa
			EI2									; ativo as interrupções
			EI
			JMP fim_voluntario
		atualiza_flag:
			MOV R1, 1
			MOV [pausa_jogo], R1				; altero o flag a indicar que o jogo foi pausado
			DI2									; desativo as interrupções
			DI
	
	fim_voluntario:
		MOV R1, 0DH
		CMP R0, R1								; verifico se foi premida a tecla E - fim
		JNZ fim_energia
		MOV R1, 3
		MOV [fim_jogo], R1						; altero o flag a indicar que o jogador terminou voluntariamente
	
	fim_energia:
		MOV R1, R7
		CMP R1, 0000H							; verifico se a energia da nave chegou a 0
		JNZ fim_colisao
		MOV R1, 1
		MOV [fim_jogo], R1						; altero o flag a indicar que o jogo terminou por falta de energia
	
	fim_colisao:
		; chamar rotina que deteta colisões
		;JNZ controlo
		;MOV R1, 2						
		;MOV [fim_jogo], R1						; altero o flag a indicar que o jogo terminou devido a uma colisão

	POP R2
	POP R1
	RET

leitura_teclado:
	PUSH R2
	PUSH R3
	PUSH R5
	MOV  R2, TEC_LIN							; endereço do periférico das linhas
	MOV  R3, TEC_COL							; endereço do periférico das colunas
	MOV  R5, MASCARA							; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB  [R2], R1								; escrever no periférico de entrada( linhas)
	MOVB  R0, [R3]								; ler do periférico de saída (colunas)
	AND  R0, R5									; isolar os últimos 4 bits
	POP R5
	POP R3
	POP R2
	RET

tecla_premida:
	PUSH R6
	MOV R6, ZERO								; inicializo o contador
	converte_linha:
		ADD R6,1
		SHR R1,1								; conta-se o numero de ciclos que é preciso para a linha ficar a 0
		JNZ converte_linha
		SUB R6, 1								; porque as lihas vão de 1-4 e precisamos de 0-3
	
	MOV R1, R6									; converte a linha para 0-3
	MOV R6, ZERO								; reinicializo o contador para as colunas
	
	converte_coluna:
		ADD R6, 1								; conta-se o numero de ciclos que é preciso para a coluna ficar a 0
		SHR R0, 1
		JNZ converte_coluna
		SUB R6, 1								; subtrai 1 pq as colunas vao de 0-3 em vez de 1-4
	
	MOV R0, R6									; converte a coluna para 0-3
	
	MOV R6, 4
	MUL R1, R6									; 4*LINHA
	ADD R1, R0									; linha + coluna
	
	MOV [tecla_carregada], R1					; atualiza a tecla carregada
	POP R6
	RET


decresce_sonda:
	PUSH R0
	MOV R0, 5
	SUB R7, R0									; R7 é o meu contador do valor dos displays que vai-se ir sempre atualizando
	MOV R6, R7									; guardo o valor em hexadecimal para executar as operações no hexadecimal e não no decimal
	CALL decimal
	MOV [DISPLAYS], R5							; atualizo os displays com o valor em decimal
	MOV R7, R6
	POP R0
	RET
	

energia_asteroide_min:
	PUSH R0
	MOV R0, 25
	ADD R7, R0
	
	MOV R6, R7									; guardo o valor em hexadecimal para executar as operações no hexadecimal e não no decimal
	CALL decimal
	MOV [DISPLAYS], R5							; atualizo os displays com o valor em decimal
	MOV R7, R6
	POP R0
	RET

decimal: 
	PUSH R0
	PUSH R4
	PUSH R2


	MOV R0, 1000							; FATOR
	MOV R5, 0								; RESULTADO
	MOV R2, 10								
	ciclo1:
		MOD R7, R0							; número: o valor a converter nesta iteração
											; fator: uma potência de 1000 (para obter os dígitos)
		DIV R0, R2							; prepara o próximo fator de divisão
		CMP R0, 1
		JLT fim_ciclo1
		MOV R4, R7							; mais um dígito do valor decimal (0 a 9)
		DIV R4, R0
		
		SHL R5, 4
		OR R5, R4							; vai compondo o resultado
		JMP ciclo1
		
	
	fim_ciclo1:


		POP R2
		POP R4
		POP R0
		RET
		


; Rotinas de interrupcao *************************************
;*************************************************************

inter_2_ener:
	DEC R7
	MOV R6, R7								; guardo o valor em hexadecimal noutra variável 
											
	CALL decimal
	
	MOV [DISPLAYS], R5						; atualizo com o valor em decimal
		
	MOV R7, R6								; para depois ir decrementando o valor em hexadecimal 
											; pq se decrementar o valor já convertido, irá dar um valor muito superior
	RFE
	