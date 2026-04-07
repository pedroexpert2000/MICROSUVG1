; =========================================
; PROYECTO-RELOJ-PEDRO-PORRAS.asm
; =========================================
; Muestra HH:MM en display de 4 dígitos
; =========================================

.include "M328PDEF.inc"

; -----------------------------------------
; Variables en SRAM
; -----------------------------------------
.dseg

;.BYTE 1 GUARDA LA VARIABLE EN UN ESPACIO DE LA RAM 
; VARIABLES FIJAS A UTILIZAR 

DISPLAY:   .byte 1              
SEGUNDOS:  .byte 1
MINUTOS:   .byte 1
HORAS:     .byte 1

MODO:      .byte 1


; El reloj se divide en unidades y decenas, siendo dos dígitos correspondientes. Dos a la derecha y dos a la izquierda del display.

H_DEC:     .byte 1
H_UNI:     .byte 1
M_DEC:     .byte 1
M_UNI:     .byte 1

DIAS:      .byte 1 
MESES:     .byte 1

DIA_DEC:   .byte 1
DIA_UNI:   .byte 1
MES_UNI:   .byte 1
MES_DEC:   .byte 1

ALM_M_UNI: .byte 1
ALM_M_DEC: .byte 1 
ALM_H_UNI: .byte 1 
ALM_H_DEC: .byte 1 
ALM_ACTIVA: .byte 1
FLAG_ALM:  .byte 1

VAR_INC:   .byte 1
VAR_DEC:   .byte 1

VAR_SEL:   .byte 1
CONF:      .byte 1

; VARIABLES TEMPORALES DE CONFIGURACION 

CFG_H_DEC: .byte 1
CFG_H_UNI: .byte 1
CFG_M_DEC: .byte 1
CFG_M_UNI: .byte 1

CFG_DIA_DEC: .byte 1
CFG_DIA_UNI: .byte 1
CFG_MES_DEC: .byte 1
CFG_MES_UNI: .byte 1

CFG_AM_UNI:  .byte 1
CFG_AM_DEC:  .byte 1
CFG_AH_UNI:  .byte 1
CFG_AH_DEC:  .byte 1


; -----------------------------------------
; Vector de interrupciones
; -----------------------------------------

; OBTENEMOS LOS VECTORES NECESARIOS PARA PODER ACTIVAR NUESTRAS INTERRUPCIONES 
.cseg
.org 0x0000          ;reset 
    RJMP START

.org PCI1addr         ; interrupciones en pin c
    RJMP EXT_INT

.org OC1Aaddr          ; interrupcion por comparacion en timer 1
    RJMP TIMER1_INT

.org OVF0addr           ; interrupcion por overflow en timer 0
    RJMP TIMER0_INT

.org 0x40 


; -----------------------------------------
; Tabla de patrones 7 segmentos (0–F)
; -----------------------------------------

TABLE7SEG:
    .db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E,0x79,0x71  // TABLA SEGMENTOS EN DISPLAY 

TABLAMES: 
    .db 31,28,31,30,31,30,31,31,30,31,30,31   //DIAS CORRESPONDIENTES A CADA MES 


; =========================================
; Inicialización
; =========================================
START:

    CLR R1

    LDI R16, LOW(RAMEND)
    OUT SPL, R16

    LDI R16, HIGH(RAMEND)
    OUT SPH, R16


     LDI R16, (1<<TOIE0)
     STS TIMSK0, R16               ; HABILITAMOS BIT POR OVERFLOW EN TIMER 0 

    LDI R16, (1<<CS01)|(1<<CS00)
    OUT TCCR0B, R16                ; Prescaler de 64 


                                 
    LDI R16, (1<<OCIE1A)          ; habilitamos interrupción por comparación A del Timer1
    STS TIMSK1, R16              

    LDI R16, (1<<WGM12)|(1<<CS12)|(1<<CS10)   ; modo CTC y prescaler 1024 
    STS TCCR1B, R16            

    LDI R16, HIGH(15624)          ; parte alta del valor para generar 1 segundo
    STS OCR1AH, R16               ; cargamos el valor alto en el registro de comparación

    LDI R16, LOW(15624)           ; parte baja del valor de comparación
    STS OCR1AL, R16               ; completa el valor 15624 

	LDI R16,0x00                  ; cargamos 0 para deshabilitar periféricos UART
    STS UCSR0B,R16                
    STS UCSR0C,R16                

    ; Configuración puertos
    LDI R16, 0xFF        ; PB0–PB3 salidas (PV0–PV3)
    OUT DDRB, R16

    LDI R16, 0x00        ; salidas 
    OUT PORTB, R16

    LDI R16, 0xFF        ; PORTD salidas (segmentos)
    OUT DDRD, R16

    LDI R16, 0x00        ; salidas 
    OUT PORTD, R16
    
	LDI R16,0x00
    OUT DDRC,R16         ; PORTC entradas

	SBI DDRC,PC0         ; unico pin de C que es salida de una LED 

    LDI R16,0xFF
    OUT PORTC,R16        ; pull-ups activados

	SBI PORTC, PC0       ; salida de pin c 

	LDI R16,(1<<PCIE1)   ; activamos 
    STS PCICR,R16

	LDI R16,(1<<PCINT9)|(1<<PCINT10)|(1<<PCINT11) |(1<<PCINT12) |(1<<PCINT13)
    STS PCMSK1,R16

    ; CARGAMOS NUESTRAS VARIABLES PARA INICIALIZAR EN 0 

    LDI R16, 0
    STS DISPLAY, R16
    STS SEGUNDOS, R16
    STS MINUTOS, R16
    STS HORAS, R16
    STS M_UNI, R16
    STS M_DEC, R16
    STS H_UNI, R16
    STS H_DEC, R16
    STS MODO, R16
	STS DIA_DEC, R16
	STS MES_DEC, R16
	STS VAR_INC, R16
	STS VAR_DEC, R16
	STS CFG_H_DEC, R16
    STS CFG_H_UNI, R16
    STS CFG_M_DEC, R16
    STS CFG_M_UNI, R16
    STS CFG_DIA_DEC, R16
    STS CFG_MES_DEC, R16
	STS CFG_AM_UNI, R16
    STS CFG_AM_DEC, R16
    STS CFG_AH_UNI, R16
    STS CFG_AH_DEC, R16
	STS ALM_ACTIVA, R16
    STS FLAG_ALM, R16

    ; CARGAMOS NUESTRAS VARIABLES PARA INICIALIZAR EN 1
	LDI R16,1
    STS DIAS,R16
    STS MESES,R16
	STS DIA_UNI, R16 
    STS MES_UNI, R16
	STS CFG_DIA_UNI, R16
	STS CFG_MES_UNI, R16


    SEI

