		.cdecls C,LIST,"msp430.h"       				; Include device header file
		.include	timer.asm

		.global	LINHA_1,LINHA_2,MSG,MSG2,SET_NUM_LINHAS_E_TAM_FONTE,SET_DISPLAY_OFF
		.global	SET_DISPLAY_CLEAR,RETURN_HOME,SET_CURSOR_MV_DIR,SET_CURSOR_MV_ESQ,SET_SHOW_CURSOR,COMANDO,ROLA_TELA_ESQ
		.def	ENVIA_BYTE_TO_LCD,INICIAR_LCD,MSG_TO_LCD,ENVIA_DADOS_TO_LCD,PRINT_LCD_X_Y,DELAY_TIMER_1

		.data
SET_NUM_LINHAS_E_TAM_FONTE					;Comando para configurar numero de linh e tamanho da fonte do lcd
			.byte	0x28
SET_DISPLAY_OFF	.byte	0x08				;Comando para desligar display do lcd

SET_DISPLAY_CLEAR							;Comando para limpar display do lcd
			.byte	0x01
RETURN_HOME
			.byte	0x02
SET_CURSOR_MV_DIR							;Comando para ajustar a movimentação do cursor (no caso para direita)
			.byte	0x06
SET_CURSOR_MV_ESQ							;Comando para ajustar a movimentação do cursor (no caso para direita)
			.byte	0x07
SET_SHOW_CURSOR
			.byte	0x0C					;Comando para mostrar o cursor do lcd
COMANDO		.byte	0xCA
ROLA_TELA_ESQ
			.byte	0x1C
X			.byte	0x00
Y			.byte	0x00

