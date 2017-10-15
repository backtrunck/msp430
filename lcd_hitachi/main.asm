;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .include	timer.asm
            .define	32,	UM_MILI_SEG
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
			.data
MSG			.byte	'a'
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

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP
			PULSO_MAC #P2OUT
			MSG_TO_LCD_MAC #MSG
			INICIAR_LCD_MC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT

			jmp	LOOP
			nop

PULSO
			push	R15
			mov.w	4(SP), R15
			bic.b	#BIT1,0(R15)						;Desliga P2.1 (Pino Enable)
			bis.b	#BIT1,0(R15)						;Liga P2.1 (Pino Enable)
			DELAY_TIMER_1_MAC #UM_MILI_SEG				;Aguarda 1ms
			bic.b	#BIT1,0(R15)						;Desliga P2.1 (Pino Enable)
			pop 	R15
			ret

MSG_TO_LCD

			push	R15
			mov.w	4(SP), R15
			cmp.b	#0,0(R15)
			jz		F_MSG
			ENV_BYTE_TO_LCD_MAC #P2OUT,R15
			;terminar loop
F_MSG
			pop		R15
			ret


ENVIA_BYTE_TO_LCD
			push	R15
			push	R14
			push	R13
			mov.w 	8(SP),R15
			mov.w 	10(SP),R14
			mov.b	0(R15),R13
			DELAY_TIMER_1_MAC #UM_MILI_SEG
			and.b		#BIT3 | BIT2 | BIT1 | BIT0,R13
			and.b		#BIT7 | BIT6 | BIT5 | BIT4,0(R14)
			xor.b	R13,0(R14)
			mov.b	0(R15),R13
			rra		R13
			rra		R13
			rra		R13PUSH
			rra		R13
			DELAY_TIMER_1_MAC #UM_MILI_SEG
			and.b		#BIT3 | BIT2 | BIT1 | BIT0,R13
			and.b		#BIT7 | BIT6 | BIT5 | BIT4,0(R14)
			xor.b	R13,0(R14)

			pop 	R13
			pop 	R14
			pop		R15
			ret


INICIAR_LCD
			push	R15
			push	R14
			push	R13

			;mov.w 	10(SP),R15
			mov.w 	12(SP),R15
			mov.w 	16(SP),R14
			mov.w 	18(SP),R13

			bic.b	10(SP),0(R14)		;Desliga RS
			mov.b	BIT0 | BIT1,0(R13)	;envia 0x03 para o lcd

			PULSO_MAC #P2OUT			;envia pulso

			DELAY_TIMER_1_MAC ;colocar 5milis

			PULSO_MAC #P2OUT			;envia pulso

			DELAY_TIMER_1_MAC ;colocar 1milis

			PULSO_MAC #P2OUT			;envia pulso

			pop 	R14
			pop		R15



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
            