MAIN_LOOP:
    RJMP MAIN_LOOP

; =========================================
; Rutina HORA: devuelve índice en R17
; =========================================

HORA:                        ; estado de hora 
    
	SBI PORTC, PC0           ; led PC0
	CBI PORTB, PB5           ; LED PB5 

    LDS R16, DISPLAY         ; leemos display para multiplexar 

    CPI R16, 0               ; segun el pin, es el dígito 
    BREQ VM_UNI

    CPI R16, 1               
    BREQ VM_DEC

    CPI R16, 2
    BREQ VH_UNI

    LDS R17, H_DEC          ; guardamos por default (ultimo caso posible, ultimo digito de iquiserda a derecha)
    RET

VM_UNI:                     ; guardamos nuestros valores en la RAM nuevamente 
    LDS R17, M_UNI       
    RET

VM_DEC:
    LDS R17, M_DEC
    RET

VH_UNI:
    LDS R17, H_UNI
    RET


FECHA:                      ; modo fecha 
   
    SBI PORTB, PB5          ; led PB5
	CBI PORTC, PC0          ; led PC0 

    LDS R16,DIAS            ; cargamos dias 
    CLR R17           
    LDI R18,10              ; cargamos valor del divisor 

DIVISION_DIA:               ; dividimos nuestras funciones para obtener la suma correcta 
    CP  R16,R18
    BRLO FIN_DIV_DIA

    SUB R16,R18
    INC R17
    RJMP DIVISION_DIA

FIN_DIV_DIA:
    STS DIA_UNI,R16
    STS DIA_DEC,R17

	LDS R19, MESES
	CLR R20
	LDI R21, 10             ; divisor de meses con dias

DIVISION_MES:               ; mismo procedimiento con mes 
    CP R19, R21 
	BRLO  FIN_DIV_MES

	SUB R19, R21
	INC R20
	RJMP DIVISION_MES

FIN_DIV_MES: 
    STS MES_UNI, R19        ; siempre guardamos valores en nuestras variables despues de su operación 
	STS MES_DEC, R20

    LDS R16, DISPLAY        ; dependiendo de lo que deseamos mostrar, indicamos al display que dígito encender 

    CPI R16,0               ; nuevamente seleccionamos dígitos para mostrar el display 
    BREQ VM_UNI_F
    CPI R16,1
    BREQ VM_DEC_F
    CPI R16,2
    BREQ VD_UNI

    LDS R17, DIA_DEC       ; guardamos por default (ultimo caso posible, ultimo digito de iquiserda a derecha)
    RET

VD_UNI:                    ; cargamos valores en variables en RAM 
    LDS R17, DIA_UNI
    RET
VM_DEC_F:
    LDS R17, MES_DEC
    RET
VM_UNI_F:
    LDS R17, MES_UNI 
    RET


CONFIG_HORA:               ; estado configuración hora 
    
	SBI PORTB, PB5         ; ambas LED encendidas para saber que estamos en modo configuración 
	SBI PORTC, PC0        
    
	LDS R16,DISPLAY        ; llamamos la variable de display para poder encneder el digito correspondiente 

	CPI R16,0              ; encendemos dígito segun lo que deseamos mostrar
	BREQ CFG_MUNI

	CPI R16,1
	BREQ CFG_MDEC

	CPI R16,2
	BREQ CFG_HUNI

	LDS R17,CFG_H_DEC      ; guardamos por default (ultimo caso posible, ultimo digito de iquiserda a derecha)
	RET

CFG_MUNI:                  ; guardamos valores en variable en RAM 
	LDS R17,CFG_M_UNI
	RET

CFG_MDEC:
	LDS R17,CFG_M_DEC
	RET

CFG_HUNI:
	LDS R17,CFG_H_UNI

	RET

