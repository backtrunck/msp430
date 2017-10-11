;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
            .asg	32767,T_1SEG			;constante de 1 segundo para o timer
            .eval	T_1SEG / 2,T_MEIOSEG	;constante de meio segund para o times

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

;--------------------------------  Prática 04  ---------------------------------
;Tarefa: Piscar o Led1 do kit microlab com um período de 1000ms
;(500ms aceso, 500ms apagado).
;utilizar interrupção do Timer
;--------------------------------  Ligação Jumpers------------------------------
;P4.1 <---------------------------> DB1
;P3.4 <---------------------------> LED_EN
;---------------------------------  Configura as Portas  ------------------------
;Usaremos a porta 4.1 para ligar o Led1 (DB1)
			bic		#BIT1,P4SEL				;P4.1, Entrada e Sáida
			bis		#BIT1,P4DIR				;P4.1, Porta de Saída
			bic		#BIT1,P4OUT				;P4.1, Em nível Baixo (0), led apagado

;Usaremos a porta 3.4, para habilitar a linha de Leds do kit
			bic		#BIT4,P3SEL				;P3.4, Entrada e Sáida
			bis		#BIT4,P3DIR				;P3.4, Porta de Saída
			bis		#BIT4,P3OUT				;P3.4, Em nível Alto (1), habilita leds

;---------------------------------  Configura o Timer  ------------------------
			mov.w   #CCIE,&TACCTL0         	; interupção habilitada para o estouro de TACCR0

            mov.w   #T_1SEG,&TACCR0			; Conta de 0 a 32767/2 = (32768 /2) equi 0,5s, pois iremos usar ACLK(32.768hz) e gera interrupção
            mov.w   #TASSEL_1+MC_1,&TACTL	; Usa oscilador ACLK(32.768hz), modo up
            nop                             ;
            ;bis.w   #GIE,SR            		; habilita interrupções mascaráveis
            nop

            call #CFG_TECLADO

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP
			jmp		LOOP
			nop

PISCA
			xor		#BIT1,P4OUT				;alterna saida do led, ora alto, ora baixo
			reti



CFG_TECLADO
;--------------------------------  Ligação Jumpers------------------------------
;P2.5 <---------------------------> TCL_COL0
;P2.0 <---------------------------> TCL_LIN0
;-------------------------------------------------------------------------------
 			bic		#BIT5,P2SEL             ;P2.5  Entrada e Saída
 			bis		#BIT5,P2DIR				;P2.5, Porta de Saída
 			bic		#BIT5,P2OUT				;P2.5, Em nível Baixo (0), terra p/ teclado

 			bic		#BIT0,P2SEL				;P2.0, Entrada e Saída
 			bic		#BIT0,P2DIR				;P2.0, Porta de Entrada
 			bis		#BIT0,P2IES				;P2.0, Interrupção na descida
 			bic		#BIT0,P2IFG				;P2.0, Limpa o bit de interrupção
 			bis		#BIT0,P2IE				;P2.0, Habita Interrupção
 			ret
MD_FREQ
 			mov.w   #TASSEL_1+MC_0,&TACTL	;Para o Timer
 			cmp		#T_1SEG,&TACCR0			;Vê se o Timer esta ajustado para 1seg.
 			jnz		AJ_1SEG					;Se não estiver, ajusta pra 1seg
 			mov.w	#T_MEIOSEG,&TACCR0		;Se ajustado p/1seg, ajusta para MeioSegundo
			jmp		RT_TIMER				;Vai para retoma timer
AJ_1SEG		mov.w	#T_1SEG,&TACCR0			;Ajusta o timer para 1seg
RT_TIMER	mov.w   #TASSEL_1+MC_1,&TACTL	;Retoma a contagem do timer
			bic		#BIT0,P2IFG				;P2.0, Limpa o bit de interrupção
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
            .sect TIMERA0_VECTOR			;interrupcao TimerA
            .short	PISCA					;Trata interrupção
            .sect	PORT2_VECTOR			;interrupção GPIO
			.short	MD_FREQ					;Trata interupção
            
