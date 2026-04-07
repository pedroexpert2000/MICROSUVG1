/*
 * NombreProgra.c
 *
 * Created: 
 * Author: 
 * Description: 
 */
/****************************************/
// Encabezado (Libraries)

#include <avr/io.h>
#include <stdint.h>

/****************************************/
// Encabezado (Libraries)
volatile uint8_t contador = 0;

/****************************************/
// Function prototypes

void setup();
void delay();

/****************************************/
// Main Function

int main(void)
{
	setup();
	while(1)
	{
		PORTC |= (1<<DDC3) | (1<<DDC2) |(1<<DDC1) |(1<<DDC0);	
		delay();
		PORTC &= ~((1<<DDC3) | (1<<DDC2) |(1<<DDC1) |(1<<DDC0));
		delay(); 
	}
}
/****************************************/
// NON-Interrupt subroutines

void setup()
{
	CLKPR = (1<<CLKPCE)
	CLKPR = (1<<CLKPS2)
	
	DDRC |= (1<<DDC3) | (1<<DDC2) |(1<<DDC1) |(1<<DDC0); 
	PORTC &= ~((1<<DDC3) | (1<<DDC2) |(1<<DDC1) |(1<<DDC0));
	
	
}
void delay(){
	for(volatile uint8_t i = 0; i < 255; i++)
	{
		for (volatile uint8_t j = 0; j < 255; j++)
	}
}

/****************************************/
// Interrupt routines
