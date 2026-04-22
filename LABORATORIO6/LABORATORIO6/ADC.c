/*
 * ADC.c
 *
 * Created: 13/04/2026 20:25:10
 *  Author: Pedro Porras
 */ 


#include "ADC.h"

void initADC(uint8_t voltage, uint8_t HIGH_LOW, uint8_t prescaler){

	ADMUX = 0;
	ADMUX |= voltage | HIGH_LOW;

	ADCSRA = 0;
	ADCSRA |= ADC_ENABLE |  prescaler;
}

uint16_t readADC(uint8_t canal){

	ADMUX = (ADMUX & 0xF0) | (canal & 0x0F);
	
	ADCSRA |= ADC_START;


	while(ADCSRA & (1<<ADSC));

	return ADCH;
}