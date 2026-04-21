/*
 * LABORATORIO4.c
 * Created: 06/04/2026 16:20:20
 * Author : Pedro Porras  
 */

/**/
// Encabezado (Libraries)

#define F_CPU 1000000UL
#include <avr/io.h>
#include <stdint.h>
#include <avr/interrupt.h>


// VARIABLE UNIVERSAL DE CONTADOR  

volatile uint8_t contador = 0;        // VARIABLE CONTADOR GENERAL
volatile uint8_t digito = 0;          // VARIABLE DE MULTIPLEXADO 
volatile uint8_t comparar = 0;        // VARIABLE DE COMPARACIÓN 
volatile uint8_t numdisplay = 0;      // VARIABLE AUXILIAR 

// VECTOR DE 7 SEGMENTOS
const uint8_t display[16] = {
	0x3F,
	0x06,
	0x5B,
	0x4F,
	0x66,
	0x6D,
	0x7D,
	0x07,
	0x7F,
	0x6F,
	0x77,
	0x7C,
	0x39,
	0x5E,
	0x79,
	0x71
};

/**/
// Function prototypes

void setup();
void initADC(); 
void compare();

/**/
// Main Function

int main(void)
{
    setup();
	initADC();
	sei();                                             
	while(1){
		uint8_t port_c = (PORTC & 0xF0) | (contador & 0x0F);
		
		uint8_t bits_altos = (contador & 0xF0) >> 2;
		
		uint8_t port_b = (PORTB & 0x03) | (bits_altos & 0xFC);
		
		cli(); 
		PORTC = port_c;
		PORTB = port_b;
		compare(); 
		sei(); 
	}	
		
}

/**/
// NON-Interrupt subroutines

void setup() {
	
	UCSR0B &= ~((1 << RXEN0) | (1 << TXEN0));     
	
	PCICR = (1<<PCIE1);                        // ACTIVAMOS LA INTERRUPCION POR PINCHANGE EN PUERTO B 
	PCMSK1 = (1<<PCINT5) | (1<<PCINT4);        // ACTIVAMOS LOS PINES ESPECIFICOS QUE GENERARÁN LA INTERRUPCION
	
	ADCSRA  |= (1<<ADIE);                      // HABILITAMOS INTERRUPCIÓN DEL ADC
	ADCSRA	|= (1<<ADSC);		               // INICIa CONVERSION DE ADC
	
	TIMSK0  |= (1<<TOIE0);                     // INTERRUPCION POR OVERFLOW  EN TIMER 0 
	
	CLKPR =(1<<CLKPCE);                       // HABILITAMOS PREESCALER 
	CLKPR =(1<<CLKPS2);                       // PREESCALER DE 16 MHZ 
	
	TCCR0A = 0x00;                             // MODO NORMAL
	TCCR0B |= (1<<CS01);	                  // PREESCALER 8
	TCNT0 = 100;
	TIFR0  |= (1<<TOV0);
	
	DDRD  = 0xFF;                              // DEFINIMOS SALIDAS 
	DDRB  = 0xFF;  
	DDRC  = 0x0F;
	
	PORTD = 0xFF;                              // ACTIVAMOS SALIDAS EN D
	PORTB = 0xFF;
	PORTC = 0xFF;                              // ACTIVAMOS PULL- UP EN B
}

void initADC(){

	ADMUX = (1<<REFS0)|(1<<ADLAR)|(1<<MUX0)|(1<<MUX1)|(1<<MUX2);

	ADCSRA = (1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);

	ADCSRA |= (1<<ADSC);
}
void compare() {                                // FUNCION DE COMPARACIÓN 
	if (contador == ADCH) {                     // COMPARAMOS SI EL CONTADOR ES IGUAL A ADCH DEL ADC
		PORTD |= (1 << PORTD7);                 // ENCEDNEMOS BIT DE INDICADOR
		} 
		else {                          
		PORTD &= ~(1 << PORTD7);                // SE APAGA 
	}
}
/**/
// Interrupt routines

ISR(PCINT1_vect){                               // VECTOR DE INTERRUPCION EN B 
	if (!(PINC & (1 << PINC4))) {               // LEEMOS SI EL PIN ESTA PRESIONADO 
		contador++ ;                            // SUMAMOS 1 AL CONTADOR 
	}
	  if (!(PINC & (1 << PINC5))) {
		contador-- ;                            // MISMO PROCEDIMIENTOS SOLO QUE RESTAMOS A NUESTRO CONTADOR 
	  }
}


ISR(ADC_vect){                                  // VECTOR DE ADCA
	ADCSRA |= (1<<ADSC);                        // ACTIVAMOS EL INICIO DE CONVERSION DEL ADC
}

ISR(TIMER0_OVF_vect) {
	
	PORTB |= (1 << PORTB0) | (1 << PORTB1);     // APAGAMOS DISPLAY PARA EVITAR GHOSTING 
	
	
	PORTD &= 0x80;     // APGAMOS SEGMENTOS EXCEPTUANDO PD7
	
	TCNT0 = 100;

	if (digito == 0) {
		PORTD &= 0x80; 
		PORTD |= (display[ADCH & 0x0F] & 0x7F);
		PORTB &= ~(1 << PORTB0);
		digito = 1;
	}
	else {
		PORTD &= 0x80; 
		PORTD |= (display[(ADCH >> 4) & 0x0F] & 0x7F);
		PORTB &= ~(1 << PORTB1);
		digito = 0;
	}
}