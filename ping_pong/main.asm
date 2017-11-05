;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
			.include	timer.asm

			.define	32768,UM_SEG
			.eval UM_SEG / 2,MEIO_SEG
			.eval	32767 * 2,DOIS_SEG
			.define	0,PREP_SAQUE
			.define 1,SAQUE_JG_DIR
			.define	2,SAQUE_JG_ESQ
			.define	3,EM_JOGO
			.define	0,JG_ESQ_REBATEU
			.define	1,JG_DIR_REBATEU
			.define 0,PARA_ESQ
			.define 1,PARA_DIR
			.define 5,TMP_PREP_SAQUE


            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
			.def	PLACAR_NUM,PONTOS_JQ_DIR,PONTOS_JQ_ESQ,LINHA_1,LINHA_2
			.def 	ESTADO,EM_PAUSA

			.global valor_serial

            .data
LEDS										;Variável para controlar qua led estará ligado
			.byte	0x00
DIRECAO		.byte	0x00
PONTOS_JQ_DIR
			.word	0x00
PONTOS_JQ_ESQ
			.word	0x00
ESTADO
			.byte	0x00
REBATIDA	.byte	0x00

EM_PAUSA	.byte	0x00
FREQ_ATUAL	.word	0x0000

PLACAR_NUM	.byte	0x00,0x00,0x00

LINHA_1		.byte	"Placar Ping-Pong",0x00
LINHA_2		.byte	"   "
PLACAR_JG_ESQ
			.byte	0x30,0x30,0x30
			.byte   "  X  "
PLACAR_JG_DIR
			.byte	0x30,0x30,0x30
			.byte	"   ",0x00


;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;-------------------------------------------------------------------------------
;			Configura as portas P9.0 a P9.6, para ligar a linha de leds
;-------------------------------------------------------------------------------
			mov.b	#BIT6 | BIT5 |BIT4 | BIT3 | BIT2 | BIT1 | BIT0,P9DIR	;P1.0, configura como saida
			mov.b	#0,P9OUT												;P1.0, coloca em estado baixo(0), desliga led vermelho
			bic.w   #LOCKLPM5,&PM5CTL0										;Destrava FRAM

;-------------------------------------------------------------------------------
;			Configura a porta P1.5 (botão jogador DIR), como entrada com pull up register
;-------------------------------------------------------------------------------
			bic		#BIT5,P1DIR				;Limpa bit, P1.5 como entrada
			bis		#BIT5,P1OUT				;Seta bit para configurar a porta com pull up register
			bis		#BIT5,P1REN				;Seta bit para configurar a porta com pull up register
			bic		#BIT5,P1IFG				;Limpa bit indicador de interrupção
			bis		#BIT5,P1IES				;Seta bit, interrupção vai ser disparada na transição ALTO BAIXO
			bis		#BIT5,P1IE				;Seta bit, interrução de P1.5, habilitadas
;-------------------------------------------------------------------------------
;			Configura a porta P1.6 (botão jogador ESQ), como entrada com pull up register
;-------------------------------------------------------------------------------
			bic		#BIT6,P1DIR				;Limpa bit, P1.6 como entrada
			bis		#BIT6,P1OUT				;Seta bit para configurar a porta com pull up register
			bis		#BIT6,P1REN				;Seta bit para configurar a porta com pull up register
			bic		#BIT6,P1IFG				;Limpa bit indicador de interrupção
			bis		#BIT6,P1IES				;Seta bit, interrupção vai ser disparada na transição ALTO BAIXO
			bis		#BIT6,P1IE				;Seta bit, interrução de P1.6, habilitadas
