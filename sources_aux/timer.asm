			.define	32,	UM_MILI_SEG
            .eval	32 * 5, CINCO_MILI_SEG
            .eval	32 * 15, QUINZE_MILI_SEG
            .eval	32*47/1000,TRINTA_MICRO_SEG
            .define	"bis.b	#BIT1,P2OUT",ENABLE_H
            .define	"bic.b	#BIT1,P2OUT",ENABLE_L
            .define	"bis.b	#BIT5,P2OUT",RS_H
            .define	"bic.b	#BIT5,P2OUT",RS_L



DELAY_TIMER_1_MAC		.macro	QT_SEGUNDOS
							push	QT_SEGUNDOS
							call	#DELAY_TIMER_1
							add	#2,SP
						.endm
PULSO_MAC				.macro		PORTA_ENABLE,	BIT_ENABLE
							push	PORTA_ENABLE
							push	BIT_ENABLE
							call	#PULSO
							add	#4,SP
						.endm

MSG_TO_LCD_MAC			.macro		PORTA_RS, BIT_RS, PORT_ENABLE, BIT_ENABLE, BUFFER_DADOS,MENSAGEM
							push	PORTA_RS
							push 	BIT_RS
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							push	MENSAGEM
							call	#MSG_TO_LCD
							add		#12,SP
						.endm

ENV_BYTE_TO_LCD_MAC		.macro		PORT_ENABLE,BIT_ENABLE,BUFFER_DADOS,BYTE
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							push	BYTE
							call	#ENVIA_BYTE_TO_LCD
							add		#8,SP
						.endm

ENVIA_DADOS_TO_LCD_MAC		.macro		PORT_ENABLE,BIT_ENABLE,BUFFER_DADOS,BYTE
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							push	BYTE
							call	#ENVIA_DADOS_TO_LCD
							add		#8,SP
						.endm

INICIAR_LCD_MC			.macro		PORTA_RS,	BIT_RS,	PORT_ENABLE,	BIT_ENABLE,	BUFFER_DADOS
							push	PORTA_RS
							push 	BIT_RS
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							call	#INICIAR_LCD
							add		#10,SP
						.endm

SET_COMANDO_MAC			.macro	REGISTRADOR,PINO,ENABLE
							push	REGISTRADOR
							push	PINO
							push	ENABLE
							call	#SET_COMANDO
							add		#6,SP
						.endm


PRINT_LCD_X_Y_MAC		.macro		PORTA_RS, BIT_RS, PORT_ENABLE, BIT_ENABLE, BUFFER_DADOS,MENSAGEM,COORD_X,COORD_Y
							push	PORTA_RS
							push 	BIT_RS
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							push	MENSAGEM
							push	COORD_X
							push	COORD_Y
							call	#PRINT_LCD_X_Y
							add		#16,SP
						.endm

PRINT_PLACAR_MAC 		.macro		PORTA_RS, BIT_RS, PORT_ENABLE, BIT_ENABLE, BUFFER_DADOS,MENSAGEM
							push	PORTA_RS
							push 	BIT_RS
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							push	MENSAGEM
							call	#MSG_TO_LCD
							add		#12,SP
						.endm

						.global	ENVIA_BYTE_TO_LCD,INICIAR_LCD,MSG_TO_LCD,PRINT_LCD_X_Y,PRINT_PLACAR
