/*
 * Prelab6_Mircros.c
 *
 * Created: 21/04/2026 14:46:51
 * Author : Pedro Porras
 */ 

#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

/****************************************/
// Declaración de funciones

void initUSART(void);
void USART_Transmit(unsigned char data);
unsigned char USART_Receive(void);

/****************************************/
int main(void) {
    
    // Configurar PB0–PB5 como pines de salida
    DDRB |= 0x3F; 
    
    DDRC |= 0x03; 

    // Inicializar USART
    initUSART();

    USART_Transmit('L');
    USART_Transmit('\r');
    USART_Transmit('\n');

    unsigned char caracter_recibido;

    while (1) {
        
		caracter_recibido = USART_Receive(); 

        PORTB = (PORTB & 0xC0) | (caracter_recibido & 0x3F);

        PORTC = (PORTC & 0xFC) | ((caracter_recibido & 0xC0) >> 6);
        
        // Enviar de regreso el mismo dato recibido
        USART_Transmit(caracter_recibido);
    }
}

// CONFIGURACIÓN Y USO DEL USART 

void initUSART(void) {
	
    uint16_t ubrr = 103;
    UBRR0H = (unsigned char)(ubrr >> 8);
    UBRR0L = (unsigned char)ubrr;

    UCSR0B = (1 << RXEN0) | (1 << TXEN0);

    // Configuración de trama: 8 bits, sin paridad, 1 stop
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}

void USART_Transmit(unsigned char data) {
	
    while (!(UCSR0A & (1 << UDRE0)));
    
    UDR0 = data;
}

unsigned char USART_Receive(void) {

    while (!(UCSR0A & (1 << RXC0)));
    
    return UDR0;
}