;-------------------------------------------------------------------------------
;			Ligação das portas MSP X LCD
;-------------------------------------------------------------------------------
;			P4.0 <--------------------->Pino 11 (DB4)
;			P4.1 <--------------------->Pino 12 (DB5)
;			P4.2 <--------------------->Pino 13 (DB6)
;			P4.3 <--------------------->Pino 14 (DB7)
;			P2.1 <--------------------->Pino 06 (ENABLE)
;			P2.5 <--------------------->Pino 04 (RS)
;-------------------------------------------------------------------------------
;			Configura as portas P4.0 a P4.3 para troca de dados com o Lcd
;			Configura porta P2.1 para pino (enable) do lcd
;			Configura porta P2.5 para pino (RS) do lcd
;-------------------------------------------------------------------------------
			bis.b	#BIT0 | BIT1| BIT2| BIT3,P4DIR		;P4.0 a P4.3, configura como saida
			bis.b	#BIT1| BIT5,P2DIR					;P2.1 a P2.5, configura como saida
;-------------------------------------------------------------------------------
;			Configura o Timer_A, modo continuo
;-------------------------------------------------------------------------------

			mov.w   #CCIE,&TA0CCTL0         		; TACCR0 interupção habilitada
            mov.w   #UM_SEG,&TA0CCR0				; Conta até 32767 e gera interrupção
            mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  	; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
;-------------------------------------------------------------------------------
;			Configura o Timer_A_1, modo continuo, utilizado para o Delay do LCD
;-------------------------------------------------------------------------------
			mov.w	#0,&TA1CCR0							;Para o Timer 1
			mov.w   #CCIE,&TA1CCTL0         			; TACCR0 interupção habilitada
            ;mov.w   #UM_MILI_SEG,&TA1CCR0				; Interruções em 1 milisegundos
            mov.w   #TASSEL__ACLK+MC__UP,&TA1CTL  		; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up


            mov.w	 #2,&valor_serial
;-------------------------------------------------------------------------------
;			habilita interrupções mascaráveis
;-------------------------------------------------------------------------------
            nop
            bis.w   #GIE,SR
            nop
;-------------------------------------------------------------------------------
;			Inicia LCD
;-------------------------------------------------------------------------------
			INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT

;-------------------------------------------------------------------------------
;			Inicia partida
;-------------------------------------------------------------------------------
            mov.b	#BIT0,&LEDS							;Prepara para ligar o Led da extrema direita
            mov.b	&LEDS,P9OUT							;Liga o Led da extrema direita
            mov.b	#SAQUE_JG_DIR,&ESTADO				;Estado inicial o jogo. Saque do jogador da direita
            mov.b	#0,&EM_PAUSA						;Jogo não esta pausado
;-------------------------------------------------------------------------------
			call	#PRINT_PLACAR						;Mostra o placar
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP
			jmp		LOOP								;loop infinito
			nop

PISCA
			cmp.b	#EM_JOGO,&ESTADO
			jz		INICIO
			reti
			cmp.b	#SAQUE_JG_ESQ,&ESTADO
			jz		JG_ESQ_SACA
			cmp.b	#SAQUE_JG_DIR,&ESTADO
			jz		JG_DIR_SACA
JG_ESQ_SACA
			mov.b	#BIT6,&LEDS
            mov.b	&LEDS,P9OUT
            mov.b	#1,DIRECAO
            reti
JG_DIR_SACA
 			mov.b	#BIT0,&LEDS
            mov.b	&LEDS,P9OUT
            mov.b	#PARA_ESQ,DIRECAO
            reti
INICIO
			cmp.b	#PARA_ESQ,DIRECAO					;Verifica se a Direção do acendimento dos leds é para a esquerda
			jnz		DIR									;Se não for para a Esquerda, então é para a direita
ESQ														;Se não pular a direção é para a esquerda
			bit.b	#BIT6,LEDS							;Verifica se já chegou na extrema esquerda (bit6)
			jnz		DIR									;Se chegou na extrema esquerda, muda de direção (para a direita)
			mov.b	#PARA_ESQ,DIRECAO					;Informa a direção atual
			bit.b	#BIT0,LEDS							;Led da extrema direita ligado?
			jz		MOVE_BOLA_ESQ						;Se Led da extrema direita desligado. Move bola para esquerda
			cmp.b	#JG_DIR_REBATEU,&REBATIDA			;Led da extrema direita ligado. antes de apaga-lo e acender o proximo, verifica se o jogador da direita fez a rebatida.
			jnz		JG_DIR_NAO_REBATEU					;Jogador da direita não rebateu. Pula.
