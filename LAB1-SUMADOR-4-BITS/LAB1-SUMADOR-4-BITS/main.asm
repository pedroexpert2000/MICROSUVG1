/*
* SUMADOR-4-BITS.asm
*
* Autor : Pedro Pablo Porras
* Descripción: LABORATORIO 1
*/

.include "M328PDEF.inc"

.cseg
.org 0x0000

 /****************************************/
// Configuración de la pila

RESET:
    LDI R16, LOW(RAMEND)
    OUT SPL, R16
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16

/****************************************/
// Configuracion MCU

SETUP:
  
    LDI R16, 0                     // APAGAMOS EL PUERTO SERIAL TX / RX  
    STS UCSR0B, R16
    OUT SPCR, R16

    LDI R16, 0b00101111            // DEFINIMOS ENTRADAS Y SALIDAS DE B 
    OUT DDRB, R16                 
    OUT PORTB, R16

  
    LDI R16, 0x00                  // DEFINIMOS ENTRADAS Y SALIDAS DE C
    OUT DDRC, R16
    LDI R16, 0b00011111            // ACTIVAMOS PULL UP EN LAS ENTRADAS
    OUT PORTC, R16

    LDI R16, 0xFF                  // ACTIVAMOS LAS SALIDAS EN D 
    OUT DDRD, R16
    OUT PORTD, R16

    LDI R16, (1<<CLKPCE)           // MODIFICAMOS EL PRESCALER A 1MHZ
    STS CLKPR, R16
    LDI R16, 0b00000100
    STS CLKPR, R16

    
    CLR R21                        // REGISTRO DE SUMA
    CLR R22                        // REGISTRO DE RESTA
    CLR R23                        // REGISTRO DE RESULTADO 

    CBI PORTB, 5                   // APAGAMOS LED INICAL DE OVERFLOW 

/****************************************/
// Loop Infinito

MAIN:
    RCALL CONTADOR1                // LLAMAMOS FUNCIONES PRINCIPALES 
    RCALL CONTADOR2
    RCALL SUMADOR
    RJMP MAIN                      // SALTO RELATIVO A CICLO 

/****************************************/
// NON-Interrupt subroutines

CONTADOR1:                         // CREAMOS EL PRIMER CONTADOR: 
    IN R20, PINC                   // LEEMOS EL PINC EN R20 PARA LEER 
	 
    SBRS R20, 0                    // COMPARAMOS EL BIT 0 DE C = BOTON1 (1 = NO PRESIONADO)
    RCALL CONT1_SUMAR              // LLAMAMOS A LLAMAR FUNCION SUMA DEL PRIMER CONTADOR 

    SBRS R20, 1                    // COMPARAMOS EL BIT 1 DE C = BOTON2 (1 = NO PRESIONADO)
    RCALL CONT1_RESTAR             // LLAMAMOS A LLAMAR A LA FUNCION RESTAR DEL PRIMER CONTADOR 

    MOV R16, R21                   // MOVEMOS EL CONTADOR A UN NUEVO REGISTRO 
    ANDI R16, 0x0F                 // ENMASCARAMOS PARA TRABAJAR CON EL NIBBLE MENOS SIGNIFICATIVO
    OUT PORTB, R16                 // LA SALIDA SE MUESTRA EN LEDs EN PORTB 
    RET 

CONT1_SUMAR:                       // FUNCION DE SUMAR EN PRIMER CONTADOR
    RCALL DELAY                   
    IN R20, PINC                   // LEEMOS PINC PARA IDENTIFICAR BOTON 
    SBRS R20, 0                    // COMPARAMOS EL BIT 0 DE C = BOTON1 (1 = NO PRESIONADO)
    RET
    INC R21                        // INCREMENTAMOS EL CONTADOR (R21)
    ANDI R21, 0x0F                 // LIMITAMOS EL NÚMERO 
CONT1_ESPERA0: 
    IN R20, PINC                   // LEEMOS PIN NUEVAMENTE 
    SBRS R20, 0                    // VERIFICAMOS EL BOTON NUEVAMENTE 
    RJMP CONT1_ESPERA0             // REGRESA A LA FUNCION 
    RET

