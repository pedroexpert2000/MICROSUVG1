/*
 * PRE_LAB_2.c
 *
 * Created: 13/04/2026 11:35:00
 * Author : Pedro Porras
 */ 

#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

/****************************************/
// Encabezado (Libraries)

#include "ADC.h"
#include "PWM1.h"
void  setup();

/****************************************/
// Main Function

int main(void)
{
    setup();
    initPWM1(PWM1A_NO_INVERTIDO, 0 , ICR1_A, ICR1_B, PWM_PR_8, 39999);
    initADC(ADC_AVCC, ADCH_ACT, PS_8);
	sei();
    while (1)
   {
	   uint8_t pot1;
	   uint16_t pwm_servo1;

	   readADC(0);        
	   pot1 = readADC(0);  

	   pwm_servo1 =  1500 + (((uint32_t)pot1 * 3735) / 255);
	   setPWM1A(pwm_servo1);
	  
	   _delay_ms(20);
   }
}

/****************************************/
// NON-Interrupt subroutines

void setup(){
	
	DDRC &= ~((1<<DDC0));
   
}
