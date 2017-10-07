;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
            .def	BT_K2
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;Configura P2.5 para aterrar (nivel logico 0) a coluna do teclado do kit (TCL_COL_0)
			;bic     #BIT5, &P2SEL          ;P2.5, configura primeira função I/0
       		bis     #BIT5, &P2DIR 			;P2.5, configura como porta de saida
			bic     #BIT5, &P2OUT			;P2.5, Coloca a porta em baixo(0),Terra.
;Configura P2.0 para realizar a leitura do botão K2 do teclado do kit
			;bic     #BIT0, &P2SEL           ;P2.0, configura primeira função I/0
       		bic     #BIT0, &P2DIR 			;P2.0, configura como porta de entrada
      		bis		#BIT0, &P2IES			;P2.0, interrupção na transição negativa(1->0)
      		bic		#BIT0, &P2IFG			;P2.0, limpa flag interrupção
       		bis		#BIT0, &P2IE			;P2.0, habilita a interrupção
;Configuar P3.4 para habilitar os leds do kit
			;bic     #BIT4, &P2SEL           ;P2.4, configura primeira função I/0
       		bis     #BIT4, &P2DIR 			;P2.4, configura como porta de saida
       		bis		#BIT4, &P2OUT			;P2.4, Coloca a porta em alto(1),habilita leds.

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP		jmp		LOOP
			nop

BT_K2
;Verifica se o botão apertado foi k2(P2.0)
			bit		#BIT0,&P2IFG			;Verifica o flag de interrupção
			jnc		FIM_BT_K2				;Se gerar Carry P2IFG=1 (gerou interrupção)
;trata a interrupção
			xor		#BIT0,&P2OUT			;Alterna estado do Led.
			bic		#BIT0,&P2IFG			;Limpa o flag de interrupção
FIM_BT_K2
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
            
	        .sect	".int34"
            .short	BT_K2

