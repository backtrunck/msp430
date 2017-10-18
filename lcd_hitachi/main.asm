;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .include	timer.asm
            .define	32,	UM_MILI_SEG
            .eval	32 * 5, CINCO_MILI_SEG
            .eval	32 * 15, QUINZE_MILI_SEG
            .define	"bis.b	#BIT1,P2OUT",ENABLE_H
            .define	"bic.b	#BIT1,P2OUT",ENABLE_L
            .define	"bis.b	#BIT5,P2OUT",RS_H
            .define	"bic.b	#BIT5,P2OUT",RS_L
            

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
			.data
MSG			.byte	0X41
SET_NUM_LINHAS_E_TAM_FONTE
			.byte	0x28
SET_DISPLAY_OFF	.byte	0x08
SET_DISPLAY_CLEAR
			.byte	0x01
SET_CURSOR_MV_DIR
			.byte	0x06
MODE_SET
SET_SHOW_CURSOR
			.byte	0x0F
COMANDO		.byte	0xC0



            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

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
;			configura portas de saída
;-------------------------------------------------------------------------------

			bis.b	#BIT0 | BIT1| BIT2| BIT3,P4DIR		;P4.0 a P4.3, configura como saida
			bis.b	#BIT1| BIT5,P2DIR					;P2.1 a P2.5, configura como saida

			bic.w   #LOCKLPM5,&PM5CTL0		;Destrava FRAM
;-------------------------------------------------------------------------------
;			Configura o Timer_A_1, modo continuo
;-------------------------------------------------------------------------------
			mov.w   #CCIE,&TA1CCTL0         		; TACCR0 interupção habilitada
            ;mov.w   #UM_MILI_SEG,&TA1CCR0			; Interruções em 1 milisegundos
            mov.w   #TASSEL__ACLK+MC__UP,&TA1CTL  	; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
            ;nop
            ;bis.w   #GIE,SR            				; habilita interrupções mascaráveis
            ;nop


            CALL #TESTE
            INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT
            bis.b	#BIT5,P2OUT
            MSG_TO_LCD_MAC  #MSG
            bic.b	#BIT5,P2OUT
            ENV_BYTE_TO_LCD_MAC #P2OUT,#COMANDO
            bis.b	#BIT5,P2OUT
            MSG_TO_LCD_MAC  #MSG


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP
			PULSO_MAC #P2OUT,#BIT1
			MSG_TO_LCD_MAC #MSG
			INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT

			jmp	LOOP
			nop

TESTE

			DELAY_TIMER_1_MAC #QUINZE_MILI_SEG
			SET_COMANDO_MAC #P2OUT,#BIT5
			mov.b	#BIT0 | BIT1,P4OUT

			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #CINCO_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #UM_MILI_SEG


			PULSO_MAC #P2OUT, #BIT1

			mov.b	#BIT1,P4OUT

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1


			DELAY_TIMER_1_MAC #UM_MILI_SEG

			ENV_BYTE_TO_LCD_MAC #P4OUT,#SET_NUM_LINHAS_E_TAM_FONTE

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			ENV_BYTE_TO_LCD_MAC #P4OUT,#SET_DISPLAY_OFF

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			ENV_BYTE_TO_LCD_MAC #P4OUT,#SET_DISPLAY_CLEAR

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			ENV_BYTE_TO_LCD_MAC #P4OUT,#SET_CURSOR_MV_DIR


			ENV_BYTE_TO_LCD_MAC #P4OUT,#SET_SHOW_CURSOR

			RS_H



			ENV_BYTE_TO_LCD_MAC #P4OUT,#MSG

			mov.b	#0x4,P4OUT


			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #UM_MILI_SEG


			mov.b	#0x1,P4OUT

			PULSO_MAC #P2OUT, #BIT1
			nop
			ret









SET_COMANDO
			push	R15
			push	R14

			mov		6(SP),R15							;Pino(RS)
			mov		8(SP),R14							;Porta

			bic.b	R15,0(R14)

			pop R14
			pop R15