MOVE_BOLA_ESQ
			mov.b	#EM_JOGO,&ESTADO					;Caso o jogador tenha rebatido ou o led aceso não seja o da estrema direita. Muda estado do jogo.
			rla.b	&LEDS								;prepara para ligar o próximo LED da esquerda
			mov.b	&LEDS,P9OUT							;Liga o próximo LED da esquerda, apaga os outros.
			reti

JG_DIR_NAO_REBATEU										;Jogador da direita não rebateu. Led da extrema direita acendeu e o jogador não fez nada.
			call 	#FALHA_JG_DIR						;chama a função.
			reti
DIR
			bit.b	#BIT0,LEDS							;Verifica se já chegou na extrema direita (bit0)
			jnz		ESQ									;Se chegou na extrema direita, muda de direção (para a esquerda)
			mov.b	#PARA_DIR,DIRECAO					;Informa a direção atual
			bit.b	#BIT6,LEDS							;Led da extrema esquerda ligado?
			jz		MOVE_BOLA_DIR						;Se Led da extrema esquerda desligado. Move bola para direita
			cmp.b	#JG_ESQ_REBATEU,&REBATIDA			;Led da extrema esquerda ligado. antes de apaga-lo e acender o proximo, verifica se o jogador da esquerda fez a rebatida.
			jnz		JG_ESQ_NAO_REBATEU					;Jogador da esquerda não rebateu. Pula.
MOVE_BOLA_DIR
			mov.b	#EM_JOGO,&ESTADO					;Caso o jogador tenha rebatido ou o led aceso não seja o da estrema esquerd. Muda estado do jogo.
			rra.b	LEDS								;prepara para ligar o próximo LED da direita
			mov.b	LEDS,P9OUT							;Liga o próximo LED da direita, apaga os outros.
			reti
JG_ESQ_NAO_REBATEU										;Jogador da esquerda não rebateu. Led da extrema esquerda acendeu e o jogador não fez nada.
			call 	#FALHA_JG_ESQ						;Chama a função
F_PISCA
			reti

BUTTON_JG
			;xor		#CCIE,&TA0CCTL0						;Desabilita a interrupção do contador 0. O led que estava aceso ao pressionar

			mov.w   #TASSEL__ACLK+MC__STOP,&TA0CTL  	; Para o Timer (MC_STOP).
														;fica aceso
			add		&P1IV,PC							;Desvia a depender do botão pressionado
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop
			jmp		BUTTON_JG_DIR						;Jogador da esquerda pressionou o botão
			jmp		BUTTON_JG_ESQ						;Jogador da direita pressionou o botão


BUTTON_JG_DIR
			bic		#BIT5,P1IFG							;Limpa bit indicador de interrupção
			cmp.b	#1,&EM_PAUSA						;Verifica se o jogo esta pausado
			jz		F_BUTTON							;Se o jogo estiver pausado. O pressionamento do botão não desconta pontos
			cmp.b	#SAQUE_JG_ESQ,&ESTADO				;Verifica se esta no saque do jogador da Esquerda
			jz		F_BUTTON							;Se o jogo estiver no saque do jogador da Esquerda. O pressionamento do botão não desconta pontos
			bit.b	#BIT0,LEDS							;O jogo não está pausado. Continua. O led mais a direita esta aceso?
			jz		ERR_JG_DIR							;Se o led da estrema direita não esta ligado. A principio o Jogador errou!
			cmp.b	#SAQUE_JG_DIR,&ESTADO
			jz		SAQUE_DIR
			call	#VELOC_AUMENTAR
SAQUE_DIR
			mov.b	#JG_DIR_REBATEU,&REBATIDA
			jmp		RETOMA_JOGO

