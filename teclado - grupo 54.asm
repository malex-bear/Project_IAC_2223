;** Constantes***********************************************
;************************************************************
COMANDOS			EQU 6000H
DISPLAYS   			EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    			EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    			EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
MASCARA    			EQU 000FH   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
DISPLAY_VALOR		EQU 0100H	; valor  predefenido para os displays 
LINHA 				EQU 8
ZERO				EQU 0
TECLA_4				EQU 4
TECLA_1				EQU 1
TECLA_2				EQU 2
TOCA_SOM			EQU COMANDOS + 5AH

; ***********************************************************
; * Dados 
; ***********************************************************

PLACE       1000H
pilha:
	STACK 100H					; espaço reservado para a pilha 
								; (200H bytes, pois são 100H words)
SP_inicial:						; este é o endereço (1200H) com que o SP deve ser 
								; inicializado. O 1.º end. de retorno será 
								; armazenado em 11FEH (1200H-2)

;**Código ***************************************************

PLACE ZERO
inicio:							;inicializacoes
	MOV SP, SP_inicial			;inicializa SP para a palavra a seguir
								;à última da pilha
	MOV R2, TEC_LIN				;endereco do periférico das linhas
	MOV R3, TEC_COL				;endereco do periférico das colunas
	MOV R4, MASCARA				;para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV R1,DISPLAY_VALOR
	MOV [DISPLAYS], R1
	MOV R7, DISPLAY_VALOR		;crio uma variável que vai ser atualizada 
								;sempre que houver alterações nos displays

ciclo:
	
	MOV R5, LINHA				;contador das linhas já percorridas				

espera_tecla:					;espera até uma tecla ser premida

	MOV R6, ZERO				;contador para conversao das linhas e colunas
	MOV R1, R5					;inicializo a linha a ser testada
	MOVB [R2], R1				;redireciona a linha para o periférico de linhas
	MOVB R0,[R3]				;lê a coluna lida
	AND R0, R4					;isola os 4 bits de menor peso
	CMP R0,ZERO
	JNZ tecla_premida			;se houver uma tecla premida, 
								;passa para a parte de alterar os displays
	JMP ha_tecla

tecla_premida:
	CALL converte_linha 
	SUB R6, 1					;subtrai 1 pq as linhas vao de 0-3 em vez de 1-4
	MOV R1, R6					;converte a linha para 0-3
	MOV R6, ZERO				;reinicializo o contador para as colunas
	CALL converte_coluna
	SUB R6, 1					;subtrai 1 pq as colunas vao de 0-3 em vez de 1-4
	MOV R0, R6					;converte a coluna para 0-3
	
	;processo de conversão para hexadecimal
	MOV R6, TECLA_4
	MUL R1, R6					;4* linha	
	OR R1,R0					;linha + coluna
	
	CMP R1,R6 					;correspondente à tecla '4' 
	JZ incrementa_display
	
	MOV R6, LINHA
	CMP R1,R6            		;correspondente à tecla '8'
	JZ decrementa_display
	
	MOV R6, TECLA_1				;correspondente à tecla '1'
	CMP R1,R6
	CALL SOM_SONDA
	
	MOV R6, TECLA_2				;correspondente à tecla '2'
	CMP R1, R6
	

ha_tecla:						;verifica se existem mais alguma tecla a ser premida
	MOV R1, R5					;inicializo a linha a ser testada
	MOVB [R2], R1				;redireciona a linha para o periférico de linhas
	MOVB R0,[R3]				;lê a coluna lida
	AND R0, R4					;isola os 4 bits
	CMP R0,ZERO					;verifica se existe uma tecla premida
	JNZ ha_tecla				; se exitir, repete o ciclo até não houver
	SHR  R5,1					;para passar para a linha anterior
	CMP	 R5, ZERO				;verifica se é a primeira linha
    JNZ  espera_tecla   		;se não for a primeira linha, continua a percorrer o teclado
	JMP ciclo

incrementa_display:
	INC R7						; incrementa o valor do display

    ; Atualiza o valor do display
    MOV [DISPLAYS], R7

    JMP  ha_tecla           	; volta ao início do ciclo

decrementa_display:
	DEC R7						; decrementa o valor do display

    ; Atualiza o valor do display
    MOV [DISPLAYS], R7

    JMP  ha_tecla           	; volta ao início do ciclo
	
;** Rotinas**************************************************
;************************************************************

converte_linha:
	ADD R6,1
	SHR R1,1					; conta-se o numero de ciclos que é preciso para a linha ficar a 0
	JNZ converte_linha
	RET

converte_coluna:
	ADD R6, 1					; conta-se o numero de ciclos que é preciso para a coluna ficar a 0
	SHR R0, 1
	JNZ converte_coluna
	RET
	
SOM_SONDA:
	PUSH R9
	MOV R9,0
	MOV [TOCA_SOM],R9
	POP R9
	RET