PULSO
			push	R15									;salva na pilha
			push	R14									;salva na pilha
			mov.w	8(SP), R15							;Retira da pilha a GPIO passada
			bic.b	6(SP),0(R15)						;Desliga a GPIO passada, usando o bit passado, (Pino Enable) Ex. P2.1
			bis.b	6(SP),0(R15)						;Liga a GPIO passada, usando o bit passado, P2.1 (Pino Enable)
			DELAY_TIMER_1_MAC #UM_MILI_SEG				;Aguarda 1ms
			bic.b	6(SP),0(R15)						;Desliga a GPIO passada, usando o bit passado, (Pino Enable) Ex. P2.1 (
			pop 	R14									;restaura R14
			pop 	R15									;restaura R15
			ret

MSG_TO_LCD

			push	R15									;salva na pilha
			mov.w	4(SP), R15							;Retira da pilha o ponteiro da mensagem a ser enviado
			cmp.b	#0,0(R15)							;Compara com NULL
			jz		F_MSG								;Se for NULL, pula
			ENV_BYTE_TO_LCD_MAC #P2OUT,R15
			;terminar loop
F_MSG
			pop		R15									;restaura da pilha
			ret


ENVIA_BYTE_TO_LCD
			push	R15										;salva na pilha
			push	R14										;salva na pilha
			push	R13										;salva na pilha
			mov.w 	8(SP),R15								;Pega o ponteiro para o byte a ser enviado
			mov.w 	10(SP),R14								;Pega o registrador (GPIO)
			mov.b	0(R15),R13								;Pega o conteúdo do ponteiro e salva em R13

			rra		R13										;Desloca quatro vezes o bits para esquerda
			rra		R13										;Desloca os nibble msb para os lsb
			rra		R13
			rra		R13
			bic.b	#BIT7 | BIT6 | BIT5 | BIT4,R13		;Apaga o nibble superior do byte, R13 contém o nibble inicial do byte
			bic.b	#BIT3 | BIT2 | BIT1 | BIT0,0(R14)	;Apaga o nible inferior da GPIO
			bis.b	R13,0(R14)							;Copia o nibble inferior para a GPIO. (Transmissão de 4 em 4 bits)

			PULSO_MAC #P2OUT, #BIT1


			mov.b	0(R15),R13								;Novamente, Pega o conteúdo do ponteiro e salva em R13

			bic.b	#BIT7 | BIT6 | BIT5 | BIT4,R13		;Apaga o nibble superior do byte, R13 contém o nibble inicial do byte
			bic.b	#BIT3 | BIT2 | BIT1 | BIT0,0(R14)	;Apaga o nible inferior da GPIO
			bis.b	R13,0(R14)								;Copia o nibble inferior para a GPIO. (Transmissão de 4 em 4 bits)

			PULSO_MAC #P2OUT, #BIT1



			pop 	R13										;restaura da pilha
			pop 	R14										;restaura da pilha
			pop		R15										;restaura da pilha
			ret


INICIAR_LCD
			push	R15
			push	R14
			push	R13

			;mov.w 	10(SP),R15
			mov.w 	12(SP),R15							;Pega Porta Enable Ex. 2.1
			mov.w 	16(SP),R14							;Pega Porta RS Ex. 2.5
			mov.w 	8(SP),R13							;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3

			;bic.b	14(SP),0(R14)						;Desliga RS, 14(SP = BIT ENABLE
			;******
			RS_L
			ENABLE_L
			DELAY_TIMER_1_MAC #UM_MILI_SEG					;Aguarda

			mov.b	#BIT0 | BIT1,0(R13)					;envia 0x03 para o lcd, Portas DB4,DB5,DB6,DB7

			ENABLE_H
			DELAY_TIMER_1_MAC #CINCO_MILI_SEG					;Aguarda
			ENABLE_L
			DELAY_TIMER_1_MAC #UM_MILI_SEG					;Aguarda
			mov.b	#BIT0 | BIT1,0(R13)					;envia 0x03 para o lcd, Portas DB4,DB5,DB6,DB7

			ENABLE_H
			DELAY_TIMER_1_MAC #CINCO_MILI_SEG					;Aguarda
			ENABLE_L
			DELAY_TIMER_1_MAC #UM_MILI_SEG					;Aguarda
			mov.b	#BIT0 | BIT1,0(R13)					;envia 0x03 para o lcd, Portas DB4,DB5,DB6,DB7

			ENABLE_H
			DELAY_TIMER_1_MAC #CINCO_MILI_SEG					;Aguarda
			ENABLE_L
			DELAY_TIMER_1_MAC #UM_MILI_SEG					;Aguarda

			bic.b	14(SP),0(R14)
			;ENV_BYTE_TO_LCD_MAC	#P2OUT,	#DISPLAY_OFF			;desliga display
			;ENV_BYTE_TO_LCD_MAC	#P2OUT,	#DISPLAY_CLEAR			;limpa display
			ENV_BYTE_TO_LCD_MAC	#P2OUT,	#MODE_SET				;configura (?)
;			ENV_BYTE_TO_LCD_MAC	#P2OUT,	#F						;configura (?)

			pop		R13
			pop 	R14
			pop		R15


CODIGO_INICIALIZACAO
			mov.b	#BIT0 | BIT1,P4OUT

			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #CINCO_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #UM_MILI_SEG


			PULSO_MAC #P2OUT, #BIT1

			mov.b	#BIT1,P4OUT

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1

DELAY_TIMER_1
			bis.w   #CCIE,&TA1CCTL0
			mov.w   2(SP),&TA1CCR0
			nop
			bis.w	#LPM3 | GIE, SR
			nop
			bic.w	#CCIE,&TA1CCTL0

			ret

TRATA_TIMER1_A0
			bic.w 	#LPM3,0(SP)
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
            .sect  TIMER1_A0_VECTOR
            .short TRATA_TIMER1_A0
            
