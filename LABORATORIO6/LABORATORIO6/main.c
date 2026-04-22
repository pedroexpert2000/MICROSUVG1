/*
 * PRE_LAB6_C.c
 *
 * Created: 20/04/2026
 * Author : Pedro Porras
 */ 

#define F_CPU 16000000UL

#include <avr/io.h>
#include <stdint.h>
#include <avr/interrupt.h>
#include <util/delay.h>  
#include "USART.h"
#include "ADC.h"

/****************************************/
// Define Prototypes 
void setup();
void menu();

volatile char estado = 0;
volatile uint8_t pot1 = 0;

/****************************************/
// Main Function
int main(void)
{
    cli();
    setup();
    initUSART(0, RX_INTERRUPT | RECEIVER_ENABLE| TRANSMITTER_ENABLE, PARITY_NONE, ASYNCHRONOUS_MODE, STOP_BIT_1, CHAR_SIZE_8, 9600);
    initADC(ADC_AVCC, ADCH_ACT, PS_8); 
    sei(); 
    menu();
    while (1) 
    {
        if (estado == '1'){    
            pot1 = readADC(2);
         
            uint8_t centena = pot1 / 100;
            uint8_t decena  = (pot1 % 100) / 10; 
            uint8_t unidad  = pot1 % 10; 
                
            writeString("Valor de Voltaje: "); 
            writeChar(centena + '0');
            writeChar(decena + '0'); 
            writeChar(unidad + '0');
            writeString("\r\n");
            
            _delay_ms(500);
        }
    }
}

/****************************************/
// NON-Interrupt subroutines

void setup(){
    
    DDRB |= 0x3F; 
    PORTB &= ~0x3F; 
    
    DDRC |= 0x03; 
    PORTC &= ~0x03; 
} 


void menu(){
    writeString("\r\nMenu Principal\r\n");
    writeString("1. Potenciometro\r\n");
    writeString("2. Caracter en LEDs\r\n");
}

/****************************************/
// Interrupt routines

ISR(USART_RX_vect){
	
	uint8_t tecla = UDR0;
	writeChar(tecla);
	
	if (estado == '2') {
		PORTB = (PORTB & 0xC0) | (tecla & 0x3F);
		PORTC = (PORTC & 0xFC) | ((tecla & 0xC0) >> 6);
		
		writeString("Caracter Seleccionado en LEDs");
		estado = 0;
		menu();
	}
	
	else if (tecla == '1') {
		writeString("Lectura de voltaje:");
		estado = '1';
	}
	else if (tecla == '2') {
		writeString("Ingresa un caracter:");
		estado = '2'; 
	}
	else if (tecla == '0') {
		writeString("\r\nRegresando al menu:\r\n");
		estado = 0;
		menu();
	}
}
/****************************************/