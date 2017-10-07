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

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;#####################   Pratica 04   ##############################
;Led 01 irá ligar e apagar a cada 0,5segundos, utilizando o timer_a
;###################################################################

;###################################################################
;			Configura a porta P1.0
;###################################################################
			bis.b	#BIT0,P1DIR				;P1.0, configura como saida
			bic.b	#BIT0,P1OUT				;P1.0, coloca em estado baixo(0), desliga led vermelho
			bic.w   #LOCKLPM5,&PM5CTL0		;Destrava FRAM

;################################################################
;			Configura o Timer_A, modo continuo
;################################################################
			mov.w   #CCIE,&TA0CCTL0         ; TACCR0 interupção habilitada
            mov.w   #UM_SEG,&TA0CCR0			; Conta até 32767 e gera interrupção
            mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  ; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
            nop                             ;
            bis.w   #GIE,SR            		; habilita interrupções mascaráveis
            nop                             ;
;################################################################
;Início do programa (de fato)
;################################################################
			;call	#REIN_CONT
			call #CONF_P1_1

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP
			jmp		LOOP
			nop

PISCA
			xor		#BIT0,P1OUT
			reti

CONF_P1_1
			bic		#BIT1,P1DIR
			bis		#BIT1,P1OUT
			bis		#BIT1,P1REN
			bic		#BIT1,P1IFG
			bis		#BIT1,P1IES
			bis		#BIT1,P1IE
			ret

MUDA_FREQ
			bit		#BIT1,P1IN
			jnz		FIM_M_FREQ
			mov.w   #TASSEL__ACLK+MC__STOP,&TA0CTL
			cmp		#UM_SEG,TA0CCR0
			jnz		MUDA_F2
			mov.w   #MEIO_SEG,&TA0CCR0			; Conta até 32767 e gera interrupção
			jmp		RESTAURA
MUDA_F2
			mov.w   #UM_SEG,&TA0CCR0			; Conta até 32767 e gera interrupção
RESTAURA	mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  ; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
FIM_M_FREQ
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
            .short  PISCA					;função para tratar a interrupção
            .sect	PORT1_VECTOR
            .short	MUDA_FREQ
            
