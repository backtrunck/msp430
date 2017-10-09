;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .define	1,NUM_1
            .define	32768,UM_SEG
            .define 0,POS0
            .define 1,POS1
            .define 2,POS2
            .define 3,POS3
            .define 4,POS4
            .define 5,POS5
            .define 6,POS6

;----------- Definições para o Display

            .define BIT0,	SEG_M					;
            .define BIT1,	SEG_G					;	  AAAAAAAAA
            .define BIT2,	SEG_F					;	 F H  J  K B
            .define BIT3,	SEG_E					;    F  H J K  B
            .define BIT4,	SEG_D					;    F    J    B
            .define BIT5,	SEG_C					;	   GGG MMM
            .define BIT6,	SEG_B					;	 E    P    C
            .define BIT7,	SEG_A					;	 E	Q P N  C
            .define BIT8,	SEG_H					;    E Q  P  N C
            										;     DDDDDDDDD


			.define SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F, 					DIGITO_0
			.define SEG_B | SEG_C, 													DIGITO_1
			.define SEG_A | SEG_B | SEG_M | SEG_G | SEG_E | SEG_D , 				DIGITO_2
			.define SEG_A | SEG_B | SEG_M | SEG_G | SEG_C | SEG_D, 					DIGITO_3
			.define SEG_F | SEG_G | SEG_M | SEG_B | SEG_C,							DIGITO_4
			.define SEG_A | SEG_F | SEG_G | SEG_M | SEG_C | SEG_D,					DIGITO_5
			.define SEG_A | SEG_F | SEG_G | SEG_M | SEG_C | SEG_D | SEG_E, 			DIGITO_6
			.define SEG_A | SEG_B | SEG_C, 											DIGITO_7
			.define SEG_A | SEG_B | SEG_F | SEG_G | SEG_M | SEG_E | SEG_D | SEG_C, 	DIGITO_8
			.define SEG_A | SEG_F | SEG_B | SEG_G | SEG_M | SEG_C | SEG_D,			DIGITO_9
			.define SEG_A | SEG_F | SEG_B | SEG_G | SEG_M | SEG_C | SEG_E,			LETRA_A
			.define SEG_F | SEG_G | SEG_M | SEG_C | SEG_D | SEG_E,					LETRA_b
			.define SEG_A | SEG_F | SEG_E | SEG_E, 									LETRA_C



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

			mov		#9,R15

			call	#CNF_LCD_4MUX

			call 	#CNF_TIMER

			;push	#NUM_1
			;call 	#PRINT_CARAC
			;add		#0x2,SP

			;mov.b	#0xFF,&LCDM3													;coração, exclamação,relagio,[R]
			;segundo digito (inicio)

			;mov.b	#0xFF,&LCDM4													;4º Digito (8)
			;mov.b	#0xFF,&LCDM5													;4º Digito (completo) com ponto inferior a esquerda e sinal de antena
			;segundo digito (fim)

			;digito (inicio)
			;mov.b	#0xFF,&LCDM6													;5º Digito (8)
			;mov.b	#0xFF,&LCDM7													;5º Digito (completo) com ponto inferior a esquerda e sinal de dois pontos entre o 5º e 4º digito.
			;digito (fim)

			;digito (inicio)
			;mov.b	#0xFF,&LCDM8													;1º Digito (8)
			;mov.b	#0xFF,&LCDM9													;1º Digito (complet)e sinal de Tx e Rx da antena
			;digito (fim)


			;digito (inicio)
			;mov.b	#0xFF,&LCDM10													;6º Digito (8)
			;mov.b	#0xFF,&LCDM11													;6º Digito (completo) com ponto inferior a esquerda  e sinal de menos,
			;digito (fim)

			;digito (inicio)
			;mov.b	#0xFF,&LCDM12													;sem efeito nos testes
			;mov.b	#0x01,&LCDM13													;sem efeito nos testes
			;mov.b	#0xF0,&LCDM14													;Medidor de baterias, a partir da esquerda (010101) com pino da bateria a esquerda
			;digito (fim)



			;digito (inicio)
			;mov.b	#0xFF,&LCDM15													;2º Digito (8)
			;mov.b	#0xFF,&LCDM16													;2º Digito (completo) com ponto inferior a esquerda, mais sinal de angulo (grau)
			;digito (fim)


			;mov.b	#0xFF,&LCDM17													;Sem efeito nos testes

			;mov.b	#0xFF,&LCDM18													;Bateria ([10101])
			;mov.b	#0xFF,&LCDM19													;3º Digito (8)


			;mov.b	#0xFF,&LCDM20													;3º Digito (completo) com ponto inferior a esquerda e sinal de dois pontos entre o 3º e 2º digito.

			;mov.b	#DIGITO_8,&LCDM8








;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP
			jmp LOOP
			nop

CNF_LCD_4MUX
;----------- configura os pinos/portas para trabalharem com o display (BackPlane)------------------

;P6.3 	<-------------------------> 	COM0
;P6.4	<-------------------------> 	COM1
;P6.5	<-------------------------> 	COM2
;P6.6 	<-------------------------> 	COM3

;P6SEL0.x = 1
;P6SEL1.x = 1

;---------------------------------------------------------------------------------
			bis		# BIT3 | BIT4 | BIT5 | BIT6,&P6SEL0
			bis		# BIT3 | BIT4 | BIT5 | BIT6,&P6SEL1