ERR_JG_DIR												;Jogador da direita prescionou botão e o led não estava na extrema direita
			cmp.b	#SAQUE_JG_ESQ,&ESTADO				;Estava no momento do saque do jogador da esquerda? Se sim. Não deve-se considerar uma falha
			jz		F_BUTTON							;Vai para o fim da rotina
			call 	#FALHA_JG_DIR						;Como não estava em pausa, nem era o momento do saque do jogador da esquerda. Foi uma falha.
			mov.w  	#MC__UP,&TA0CTL
			mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  	; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
			DELAY_TIMER_1_MAC #QUINZE_MILI_SEG
			bic		#BIT6,P1IFG
			bic		#BIT5,P1IFG
			reti
BUTTON_JG_ESQ
			bic		#BIT6,P1IFG							;Limpa bit indicador de interrupção
			cmp.b	#1,&EM_PAUSA						;Verifica se o jogo esta pausado
			jz		F_BUTTON							;Se o jogo estiver pausado. O pressionamento do botão não desconta pontos
			cmp.b	#SAQUE_JG_DIR,&ESTADO				;Verifica se esta no saque do jogador da Direita
			jz		F_BUTTON							;Se o jogo estiver no saque do jogador da Direita. O pressionamento do botão não desconta pontos
			bit.b	#BIT6,LEDS							;O jogo não está pausado. Continua. O led mais a esquerda esta aceso?
			jz		ERR_JG_ESQ							;Se o led da estrema esquerda não esta ligado. A principio o Jogador errou! Pula,
			cmp.b	#SAQUE_JG_ESQ,&ESTADO				;Jogador não errou! É um saque?
			jz		SAQUE_ESQ							;Se for um saque. Pula.
			call	#VELOC_AUMENTAR						;Não foi um saque, foi um rebatida. Aumenta velocidade.
SAQUE_ESQ
			mov.b	#JG_ESQ_REBATEU,&REBATIDA			;Seja saque ou rebatida. informa que o jogador rebateu no momento exato.
			jmp		RETOMA_JOGO							;Volta pro jogo.
ERR_JG_ESQ												;Jogador da esquerda prescionou botão e o led não estava na extrema direita
			cmp.b	#SAQUE_JG_DIR,&ESTADO				;Estava no momento do saque do jogador da direira? Se sim. Não deve-se considerar uma falha
			jz		F_BUTTON							;Vai para o fim da rotina
			call	#FALHA_JG_ESQ						;Como não estava em pausa, nem era o momento do saque do jogador da direita. Foi uma falha.
			mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  	; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
			DELAY_TIMER_1_MAC #QUINZE_MILI_SEG
			bic		#BIT6,P1IFG
			bic		#BIT5,P1IFG
			reti										;sai da interupção
RETOMA_JOGO												;retoma o jogo, habilita interrupção do timer A0 e muda o estado do jogo para EM_JOGO

			mov.b	#EM_JOGO,&ESTADO					;Muda o estado do jogo
F_BUTTON

			DELAY_TIMER_1_MAC #QUINZE_MILI_SEG
			bic		#BIT6,P1IFG
			bic		#BIT5,P1IFG
			mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  		; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
			reti										;sai da interrupção

PREP_SQ_DIR												;Prepara o saque do jogador da direita
			mov.b	#SAQUE_JG_DIR,&ESTADO				;Muda o estado do jogo
			mov.b	#PARA_ESQ,DIRECAO					;Muda a direção (para esquerda)
			mov.b	#BIT0,&LEDS							;prepara para ligar o LED da extrema direita
            mov.b	&LEDS,P9OUT							;Ligar o LED da extrema direita
            call	#PAUSA_SQ_LIGAR						;Coloca o jogo em pausa, para o saque
        	ret
PREP_SQ_ESQ												;Prepara o saque do jogador da esquerda
			mov.b	#SAQUE_JG_ESQ,&ESTADO				;Muda o estado do jogo
			mov.b	#PARA_DIR,DIRECAO					;Muda a direção (para direita)
			mov.b	#BIT6,&LEDS							;prepara para ligar o LED da extrema esquerda
            mov.b	&LEDS,P9OUT							;Ligar o LED da extrema esquerda
            call	#PAUSA_SQ_LIGAR						;Coloca o jogo em pausa, para o saque
            ret

