/*
* 
*
* Autor : Pedro Pablo Porras
* Descripción: LABORATORIO 3: INTERRUPCIONES 
*/

.include "M328PDEF.inc"


.cseg
.org 0x0000                     // VECTOR DE RESET
RJMP START                      // HABILITAMOS LA INTERRUPCION PARA EL SETUP 

.org PCI1addr					// HABILITAMOS LA INTERRUPCION PARA PUERTOC
RJMP CONTADOR_LEDs

.org OVF0addr                   // HABILITAMOS LA INTERRUPCION DE OVERFLOW PARA TIMER 0
RJMP OVERFLOW 


/****************************************/
// Configuración de la pila

START:
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16


TABLE7SEG:
.db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E,0x79,0x71    // 0 - F   


/****************************************/
// Configuracion MCU

SETUP:

    CLR     R1                                       // IMPORTANTE PARA ADC (VERIFICACIÓN)

    LDI     R16, 0b00001111							 // DEFINIMOS LEDs DE SALIDA EN PIN B 
    OUT     DDRB, R16

    LDI     R16, 0b00001100						     // DEFINIMOS 2 ENTRADAS DE PARA PUSH, Y DOS DE TRANSISTORES EN PIN C
    OUT     DDRC, R16

	LDI		R16, 0b11111111							 // SALIDAS DE DISPLAY
    OUT		DDRD, R16

    SBI     PORTC, PC0								 // ACTIVAMOS PULL UP BOTON 1
    SBI     PORTC, PC1								 // ACTIVAMOS PULL UP BOTON 2 

	CBI     PORTC, PC2								 // APAGAMOS TRANSISTOR 1
	CBI     PORTC, PC3								 // APAGAMOS TRANSISTOR 2

	CLR     R23                                      // REGISTRO DE CONTEO UNITARIO

	LDI     R16, 0x00
	STS     UCSR0B, R16								 // DESACTIVAMOS UART

	LDI		R16, (1<<CLKPCE)						 // HABILITAMOS CAMBIO DE RELOJ
    STS		CLKPR, R16
    LDI		R16, 0b00000100							 // DIVIDIMOS ENTRE 16  (1MHZ)
    STS		CLKPR, R16			                     

	LDI		R16, (1<<PCIE1)                          //  ACTIVAMOS INTERRUPCIONES EN PIN C
	STS		PCICR, R16
	LDI		R16, (1<<PCINT8)|(1<<PCINT9)             //  INTERRUPCION EN PC1, PC0
	STS		PCMSK1, R16

	LDI     R16, (1<<TOIE0)                          // HABILITAMOS BIT DE OVERFLOW EN TIMER0
	STS     TIMSK0, R16 

	LDI     R16, 0x00                                // MODO NORMAL
	STS     TCCR0A, R16

	LDI     R16, (1<<CS01) | (1<<CS00)               // PREESCALER 64 
    OUT     TCCR0B, R16

	CLR		R24										 // CONTADOR DE OVERFLOW 
	CLR		R22										 // CONTADOR DISPLAY DECENAS 
	CLR     R20										 // CONTADOR LEDS 
	CLR     R25										 // CONTADOR DISPLAY UNIDADES 

	IN		R21, PINC							     // ESTADO INICIAL BOTONES

    SEI                                              // ACTIVAMOS BANDERA GENERAL DE INTERRUPCIONES


/****************************************/
// Loop Infinito

MAIN_LOOP:
    RJMP    MAIN_LOOP


/****************************************/
// Interrupt routines

CONTADOR_LEDs:

    PUSH	R16                                  // REGISTRO EN RAM PARA PARA NO INTERRUMPIR REGISTRO 
    PUSH	R17
    IN		R16, SREG                            // GUARDAMOS BANDERAS 
    PUSH	R16

    IN		R16, PINC							 // LEEMOS EL PINC
    MOV		R17, R16							 // GUARDAMOS VALOR PARA COMPARAR

    EOR		R16, R21							 // DETECTAMOS QUE BIT CAMBIO

    // FUNCION DE SUMA 
    SBRS	R16, 0								 // SI NO CAMBIO SALTA
    RJMP	RESTA								 
    SBRS	R17, 0								 // SI ESTA EN 0 ESTA PRESIONADO
    INC		R20

RESTA:
    // FUNCION DE RESTA 
    SBRS	R16, 1								 // SI CAMBIA SALTA 
    RJMP	LEDs_OUT						     
    SBRS	R17, 1								
    DEC		R20								

LEDs_OUT:
    ANDI	R20, 0x0F							 // SOLO TRABAJAMOS CON EL NIBBBLE MAS BAJO
    OUT		PORTB, R20

    MOV		R21, R17							 // ACTUALIZAMOS ESTADO 

    POP		R16                                  // SACAMOS DE LA STACK A REGISTRO 
	OUT		SREG, R16                              

	POP		R17                                    
	POP		R16                                   

	RETI                                          // REGRESAMOS DE LA INTERRUPCION 