CONFIG_FECHA:              ; estado confiiguración fecha 

    SBI PORTC, PC0         ; mismas LEDs encendidad que en cofiguración hora 
    SBI PORTB, PB5

    CLR R17 

    LDS R16, DISPLAY       ; dependiendo del valor a mostrar, encendemos dígito en display 

	CPI R16, 0
	BREQ CFG_M_UNI1

	CPI R16, 1
	BREQ CFG_M_DEC1

	CPI R16, 2
	BREQ CFG_D_UNI

	LDS R17, CFG_DIA_DEC    ; guardamos por default (ultimo caso posible, ultimo digito de iquiserda a derecha)
	RET

CFG_D_UNI:                   ; cargamos valores en variables dentro de la RAM 
    LDS R17, CFG_DIA_UNI
	RET

CFG_M_DEC1: 
    LDS R17, CFG_MES_DEC
    RET

CFG_M_UNI1:
    LDS R17, CFG_MES_UNI
	RET


CONFIG_ALARMA:              ; estado configuracion alarma 
    
	CBI PORTC, PC0          ; apagamos ambos LEDs para identificar que estamos en este estado 
	CBI PORTB, PB5

	LDS R16, DISPLAY        ; leemos el estados de display donde seleccionamos que digito encender 

	CLR R17 

	CPI R16, 0 
	BREQ CFG_AM_UNIDAD

	CPI R16, 1
	BREQ CFG_AM_DECENA

	CPI R16, 2
	BREQ CFG_AH_UNIDAD

	LDS R17, CFG_AH_DEC     ; guardamos por default (ultimo caso posible, ultimo digito de iquiserda a derecha)
	RET

CFG_AM_UNIDAD:              ; guardamos valor en variables dentro de la RAM 
    LDS R17, CFG_AM_UNI 
    RET

CFG_AM_DECENA:
    LDS R17, CFG_AM_DEC
    RET

CFG_AH_UNIDAD:
    LDS R17, CFG_AH_UNI
 
    RET 

/****************/

INCREMENTAR	:                 ; subrutina de incremento // utilizado en boton especíico de PC3
   
	LDS R17, MODO             ; leemos modo, donde deoendiendo de esto definimos que variables estamos incrementando y por ende mostrando en el display 

	CPI R17,2
	BREQ INCREMENTAR_HORA1    ; posible caso en incremento de hora 

	CPI R17,3
	BREQ INCREMENTAR_FECHA    ; posible caso en incremento de fecha 
     
	CPI  R17, 4
	RJMP INCREMENTAR_ALARMA   ; posible cado en incremento de alarma 

	RET

INCREMENTAR_HORA1:            ; sacamos variables de la ram con la vairbale var_sel, lo que nos ayuda a intercambia entre unidades y decenas de los primeros dos y ultimos dos dígitos 
    
	LDS R16, VAR_SEL          ; dependiendo del valor que esta cargadop en la variable, es el modo que vamos a incrementar  

	CPI R16, 0 
	BREQ INC_MINUTOS          ; incremento en minutos 

	CPI R16, 1                ; incremento de horas 
	BREQ INC_HORAS

	RET

INC_MINUTOS:                  ; fucion de incremento en minutos, usamos dos registros para entrar entre minutos o decenas en los dígitos del display 

    LDS R16, CFG_M_UNI
    LDS R17, CFG_M_DEC

    INC R16
    CPI R16,10                ; limitamos el conteo de la varible, en el caso de unidades contamos de 0 a 9 

    BRNE GUARDAR_MIN          ; rutina donde constantemente guardamos el valor en la RAM 
	 
    CLR R16                   ; en caso coincida, limpiamos el registro para generar un reset 
    INC R17
    CPI R17,6                 ; de igual manera con la decenas del minuto, contamos de 0 a 5 
    BRNE GUARDAR_MIN         

    CLR R17                   ; al llegar al máximo, se reinicia la variable  

GUARDAR_MIN:                  ; rutina donde se guardan todas las variables nuevamente en la RAM 
    STS CFG_M_UNI,R16
    STS CFG_M_DEC,R17

    RET
	RET 

INC_HORAS:                   ; incremento de horas en formato 24h (00–23)

    LDS R16,CFG_H_UNI       ; unidades de hora         
    INC R16

    LDS R17,CFG_H_DEC       ; decenas de hora

    CPI R17,2               ; si estamos en 20–23
    BRNE HORA_NORMAL_CFG1

    CPI R16,4               ; límite máximo 23
    BRLO GUARDAR_CFG_HUNI1

    CLR R16                 ; 23 ? 00
    CLR R17
    RJMP GUARDAR_CFG_HORA1

HORA_NORMAL_CFG1:

    CPI R16,10              ; overflow unidades
    BRLO GUARDAR_CFG_HUNI1

    CLR R16
    INC R17                 ; incrementa decenas

GUARDAR_CFG_HORA1:
    STS CFG_H_DEC,R17

GUARDAR_CFG_HUNI1:
    STS CFG_H_UNI,R16

    RET


INCREMENTAR_FECHA: 
    
	LDS R16, VAR_SEL         ; 0 ? día, 1 ? mes
	
	CPI  R16, 0
	BREQ INC_DIA

	CPI  R16, 1
	BREQ INC_MES

	RET


