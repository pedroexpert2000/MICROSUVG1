/*
* 
*
* Autor : Pedro Pablo Porras
* Descripción: LABORATORIO 2: BOTONES Y TIMER0 
*/

.include "M328PDEF.inc"

/****************************************/
.cseg
.org 0x0000

/****************************************/
/* CONFIGURACIÓN DE LA PILA */

RESET:
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16

/****************************************/
/* SETUP */

    LDI     R16, 0b00011111    // Definimos entradas y salidas en PORTB
    OUT     DDRB, R16

    LDI     R16, 0b00000000    // Definimos entradas y salidas en PORTC
    OUT     DDRC, R16

	LDI     R16, 0b11111111    // Definimos entradas y salidas en PORTD
	OUT     DDRD, R16

	LDI     R16, 0b00011111    // Activamos las salida de las LEDs
	OUT     PORTB, R16 

    SBI     PORTC, PB0         // ACTIVAMOS PULL UP BOTON 1
    SBI     PORTC, PB1         // ACTIVAMOS PULL UP BOTON 2 

	LDI     R16, 0b11111111    // Activamos las salidas de las LEDs para display 
	OUT     PORTD, R16 

    CLR     R21                // CONTADOR  A UTILIZAR
	CLR     R22

	LDI     R16, 0x00          // APAGAMOS LA COMUNICACION SERIAL DE PINEB
	STS     UCSR0B, R16 

	LDI		R16, (1<<CLKPCE)   // MODIFICAMOS EL PRESCALER A 1MHZ
    STS		CLKPR, R16
    LDI		R16, 0b00000100
    STS		CLKPR, R16

	LDI     R16, (1<<CS02)    // TIMER 0 (256 PRESCALER)
    OUT     TCCR0B, R16


/****************************************/
/* LOOP PRINCIPAL */

MAIN_LOOP:
    
    RCALL   WAIT_OVF      // 100ms

    INC     R22           // CONTADOR DE OVERFLOWS

    CPI     R22, 15
    BRNE    CONTINUAR

    CLR     R22
    INC     R21
    ANDI    R21, 0x0F

CONTINUAR:

    MOV     R23, R21
    OUT     PORTB, R23

    RJMP    MAIN_LOOP


WAIT_OVF:
WAIT:
    IN      R16, TIFR0
    SBRS    R16, TOV0
    RJMP    WAIT

    SBI     TIFR0, TOV0
    RET




/*
	IN      R20, PINC       // LEEMOS PIN C 

    SBRS    R20, 0          // VERIFICAMOS QUE EL PIN0 SE ENCUENTRE PRESIONADO (0)
    RCALL   SUMAR           // LLAMAMOS A LA FUNCION SUMAR

    SBRS    R20, 1          // VERIFICAMOS QUE EL PIN1 SE ENCUENTRE PRESIONADO (0)
    RCALL   RESTAR          // LLAMAMOS A LA FUNCION RESTAR 

    MOV     R16, R21        // MOVEMOS EL CONTADOR A NUESTRO VECTOR DE BITS
    ANDI    R16, 0x0F       // TOMAMOS LOS 4 BITS MENOS SIGNFICATIVOS PARA GENERAR LAS 16 COMB. 
    OUT     PORTB, R16      // MOSTRAMOS LA SALIDA EN PUERTO B 

    RJMP    MAIN_LOOP       // SALTO RELATIVO A LOOP PRINCIPAL


// SUBRUTINAS 


SUMAR:             
    INC     R21             // INCREMENTAMOS REGISTRO 
    ANDI    R21, 0x0F       // LIMITAMOS EL CONTADOR CON LOS 4 ULTIMOS BITS
    RCALL   DELAY           
ESPERA_PC0:
    IN      R20, PINC       // LEEMOS NUEVAMENTE PINC 
    SBRS    R20, 0          //  PC0 ESTA EN 0 
    RJMP    ESPERA_PC0       
    RET

RESTAR:
    DEC     R21
    ANDI    R21, 0x0F
    RCALL   DELAY
ESPERA_PC1:
    IN      R20, PINC
    SBRS    R20, 1
    RJMP    ESPERA_PC1
    RET


 DELAY (ANTIREBOTE) 

DELAY:
    LDI     R18, 255
D1:
    LDI     R19, 255
D2:
    DEC     R19
    BRNE    D2
    DEC     R18
    BRNE    D1
    RET
	*/