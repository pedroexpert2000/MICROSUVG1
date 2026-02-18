/*
* 
*
* Autor : Pedro Pablo Porras
* Descripción: LABORATORIO 2: BOTONES Y TIMER0 
*/

.include "M328PDEF.inc"


.cseg
.org 0x0000
RJMP START

.org PCI1addr					// HABILITAMOS LA INTERRUPCION PARA PUERTOC
RJMP IncDec_4leds

 /**************/
// Configuración de la pila

START:
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16

/**************/
// Configuracion MCU

SETUP:

    LDI     R16, 0b00001111    // Definimos entradas y salidas en PORTB
    OUT     DDRB, R16

    LDI     R16, 0b00000000    // Definimos entradas y salidas en PORTC
    OUT     DDRC, R16

	LDI     R16, 0b00001111    // Activamos las salida de las LEDs
	OUT     PORTB, R16 

    SBI     PORTC, PC0         // ACTIVAMOS PULL UP BOTON 1
    SBI     PORTC, PC1         // ACTIVAMOS PULL UP BOTON 2 

	CLR     R23                // CONTADOR LEDs SECUENCIA 1s

	LDI     R16, 0x00          // APAGAMOS LA COMUNICACION SERIAL DE PINEB
	STS     UCSR0B, R16 

	LDI		R16, (1<<CLKPCE)   // MODIFICAMOS EL PRESCALER A 1MHZ
    STS		CLKPR, R16
    LDI		R16, 0b00000100    
    STS		CLKPR, R16			

	LDI		R16, (1<<PCIE1)        // Configurar PCINT1
	STS		PCICR, R16
	LDI		R16, (1<<PCINT8)|(1<<PCINT9)
	STS		PCMSK1, R16

 	LDI		R16, 0x00             // LEDS APAGADOS 
    OUT		PORTB, R16

	CLR		R20                   // CONTADOR  
	CLR		R21	                  // CONTADOR 
	IN		R21, PINC              // ESTADO PREVIO DE BOTONES 

// ACTIVO INTERRUPCIONES GLOBALES
SEI 
/**************/
// Loop Infinito
MAIN_LOOP:
    RJMP    MAIN_LOOP

/**************/
// NON-Interrupt subroutines

/**************/
// Interrupt routines

CONTADOR_LEDs:
    PUSH	R16
    PUSH	R17
    IN		R16, SREG
    PUSH	R16

    IN		R16, PINC							 // LEEMOS EL PINC
    MOV		R17, R16							 // GUARDAMOS VALOR PARA COMPARAR

    EOR		R16, R21							 // Detectar qué bits cambiaron ya que r21 tiene el estado inicial de los botones. si cambió entondes es 1.
											 
									             // FUNCION DE SUMA 
    SBRS	R16, 0								 // SE COMPARA EL BOTON SI SE PRESIONA O NO 
    RJMP	resta								 
    SBRS	R17, 0								 // SE COMPARA EL OTRO BOTON 
    INC		R20

resta:
                                                 // FUNCION DE RESTA 
    SBRS R16, 1								     // COMPARAMOS EL BOTON SI SE PRESIONA O NO 
    RJMP LEDs_OUT						      
    SBRS R17, 1								
    DEC  R20								

LEDs_OUT:
    ANDI R20, 0x0F							     // SE QUEDA EL PRIMER NIBBLE
    OUT  PORTB, R20

    MOV  R21, R17							    // ACTUALIZAMOS EL ESTADO 

    POP  R16                                    // RECUPERAMOS SREG ORIGINAL
	OUT  SREG, R16                              // RESTAURAMOS FLAGS DEL PROGRAMA

	POP  R17                                    // RECUPERAMOS REGISTRO R17
	POP  R16                                    // RECUPERAMOS REGISTRO R16

	RETI                                        // RETORNAMOS DE LA INTERRUPCION



/**************/