CONT1_RESTAR:                      // FUNCION DE RESTAR EN PRIMER CONTADOR 
    RCALL DELAY
    IN R20, PINC 
    SBRS R20, 1                    // COMPARAMOS EL BIT 1 DE C = BOTON 2 (1 = NO PRESIONADO)
    RET
    DEC R21                        // REDUCIMOS EL CONTADOR 
    ANDI R21, 0x0F                 // LIMITAMOS EL NUMERO 
CONT1_ESPERA1:
    IN R20, PINC
    SBRS R20, 1                    // VERIFICAMOS EL BOTON NUEVAMENTE 
    RJMP CONT1_ESPERA1             // REGRESA A LA FUNCION 
    RET


CONTADOR2:                         /* MISMO PROCEDIMIENTO PARA SEGUNDO CONTADOR (R22)*/
    IN R20, PINC

    SBRS R20, 2
    RCALL CONT2_SUMAR

    SBRS R20, 3
    RCALL CONT2_RESTAR

    MOV R17, R22
    ANDI R17, 0x0F
    SWAP R17

    IN R18, PORTD
    ANDI R18, 0x0F
    OR R18, R17
    OUT PORTD, R18
    RET

CONT2_SUMAR:
    RCALL DELAY
    IN R20, PINC
    SBRS R20, 2
    RET
    INC R22
    ANDI R22, 0x0F
CONT2_ESPERA2:
    IN R20, PINC
    SBRS R20, 2
    RJMP CONT2_ESPERA2
    RET

CONT2_RESTAR:
    RCALL DELAY
    IN R20, PINC
    SBRS R20, 3
    RET
    DEC R22
    ANDI R22, 0x0F
CONT2_ESPERA3:
    IN R20, PINC
    SBRS R20, 3
    RJMP CONT2_ESPERA3
    RET


SUMADOR:                          // FUNCION QUE SUMARÁ AMBOS REGISTROS 
    IN R20, PINC                  // LEEMOS PINC 
    SBRC R20, 4                   // COMPARAMOS BOTON SI ESTA PRESIONADO 
    RET  

    MOV R23, R21                  // MOVEMOS EL PRIMER REGISTRO A R23
    ADD R23, R22                  // SUMAMOS PRIMER REGISTRO CON EL SEGUNDO 

    // VERIFICAREMOS SI HAY OVERFLOW

    MOV R19, R23                   
    ANDI R19, 0xF0                 // TOMAMOS LOSS BITS MAS ALTOS 
    CPI R19, 0                     // COMPARAMOS EL REGISTRO DEL RESULTADO CON 0 
    BREQ NOOVERFLOW                // CONDICIONAMOS SI SE ACTIVA LA 0 FLAG 
    SBI PORTB, 5                   // ENCNEDEMOS LA LED QUE INDIQUE OVERFLOW 
    RJMP SHOW_SUM                  // MOSTRAMOS LA SUMA EN LAS LEDs

NOOVERFLOW:
    CBI PORTB, 5

SHOW_SUM:                          // FUNCION QUE MOSTRARÁ LA SUMA 
    MOV R16, R23
    ANDI R16, 0x0F                 // SE QUEDA CON LOS BITS BAJOS DE LA SUMA 
    IN R18, PORTD                  // LEEMOS EL VALOR ACTUAL 
    ANDI R18, 0xF0                 // SE QUEDA CON LOS BITS ALTOS DE LA SUMA 
    OR R18, R16                    // SE INSERTAN LOS BITS BAJOS AL PORTD
    OUT PORTD, R18                 // MOSTRAMOS LA SALIDA DE R18 

SUMA_ESPERA:                       // FUNCION DE VERIFICACION DE BOTON A QUE SE SUELTE 
    IN R20, PINC
    SBRS R20, 4                    // SI EL BIT ESTA EN 1 SALTA 
    RJMP SUMA_ESPERA               // RETOMAMOS LA FUNCION HASTA QUE SE SUELTE EL BOTON 
    RET


DELAY:                             // TOMAMOS DELAY PARA GENERAR EL ANTIRREBOTE 
    LDI R18, 255
FOR:
    LDI R19, 255
FOR2:
    DEC R19
    BRNE FOR2
    DEC R18
    BRNE FOR
    RET
