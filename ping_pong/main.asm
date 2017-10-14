;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
			.define	32768,UM_SEG
			.eval UM_SEG / 2,MEIO_SEG

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
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;-------------------------------------------------------------------------------
;			Configura a porta P9.0
;-------------------------------------------------------------------------------
			mov.b	#BIT6 | BIT5 |BIT4 | BIT3 | BIT2 | BIT1 | BIT0,P9DIR	;P1.0, configura como saida
			mov.b	#0,P9OUT												;P1.0, coloca em estado baixo(0), desliga led vermelho
			bic.w   #LOCKLPM5,&PM5CTL0										;Destrava FRAM
;-------------------------------------------------------------------------------
;			Configura a porta P1.6, como entrada com pull up register
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

            mov.b	#BIT0,&LEDS
            mov.b	&LEDS,P9OUT

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP
			jmp		LOOP
			nop

PISCA
			cmp.b		#0,DIRECAO
			jnz		ESQ
DIR
			bit.b	#BIT6,LEDS
			jnz		ESQ
			mov.b	#0,DIRECAO
			rla.b	&LEDS
			mov.b	&LEDS,P9OUT
			jmp F_PISCA

ESQ
			bit.b	#BIT0,LEDS
			jnz		DIR
			mov.b	#1,DIRECAO
			rra.b	LEDS
			mov.b	LEDS,P9OUT
F_PISCA
			reti
BUTTON_JG_1
			xor		#CCIE,&TA0CCTL0
			bic		#BIT6,P1IFG				;Limpa bit indicador de interrupção
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
            .sect	PORT1_VECTOR
            .short	BUTTON_JG_1

            
