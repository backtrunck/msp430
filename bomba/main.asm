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

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer



;SNAT (SENSOR TANQUE NIVEL ALTO, P2.0, Se = 1 , Nivel = ALTO)
       		bic      #0x01, &P2SEL           ;P2.0, configura primeira função I/0
       		bic      #0x01, &P2DIR           ;P2.0, configura como porta de entrada
;SNBT (SENSOR TANQUE NIVEL BAIXO, P2.1, Se = 1 , Nivel = Baixo)
       		bic      #0x02, &P2SEL           ;P2.1, configura primeira função (I/0)
       		bic      #0x02, &P2DIR           ;P2.1, configura como porta de entrada
;SNBP (SENSOR POÇO NIVEL BAIXO, P2.2 , Se = 1 , Nivel = Baixo))
       		bic      #0x04, &P2SEL           ;P2.2, configura primeira função (I/0)
       		bic      #0x04, &P2DIR           ;P2.2, configura como porta de entrada
;BH (ATUADOR DA BOMBA P4.0, 1 para bomba ligada
       		bic      #0x01, &P4SEL           ;P4.0, configura primeira função (I/0)
       		bis      #0x01, &P4DIR           ;P4.0, configura como porta de saida
;ANBP (Atuador do alarme de poço vazio P4.1, 1 alarme ligado)
       		bic      #0x02, &P4SEL           ;P4.1, configura primeira função (I/0)
       		bis      #0x02, &P4DIR           ;P4.1, configura como porta de saida
;COL0 (PINO PARA FORNECER TERRA AO TECLADO)
       		bic      #0x32, &P2SEL           ;P2.5, configura primeira função (I/0)
       		bis      #0x32, &P2DIR           ;P2.5, configura como porta de saida
       		bic      #0x32, &P2OUT           ;P2.5, coloca em baixo(0),a porta, coluna teclado

;LEDEN (PINO PARA HABILITAR OS LED'S)
       		bic      #0x16, &P3SEL           ;P3.4, configura primeira função (I/0)
       		bis      #0x16, &P3DIR           ;P3.4, configura como porta de saida
       		bis      #0x16, &P3OUT           ;P3.4,Coloca em Alto(1),a porta. Habilita os Leds

;-------------------------------------------------------------------------------
;LIGAÇOES DOS FIOS (JUMPERS) NA PLACA
;TCL_LIN0  <-----------------------------> P2.0 (SNAT)
;TCL_LIN1  <-----------------------------> P2.1 (SNBT)
;TCL_LIN2  <-----------------------------> P2.2 (SNBP)
;TCL_COL0  <-----------------------------> P2.5 (VIDE SLIDE 18, AULA 7)
;LED_EN    <-----------------------------> P3.4 (VIDE SLIDE 18, AULA 7)
;DB0(LED1) <-----------------------------> P4.0 (BH) (VIDE SLIDE 18, AULA 7)
;DB1(LED2) <-----------------------------> P4.1	(ANBP)(VIDE SLIDE 18, AULA 7)
;OBS1: NO SLIDE 29 DA AULA 7, PEDE LIGAÇÃO EM OUTROS PINOS (P5.0 A P5.4) NÃO SEGUI ESTA CONFIGURAÇÃO
;OBS2: OS SENSORES SNAT, SNBT E SNBP, VÁO SER SIMULADOS RESPECTIVAMENTE PELAS TECLAS K2,K5,K8,
;CONFORME AS LIGAÇÕES DOS FIOS ACIMA. INICIALMENTE TODOS OS SENSORES ESTARÃO EM ALTO(LIGAGOS) E A
;CADA TOQUE(MANTENDO PRESSIONADO) O SENSOR VAI PARA BAIXO(DESLIGADO). ASSIM PARA SIMULAR SNAT, SNBT
;E SNBP BAIXOS, DEVE-SE MANTER PRESSIONADAS AS TECLAS K2, K5 E K8.
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LOOP:
       	bit    	#0x04, &P2IN				;P2.2, verifica se poço esta baixo
       	jz    	POCOCOMAGUA					;se bit = 0, Nivel do Poço não está baixo. Desvia
       	bis		#0x02,&P4OUT				;P4.1, ligar o alarme do poço (liga LED2), nivel poço baixo
		bic		#0x01,&P4OUT				;P4.0, Desligar a bomba (desliga LED1)
		jmp		LOOP						;poço vazio, retorna para início
POCOCOMAGUA:
		bic		#0x02,&P4OUT				;P4.1, desliga o alarme do Poço (desliga LED2).
       	bit     #0x01, &P2IN				;P2.0, verifica se o nivel do tanque esta alto (SNAT)
       	jz		VRF_SNBT					;Se o nivel do tanque não está alto (SNAT=0), desvia para Verificar SNBT (VRF_SNBT)
       	bic		#0x01,&P4OUT				;P4.0. o nivel do tanque está alto (SNAT=1),desliga a bomba (desliga LED1)
       	jmp    	LOOP						;volta início

VRF_SNBT:
       	bit		#0x02,&P2IN 				;P2.1, verifica se o nível do tanque esta baixo (SNBT)
       	jz		LOOP						;Se o nivel do tanque não esta baixo(SNBT=0), não há o que fazer, volta para início
       	bis		#0x01,&P4OUT				;P4.0,o nível do tanque esta baixo (SNBT=1) liga a bomba (liga LED1)
       	jmp    	LOOP						;volta início



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
            