;------------- configura o controlador do display --------------------------------
;Registrador
;LCDCCTL0.LCDON = ligado. Liga o display
;LCDCCTL0.LCDMXx = LD4MUX. Multiplexação 4
;LCDCCTL0.LCDSSEL = 0. seleciona ACLK como fonte de frequencia
;LCDCCTL0.LCDPREx e LCDCCTL0.LCDDIVx,são usados para dividir ACLK e obter a frequencia que vai ser utilizada pelo LCD ou framing frequency-> dada pelo datasheet do LCD
;LCDCCTL0.LCDPRE2 = LCDPRE2 = 2
;LCDCCTL0.LCDDIVx = LCDDIV_21 = 21
;Framing Frequency = ACLK/[(LCDDIVx + 1) * 2 ** LCDPRE2]

			mov.w	#LCDON | LCD4MUX | LCDPRE2 | LCDDIV_9 | LCDLP,&LCDCCTL0

;----------- configura os pinos/portas para trabalharem com o display (Segmentos) ------------------

;Olhar a pinagem do datasheet do MicroControlador e verificar quais pinos trabalhar com quais segmentos do LCD
;Exemplo
;O pino 12 do microcontrolador msp430fr6989, é a porta P6.5 (digital I/O) e também controla o segmento 2 do LCD
;Assim temos que habilitar o pino 2 para controlar o segmento 2 e não ser um porta digital I/O
;LCDCPCTL0.LCDS35 = 1. Pino 12 ou Porta P6.5 controla o segmento 35 do display.

;configuramos todas as portas que ligam o micro controlador ao Display, para testar

			mov.w	#LCDS32 | LCDS33 | LCDS34 | LCDS35 | LCDS36 | LCDS37 | LCDS38 | LCDS39  ,&LCDCPCTL2
			mov.w	#LCDS4 | LCDS5 | LCDS6 | LCDS7 | LCDS8 | LCDS9 | LCDS10 | LCDS11 | LCDS12 | LCDS13 | LCDS14 | LCDS15 ,&LCDCPCTL0
			mov.w	#LCDS16 | LCDS17 | LCDS18 | LCDS19 | LCDS20 | LCDS21 | LCDS22 | LCDS23 | LCDS24 | LCDS25 | LCDS26 | LCDS27 | LCDS28 | LCDS29 | LCDS31 | LCDS30 ,&LCDCPCTL1


			mov.w	#LCDDISP,&LCDCMEMCTL									;Display ligado ao que esta gravado na memória
			mov.w	#LCDCLRM,&LCDCMEMCTL									;Limpa Memória


			ret
                                            

PRINT_CARAC

			push		R15
			push		R14
			mov.w		6(SP),R15					;Pega o caracter a ser mostrado no display
			mov.w		8(SP),R14					;Pega a posição onde vai ser impresso

PS1
			cmp			#POS1,R14
			jnz			PS2
			mov.b		R15,&LCDM8
			jmp			FIM_PRINT_CARAC
PS2
			cmp			#POS2,R14
			jnz			PS3
			mov.b		R15,&LCDM15
			jmp			FIM_PRINT_CARAC
PS3
			cmp			#POS3,R14
			jnz			PS4
			mov.b		R15,&LCDM19
			jmp			FIM_PRINT_CARAC
PS4
			cmp			#POS4,R14
			jnz			PS5
			mov.b		R15,&LCDM4
			jmp			FIM_PRINT_CARAC
PS5
			cmp			#POS5,R14
			jnz			PS6
			mov.b		R15,&LCDM6
			jmp			FIM_PRINT_CARAC
PS6
			mov.b		R15,&LCDM10
FIM_PRINT_CARAC
			pop			R14
			pop			R15
			ret

;-------------- Configura o Timer_A, modo up -------------
CNF_TIMER
			mov.w   #CCIE,&TA0CCTL0         ; TACCR0 interupção habilitada
            mov.w   #UM_SEG,&TA0CCR0			; Conta até 32767 e gera interrupção
            mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  ; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
            nop                             ;
            bis.w   #GIE,SR            		; habilita interrupções mascaráveis
            nop
            ret

 ;------------------ Mostra Contagem no Display --------------------------------
CONTADOR

 			inc		R15
 			cmp		#10,R15
 			jnz		UM
 			mov		#0,R15

 			push	#POS1
 			push	#DIGITO_0
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

 			jmp		FIM_CONTADOR
UM
 			cmp		#1,R15
 			jnz		DOIS

 			push	#POS1
 			push	#DIGITO_1
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

 			jmp		FIM_CONTADOR
DOIS
			cmp		#2,R15
 			jnz		TRES

			push	#POS1
 			push	#DIGITO_2
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR
TRES
			cmp		#3,R15
 			jnz		QUATRO

			push	#POS1
 			push	#DIGITO_3
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR
QUATRO
			cmp		#4,R15
 			jnz		CINCO

			push	#POS1
 			push	#DIGITO_4
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR

CINCO
			cmp		#5,R15
 			jnz		SEIS

			push	#POS1
 			push	#DIGITO_5
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR
SEIS
			cmp		#6,R15
 			jnz		SETE

 			push	#POS1
 			push	#DIGITO_6
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR
SETE
			cmp		#7,R15
 			jnz		OITO

			push	#POS1
 			push	#DIGITO_7
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR
OITO
			cmp		#8,R15
 			jnz		NOVE

			push	#POS1
 			push	#DIGITO_8
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

			jmp		FIM_CONTADOR
NOVE
			push	#POS1
 			push	#DIGITO_9
 			call	#PRINT_CARAC
 			mov		#POS2,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS3,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS4,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS5,2(SP)
 			call	#PRINT_CARAC
 			mov		#POS6,2(SP)
 			call	#PRINT_CARAC
 			add		#4,SP

FIM_CONTADOR
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
            .short  CONTADOR				;função para tratar a interrupção
            
