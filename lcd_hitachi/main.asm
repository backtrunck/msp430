;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
			.nolist
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .include	timer.asm
            

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
			.list
			.global	LINHA_1,LINHA_2,MSG,MSG2,SET_NUM_LINHAS_E_TAM_FONTE,SET_DISPLAY_OFF
			.global	SET_DISPLAY_CLEAR,RETURN_HOME,SET_CURSOR_MV_DIR,SET_CURSOR_MV_ESQ,SET_SHOW_CURSOR,COMANDO,ROLA_TELA_ESQ

			.data
LINHA_1		.byte	"Placar Ping-Pong",0x00
LINHA_2		.byte	"   00  X  00    ",0x00

MSG			.byte	"0123456789ABCEFGHIJKLMNOPQRSTUVXWYZGGGGGQQQQQQQQQQ",0x00		;String a ser impressa no Lcd
MSG2		.byte	"teste",0x00


SET_NUM_LINHAS_E_TAM_FONTE					;Comando para configurar numero de linh e tamanho da fonte do lcd
			.byte	0x28
SET_DISPLAY_OFF	.byte	0x08				;Comando para desligar display do lcd

SET_DISPLAY_CLEAR							;Comando para limpar display do lcd
			.byte	0x01
RETURN_HOME
			.byte	0x02
SET_CURSOR_MV_DIR							;Comando para ajustar a movimentação do cursor (no caso para direita)
			.byte	0x06
SET_CURSOR_MV_ESQ							;Comando para ajustar a movimentação do cursor (no caso para direita)
			.byte	0x07
SET_SHOW_CURSOR
			.byte	0x0C					;Comando para mostrar o cursor do lcd
COMANDO		.byte	0xCA
ROLA_TELA_ESQ
			.byte	0x1C
X			.byte	0x00
Y			.byte	0x00


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

            INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT

            mov.b	#0,&X
            mov.b	#0,&Y
            PRINT_LCD_X_Y_MAC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT,#LINHA_1,#X,#Y

            mov.b	#1,&X
            mov.b	#0,&Y
            PRINT_LCD_X_Y_MAC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT,#LINHA_2,#X,#Y

			;ENV_BYTE_TO_LCD_MAC #P2OUT,#BIT1,#P4OUT,#ROLA_TELA_ESQ
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP

			jmp	LOOP
			nop


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
            
