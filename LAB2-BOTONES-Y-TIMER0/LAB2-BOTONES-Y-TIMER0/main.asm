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

//STACKPOINTER

TABLE7SEG:
    .db     0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71  // 0 - F

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

    SBI     PORTC, PC0         // ACTIVAMOS PULL UP BOTON 1
    SBI     PORTC, PC1         // ACTIVAMOS PULL UP BOTON 2 

	LDI     R16, 0b11111111    // Activamos las salidas de las LEDs para display 
	OUT     PORTD, R16 

    CLR     R21                // CONTADOR  A UTILIZAR PARA DISPLAY
	CLR     R22                // CONTADOR DE OVERFLOW
	CLR     R23                // CONTADOR LEDs SECUENCIA 1s

	LDI     R16, 0x00          // APAGAMOS LA COMUNICACION SERIAL DE PINEB
	STS     UCSR0B, R16 

	LDI		R16, (1<<CLKPCE)   // MODIFICAMOS EL PRESCALER A 1MHZ
    STS		CLKPR, R16
    LDI		R16, 0b00000100    
    STS		CLKPR, R16

	LDI     R16, (1<<CS02)     // TIMER 0 (256 PRESCALER)
    OUT     TCCR0B, R16

    LDI     ZH, HIGH(TABLE7SEG<<1)     // CARGAMOS EN ZH LA PARTE ALTA DE LA DIRECCION
    LDI     ZL, LOW(TABLE7SEG<<1)      // CARGAMOS EN ZL LA PARTE BAJA DE LA DIRECCION

	LDI     R16, 0x00         // INICIAMOS EN 0 
	OUT     PORTD, R16

/****************************************/
/* LOOP PRINCIPAL */

MAIN_LOOP:

    RCALL   WAIT_OVF            // ESPERAMOS UN OVERFLOW DEL TIMER0 
	INC     R22                 // INCREMENTAMOS EL CONTADOR DE OVERFLOWS
	CPI     R22, 15             // COMPARAMOS SI YA VAN 15 OVERFLOWS
    BRNE    SEGUNDO             // SI NO LLEGA A 15, SALTAMOS

	CLR     R22                 // SI LLEGA A 15, REINICIAMOS EL CONTADOR DE OVERFLOWS
	INC     R23                 // INCREMENTAMOS EL CONTADOR PRINCIPAL
	ANDI    R23, 0x0F           // LIMITAMOS A 4 BITS 

SEGUNDO:
    RCALL   CONTINUAR           // LLAMAMOS RUTINA COTNINUAR 

	IN      R20, PINC           // LEEMOS EL ESTADO DE LOS BOTONES EN EL PUERTO C

    SBRS    R20, 0              // SI EL BIT 0 ESTA EN 1 (NO PRESIONADO) SE SALTA
    RCALL   SUMAR               // SI ESTA EN 0 (PRESIONADO) LLAMAMOS A SUMAR

    SBRS    R20, 1              // SI EL BIT 1 ESTA EN 1 (NO PRESIONADO) SE SALTA
    RCALL   RESTAR              // SI ESTA EN 0 (PRESIONADO) LLAMAMOS A RESTAR

    RCALL   DISPLAY             // ACTUALIZAMOS EL DISPLAY CON EL VALOR ACTUAL

	RCALL   VERIFICACION        // HACEMOS UNA VERIFICACION 

    RJMP    MAIN_LOOP           // VOLVEMOS A INICIAR EL CICLO PRINCIPAL



CONTINUAR:
    IN      R16, PORTB        // LEEMOS EL ESTADO ACTUAL DEL PUERTO
    ANDI    R16, 0x10         // CONSERVAMOR PB4
    OR      R16, R23          // COBMINAMOS LEDs CON CONTADOR 
    OUT     PORTB, R16        // SCAMAOS EL PUERTOB
	RET

