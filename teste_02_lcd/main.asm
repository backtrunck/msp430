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

            .define	BIT0,	SEG_M					;
            .define	BIT1,	SEG_G					;	  AAAAAAAAA
            .define	BIT2,	SEG_F					;	 F H  J  K B
            .define	BIT3,	SEG_E					;    F  H J K  B
            .define	BIT4,	SEG_D					;    F    J    B
            .define	BIT5,	SEG_C					;	   GGG MMM
            .define	BIT6,	SEG_B					;	 E    P    C
            .define	BIT7,	SEG_A					;	 E	Q P N  C
            .define	BIT8,	SEG_DP					;    E Q  P  N C
            .define	BIT9,	SEG_N					;     DDDDDDDDD
            .define	BITA,	SEG_NEG
            .define	BITB,	SEG_Q
            .define	BITC,	SEG_P
            .define	BITD,	SEG_K
            .define	BITE,	SEG_J
            .define	BITF,	SEG_H



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
			.define	SEG_M | SEG_G | SEG_J | SEG_P | SEG_K | SEG_Q | SEG_H | SEG_N,	CARAC_ASTER

PRTDSP		.macro	POS_LCD, CARAC, TP_CARAC
			push	POS_LCD
			push	CARAC
			push	TP_CARAC
			call	#PRT_CARAC
			add		#6,SP
			.endm



;-------------------------------------------------------------------------------
			.data

NUMEROS		.word 0x28FC, 0x2060, 0x00DB, 0x00F3, 0x0067, 0x00B7, 0x00BF, 0x00E4, 0x00FF, 0x00F7			;Digitos de "0" a "9"
MAIUSCULAS	.word 0x00EF, 0x50F1, 0x009C, 0x50F0, 0x009F, 0x008F, 0x00BD, 0x006F, 0x5090, 0x0078, 0x220E, 0x001C, 0xA06C
			.word 0x826C, 0x00FC, 0x00CF, 0x02FC, 0x02CF, 0x00B7, 0x5080, 0x007C, 0x280C, 0x0A6C, 0xAA00, 0xB000, 0x2890			;Letras A  a Z
			.word 0xFA03
MEM_LED		.byte 0x07,0x0E,0X12,0X03,0X05,0X09
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

			mov		#0,R15


			push	#0
			call 	#DSP_PING_PONG
			push	#1
			call 	#DSP_PING_PONG


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

;------------------ Imprime Carateres na Telas -------------------------------

PRT_CARAC											;recebe três parametros POS_LCD,CARAC,TP_CARAC pela pilha
													;POS_LCD -> Onde o caracter vai ser impresso no LCD. POS_LCD = 0,
													;posição mais a direita, POS_LCD = 5, Posição mais a esquerda.
													;CARAC -> Caracter que vai ser impresso na tela do LCD
													;TP_CARAC -> tipo do caracter; TP_CARAC = 0, mostra numeros,
													;TP_CARAC = 1, mostra letras maiusculas
													;TP_CARAC = 2, mostra letras minúsculas (a implementar)

			push		R15							;Salva R15 na pilha
			push		R14							;Salva R14 na pilha
			push		R13							;Salva R13 na pilha

			mov.w		8(SP), R13
			mov.w		10(SP), R15					;Pega o parametro CARAC
			mov.w		12(SP),R14					;Pega o parametros POS_LCD

			rla			R15							;R15 * 2, pula dois endereços na memória, caracter de 16bits

			mov.b		MEM_LED(R14),R14			;Pega no array MEM_LED, o offset da posição de memória
													;do LCD. Serve para mostramos o caracter numa posição
													; específica do Display. Conforme argumento passado
IF_PRT_NUM													;para a função.
			cmp			#0,R13
			jnz			IF_PRT_MAI
			mov			NUMEROS(R15),R15			;Pega no array NUMEROS, os segmentos que vão ser
													;ligados no LCD.
			jmp			FIM_IF_PRT
IF_PRT_MAI
			;cmp			#1,R13					;a ser implementado qdo, imprimir minusculas
			mov			MAIUSCULAS(R15),R15			;Pega no array MAIUSCULAS, os segmentos que vão ser
													;ligados no LCD.

FIM_IF_PRT
			mov.b		R15,LCDM1(R14)				;Mostra o caracter contido em R15 no Display
			inc			R14							;Incrementa R14. Pega Próxima posição de Memória do
													;Display. Para ligar mais segmentos.

			swpb		R15							;Troca o byte superior com o byte inferior do registrado
													;O byte superior contem outros segmentos que precisam
													;mostrados no display para mostrar o caracter completo

			mov.b		R15,LCDM1(R14)				;Mostra o outros segmentos do Caracter. Carater completo

			pop			R13							;Restaura R13 da pilha
			pop			R14							;Restaura R14 da pilha
			pop			R15							;Restaura R15 da pilha
			ret

;------------------ Configura o Timer_A, modo up -----------------------------
CNF_TIMER
			mov.w   #CCIE,&TA0CCTL0        		 	; TACCR0 interupção habilitada
            mov.w   #UM_SEG,&TA0CCR0				; Conta até 32767 e gera interrupção
            mov.w   #TASSEL__ACLK+MC__UP,&TA0CTL  	; Usa oscilador ACLK(32.768)pg.15 user guide launch, modo up
            nop
            ;bis.w   #GIE,SR            				; habilita interrupções mascaráveis
            nop
            ret

 ;------------------ Mostra Contagem no Display --------------------------------
CONTADOR
 			mov 	#0,R14
 			push	R14
 			push 	R15
 			push	#0

L1			cmp		#6,R14
 			jz		FIM_CONTADOR


 			mov		R14,4(SP)
 			call	#PRT_CARAC
 			inc		R14
 			jmp 	L1
ZERA_CONTADOR
 			mov		#0,R15
 			reti

FIM_CONTADOR
			add		#2,SP
			pop		R15
			pop		R14
			inc 	R15
			cmp 	#36,R15
			jz		ZERA_CONTADOR
 			reti


DSP_PING_PONG
 			push	R15
 			mov 	4(SP),R15

 			mov		#CARAC_ASTER,R14


IF_IN_DIR
 			cmp		#0,R15
 			jnz		IN_ESQ

 			PRTDSP	#0,#36,#0			;PRTDSP(POS_LCD, CARAC, TP_CARAC), imprime no Display

 			mov 	#0,R13

 			jmp		FIM_IF_IN_DIR
IN_ESQ

			PRTDSP	#5,#36,#1			;PRTDSP(POS_LCD, CARAC, TP_CARAC), imprime no Display
			mov 	#5,R13

FIM_IF_IN_DIR


 			jmp		FIM_IF_IN_DIR
 			pop		R15
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
            .short  CONTADOR				;função para tratar a interrupção
            
