/*
 * PRE_LAB6_C.c
 *
 * Created: 20/04/2026 12:36:32
 * Author : Pedro Porras
 */ 

#include <avr/io.h>
#include <stdint.h>
#include "USART.h"

#define F_CPU 16000000UL

void setup();
void initUSART();

int main(void)
{
    cli;
	DDRB |= (1<<DDB5);
	PORTB &= ~)(1<<PORTB5);
	initUSART(0, RX_INTERRUPT, PARITY_NONE, ASYNCHRONOUS_MODE, STOP_BIT_1, CHAR_SIZE_8, 9600 )
	sei; 
    while (1) 
    {
    }
}

ISR(USART_RX_vect){
	
	
	
	
	
}
