;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
			.define	32768,UM_SEG
			.eval UM_SEG / 2,MEIO_SEG
			.define	0,SAQUE_INICIAL
			.define 1,SAQUE_JG_DIR
			.define	2,SAQUE_JG_ESQ
			.define	3,EM_JOGO
			.define	0,JG_ESQ_REBATEU
			.define	1,JG_DIR_REBATEU
			.define 0,PARA_ESQ
			.define 1,PARA_DIR

            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
            .data
LEDS
			.byte	0x00
DIRECAO		.byte	0x00
PONTOS_JQ_DIR
			.byte	0x00
PONTOS_JQ_ESQ
			.byte	0x00
ESTADO
			.byte	0x00
REBATIDA	.byte	0x00

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
;			Configura o Timer_A, modo continuo
;-------------------------------------------------------------------------------
			mov.w   #CCIE,&TA0CCTL0         		; TACCR0 interupção habilitada
            mov.w   #UM_SEG,&TA0CCR0				; Conta até 32767 e gera interrupção
            mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  	; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
            nop
            bis.w   #GIE,SR            				; habilita interrupções mascaráveis
            nop
;-------------------------------------------------------------------------------
;			Inicia partida
            mov.b	#BIT0,&LEDS
            mov.b	&LEDS,P9OUT
            mov.b	#SAQUE_JG_DIR,&ESTADO
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP
			jmp		LOOP
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
            mov.b	#0,DIRECAO
            reti
INICIO
			cmp.b	#0,DIRECAO
			jnz		DIR
ESQ
			bit.b	#BIT6,LEDS
			jnz		DIR
			mov.b	#0,DIRECAO
			bit.b	#BIT0,LEDS
			jz		MOVE_BOLA_ESQ
			cmp.b	#JG_DIR_REBATEU,&REBATIDA
			jnz		JG_DIR_NAO_REBATEU
MOVE_BOLA_ESQ
			mov.b	#EM_JOGO,&ESTADO
			rla.b	&LEDS
			mov.b	&LEDS,P9OUT
			reti
JG_DIR_NAO_REBATEU
			inc.b	&PONTOS_JQ_ESQ
			call	#PREP_SQ_ESQ
			reti
DIR
			bit.b	#BIT0,LEDS
			jnz		ESQ
			mov.b	#1,DIRECAO
			bit.b	#BIT6,LEDS
			jz		MOVE_BOLA_DIR
			cmp.b	#JG_ESQ_REBATEU,&REBATIDA
			jnz		JG_ESQ_NAO_REBATEU
MOVE_BOLA_DIR
			mov.b	#EM_JOGO,&ESTADO
			rra.b	LEDS
			mov.b	LEDS,P9OUT
			reti
JG_ESQ_NAO_REBATEU
			inc.b	&PONTOS_JQ_DIR
			call	#PREP_SQ_DIR
F_PISCA
			reti

BUTTON_JG
			xor		#CCIE,&TA0CCTL0			;Desabilita a interrupção do contador 0. O led que estava aceso ao pressionar
											;fica aceso
			add		&P1IV,PC
			nop								;Vetor 0:sem interrupção
			nop								;Vetor 0:sem interrupção
			nop								;Vetor 0:sem interrupção
			nop								;Vetor 0:sem interrupção
			nop								;Vetor 0:sem interrupção
			jmp		BUTTON_JG_ESQ			;Jogador da direita pressionou o botão
			jmp		BUTTON_JG_DIR			;Jogador da esquerda pressionou o botão

BUTTON_JG_DIR
			bit.b	#BIT0,LEDS				;O led mais a esquerda esta aceso?
			jz		ERR_JG_DIR
			mov.b	#JG_DIR_REBATEU,&REBATIDA
			jmp		RETOMA_JOGO
ERR_JG_DIR
			cmp.b	#SAQUE_JG_ESQ,&ESTADO
			jz		RETOMA_JOGO
			inc.b	&PONTOS_JQ_ESQ
			call	PREP_SQ_ESQ
			jmp		RETOMA_JOGO
BUTTON_JG_ESQ
			bit.b	#BIT6,LEDS				;O led mais a esquerda esta aceso?
			jz		ERR_JG_ESQ
			mov.b	#JG_ESQ_REBATEU,&REBATIDA
			jmp		RETOMA_JOGO
ERR_JG_ESQ
			cmp.b	#SAQUE_JG_DIR,&ESTADO
			jz		RETOMA_JOGO
			inc.b	&PONTOS_JQ_DIR
			call	PREP_SQ_DIR
RETOMA_JOGO
			xor		#CCIE,&TA0CCTL0
			mov.b	#EM_JOGO,&ESTADO
			reti

PREP_SQ_DIR
			mov.b	#SAQUE_JG_DIR,&ESTADO
			mov.b	#PARA_ESQ,DIRECAO
			mov.b	#BIT0,&LEDS
            mov.b	&LEDS,P9OUT
        	ret
PREP_SQ_ESQ
			mov.b	#SAQUE_JG_ESQ,&ESTADO
			mov.b	#PARA_DIR,DIRECAO
			mov.b	#BIT6,&LEDS
            mov.b	&LEDS,P9OUT
            ret


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
            .sect	PORT1_VECTOR
            .short	BUTTON_JG				;Trata o pressionamento dos botões dos jogadores

            
