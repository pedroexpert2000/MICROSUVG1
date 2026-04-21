/*
 * USART.c
 *
 * Created: 16/04/2026 15:28:31
 * Author : Pedro Porras
 */ 



#include <avr/io.h>
#include <avr/interrupt.h>

void initUART();
void writeChar(char c);
void writeString(char*string);


int main(void)
{
	cli();
	DDRB |= (1<<DDB5);
	PORTB &= ~)(1<<PORTB5);
	initUART();
	sei();
	writeChar ("H");
	writeChar ("O");
    writeChar ("L");
	writeChar ("A");
	writeString ("Hola Seccion 10");
    while (1) 
    {
    }
}


void initUART(){
	 
	 DDRD &= ~(1<<DDD0);    // RX
	 DDRD |= (1<<DDD1);     // TX
	 // normal speed
	 UCSR0A = 0;
	 // HABILITAR TX Y RX
	 UCSR0B = (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
	 // Modo Async , sin paridad, 1 stop bit, 8 data bits
	 UCSR0C = (1<<UCSZ01) | (1<< UCSZ00);
	 // Caragr UBRR0
	 UBRR0 = 103;

     
}

void writeChar(char c){
	
	while(!(UCSR0A & (1<<UDRE0)));
	UDR0 = c;
}

void writeString(char*string){
	
	for(uint8_t i =0; *(string + i) != '\0'; i++);
	{
		writeChar(*(string + i));
	}
} 

ISR(USART_RX_vect){
	
	uint8_t bufferRX = UDR0;
	writeChar(bufferRX);
	if (bufferRX == 'a')
	{
	PORTB |= (1<<PORTB5);
	PORTD |= (1<<PORTD5);
	}
	
	if (bufferRX == 'b')
	{
		PORTB &= ~(1<<PORTB5);
		PORTD &= ~(1<<PORTD5);
	}
}