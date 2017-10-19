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

MSG_TO_LCD_MAC			.macro	PORTA_RS, BIT_RS, PORT_ENABLE, BIT_ENABLE, BUFFER_DADOS,MENSAGEM
							push	PORTA_RS
							push 	BIT_RS
							push	PORT_ENABLE
							push	BIT_ENABLE
							push	BUFFER_DADOS
							push	MENSAGEM
							call	#MSG_TO_LCD
							add		#12,SP
						.endm

ENV_BYTE_TO_LCD_MAC		.macro	REGISTRADOR,BYTE
							push	REGISTRADOR
							push	BYTE
							call	#ENVIA_BYTE_TO_LCD
							add		#4,SP
						.endm
INICIAR_LCD_MC			.macro	PORTA_RS,	BIT_RS,	PORT_ENABLE,	BIT_ENABLE,	BUFFER_DADOS
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