INC_DIA:                    ; incremento de día considerando el mes actual

    LDS R16,CFG_DIA_UNI
    LDS R17,CFG_DIA_DEC

    LDI R18,10
    MUL R17,R18             ; decenas * 10
    ADD R16,R0              ; reconstruye día completo
    CLR R1                  ; limpia registro tras MUL

    INC R16                 ; día++

    LDS R19,CFG_MES_UNI
    LDS R20,CFG_MES_DEC

    LDI R18,10
    MUL R20,R18
    ADD R19,R0              ; reconstruye mes completo
    CLR R1

    DEC R19                 ; índice 0–11 para tabla

    LDI ZH,HIGH(TABLAMES<<1)
    LDI ZL,LOW(TABLAMES<<1)

    ADD ZL,R19
    ADC ZH,R1

    LPM R21,Z               ; obtiene días máximos del mes

    CP R16,R21
    BRLO OK_INC             
    BREQ OK_INC             

    LDI R16,1               ; si se pasa ? reinicia día
    RCALL INC_MES           ; incrementa mes

OK_INC:
    CLR R17                 ; conversión a BCD

DIV_INC:
    CPI R16,10
    BRLO FIN_INC
    SUBI R16,10
    INC R17
    RJMP DIV_INC

FIN_INC:
    STS CFG_DIA_UNI,R16
    STS CFG_DIA_DEC,R17

    RET


INC_MES:                    ; incremento de mes (01–12)

    LDS R16, CFG_MES_UNI
	LDS R17, CFG_MES_DEC

    INC R16
    CPI R16,10
    BRNE GUARDAR_MES_UNI

    CLR R16
    LDS R17,CFG_MES_DEC
    INC R17

GUARDAR_MES_UNI:
    STS CFG_MES_UNI,R16
    STS CFG_MES_DEC,R17

    LDS R16,CFG_MES_DEC
    CPI R16,1
    BRNE FIN_MES

    LDS R17,CFG_MES_UNI
    CPI R17,3
    BRLO FIN_MES

    LDI R16,1               ; 12 ? 01
    CLR R17
    STS CFG_MES_UNI,R16
    STS CFG_MES_DEC,R17

FIN_MES:
    RET


INCREMENTAR_ALARMA:         ; selecciona incremento de alarma
    
	LDS R16, VAR_SEL         ; 0 ? minutos, 1 ? horas

	CPI R16, 0
	BREQ INC_MINUTOS_AM

	CPI R16, 1
	BREQ INC_HORAS_AM
	
	RET
	

INC_MINUTOS_AM:             ; incremento minutos alarma (00–59)

    LDS R16, CFG_AM_UNI
    LDS R17, CFG_AM_DEC

    INC R16
    CPI R16,10
    BRNE GUARDAR_MIN_AM

    CLR R16
    INC R17
    CPI R17,6
    BRNE GUARDAR_MIN_AM

    CLR R17

GUARDAR_MIN_AM:
    STS CFG_AM_UNI,R16
    STS CFG_AM_DEC,R17

    RET 


INC_HORAS_AM:               ; incremento horas alarma (00–23)

    LDS R16,CFG_AH_UNI
    INC R16

    LDS R17,CFG_AH_DEC

    CPI R17,2
    BRNE HORA_NORMAL_CFGAL

    CPI R16,4
    BRLO GUARDAR_CFG_HUNIAM

    CLR R16
    CLR R17
    RJMP GUARDAR_CFG_HORAAM

HORA_NORMAL_CFGAL:

    CPI R16,10
    BRLO GUARDAR_CFG_HUNIAM

    CLR R16
    INC R17

GUARDAR_CFG_HORAAM:
    STS CFG_AH_DEC,R17

GUARDAR_CFG_HUNIAM:
    STS CFG_AH_UNI,R16

    RET


DECREMENTAR: 
	
	LDS R18, MODO            ; leemos el modo actual para decidir qué variable decrementar
	
	CPI R18, 2
	BREQ DECREMENTAR_HORA    ; modo configuración de hora

	CPI R18, 3
	BREQ DECREMENTAR_FECHA   ; modo configuración de fecha

	CPI R18, 4
	RJMP DECREMENTAR_ALARMA  ; modo configuración de alarma

	RET                      ; si no está en modo válido, no hace nada


DECREMENTAR_HORA: 

    LDS  R19, VAR_SEL       ; selecciona qué parte modificar (0=minutos, 1=horas)

	CPI  R19, 0
	BREQ DEC_MINUTOS         ; decremento de minutos

	CPI  R19, 1
	BREQ DEC_HORAS           ; decremento de horas

	RET


DEC_MINUTOS:

    LDS R16,CFG_M_UNI       ; unidades de minutos
    TST R16                 ; verifica si es 0
    BRNE DEC_MUNI_OK        ; si no es 0, solo decrementa

    LDI R16,9               ; si es 0 ? pasa a 9
    LDS R17,CFG_M_DEC       ; decenas
    DEC R17                 ; decrementa decenas

    BRPL GUARDAR_CFG_MDEC   ; si sigue positiva, guardar

    LDI R17,5               ; si pasa de 00 ? 59

GUARDAR_CFG_MDEC:
    STS CFG_M_DEC,R17       ; guarda decenas
    RJMP GUARDAR_CFG_MUNI

DEC_MUNI_OK:
    DEC R16                 ; decremento normal

GUARDAR_CFG_MUNI:
    STS CFG_M_UNI,R16       ; guarda unidades

    RET


