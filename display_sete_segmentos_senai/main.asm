;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
             ;.asg	32767,T_1SEG			;constante de 1 segundo para o timer
             .define	32768,UM_SEG
            .eval	UM_SEG / 2,T_MEIOSEG	;constante de meio segund para o times
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

            .data
NUMBER		.byte 	0X3F,0X06,0X5B,0X4F,0X66,0X6D,0X7D,0X07,0X7F,0X6F
LEDS		.byte	0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
;			Configura o Timer_A, modo continuo
;-------------------------------------------------------------------------------
			mov.w   #CCIE,&TA0CCTL0         ; TACCR0 interupção habilitada
            mov.w   #T_MEIOSEG,&TA0CCR0			; Conta até 32767 e gera interrupção
            mov.w   #TASSEL_1 + MC_1,&TA0CTL  ; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
            nop                             ;
            bis.w   #GIE,SR            		; habilita interrupções mascaráveis
            nop                             ;

;-------------------------------------------------------------------------------
;			Configura Portas
;-------------------------------------------------------------------------------
;--------------------------------  Ligação Jumpers------------------------------
;P3.5 <---------------------------> DIS1_EN
;P3.4 <---------------------------> LED_EN
;---------------------------------  Configura as Portas  ------------------------
;Usaremos a porta 4.0 a 4.6 para ligar display
			bic		#BIT0 | BIT1 | BIT2 | BIT3 | BIT4 | BIT5 | BIT6 | BIT7,P4SEL				;P4.X, Entrada e Sáida
			bis		#BIT0 | BIT1 | BIT2 | BIT3 | BIT4 | BIT5 | BIT6 | BIT7,P4DIR				;P4.X, Porta de Saída
			mov		#0,R10
			mov		NUMBER(R10),P4OUT				;P4.X	DISPLAY COM 0
			mov		#0,R9
;Usaremos a porta 3.5, para habilitar display de sete segmentos do kit
			bic		#BIT5,P3SEL				;P3.4, Entrada e Sáida
			bis		#BIT5,P3DIR				;P3.4, Porta de Saída
			bis		#BIT5,P3OUT				;P3.4, Em nível Alto (1), habilita leds

;Usaremos a porta 3.4, para desabilitar led
			bic		#BIT4,P3SEL				;P3.4, Entrada e Sáida
			bis		#BIT4,P3DIR				;P3.4, Porta de Saída
			bic		#BIT4,P3OUT				;P3.4, Em nível Alto (1), habilita leds
;Usaremos a porta 3.6, para habilitar display de sete segmentos (2) do kit
			bic		#BIT6,P3SEL				;P3.4, Entrada e Sáida
			bis		#BIT6,P3DIR				;P3.4, Porta de Saída
			bis		#BIT6,P3OUT				;P3.4, Em nível Alto (1), habilita leds



;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
LOOP
		jmp	LOOP


PISCA
		cmp.b		#1,R8
		jz			P5
		cmp.b		#0,R9
		jnz			DECREMENTO
		cmp.b		#9,R10
		jz			P1
		inc.b 		R10
		jmp			P2
P1
		mov.b		#1,R9
		jmp			DECREMENTO

P2		;call	#LIGA_LED
		mov.b	NUMBER(R10),P4OUT
		reti

DECREMENTO
		cmp.b		#1,R9
		jnz			PISCA
		cmp.b		#0,R10
		jz		P3
		dec.b 	R10
		jmp		P4
P3
		mov.b	#0,R9
		jmp		PISCA
P4		mov.b	NUMBER(R10),P4OUT
P5
		reti


LIGA_LED
		bic			#BIT5,P3OUT
		bis			#BIT4,P3OUT
		mov.b		#1,R8
		cmp.b		#0,R9
		jnz			FIM_LIG
		mov.b		LEDS(R10),P4OUT
		;mov.b		#0,R8

		bis.b		#TAIFG,&TACTL
		mov.b		#0,R8
;L1		cmp.b		#0xFF,R8
;		jz			FIM_LIG
;		inc.b		R8
;		jmp			L1
FIM_LIG
		bic		#BIT4,P3OUT
		bis		#BIT5,P3OUT
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
            .sect   TIMER0_A0_VECTOR        ; Timer0_A3 CC0 Vetor Interrução do timer
            .short  PISCA

            