/****************************************/
// INTERRUPCION TIMER0

OVERFLOW:                                        // FUNCIÓN DE OVERFLOW PARA REALZIAR CONTADOR DE DECENAS Y UNIDADES

    PUSH    R16                                  // GUARDAMOS REGISTRO EN STACK 
    PUSH    ZH                                   // GUARDAMOS EL VALOR ORIGINAL DEL PUNTERO EN NIBBLE HIGH
    PUSH    ZL                      
    IN      R16, SREG                            // LEEMOS BANDERA 
    PUSH    R16

    //CONTADOR DE 1 SEGUNDO
    
    INC     R24                                  // R24, CONTADOR DE OVERFLOW 
    CPI     R24, 61								 // 61 OVERFLOW = 1 SEGUNDO 
    BRNE    MULTIPLEXADO         

    CLR     R24                                  // REINICIAMOS CONTADOR 

    
    //CONTADOR DE UNIDADES (0–9)
    
    INC     R25                                  // R25, CONTADOR DE UNIDADES
    CPI     R25, 10                              // COMPARACIÓN DE 10 OVERFLOW
    BRNE    MULTIPLEXADO

    CLR     R25                                  // LIMPIAMOS CONTADOR 
    INC     R22


    //CONTADOR DE DECENAS (0–5)

    CPI     R22, 6                               // R22, CONTADOR DE DECENAS 
    BRNE    MULTIPLEXADO 

    CLR     R22                                  // LIMPIAMOS CONTADOR 


/****************************************/

MULTIPLEXADO:                                    // FUNCIÓN DE MULTIPLEXADO PARA ALTERNAR ENTRE DISPLAY DE UNIDADES Y DECENAS

    // ALTERNAMOS DISPLAYS
	 
    INC     R23                                  // INCREMENTAMOS R23 (REGISTRO SELECTOR DE DISPLAY)
    ANDI    R23, 0x01                            // SOLO DEJAMOS EL BIT 0 
                                                 // ESTO PERMITE ALTERNAR ENTRE UN DISPLAY Y OTRO EN CADA OVERFLOW

    // APAGAMOS AMBOS DISPLAY
    CBI     PORTC, PC2                           // DESACTIVAMOS TRANSISTOR DE DECENAS
    CBI     PORTC, PC3                           // DESACTIVAMOS TRANSISTOR DE UNIDADES
                                                 

    // MOSTRAMOS UNIDADES
    CPI     R23, 0                               // COMPARAMOS SI EL SELECTOR VALE 0
    BREQ    DISPLAY_UNIDADES                     // SI ES 0, SALTAMOS A MOSTRAR UNIDADES



DISPLAY_DECENAS:

    SBI     PORTC, PC2                           // ACTIVAMOS TRANSISTOR DEL DISPLAY DE DECENAS PC2
                                                
 
    LDI     ZH, HIGH(TABLE7SEG<<1)               // CARGAMOS PARTE ALTA DEL PUNTERO A LA TABLA 7 SEGMENTOS
    LDI     ZL, LOW(TABLE7SEG<<1)                // CARGAMOS PARTE BAJA DEL PUNTERO

    ADD     ZL, R22                              // SUMAMOS EL VALOR DE DECENAS R22
    ADC     ZH, R1                               // SI HUBO ACARREO EN ZL

    LPM     R16, Z                               // LEEMOS EL DISPLAY EN Z
    OUT     PORTD, R16                           // MOSTRAMOS EN DISPLAY 

    RJMP    FIN                                  // SALTAMOS AL FINAL DE LA INTERRUPCIÓN



DISPLAY_UNIDADES:

    SBI     PORTC, PC3                           // ACTIVAMOS TRANSISTOR DEL DISPLAY DE UNIDADES PC3
                                                

    LDI     ZH, HIGH(TABLE7SEG<<1)               // CARGAMOS DIRECCIÓN BASE DE LA TABLA
    LDI     ZL, LOW(TABLE7SEG<<1)

    ADD     ZL, R25                              // SUMAMOS EL VALOR DE UNIDADES R25
    ADC     ZH, R1                               // AJUSTAMOS SI HUBO ACARREO

    LPM     R16, Z                               // LEEMOS DISPLAY EN Z
    OUT     PORTD, R16                           // MOSTRAMOS EN DISPLAY 
	 


FIN:

    POP     R16                                  // RECUPERAMOS SREG GUARDADO
    OUT     SREG, R16                            // RESTAURAMOS BANDERAS

    POP     ZL                                   // RESTAURAMOS PUNTERO Z ORIGINAL
    POP     ZH

    POP     R16                                  // RESTAURAMOS REGISTRO R16

    RETI                                         // REGRESAMOS DE LA INTERRUPCIÓN