SET_COMANDO												;Habilita modo escrita ou de comando do LCD
														;Parametros (PORTA_DE_SAIDA,PINO,ENABLE
			push	R15									;Salva na pilha
			push	R14									;Salva na pilha

			mov		8(SP),R15							;Pino(RS)
			mov		10(SP),R14							;Porta

			cmp		#0,6(SP)							;Compara ENABLE com 0, se igual vai por modo comando, se for 1 modo escrita de dados
			jnz		S1
			bic.b	R15,0(R14)							;Ajusta para modo comando
			jmp 	S2
S1			bis.b	R15,0(R14)							;Ajusta para modo escrita

S2			pop R14
			pop R15
			ret

PULSO
			push	R15									;salva na pilha
			push	R14									;salva na pilha

			mov.w	8(SP), R15							;Retira da pilha a GPIO passada

			;bic.b	6(SP),0(R15)						;Desliga a GPIO passada, usando o bit passado, (Pino Enable) Ex. P2.1
			bis.b	6(SP),0(R15)						;Liga a GPIO passada, usando o bit passado, P2.1 (Pino Enable)

			;DELAY_TIMER_1_MAC #UM_MILI_SEG				;Aguarda 1ms

			bic.b	6(SP),0(R15)						;Desliga a GPIO passada, usando o bit passado, (Pino Enable) Ex. P2.1 (
			pop 	R14									;restaura R14
			pop 	R15									;restaura R15
			ret
MSG_TO_LCD

			push	R15
			push	R14
			push	R13
			push	R12
			push	R11
			push	R10

			mov.w	14(SP),R11											;Pega Mensagem (ponteiro) mostrar no Lcd
			mov.w 	16(SP),R13											;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	18(SP),R10											;Bit Enable
			mov.w 	20(SP),R15											;Pega Porta Enable Ex. 2.1
			mov.w	22(SP),R12											;Pega Bit RS para ajustar o LCD em modo comando ou escrita
			mov.w 	24(SP),R14											;Pega Porta RS Ex. 2.5

			SET_COMANDO_MAC	R14,R12,#1									;Seta modo escrita do LCD

M1			cmp.b	#0,0(R11)							;Ve se o caracter atual da Mensagem é NULL
			jz		F_MSG								;Se for NULL, pula (toda a mensagem já foi passada para o lcd)

			ENVIA_DADOS_TO_LCD_MAC R15,R10,R13,R11
			inc		R11
			jmp 	M1
F_MSG
			SET_COMANDO_MAC	R14,R12,#0					;Volta modo comando
			pop		R10									;restaura da pilha
			pop		R11
			pop		R12
			pop		R13
			pop 	R14
			pop		R15
			ret

ENVIA_BYTE_TO_LCD
			push	R15										;salva na pilha
			push	R14										;salva na pilha
			push	R13										;salva na pilha

			push	R12
			push	R11


			mov.w 	12(SP),R15								;Pega byte (ponteiro) mostrar no Lcd
			mov.w 	14(SP),R14								;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	16(SP),R12								;Bit Enable
			mov.w	18(SP),R11								;Porta Enable

			mov.b	0(R15),R13								;Pega o conteúdo do ponteiro e salva em R13

			rra		R13										;Desloca quatro vezes o bits para direita
			rra		R13										;Desloca os nibble msb para os lsb
			rra		R13
			rra		R13
			bic.b	#BIT7 | BIT6 | BIT5 | BIT4,R13			;Apaga o nibble superior do byte, R13 contém o nibble inicial do byte
			bic.b	#BIT3 | BIT2 | BIT1 | BIT0,0(R14)		;Apaga o nible inferior da GPIO
			bis.b	R13,0(R14)								;Copia o nibble inferior para a GPIO. (Transmissão de 4 em 4 bits)

			PULSO_MAC R11, R12
			DELAY_TIMER_1_MAC #UM_MILI_SEG


			mov.b	0(R15),R13								;Novamente, Pega o conteúdo do ponteiro e salva em R13

			bic.b	#BIT7 | BIT6 | BIT5 | BIT4,R13			;Apaga o nibble superior do byte, R13 contém o nibble inicial do byte
			bic.b	#BIT3 | BIT2 | BIT1 | BIT0,0(R14)		;Apaga o nible inferior da GPIO
			bis.b	R13,0(R14)								;Copia o nibble inferior para a GPIO. (Transmissão de 4 em 4 bits)

			PULSO_MAC R11, R12
			DELAY_TIMER_1_MAC #UM_MILI_SEG


			pop		R11
			pop		R12
			pop 	R13										;restaura da pilha
			pop 	R14										;restaura da pilha
			pop		R15										;restaura da pilha
			ret

ENVIA_DADOS_TO_LCD
			push	R15										;salva na pilha
			push	R14										;salva na pilha
			push	R13										;salva na pilha

			push	R12
			push	R11


			mov.w 	12(SP),R15								;Pega byte (ponteiro) mostrar no Lcd
			mov.w 	14(SP),R14								;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	16(SP),R12								;Bit Enable
			mov.w	18(SP),R11								;Porta Enable

			mov.b	0(R15),R13								;Pega o conteúdo do ponteiro e salva em R13

			rra		R13										;Desloca quatro vezes o bits para direita
			rra		R13										;Desloca os nibble msb para os lsb
			rra		R13
			rra		R13
			bic.b	#BIT7 | BIT6 | BIT5 | BIT4,R13			;Apaga o nibble superior do byte, R13 contém o nibble inicial do byte
			bic.b	#BIT3 | BIT2 | BIT1 | BIT0,0(R14)		;Apaga o nible inferior da GPIO
			bis.b	R13,0(R14)								;Copia o nibble inferior para a GPIO. (Transmissão de 4 em 4 bits)

			PULSO_MAC R11, R12
			;DELAY_TIMER_1_MAC  #TRINTA_MICRO_SEG


			mov.b	0(R15),R13								;Novamente, Pega o conteúdo do ponteiro e salva em R13

			bic.b	#BIT7 | BIT6 | BIT5 | BIT4,R13			;Apaga o nibble superior do byte, R13 contém o nibble inicial do byte
			bic.b	#BIT3 | BIT2 | BIT1 | BIT0,0(R14)		;Apaga o nible inferior da GPIO
			bis.b	R13,0(R14)								;Copia o nibble inferior para a GPIO. (Transmissão de 4 em 4 bits)

			PULSO_MAC R11, R12
			;DELAY_TIMER_1_MAC #TRINTA_MICRO_SEG
			DELAY_TIMER_1_MAC #UM_MILI_SEG


			pop		R11
			pop		R12
			pop 	R13										;restaura da pilha
			pop 	R14										;restaura da pilha
			pop		R15										;restaura da pilha
			ret



PRINT_PLACAR

			ENV_BYTE_TO_LCD_MAC R15,R11,R13,#SET_DISPLAY_CLEAR			;Limpa lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			mov.b	#0,&X
			mov.b	#0,&Y
			PRINT_LCD_X_Y_MAC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT,#LINHA_1,#X,#Y
			mov.b	#1,&X
			mov.b	#0,&Y
			PRINT_LCD_X_Y_MAC #P2OUT,#BIT5,#P2OUT,#BIT1,#P4OUT,#LINHA_2,#X,#Y
			ret

PRINT_LCD_X_Y
			push	R15
			push	R14
			push	R13
			push	R12
			push	R11
			push	R10
			push	R9
			push	R8

			mov.w	18(SP),R8											;Pega Coordenada Y (coluna do Lcd) do local onde vai ser apresentada a msg
			mov.w	20(SP),R9											;Pega Coordenada X (linha do Lcd) do local onde vai ser apresentada a msg
			mov.w	22(SP),R11											;Pega Mensagem (ponteiro) mostrar no Lcd
			mov.w 	24(SP),R13											;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	26(SP),R10											;Bit Enable
			mov.w 	28(SP),R15											;Pega Porta Enable Ex. 2.1
			mov.w	30(SP),R12											;Pega Bit RS para ajustar o LCD em modo comando ou escrita
			mov.w 	32(SP),R14											;Pega Porta RS Ex. 2.5

			bit.b	#1,0(R9)												;verfifica se a linha = 1
			jz		LN1													;se linha = 0, pule
			add.b	#0x40,0(R8)											;se não pulou, linha = 1, soma endereço do início da segunda linha do lcd (0x40) com a coluna
																		;para achar a posição (1,coluna) do lcd.
LN1																		;se pulou linha=0, então como a posição do inicio do lcd é 0x00, então a posição
																		;vai ser 0 + coluna, portanto (0,coluna). Não precisa fazer nada.
			bis.b	#BIT7,0(R8)											;Set o Bit 7, para que forme o comando "set DDRAM address"
			ENV_BYTE_TO_LCD_MAC R15,R10,R13,R8							;Comando: posicina o cursor no lcd

			MSG_TO_LCD_MAC  R14,R12,R15,R10,R13,R11

			pop 	R8
			pop		R9
			pop		R10													;restaura da pilha
			pop		R11
			pop		R12
			pop		R13
			pop 	R14
			pop		R15

			ret

INICIAR_LCD
			push	R15
			push	R14
			push	R13
			push	R12
			push	R11

			mov.w 	12(SP),R13											;Pega portas DB4,DB5,DB6,DB7 Ex. 4.0 a 4.3
			mov.w	14(SP),R11											;Bit Enable
			mov.w 	16(SP),R15											;Pega Porta Enable Ex. 2.1
			mov.w	18(SP),R12											;Bit RS, para ajustar o LCD em modo comando
			mov.w 	20(SP),R14											;Pega Porta RS Ex. 2.5

			SET_COMANDO_MAC	R14,R12,#0									;Ajusta para modo comando do lcd

			call #CODIGO_INICIALIZACAO									;Passa os códigos de inicialização do LCD

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R15,R11,R13,#SET_NUM_LINHAS_E_TAM_FONTE	;Ajusta o numero de linha e fonte do lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R15,R11,R13,#SET_DISPLAY_OFF			;Desliga Lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R15,R11,R13,#SET_DISPLAY_CLEAR			;Limpa lcd

			DELAY_TIMER_1_MAC #UM_MILI_SEG								;Aguarda

			ENV_BYTE_TO_LCD_MAC R15,R11,R13,#SET_CURSOR_MV_DIR			;Ajusta o movimento do cursor (para direita)


			ENV_BYTE_TO_LCD_MAC R15,R11,R13,#SET_SHOW_CURSOR			;Mostra o cursor

			pop		R11
			pop		R12
			pop		R13
			pop 	R14
			pop		R15
			ret


CODIGO_INICIALIZACAO
			mov.b	#BIT0 | BIT1,P4OUT

			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #CINCO_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1

			mov.b	#BIT1,P4OUT

			DELAY_TIMER_1_MAC #UM_MILI_SEG

			PULSO_MAC #P2OUT, #BIT1
			ret

DELAY_TIMER_1
			;push	&TA0CCTL0
			;push	&TA0CCTL1
			;bic		#CCIE,&TA0CCTL0
            ;bic		#CCIE,&TA0CCTL1

			bis.w   #CCIE,&TA1CCTL0


			mov.w   2(SP),&TA1CCR0
			nop
			bis.w	#LPM3 | GIE, SR
			nop

			mov.w	#0,&TA1CCR0					;Para o Timer 1
			bic.w	#CCIE,&TA1CCTL0				;Desabilita interrupção do Timer 1

			;pop		&TA0CCTL1
			;pop		&TA0CCTL0


			ret

