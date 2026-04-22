/*
 * USART.c
 *
 * Created: 16/04/2026 15:28:31
 * Author : Pedro Porras
 */ 


#ifndef F_CPU
#define F_CPU 16000000UL 
#endif

// Librerias utilizadas 

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>

// Prototipos

void writeChar(char c);
void writeString(char*string);
void initUART(); 

int main(void)
{
    cli();
    
    // Configuración de Pines
    DDRB |= (1<<DDB5);
    PORTB &= ~(1<<PORTB5); 
    
    DDRD |= (1<<DDD5);     
    PORTD &= ~(1<<PORTD5); // Nos aseguramos que empiece apagado

    initUART();
    sei();
    
	// CARÁCTER 
    writeChar('H');
    writeChar('O');
    writeChar('L');
    writeChar('A');
	writeString("\r\n");
    writeString(" Me llamo Pedro Pablo");    // ORACIÓN 
    
    while (1) 
    {

    }
}

void initUART(){
    
     DDRD &= ~(1<<DDD0);    // RX como entrada
     DDRD |= (1<<DDD1);     // TX como salida
     
     // Normal speed
     UCSR0A = 0;
     
     // HABILITAR TX, RX y la Interrupción de RX
     UCSR0B = (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
     
     // Modo Async , sin paridad, 1 stop bit, 8 data bits
     UCSR0C = (1<<UCSZ01) | (1<< UCSZ00);
     
     // Cargar UBRR0 para 9600 baudios 
     UBRR0 = 103;
}


// VECTOR DE INTERRUPCIONES 

ISR(USART_RX_vect){
    
    uint8_t bufferRX = UDR0;
    writeChar(bufferRX); 
    
    if (bufferRX == 'a')
    {
        PORTB |= (1<<PORTB5);
        PORTD |= (1<<PORTD5); 
    }

    else if (bufferRX == 'b') 
    {
        PORTB &= ~(1<<PORTB5);
        PORTD &= ~(1<<PORTD5);
    }
}