PAUSA_SQ_LIGAR
			mov.b	#TMP_PREP_SAQUE,R15
			nop
			bic.w   #GIE,SR   						; desabilita interrupções mascaráveis
			nop
			bic		#CCIE,&TA0CCTL0

			bic		#BIT5,P1IE
			bic		#BIT6,P1IE
			bis		#CCIE,&TA0CCTL1         		; TACCR1 interupção habilitada
			mov.w	&TA0CCR0,&FREQ_ATUAL
			mov.w	#UM_SEG,&TA0CCR0
            mov.w   #UM_SEG,&TA0CCR1				; Contar três segundos e gera interrupção
            mov.b	#1,&EM_PAUSA
            nop
            bis.w   #GIE,SR            				; habilita interrupções mascaráveis
            nop

            ret

TA0_HND
			add		&TA0IV,PC ; Add offset to Jump table
			RETI ; Vector 0: No interrupt
			JMP PAUSA_SQ_DELIGAR ; Vector 2: TA0CCR1

PAUSA_SQ_DELIGAR
			cmp.b   #SAQUE_JG_DIR,&ESTADO
			jz		PISCA_DIR
			xor		#BIT6,&LEDS
			mov.b	&LEDS,P9OUT
			jmp		PSD_1
PISCA_DIR
			xor		#BIT0,&LEDS
			mov.b	&LEDS,P9OUT

PSD_1		cmp.b	#0,R15
			jnz		F_TIME
			nop
			bic.w   #GIE,SR   						; desabilita interrupções mascaráveis
			nop
			mov.b	#0,&EM_PAUSA
			bic		#BIT5,P1IFG
			bic		#BIT6,P1IFG
			bis		#BIT5,P1IE
			bis		#BIT6,P1IE
			bis		#CCIE,&TA0CCTL0
            bic		#CCIE,&TA0CCTL1
            mov.w	&FREQ_ATUAL,&TA0CCR0
            mov.w	&FREQ_ATUAL,&TA0CCR1

            nop
            bis.w   #GIE,SR            				; habilita interrupções mascaráveis
            nop

            reti
F_TIME
			dec.b	R15
			reti


FALHA_JG_DIR										;Jogador da direita falhou
			inc.w	&PONTOS_JQ_ESQ					;Aumenta os pontos do jogador da Esquerda

			push	#PLACAR_JG_ESQ					;Ponteiro para o que vai ser escrito no LCD. Parametro da função MUDA_PLACAR
			push	PONTOS_JQ_ESQ					;Valor dos pontos do jogador da esquerda. Parametro da função MUDA_PLACAR


			call	#MUDA_PLACAR					;Chama MUDA_PLACAR


			add		#4,SP							;Limpa pilha

			call	#PREP_SQ_ESQ					;Prepara para o saque do jogador da Esquerda

			ret

FALHA_JG_ESQ										;Jogador da esquerdo falhou
			inc.w	&PONTOS_JQ_DIR					;Aumenta os pontos do jogador da direita

			push	#PLACAR_JG_DIR					;Ponteiro para o que vai ser escrito no LCD. Parametro da função MUDA_PLACAR
			push	PONTOS_JQ_DIR					;Valor dos pontos do jogador da esquerda. Parametro da função MUDA_PLACAR


			call	#MUDA_PLACAR					;Chama MUDA_PLACAR



			add		#4,SP							;Limpa pilha


			call	#PREP_SQ_DIR					;Prepara para o saque do jogador da Direita
			ret

VELOC_AUMENTAR
			;rra		&TA0CCR0					;Divide por dois. Dobra a frequência. Retirado.
			cmp.w		#0x1A00,&TA0CCR0					;Se a frequencia estiver em 4,923hz(período de 0,203125s), para de diminuir
			jz		V_1
			sub		#0x600,&TA0CCR0					;Diminui o valor. Aumentando a frequencia em 0x600h
			;jn		NEGATIVO
