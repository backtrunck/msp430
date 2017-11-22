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

			.data
CONTADOR	.WORD	0x0000
DEP			.byte	0x01
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
			bic.w   #LOCKLPM5,&PM5CTL0

;-----------  P9.0 saída---------------------------------------------------------
			bis.b	#BIT0,P9DIR
			bis.b	#BIT0,P9OUT
;-----------  P1.5 entrada-------------------------------------------------------

			bic		#BIT5,P1DIR				;Limpa bit, P1.5 como entrada
			bic		#BIT5,P1OUT				;Seta bit para configurar a porta com pull up register
			;bis	#BIT5,P1REN				;Seta bit para configurar a porta com pull up register
			bis		#BIT5,P1SEL0
			bis		#BIT5,P1SEL1
;-------------------------------------------------------------------------------
;			Configura a porta P1.6 como entrada com pull up register
;-------------------------------------------------------------------------------
			bic		#BIT6,P1DIR				;Limpa bit, P1.6 como entrada
			bis		#BIT6,P1OUT				;Seta bit para configurar a porta com pull up register
			bis		#BIT6,P1REN				;Seta bit para configurar a porta com pull up register
			bic		#BIT6,P1IFG				;Limpa bit indicador de interrupção
			bis		#BIT6,P1IES				;Seta bit, interrupção vai ser disparada na transição ALTO BAIXO
			bis		#BIT6,P1IE				;Seta bit, interrução de P1.6, habilitadas
;----------- Configurar TimerA

			mov.w	#CAP | SCS | CCIS_0 | CM_2 | CCIE, &TA0CCTL0
			mov.w   #TASSEL__ACLK+MC__CONTINUOUS,&TA0CTL  			; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up

			nop
            bis.w   #GIE,SR
            nop

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP		jmp		LOOP


;---------- trata interrupção de captura do timerA
TA0_HND

			mov.w	#0,R15
			;mov.w	#0,CONTADOR(R15)
			xor		#BIT0,P9OUT

			cmp.w	#0,CONTADOR(R15)
			jz		T_01
			sub.w	&TA0CCR0,CONTADOR(R15)
			cmp.w	#0x4000,CONTADOR(R15)
			jc		T_02
			nop
T_02		reti
T_01
			mov.w	&TA0CCR0,CONTADOR(R15)
			reti
;----------- fim interrupção


;---------- trata interrupção do botão em P1.6
BUTTON
			add		&P1IV,PC							;Desvia a depender do botão pressionado
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop											;Vetor 0:sem interrupção
			nop
			nop
			mov.w	#0,R15
			;mov.b	#0,CONTADOR(R15)
			reti
;----------- fim interrupção





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
            .sect   TIMER0_A0_VECTOR
            .short  TA0_HND
            .sect	PORT1_VECTOR
            .short	BUTTON					;Trata o pressionamento dos botões dos jogadores
