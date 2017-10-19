;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
			.nolist
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
			.list
			.data
MSG			.byte	"Teste mundo",0x00
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


            ;CALL #TESTE
            INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT

            MSG_TO_LCD_MAC  #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT,#MSG


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP
			;PULSO_MAC #P2OUT,#BIT1
			;MSG_TO_LCD_MAC #MSG
			;INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT

			jmp	LOOP
			nop

SET_COMANDO												;Habilita modo escrita ou de comando do LCD
														;Parametros (PORTA_DE_SAIDA,PINO,ENABLE
			push	R15									;Salva na pilha
			push	R14									;Salva na pilha

			mov		8(SP),R15							;Pino(RS)
			mov		10(SP),R14							;Porta

			cmp		#0,6(SP)							;Compara ENABLE com 0, se igual vai por modo comando, se for 1 modo escrita de dados
			jnz		S1
			bic.b	R15,0(R14)							;Ajusta para modo comando
			jmp 	S2
S1			bis.b	R15,0(R14)							;Ajusta para modo escrita

S2			pop R14
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

			push	R15
			push	R14
			push	R13
			push	R12
			push	R11
			push	R10

			mov.w	14(SP),R11											;Pega Mensagem para o Lcd
			mov.w 	16(SP),R13											;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	18(SP),R10											;Bit Enable
			mov.w 	20(SP),R15											;Pega Porta Enable Ex. 2.1
			mov.w	22(SP),R12											;Pega o valor para ajustar o LCD em modo comando
			mov.w 	24(SP),R14											;Pega Porta RS Ex. 2.5


			SET_COMANDO_MAC	R14,R12,#1									;Seta modo escrita do LCD


M1			cmp.b	#0,0(R11)							;Ve se o caracter atual da Mensagem é NULL
			jz		F_MSG								;Se for NULL, pula (toda a mensagem já foi passada para o lcd)

			ENV_BYTE_TO_LCD_MAC R13,R11
			inc		R11
			jmp 	M1
F_MSG
			pop		R10									;restaura da pilha
			pop		R11
			pop		R12
			pop		R13
			pop 	R14
			pop		R15
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
			push	R12

			mov.w 	14(SP),R15											;Pega Porta Enable Ex. 2.1
			mov.w 	18(SP),R14											;Pega Porta RS Ex. 2.5
			mov.w 	10(SP),R13											;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	16(SP),R12											;Pega o valor para ajustar o LCD em modo comando


			SET_COMANDO_MAC	R14,R12,#0								;Ajusta para modo comando do lcd

			call #CODIGO_INICIALIZACAO									;Passa os códigos de inicialização do LCD

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R13,#SET_NUM_LINHAS_E_TAM_FONTE			;Ajusta o numero de linha e fonte do lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R13,#SET_DISPLAY_OFF					;Desliga Lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R13,#SET_DISPLAY_CLEAR				;Limpa lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R13,#SET_CURSOR_MV_DIR				;Ajusta o movimento do cursor (para direita)


			ENV_BYTE_TO_LCD_MAC R13,#SET_SHOW_CURSOR					;Mostra o cursor

			pop		R12
			pop		R13
			pop 	R14
			pop		R15
			ret


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
            