DEC_HORAS:

    LDS R16,CFG_H_UNI       ; unidades de hora
    TST R16                 ; verifica si es 0
    BRNE DEC_HUNI_OK

    LDI R16,9               ; si es 0 ? pasa a 9
    LDS R17,CFG_H_DEC
    DEC R17                 ; decrementa decenas

    BRPL GUARDAR_CFG_HDEC

    LDI R17,2               ; si pasa de 00 ? 23
    LDI R16,3

GUARDAR_CFG_HDEC:
    STS CFG_H_DEC,R17
    RJMP GUARDAR_CFG_HUNI

DEC_HUNI_OK:
    DEC R16

GUARDAR_CFG_HUNI:
    STS CFG_H_UNI,R16

    RET


DECREMENTAR_FECHA:

    LDS  R19, VAR_SEL       ; 0 ? día, 1 ? mes
    
	CPI  R19, 0 
	BREQ DEC_DIA

	CPI  R19, 1
	BREQ DEC_MES

	RET


DEC_DIA:

    LDS R16,CFG_DIA_UNI     ; unidades día
    LDS R17,CFG_DIA_DEC     ; decenas día

    LDI R18,10
    MUL R17,R18             ; reconstrucción: dec*10
    ADD R16,R0              ; suma unidades ? día completo
    CLR R1

    DEC R16                 ; día--

    BRNE OK_DEC             ; si no llega a 0, continuar

    RCALL DEC_MES           ; si llega a 0 ? retrocede mes

    LDS R19,CFG_MES_UNI
    LDS R20,CFG_MES_DEC

    LDI R18,10
    MUL R20,R18
    ADD R19,R0              ; reconstruye mes completo
    CLR R1

    DEC R19                 ; índice tabla meses

    LDI ZH,HIGH(TABLAMES<<1)
    LDI ZL,LOW(TABLAMES<<1)

    ADD ZL,R19
    ADC ZH,R1

    LPM R21,Z               ; obtiene días máximos del mes

    MOV R16,R21             ; día = último del mes

OK_DEC:

    CLR R17                 ; conversión a BCD

DIV:
    CPI R16,10
    BRLO FIN
    SUBI R16,10
    INC R17
    RJMP DIV

FIN:
    STS CFG_DIA_UNI,R16
    STS CFG_DIA_DEC,R17

    RET


DEC_MES: 

    LDS R16,CFG_MES_DEC     ; decenas mes
    LDS R17,CFG_MES_UNI     ; unidades mes

    CPI R16,0
    BRNE DEC_MES_NORMAL
    CPI R17,1
    BRNE DEC_MES_NORMAL

    LDI R16,1               ; si es 01 ? pasa a 12
    LDI R17,2
    STS CFG_MES_DEC,R16
    STS CFG_MES_UNI,R17

    RET

DEC_MES_NORMAL:

    DEC R17                 ; decremento unidades
    BRPL GUARDAR_MES1

    LDI R17,9               ; borrow
    DEC R16

GUARDAR_MES1:
    STS CFG_MES_DEC,R16
    STS CFG_MES_UNI,R17

    RET


DECREMENTAR_ALARMA:

    LDS R16, VAR_SEL        ; 0 ? minutos, 1 ? horas

    CPI R16, 0
    BREQ DEC_MINUTOS_AM

    CPI R16, 1
    BREQ DEC_HORAS_AM

    RET


DEC_MINUTOS_AM:

    LDS R16,CFG_AM_UNI
    TST R16
    BRNE DEC_MUNI_AM

    LDI R16,9
    LDS R17,CFG_AM_DEC
    DEC R17
    BRPL GUARDAR_CFG_AMDEC

    LDI R17,5               ; 00 ? 59

GUARDAR_CFG_AMDEC:
    STS CFG_AM_DEC,R17
    RJMP GUARDAR_CFG_AMUNI

DEC_MUNI_AM:
    DEC R16

GUARDAR_CFG_AMUNI:
    STS CFG_AM_UNI,R16
    RET


DEC_HORAS_AM:

    LDS R16,CFG_AH_UNI
    TST R16
    BRNE DEC_HUNI_AM

    LDI R16,9
    LDS R17,CFG_AH_DEC
    DEC R17
    BRPL GUARDAR_CFG_AHDEC

    LDI R17,2               ; 00 ? 23
    LDI R16,3

GUARDAR_CFG_AHDEC:
    STS CFG_AH_DEC,R17
    RJMP GUARDAR_CFG_AHUNI

DEC_HUNI_AM:
    DEC R16

GUARDAR_CFG_AHUNI:
    STS CFG_AH_UNI,R16
    RET

/****************/

SELECTOR:

    LDS R16,VAR_SEL
    LDI R17,1
    EOR R16,R17
    STS VAR_SEL,R16

    RET

CONFIRMAR:


	LDS R16, FLAG_ALM
	CPI R16,1
	BRNE CONTINUAR_CONFIRMAR

	LDS R17,MODO

	CPI R17,0
	BREQ APAGAR_ALARMA_BTN

	CPI R17,1
	BREQ APAGAR_ALARMA_BTN
	
	RJMP CONTINUAR_CONFIRMAR

	APAGAR_ALARMA_BTN:
    CBI PORTB,4        ; apagar buzzer/LED
    RET



CONTINUAR_CONFIRMAR:

    LDS R16,MODO

    CPI R16,2
    BREQ GUARDAR_HORA

    CPI R16,3
    BREQ GUARDAR_FECHA

	CPI R16, 4
	BREQ GUARDAR_ALARMA

    RET