WAIT_OVF:                      // FUNCION QUE ESPERA A QUE OCURRA UN OVERFLOW EN TIMER0
WAIT:
    IN      R16, TIFR0         // LEEMOS EL REGISTRO DEL TIMER0                     
    SBRS    R16, TOV0          // SI EL BIT TOV0 ESTA EN 1, SE SALTA LA SIGUIENTE INSTRUCCION
    RJMP    WAIT               // SI TODAVIA NO HAY OVERFLOW 
    SBI     TIFR0, TOV0        // LIMPIAMOS LA BANDERA DE OVERFLOW
    RET                        // REGRESAMOS AL PROGRAMA PRINCIPAL

	 
VERIFICACION:                  // FUNCION PARA COMPRAR AMBOS REGISTROS DEL DISPLAY CON EL TIMER0 EN LEDs
    CP      R23, R21           // COMPARAMOS CONTADOR  
	BREQ    COMPARACION       
	RET
	  

// SUBRUTINAS 

SUMAR:             
    INC     R21                  // INCREMENTAMOS REGISTRO 
    ANDI    R21, 0x0F            // LIMITAMOS EL CONTADOR CON LOS 4 ULTIMOS BITS
    RCALL   DELAY           
ESPERA_PC0:
    IN      R20, PINC            // LEEMOS NUEVAMENTE PINC 
    SBRS    R20, 0               // COMPARAMOS EL BOTON SI SIGUE PRESIOANDO 
    RJMP    ESPERA_PC0       
    RET

RESTAR:                          // FUNCIÓN DE DECREMENTO 
    DEC     R21
    ANDI    R21, 0x0F
    RCALL   DELAY
ESPERA_PC1:
    IN      R20, PINC
    SBRS    R20, 1
    RJMP    ESPERA_PC1
    RET


DISPLAY:                                 // FUNCION DE DISPLAY DONDE DEFINIMOS EL PUNTERO Z A LA TABLA

    LDI     ZH, HIGH(TABLE7SEG<<1)       // CARGAMOS EN ZH LA PARTE ALTA DE LA DIRECCION DE LA TABLA (EN FLASH)
    LDI     ZL, LOW(TABLE7SEG<<1)        // CARGAMOS EN ZL LA PARTE BAJA DE LA DIRECCION DE LA TABLA

    ADD     ZL, R21                      // SUMAMOS EL VALOR DEL CONTADOR (R21) A ZL
                                         // ESTO NOS POSICIONA EN EL NUMERO CORRECTO DENTRO DE LA TABLA

    CLR     R1                           // LIMPIAMOS R1 (DEBE ESTAR EN 0 PARA USARSE EN ADC)
    ADC     ZH, R1                       // AJUSTAMOS ZH SI HUBO ACARREO EN LA SUMA ANTERIOR

    LPM     R20, Z                       // LEEMOS DE MEMORIA DE PROGRAMA (FLASH) EL DATO APUNTADO POR Z
                                         // GUARDAMOS EL PATRON DEL 7 SEG EN R20

    OUT     PORTD, R20                   // ENVIAMOS EL PATRON AL PUERTO D (DISPLAY)
    RET                                  // REGRESAMOS AL PROGRAMA PRINCIPAL


COMPARACION:

    IN      R16, PORTB           // LEEMOS EL ESTADO ACTUAL DEL PUERTO B (LEDS)                            
    LDI     R17, (1<<PB4)        // CARGAMOS EN R17 UNA MASCARA CON EL BIT PB4 EN 1
    EOR     R16, R17             // HACEMOS XOR ENTRE R16 Y LA MASCARA                      
    OUT     PORTB, R16           // ESCRIBIMOS EL NUEVO VALOR EN PORTB
    CLR     R23                  // LIMPIAMOS R23 CONTADOR DE LEDs
    RET                          // REGRESAMOS AL PROGRAMA PRINCIPAL
	
	               
DELAY:                           // FUNCION DE ANTI-REBOTE 
    LDI     R18, 255 
D1:
    LDI     R19, 255
D2:
    DEC     R19
    BRNE    D2
    DEC     R18
    BRNE    D1
    RET
