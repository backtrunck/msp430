;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
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
			bic.w   #LOCKLPM5,&PM5CTL0
;################################################################
;Configura as portas
;################################################################
			bis.b	#BIT0,P1DIR				;P1.0, configura como saida
			bis.b	#BIT7,P9DIR				;P9.2, configura como saida
			bis.b	#BIT0,P1OUT				;P1.0, coloca em estado alto(1), liga led vermelho
			bic.b	#BIT7,P9OUT				;P9.7, coloca em estado baixo(0),liga led verde
;################################################################
;configura o Timer_A, modo continuo
;################################################################
			mov.w   #CCIE,&TA0CCTL0         ; TACCR0 interupção habilitada
            mov.w   #32767,&TA0CCR0			; Conta até 50000 e gera interrupção
            mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  ; Usa oscilador ACLK, modo continuo
            nop                             ;
            bis.w   #GIE,SR            		; habilita interrupção
            nop                             ;
;################################################################
;Início do programa (de fato)
;################################################################
			;call	#REIN_CONT
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP		jmp		LOOP


PPISCA
;			dec.w	R15
;			jnz		PPISCA
;LOOP2		dec.w	R14
;			jnz		LOOP2
			xor		#BIT0,P1OUT
			xor		#BIT7,P9OUT
;			call	#REIN_CONT
;			jmp		PPISCA
			reti
                                            
REIN_CONT
			mov.w	#0xFFFF,R15
			mov.w	#0xFFFF,R14
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
            .sect   TIMER0_A0_VECTOR        ; Timer0_A3 CC0 Interrupt Vector
            .short  PPISCA
            