GUARDAR_HORA:
    
	LDS R17, CFG_M_UNI
	STS M_UNI, R17
	
	LDS R18, CFG_M_DEC
	STS M_DEC, R18

	LDS R19, CFG_H_UNI
	STS H_UNI, R19

	LDS R20, CFG_H_DEC
	STS H_DEC, R20

	RET

GUARDAR_FECHA:


	LDS R17,CFG_DIA_UNI
	LDS R18,CFG_DIA_DEC

	LDI R19,10
	MUL R18,R19
	ADD R17,R0
	CLR R1

	STS DIAS,R17

	LDS R17,CFG_MES_UNI
	LDS R18,CFG_MES_DEC

	LDI R19,10
	MUL R18,R19
	ADD R17,R0
	CLR R1

	STS MESES,R17

	RET

GUARDAR_ALARMA:

    LDS R17,CFG_AM_UNI
    STS ALM_M_UNI,R17

    LDS R17,CFG_AM_DEC
    STS ALM_M_DEC,R17

    LDS R17,CFG_AH_UNI
    STS ALM_H_UNI,R17

    LDS R17,CFG_AH_DEC
    STS ALM_H_DEC,R17

    LDI R16,1
    STS ALM_ACTIVA,R16

    CLR R16
    STS FLAG_ALM,R16

    RET

/**************/


; =========================================
; Interrupcion externa (Botones)
; =========================================

EXT_INT:

    PUSH R16                ; guardar registros usados
    PUSH R17
    PUSH R18
    IN   R16,SREG
    PUSH R16                ; guardar estado del CPU (flags)


    IN   R16, PINC          ; leer estado actual de los botones (PORTC)
    
    SBRS R16,1              ; si bit 1 = 1 (no presionado), salta
    RJMP BOTON_SELECTOR     ; si es 0 ? botón presionado

    SBRS R16,2
    RJMP BOTON_CONFIRMAR    ; botón confirmar

    SBRS R16,3
    RJMP BOTON_INC          ; botón incrementar

    SBRS R16,4
    RJMP BOTON_DEC          ; botón decrementar

    SBRS R16,5
    RJMP BOTON_MODO         ; botón cambio de modo

    RJMP SALIR_BOTONES      ; si ningún botón válido, salir


BOTON_SELECTOR:
    RCALL SELECTOR          ; cambia entre variables (ej: min/hora)
    RJMP SALIR_BOTONES

BOTON_CONFIRMAR:
    RCALL CONFIRMAR         ; guarda configuración actual
    RJMP SALIR_BOTONES

BOTON_INC:
    RCALL INCREMENTAR       ; aumenta valor según modo
    RJMP SALIR_BOTONES

BOTON_DEC:
    RCALL DECREMENTAR       ; disminuye valor según modo
    RJMP SALIR_BOTONES

BOTON_MODO:
    RCALL CAMBIAR_MODO      ; cambia entre modos del sistema


SALIR_BOTONES:

    POP  R16
    OUT  SREG,R16           ; restaurar flags del CPU
	POP  R18
	POP  R17
    POP  R16                ; restaurar registros usados
    RETI                    ; retorno de interrupción


CAMBIAR_MODO:
    
    LDS R16,MODO            ; leer modo actual
    INC R16                 ; siguiente modo

    CPI R16,5               ; total de modos = 5 (0–4)
    BRNE GUARDAR_MODO

    CLR R16                 ; si llega a 5 ? vuelve a 0

GUARDAR_MODO:

    STS MODO,R16            ; guardar nuevo modo

	CLR R17
	STS VAR_SEL, R17        ; reinicia selector (evita inconsistencias)
    RET
	  
; =========================================
; Multiplexado (Timer0 ISR)
; =========================================
TIMER0_INT:

    PUSH R16                ; guardar registros usados en ISR
    PUSH R17
	PUSH R18
    PUSH ZH
    PUSH ZL

    IN R16, SREG
    PUSH R16                ; guardar flags del CPU


    CBI PORTB,0             ; apagar display 0
    CBI PORTB,1             ; apagar display 1
    CBI PORTB,2             ; apagar display 2
    CBI PORTB,3             ; apagar display 3
                             ; evita ghosting entre dígitos

    LDI R16,0x00
    OUT PORTD,R16           ; limpiar segmentos antes de cambiar de dígito


    LDS R16, DISPLAY
    INC R16                 ; siguiente display (0–3)
    CPI R16,4
    BRNE MODO_DISPLAY
    CLR R16                 ; si llega a 4 ? reinicia a 0


MODO_DISPLAY:

    STS DISPLAY,R16         ; guarda índice actual de multiplexado

	LDS R18, MODO          ; selecciona qué mostrar según el modo

	CPI R18, 0
	BREQ MOSTRAR_HORA 

	CPI R18, 1
	BREQ MOSTRAR_FECHA 

	CPI R18, 2 
	BREQ MOSTRAR_CONFIG_HORA
	
	CPI R18, 3
	BREQ MOSTRAR_CONFIG_FECHA

	CPI R18, 4
	BREQ MOSTRAR_CONFIG_ALARMA

	RJMP MOSTRAR_HORA       ; por defecto muestra hora


