/*
 * PRE_LAB_4_SOLO_CONTADOR.c
 * Author : Pedro Porras  
 * Desc   : Contador de 8 bits con botones en PC4/PC5 y salida en LEDs (PORTC/PORTB)
 */

#define F_CPU 1000000UL
#include <avr/io.h>
#include <stdint.h>
#include <avr/interrupt.h>

volatile uint8_t contador = 0;
void setup();
int main(void)
{
    setup();
    sei(); 
    while(1){
       
        // Los 4 bits menos significativos van al Puerto C (PC0-PC3)
        uint8_t port_c = (PORTC & 0xF0) | (contador & 0x0F);
        
        // Los 4 bits más significativos van al Puerto B (PB2-PB5)
        uint8_t bits_altos = (contador & 0xF0) >> 2;
        uint8_t port_b = (PORTB & 0x03) | (bits_altos & 0xFC);
        
        // Actualizamos los puertos físicamente
        cli(); 
        PORTC = port_c;
        PORTB = port_b;
        sei(); 
    }   
}

// NON-Interrupt subroutines
void setup() {
    
    // 1. CONFIGURACIÓN DE PINES (ENTRADAS Y SALIDAS)
    DDRB  = 0xFF;              
    DDRC  = 0x0F;              
    
    PORTC |= (1<<PORTC4) | (1<<PORTC5); // Pull-ups internos para los botones
    

    PCICR  |= (1<<PCIE1);              // Activamos la interrupción PCINT1 

    PCMSK1 |= (1<<PCINT13) | (1<<PCINT12);   // Enmascaramos solo los pines de los botones
}

// Interrupt routines
ISR(PCINT1_vect){                               
                                             // Verificamos si el botón de SUMA PC4 fue presionado 
    if (!(PINC & (1 << PINC4))) {               
        contador++;                             
    }
    
                                            // Verificamos si el botón de RESTA PC5 fue presionado 
    if (!(PINC & (1 << PINC5))) {
        contador--;                             
    }
}