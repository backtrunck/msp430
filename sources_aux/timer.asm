DELAY_TIMER_1_MAC	.macro	QT_SEGUNDOS
				push	QT_SEGUNDOS
				call	#DELAY_TIMER_1
				add	#2,SP
	.endm


DELAY_TIMER_1
	mov.w   8(SP),&TA1CCR0
