/*
 * PRE_LAB_1_C.c
 * Created: 06/04/2026 16:20:20
 * Author : Pedro Porras  
 */

/****************************************/
// Encabezado (Libraries)

#include <avr/io.h>
#include <stdint.h>
#include <avr/interrupt.h>


// VARIABLE UNIVERSAL DE CONTADOR  

volatile uint8_t contador = 0;

/****************************************/
// Function prototypes

void setup();

/****************************************/
// Main Function

int main(void)
{
    setup();
	sei();
	while(1){
		PORTD = contador;
		}
}

/****************************************/
// NON-Interrupt subroutines

void setup() {
	
	PCICR = (1<<PCIE0);                        // ACTIVAMOS LA INTERRUPCION POR PINCHANGE EN PUERTO B 
	PCMSK0 = (1<<PCINT1) | (1<<PCINT2);        // ACTIVAMOS LOS PINES ESPECIFICOS QUE GENERARÁN LA INTERRUPCION
	
	DDRD  = 0xFF;                              // DEFINIMOS SALIDAS 
	DDRB  = (1<<DDB2) | (1<<DDB1);     
	
	PORTD = 0xFF;                              // ACTIVAMOS SALIDAS EN D
	PORTB = (1<<PORTB2) | (1<<PORTB1);         // ACTIVAMOS PULL- UP EN B
}


/****************************************/
// Interrupt routines

ISR(PCINT0_vect){                               // VECTOR DE INTERRUPCION EN B 
	if (!(PINB & (1 << PINB2))) {               // LEEMOS SI EL PIN ESTA PRESIONADO 
		contador++ ;                            // SUMAMOS 1 AL CONTADOR 
	    while (!(PINB & (1 << PINB2)));         // NO SUMA HASTA QUE DETECTE EL BOTON NUEVAMENTE  (ANTIRREBOTE)
	}
	  if (!(PINB & (1 << PINB1))) {
		contador-- ;                            // MISMO PROCEDIMIENTOS SOLO QUE RESTAMOS A NUESTRO CONTADOR 
		while (!(PINB & (1 << PINB1)));
	  }
}
