// #include <msp430.h>


/**
 * main.c
 *
 */

int ler_serial(int i);

int main(void)
{
	//WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	int i;

	
	i = ler_serial(5);


    return 0;
}