V_1			ret

NEGATIVO
			mov.w	#0x600,&TA0CCR0
			ret

MUDA_PLACAR
			push	R15
			push	R14

			push 	R12
			push	R11
			push	R10
			push	R9

			mov.w	14(SP),R15					;Valor do Placar
			mov.w	16(SP),R14					;Ponteiro para o buffer que vai ser escrito no LCD, 000 a 999 (3 bytes)
												;PLACAR_NUM vetor temporário que irá armazenar o placar do jogador

			mov.w	#0,R12						;indice para o vetor PLACAR_NUM
			mov.b	#0x30,PLACAR_NUM(R12)		;Coloca zero nos 3 bytes do placar para iniciar
			inc.w	R12
			mov.b	#0x30,PLACAR_NUM(R12)		;Coloca zero nos 3 bytes do placar para iniciar
			inc.w	R12
			mov.b	#0x30,PLACAR_NUM(R12)		;Coloca zero nos 3 bytes do placar para iniciar


			mov.w	#1,R12						;R12 vai ser o contador

			mov.w	#2,R11						;R11 vai ser o indice para PLACAR_NUM
			mov.w	#0x30,R9					;Armazenará o algarimo da centena

												;inicia apontando para a casa das unidades, depois para as dezenas, depois centenas



M0			cmp.w	#0,R15						;Se o placar atual do jogador (R15) for 0, pula para o final
			jz		MUDA_FIM					;pula se for zero

			cmp.w	#10,R12						;aqui muda de unidade para dezenas e centenas
			jnz		M1
			mov.w	#1,R12
			dec.b	R11
			inc.b	R9
			mov.b	R9,PLACAR_NUM(R11)
			inc.b	R11
			mov.b	#0x30,PLACAR_NUM(R11)
			dec.w	R15
			jmp 	M0

			;dec.w	R11
M1
			mov.w	R12,R10						;Armazena temporáriamente o contador em R10
			add.w	#0x30,R10					;Soma R10 (contador) com 0x30(codigo ASCII de "0"),R10 contém o codigo asscii do número atual

			mov.b	R10,PLACAR_NUM(R11)			;Copia o número do placar para o vetor PLACAR_NUM, na posição da unidades.

			dec.w	R15							;para controle do loop, roda tantas vezes qt for o valor do placar
			inc.w	R12							;para controle do caracter a ser impresso (unidades)

			jmp 	M0
MUDA_FIM

			mov.w	#0,R12					;copia os trẽs bytes do placar
			mov.b	PLACAR_NUM(R12),0(R14)
			inc.w	R12
			inc.w	R14
			mov.b	PLACAR_NUM(R12),0(R14)
			inc.w	R12
			inc.w	R14
			mov.b	PLACAR_NUM(R12),0(R14)


			call	#PRINT_PLACAR
			;mov.b	#1,&COOR_X_LCD				;Mostra placar no lcd
			;mov.b	#0,&COOR_Y_LCD
			;PRINT_LCD_X_Y_MAC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT,#LINHA_2,#COOR_X_LCD,#COOR_Y_LCD

			pop 	R9
			pop		R10
			pop		R11
			pop		R12
			pop		R14
			pop		R15

			ret

TRATA_TIMER1_A0
			bic.w	#LPM3, SR
			bic.w 	#LPM3,0(SP)
			;bic.w	#CCIE,&TA1CCTL0

			reti



;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect   TIMER0_A0_VECTOR        ; Timer0_A3 CC0 Vetor Interrução do timer
            .short  PISCA

            .sect	TIMER0_A1_VECTOR
            .short  TA0_HND

            .sect	PORT1_VECTOR
            .short	BUTTON_JG				;Trata o pressionamento dos botões dos jogadores

            .sect  TIMER1_A0_VECTOR
            .short TRATA_TIMER1_A0

            