MOSTRAR_HORA: 
    RCALL HORA              ; obtiene dígito en R17
	RJMP  MOSTRAR_DISPLAY_HORA

MOSTRAR_FECHA:
    RCALL FECHA             ; obtiene dígito de fecha
	RJMP  MOSTRAR_DISPLAY_FECHA

MOSTRAR_CONFIG_HORA:

    RCALL CONFIG_HORA       ; muestra valores de configuración
	RJMP MOSTRAR_DISPLAY_HORA

MOSTRAR_CONFIG_FECHA:
    
	RCALL CONFIG_FECHA
	RJMP MOSTRAR_DISPLAY_FECHA

MOSTRAR_CONFIG_ALARMA:
    
	RCALL CONFIG_ALARMA
	RJMP MOSTRAR_DISPLAY_ALARMA


MOSTRAR_DISPLAY_HORA:

    LDI ZH,HIGH(TABLE7SEG<<1)
    LDI ZL,LOW(TABLE7SEG<<1)

    ADD ZL,R17
    ADC ZH,R1               ; direcciona tabla según número

    LPM R17,Z               ; obtiene patrón de segmentos

	LDS R16, DISPLAY
    CPI R16,2               ; punto decimal en posición central
    BRNE NO_DP

    LDS R19, SEGUNDOS
    ANDI R19,1              ; alterna cada segundo
    BREQ NO_DP

    ORI R17,(1<<PD7)        ; activa punto decimal

 NO_DP:
    OUT PORTD,R17           ; envía patrón a segmentos

    OUT PORTD,R17           ; (doble escritura, asegura estabilidad)
   
    LDS R16,DISPLAY

    CPI R16,0
    BREQ ENC_MIN_UNI

    CPI R16,1
    BREQ ENC_MIN_DEC

    CPI R16,2
    BREQ ENC_HR_UNI

    SBI PORTB,3             ; activa display horas decenas
    RJMP FIN_ISR


ENC_MIN_UNI:
    SBI PORTB,0             ; activa minutos unidades
    RJMP FIN_ISR

ENC_MIN_DEC:
    SBI PORTB,1             ; activa minutos decenas
    RJMP FIN_ISR

ENC_HR_UNI:
    SBI PORTB,2             ; activa horas unidades
    RJMP FIN_ISR


/************/

MOSTRAR_DISPLAY_FECHA: 
    
	LDI ZH,HIGH(TABLE7SEG<<1)
    LDI ZL,LOW(TABLE7SEG<<1)

    ADD ZL,R17
    ADC ZH,R1

    LPM R17,Z               ; obtiene patrón del número

	LDS R16, DISPLAY
    CPI R16,2
    BRNE NO_DP1

    LDS R19, SEGUNDOS
    ANDI R19,1
    BREQ NO_DP

    ORI R17,(1<<PD7)        ; punto decimal intermitente

NO_DP1:
    OUT PORTD,R17

    OUT PORTD,R17

	LDS R16, DISPLAY

    CPI R16,0
    BREQ ENC_MES_UNI

    CPI R16,1
    BREQ ENC_MES_DEC

    CPI R16,2
    BREQ ENC_DIA_UNI

    SBI PORTB,3
    RJMP FIN_ISR

ENC_MES_UNI:
    SBI PORTB,0
    RJMP FIN_ISR

ENC_MES_DEC:
    SBI PORTB,1
    RJMP FIN_ISR

ENC_DIA_UNI:
    SBI PORTB,2
    RJMP FIN_ISR


/************/

MOSTRAR_DISPLAY_ALARMA:

	LDI ZH,HIGH(TABLE7SEG<<1)
    LDI ZL,LOW(TABLE7SEG<<1)

    ADD ZL,R17
    ADC ZH,R1

    LPM R17,Z               ; patrón del número

	LDS R16, DISPLAY
    CPI R16,2
    BRNE NO_DP2

    LDS R19, SEGUNDOS
    ANDI R19,1
    BREQ NO_DP

    ORI R17,(1<<PD7)        ; punto intermitente

NO_DP2:
    OUT PORTD,R17

    OUT PORTD,R17

	LDS R16, DISPLAY

    CPI R16,0
    BREQ ENC_AM_UNI

    CPI R16,1
    BREQ ENC_AM_DEC

    CPI R16,2
    BREQ ENC_AH_UNI

    SBI PORTB,3
    RJMP FIN_ISR

ENC_AM_UNI:
    SBI PORTB,0
    RJMP FIN_ISR

ENC_AM_DEC:
    SBI PORTB,1
    RJMP FIN_ISR

ENC_AH_UNI:
    SBI PORTB,2
    RJMP FIN_ISR


FIN_ISR:
    POP R16
    OUT SREG,R16            ; restaura flags

    POP ZL
    POP ZH
	POP R18
    POP R17
    POP R16                ; restaura registros

    RETI                   ; fin de interrupción


; =========================================
; Timer1 ISR: incrementa tiempo cada segundo
; =========================================

TIMER1_INT:

    PUSH R16                ; guardar registros usados
    PUSH R17
    PUSH R18
    PUSH R19
    PUSH R20
    PUSH R21
    PUSH R22

    IN R16,SREG
    PUSH R16                ; guardar flags del CPU


