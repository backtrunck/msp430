#include <msp430.h> 
#include "lcdLib.h"
unsigned char forte;

/**
 * main.c
 */
int main(void)
{


    forte ='T';

    WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer



	lcdInit();// Initialize LCD

	lcdWriteData(forte);

	lcdSetText("Go ", 0, 0);

	lcdSetText("Miners! ", 0,1);

	__bis_SR_register(LPM0_bits);   // Enter Low Power Mode 0 without interrupts
	
	return 0;
}
