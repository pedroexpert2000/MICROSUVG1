/*
 * PRE_LAB6_C.c
 *
 * Created: 20/04/2026 12:36:32
 * Author : Pedro Porras
 */ 

// 1. F_CPU movido hasta arriba para que _delay_ms funcione bien
#define F_CPU 16000000UL

// Encabezado (Libraries)
#include <avr/io.h>
#include <stdint.h>
#include <avr/interrupt.h>
#include <util/delay.h>  // Agregado para que compile _delay_ms()
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
       
	uint8_t centena= pot1 / 100;
	uint8_t decena = pot1 % 100 / 10; 
    uint8_t unidad = pot1 % 10; 

    if (estado == '1'){    
        pot1 = readADC(0);
            
    writeString("Valor de Voltaje"); 
	writeChar(centena +'0');
	writeChar(decena +'0'); 
	writeChar(unidad +'0');
	
	writeString("\r\n");
	    
    _delay_ms(500);
   }
  }
 }


/****************************************/

// NON-Interrupt subroutines

void setup(){
    
    DDRB = 0xFF;         
    PORTB = 0xFF;       
} 

void menu(){
    writeString("Menu Principal");
    writeString("1. Potenciometro");
    writeString("2. Caracter en LEDs");
    
}
/****************************************/

// Interrupt routines

// INTERRUPCION DE EMISOR  (MANDAR DATOS A CAMA DE 8LEDs)

ISR(USART_RX_vect){
    
    uint8_t tecla = UDR0;
    writeChar(tecla);
    
 
    if (estado == '2') {
       PORTB = tecla;
       writeString("Caracter Seleccionado:");
       estado = 0 ;
       menu();
    } 
    
    else if (tecla == '1') {     
        writeString("Lectura de voltaje:");
        estado = '1';          
        
    }
    else if (tecla == '0') {   
        writeString("Regresando al menu "); 
        menu(); 
        estado = '0';         
    }       
}

/****************************************/