; ----------------------------
; SEGUNDOS
; ----------------------------

	LDS R16,SEGUNDOS       ; cargar segundos actuales
	INC R16                ; segundos++

	CPI R16,60             ; límite 60 segundos
	BRLO SEGUNDOS_OK       ; si < 60, guardar

	CLR R16                
	STS SEGUNDOS,R16
	RJMP INCREMENTAR_MIN   ; overflow / incrementar minutos

SEGUNDOS_OK:
	STS SEGUNDOS,R16       ; guardar valor actualizado
	RCALL VERIFICAR_ALARMA ; verificar si coincide con alarma
	RJMP FIN_TIMER1
		

; ----------------------------
; MINUTOS
; ----------------------------

INCREMENTAR_MIN:

    LDS R16,M_UNI          ; unidades de minutos
	INC R16

	CPI R16,10             ; límite unidades (0–9)
	BREQ MIN_DEC_INC

	STS M_UNI,R16          ; guardar unidades
	RCALL VERIFICAR_ALARMA
	RJMP FIN_TIMER1

MIN_DEC_INC:
	CLR R16
	STS M_UNI,R16          ; reinicia unidades

	LDS R17,M_DEC          ; decenas
	INC R17

	CPI R17,6              ; límite 59
	BREQ HORA_INC

	STS M_DEC,R17          ; guardar decenas
	RCALL VERIFICAR_ALARMA
	RJMP FIN_TIMER1

HORA_INC:
	CLR R17
	STS M_DEC,R17          ; 59 ? 00
	RJMP INCREMENTAR_HORA


; ----------------------------
; HORAS
; ----------------------------

INCREMENTAR_HORA:

    LDS R18,H_UNI          ; unidades de hora
    INC R18

    LDS R19,H_DEC          ; decenas de hora

    CPI R19,2              ; si estamos en rango 20–23
    BRNE HORA_NORMAL

    CPI R18,4              ; límite 23
    BRNE GUARDAR_HUNI

    CLR R18                ; 23 ? 00
    STS H_UNI,R18

    CLR R19
    STS H_DEC,R19

    RJMP INCREMENTAR_DIA   ; cambio de día


HORA_NORMAL:

    CPI R18,10             ; overflow unidades
    BRNE GUARDAR_HUNI

    CLR R18
    STS H_UNI,R18

    INC R19
    STS H_DEC,R19
	RCALL VERIFICAR_ALARMA
    RJMP FIN_TIMER1


; ----------------------------
; CAMBIO DE DIA
; ----------------------------

INCREMENTAR_DIA:

    LDS R20,DIAS           ; día actual
    INC R20                ; día++

    LDS R21,MESES
    DEC R21                ; índice tabla (0–11)

    LDI ZH,HIGH(TABLAMES<<1)
    LDI ZL,LOW(TABLAMES<<1)

    ADD ZL,R21
    ADC ZH,R1

    LPM R22,Z              ; días máximos del mes

    CP R20,R22
    BRLO GUARDAR_DIA
    BREQ GUARDAR_DIA       ; si es válido, guardar


; ----- NUEVO MES -----

    LDI R20,1              ; reinicia día
    STS DIAS,R20
    
    LDS R21,MESES
    INC R21                ; mes++

    CPI R21,13
    BRLO GUARDAR_MES

    LDI R21,1              ; diciembre ? enero


GUARDAR_MES:
    STS MESES,R21
	RCALL VERIFICAR_ALARMA
    RJMP FIN_TIMER1


GUARDAR_DIA:
    STS DIAS,R20
	RCALL VERIFICAR_ALARMA
    RJMP FIN_TIMER1


; ----------------------------
; GUARDAR VARIABLES
; ----------------------------

GUARDAR_HUNI:
    STS H_UNI,R18          ; guardar unidades de hora
    RJMP FIN_TIMER1

GUARDAR_MMIN:
    STS M_DEC,R17          ; guardar decenas minutos
    RJMP FIN_TIMER1

GUARDAR_MSEG:
    STS M_UNI,R16          ; guardar unidades minutos

GUARDAR_SEGUNDO:
    STS SEGUNDOS,R16
    RJMP FIN_TIMER1


RCALL VERIFICAR_ALARMA     ; llamada extra de seguridad


/**************/

VERIFICAR_ALARMA:

    LDS R16, ALM_ACTIVA    ; verifica si la alarma está activa
    CPI R16,1
    BRNE SALIR_ALARMA

    LDS R16, FLAG_ALM      ; evita repetir activación
    CPI R16,1
    BREQ SALIR_ALARMA

    LDS R16, M_UNI
    LDS R17, ALM_M_UNI
    CP R16, R17
    BRNE SALIR_ALARMA

    LDS R16, M_DEC
    LDS R17, ALM_M_DEC
    CP R16, R17
    BRNE SALIR_ALARMA

    LDS R16, H_UNI
    LDS R17, ALM_H_UNI
    CP R16, R17
    BRNE SALIR_ALARMA

    LDS R16, H_DEC
    LDS R17, ALM_H_DEC
    CP R16, R17
    BRNE SALIR_ALARMA

    SBI PORTB,4            ; activa buzzer o LED

    LDI R16,1
    STS FLAG_ALM,R16       ; marca alarma como activada

SALIR_ALARMA:
    RET


FIN_TIMER1:

    POP R16
    OUT SREG,R16           ; restaurar flags

    POP R22
    POP R21
    POP R20
    POP R19
    POP R18
    POP R17
    POP R16

    RETI                   ; fin de interrupción