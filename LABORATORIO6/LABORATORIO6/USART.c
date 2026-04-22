/*
 * USART.c
 *
 * Created: 20/04/2026 11:44:07
 * Author: Pedro Porras
 */ 

#include <stdint.h>
#include <avr/io.h>

#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#include "USART.h"  


void initUSART(uint8_t config_A, uint8_t config_B, uint8_t config_C, uint8_t modo,  uint8_t stopbit, uint8_t charsize, uint32_t baud){
	
    uint16_t ubrr_value = (F_CPU / (16 * baud)) - 1;

    UBRR0H = (uint8_t)(ubrr_value >> 8);
    UBRR0L = (uint8_t)ubrr_value;

    UCSR0A = config_A;
    UCSR0B = config_B; 
    UCSR0C = config_C | modo | stopbit | charsize ;
	
}

void writeChar(char c){

	while(!(UCSR0A & (1<<UDRE0)));
	UDR0 = c;
}

void writeString(char* string){

	for(uint8_t i = 0; *(string + i) != '\0'; i++){
		writeChar(*(string + i));
	}
}
